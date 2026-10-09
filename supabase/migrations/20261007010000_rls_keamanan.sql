-- =============================================================================
-- Keamanan data: Row Level Security untuk semua tabel aplikasi
-- =============================================================================
-- Sebelumnya RLS mati di semua tabel: siapa pun dengan anon key (tertanam di
-- aplikasi) bisa membaca & mengubah seluruh data tanpa login.
--
-- Prinsip:
--   * Tanpa login (anon)         : tidak ada akses.
--   * Akun pending               : hanya profil & jabatan miliknya.
--   * Anggota aktif              : baca data organisasi, ubah data miliknya.
--   * Pengurus (level jabatan)   : sesuai menu Fitur di aplikasi
--       level 2  edit kegiatan
--       level 3  kelola kegiatan/rapat/absensi/poin/QR, kirim notifikasi
--       level 4  kas & verifikasi, berita & pengumuman, pelamar OR
--       level 5  periode, jabatan, OR, akun anggota, audit log
--   * Admin (profiles.is_admin)   : semua.
--
-- Level diambil dari jabatan di periode aktif (tabel kepengurusan), sama
-- seperti yang dibaca aplikasi. SQL Editor / service role tidak terpengaruh.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Fungsi pembantu (SECURITY DEFINER agar tidak terkena RLS & rekursi)
-- -----------------------------------------------------------------------------
create or replace function public.app_is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select is_admin from public.profiles where id = auth.uid()), false);
$$;

create or replace function public.app_is_active() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select status = 'active' from public.profiles where id = auth.uid()), false);
$$;

create or replace function public.app_level() returns integer
language sql stable security definer set search_path = public as $$
  select coalesce(max(j.level_akses), 0)
  from public.kepengurusan k
  join public.jabatan j on j.id = k.jabatan_id
  join public.periode p on p.id = k.periode_id
  where k.user_id = auth.uid()
    and (p.is_aktif or not exists (select 1 from public.periode where is_aktif));
$$;

-- Admin, atau anggota aktif dengan level jabatan >= min_level.
create or replace function public.app_has_level(min_level integer) returns boolean
language sql stable security definer set search_path = public as $$
  select public.app_is_admin() or (public.app_is_active() and public.app_level() >= min_level);
$$;

-- Pembuat profil otomatis harus berjalan sebagai pemilik tabel.
alter function public.handle_new_user() security definer set search_path = public;

-- -----------------------------------------------------------------------------
-- 2. Lindungi kolom is_admin & status dari perubahan oleh pemilik akun
-- -----------------------------------------------------------------------------
create or replace function public.protect_profile_columns() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  -- SQL Editor / service role / trigger signup (tanpa sesi user): bebas.
  if auth.uid() is null or public.app_has_level(5) then
    return new;
  end if;
  if tg_op = 'INSERT' then
    new.is_admin := false;
    new.status := 'pending';
  elsif new.is_admin is distinct from old.is_admin or new.status is distinct from old.status then
    raise exception 'Tidak diizinkan mengubah status atau hak admin akun.'
      using errcode = '42501';
  end if;
  return new;
end $$;

drop trigger if exists protect_profile_columns on public.profiles;
create trigger protect_profile_columns
  before insert or update on public.profiles
  for each row execute function public.protect_profile_columns();

-- -----------------------------------------------------------------------------
-- 3. Fungsi aman untuk aksi anggota yang menyentuh data bersama
-- -----------------------------------------------------------------------------
-- Absen lewat scan QR: validasi sesi di server, lalu catat hadir.
create or replace function public.scan_qr(p_session uuid) returns void
language plpgsql security definer set search_path = public as $$
declare s public.qr_session;
begin
  if auth.uid() is null or not public.app_is_active() then
    raise exception 'Akun belum aktif.' using errcode = '42501';
  end if;
  select * into s from public.qr_session where id = p_session;
  if not found then
    raise exception 'Sesi absensi tidak ditemukan.' using errcode = 'P0002';
  end if;
  if not s.is_active or s.expired_at <= now() then
    raise exception 'QR Code sudah kedaluwarsa atau dinonaktifkan.' using errcode = 'P0001';
  end if;
  insert into public.absensi (member_id, kegiatan_id, tipe_kegiatan, status, waktu_scan)
  values (auth.uid(), s.kegiatan_id, s.tipe_kegiatan, 'hadir', now())
  on conflict (member_id, kegiatan_id, tipe_kegiatan)
  do update set status = 'hadir', waktu_scan = now();
end $$;

-- Daftar kegiatan: cek duplikat & kuota, catat, dan tambah hitungan peserta
-- secara atomik (aman dari dua pendaftar bersamaan).
create or replace function public.daftar_kegiatan(p_kegiatan uuid) returns void
language plpgsql security definer set search_path = public as $$
declare k public.kegiatan;
begin
  if auth.uid() is null or not public.app_is_active() then
    raise exception 'Akun belum aktif.' using errcode = '42501';
  end if;
  select * into k from public.kegiatan where id = p_kegiatan for update;
  if not found then
    raise exception 'Kegiatan tidak ditemukan.' using errcode = 'P0002';
  end if;
  if exists (select 1 from public.absensi
             where member_id = auth.uid() and kegiatan_id = p_kegiatan and tipe_kegiatan = 'kegiatan') then
    raise exception 'Anda sudah terdaftar di kegiatan ini.' using errcode = 'P0001';
  end if;
  if k.kuota > 0 and k.peserta_terdaftar >= k.kuota then
    raise exception 'Kuota kegiatan sudah penuh.' using errcode = 'P0001';
  end if;
  insert into public.absensi (member_id, kegiatan_id, tipe_kegiatan, status)
  values (auth.uid(), p_kegiatan, 'kegiatan', 'belumAbsen');
  update public.kegiatan set peserta_terdaftar = peserta_terdaftar + 1 where id = p_kegiatan;
end $$;

revoke all on function public.scan_qr(uuid), public.daftar_kegiatan(uuid) from public, anon;
grant execute on function public.scan_qr(uuid), public.daftar_kegiatan(uuid) to authenticated;

-- -----------------------------------------------------------------------------
-- 4. Aktifkan RLS & buang policy lama di semua tabel aplikasi
-- -----------------------------------------------------------------------------
do $$
declare t text; p record;
begin
  foreach t in array array[
    'absensi','agenda_rapat','audit_log','berita','bidang','jabatan','kegiatan','kepengurusan',
    'notifikasi','or_pelamar','or_periode','panitia_inti','pengumuman','periode','poin_entry',
    'profiles','qr_session','rapat','rapat_peserta','sie','sie_anggota','transaksi_khas','uang_khas_bulan']
  loop
    execute format('alter table public.%I enable row level security', t);
    for p in select policyname from pg_policies where schemaname = 'public' and tablename = t loop
      execute format('drop policy %I on public.%I', p.policyname, t);
    end loop;
  end loop;
end $$;

-- -----------------------------------------------------------------------------
-- 5. Policy per tabel
-- -----------------------------------------------------------------------------
-- profiles: akun pending tetap bisa membaca profil sendiri
create policy profiles_select on public.profiles for select to authenticated
  using (id = auth.uid() or public.app_is_active());
create policy profiles_insert on public.profiles for insert to authenticated
  with check (id = auth.uid());
create policy profiles_update on public.profiles for update to authenticated
  using (id = auth.uid() or public.app_has_level(5))
  with check (id = auth.uid() or public.app_has_level(5));
create policy profiles_delete on public.profiles for delete to authenticated
  using (public.app_is_admin());

-- Struktur organisasi
create policy bidang_select on public.bidang for select to authenticated using (true);
create policy bidang_write  on public.bidang for all to authenticated
  using (public.app_has_level(5)) with check (public.app_has_level(5));

create policy jabatan_select on public.jabatan for select to authenticated using (true);
create policy jabatan_write  on public.jabatan for all to authenticated
  using (public.app_has_level(5)) with check (public.app_has_level(5));

create policy periode_select on public.periode for select to authenticated using (true);
create policy periode_write  on public.periode for all to authenticated
  using (public.app_has_level(5)) with check (public.app_has_level(5));

create policy kepengurusan_select on public.kepengurusan for select to authenticated
  using (user_id = auth.uid() or public.app_is_active());
create policy kepengurusan_write on public.kepengurusan for all to authenticated
  using (public.app_has_level(5)) with check (public.app_has_level(5));

-- Kegiatan: semua anggota boleh membuat; edit level 2 atau pembuat; hapus level 3
create policy kegiatan_select on public.kegiatan for select to authenticated using (public.app_is_active());
create policy kegiatan_insert on public.kegiatan for insert to authenticated
  with check (public.app_has_level(1));
create policy kegiatan_update on public.kegiatan for update to authenticated
  using (public.app_has_level(2) or (created_by = auth.uid() and public.app_is_active()))
  with check (public.app_has_level(2) or (created_by = auth.uid() and public.app_is_active()));
create policy kegiatan_delete on public.kegiatan for delete to authenticated
  using (public.app_has_level(3));

-- Panitia & sie mengikuti hak edit kegiatannya
create or replace function public.app_can_edit_kegiatan(p_kegiatan uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select public.app_has_level(2)
      or exists (select 1 from public.kegiatan
                 where id = p_kegiatan and created_by = auth.uid() and public.app_is_active());
$$;

create policy panitia_select on public.panitia_inti for select to authenticated using (public.app_is_active());
create policy panitia_write  on public.panitia_inti for all to authenticated
  using (public.app_can_edit_kegiatan(kegiatan_id)) with check (public.app_can_edit_kegiatan(kegiatan_id));

create policy sie_select on public.sie for select to authenticated using (public.app_is_active());
create policy sie_write  on public.sie for all to authenticated
  using (public.app_can_edit_kegiatan(kegiatan_id)) with check (public.app_can_edit_kegiatan(kegiatan_id));

create policy sie_anggota_select on public.sie_anggota for select to authenticated using (public.app_is_active());
create policy sie_anggota_write  on public.sie_anggota for all to authenticated
  using (public.app_can_edit_kegiatan((select kegiatan_id from public.sie where id = sie_id)))
  with check (public.app_can_edit_kegiatan((select kegiatan_id from public.sie where id = sie_id)));

-- Rapat: semua anggota boleh membuat; ubah/hapus level 3 atau pembuat
create or replace function public.app_can_edit_rapat(p_rapat uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select public.app_has_level(3)
      or exists (select 1 from public.rapat
                 where id = p_rapat and created_by = auth.uid() and public.app_is_active());
$$;

create policy rapat_select on public.rapat for select to authenticated using (public.app_is_active());
create policy rapat_insert on public.rapat for insert to authenticated
  with check (public.app_has_level(1));
create policy rapat_update on public.rapat for update to authenticated
  using (public.app_can_edit_rapat(id)) with check (public.app_can_edit_rapat(id));
create policy rapat_delete on public.rapat for delete to authenticated
  using (public.app_can_edit_rapat(id));

create policy agenda_select on public.agenda_rapat for select to authenticated using (public.app_is_active());
create policy agenda_write  on public.agenda_rapat for all to authenticated
  using (public.app_can_edit_rapat(rapat_id)) with check (public.app_can_edit_rapat(rapat_id));

create policy rapat_peserta_select on public.rapat_peserta for select to authenticated using (public.app_is_active());
create policy rapat_peserta_write  on public.rapat_peserta for all to authenticated
  using (public.app_can_edit_rapat(rapat_id)) with check (public.app_can_edit_rapat(rapat_id));

-- Absensi: scan QR & daftar kegiatan lewat fungsi di atas; anggota hanya
-- boleh menulis absen sekret miliknya sendiri.
create policy absensi_select on public.absensi for select to authenticated using (public.app_is_active());
create policy absensi_insert on public.absensi for insert to authenticated
  with check (public.app_has_level(3)
              or (member_id = auth.uid() and tipe_kegiatan = 'sekret' and public.app_is_active()));
create policy absensi_update on public.absensi for update to authenticated
  using (public.app_has_level(3)) with check (public.app_has_level(3));
create policy absensi_delete on public.absensi for delete to authenticated
  using (public.app_has_level(3));

create policy qr_select on public.qr_session for select to authenticated using (public.app_is_active());
create policy qr_write  on public.qr_session for all to authenticated
  using (public.app_has_level(3)) with check (public.app_has_level(3));

create policy poin_select on public.poin_entry for select to authenticated using (public.app_is_active());
create policy poin_write  on public.poin_entry for all to authenticated
  using (public.app_has_level(3)) with check (public.app_has_level(3));

-- Uang kas: anggota melihat & mengajukan pembayaran miliknya; bendahara (level 4) semua
create policy khas_select on public.uang_khas_bulan for select to authenticated
  using (member_id = auth.uid() or public.app_has_level(4));
create policy khas_insert on public.uang_khas_bulan for insert to authenticated
  with check (public.app_has_level(4)
              or (member_id = auth.uid() and public.app_is_active()
                  and status = 'pending' and not is_verified));
create policy khas_update on public.uang_khas_bulan for update to authenticated
  using (public.app_has_level(4) or (member_id = auth.uid() and status <> 'lunas'))
  with check (public.app_has_level(4)
              or (member_id = auth.uid() and status = 'pending' and not is_verified));
create policy khas_delete on public.uang_khas_bulan for delete to authenticated
  using (public.app_has_level(4));

-- Transaksi kas terbuka untuk dibaca anggota (transparansi). Anggota hanya
-- boleh mencatat transaksi pending untuk pembayaran miliknya.
create policy transaksi_select on public.transaksi_khas for select to authenticated using (public.app_is_active());
create policy transaksi_insert on public.transaksi_khas for insert to authenticated
  with check (public.app_has_level(4)
              or (is_pending and is_pemasukan and exists (
                    select 1 from public.uang_khas_bulan u
                    where keterangan = 'Bukti Pembayaran Ref ID: ' || u.id
                      and u.member_id = auth.uid())));
create policy transaksi_update on public.transaksi_khas for update to authenticated
  using (public.app_has_level(4)) with check (public.app_has_level(4));
create policy transaksi_delete on public.transaksi_khas for delete to authenticated
  using (public.app_has_level(4));

-- Berita: draft hanya terlihat oleh pengurus level 4
create policy berita_select on public.berita for select to authenticated
  using ((not is_draft and public.app_is_active()) or public.app_has_level(4));
create policy berita_write on public.berita for all to authenticated
  using (public.app_has_level(4)) with check (public.app_has_level(4));

create policy pengumuman_select on public.pengumuman for select to authenticated using (public.app_is_active());
create policy pengumuman_write  on public.pengumuman for all to authenticated
  using (public.app_has_level(4)) with check (public.app_has_level(4));

-- Notifikasi: hanya milik sendiri; tandai dibaca sendiri
create policy notifikasi_select on public.notifikasi for select to authenticated
  using (user_id = auth.uid());
create policy notifikasi_insert on public.notifikasi for insert to authenticated
  with check (public.app_has_level(3));
create policy notifikasi_update on public.notifikasi for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy notifikasi_delete on public.notifikasi for delete to authenticated
  using (user_id = auth.uid() or public.app_is_admin());

-- Open recruitment
create policy or_periode_select on public.or_periode for select to authenticated using (true);
create policy or_periode_write  on public.or_periode for all to authenticated
  using (public.app_has_level(5)) with check (public.app_has_level(5));

create policy or_pelamar_select on public.or_pelamar for select to authenticated using (true);
create policy or_pelamar_insert on public.or_pelamar for insert to authenticated
  with check (status = 'pending');
create policy or_pelamar_update on public.or_pelamar for update to authenticated
  using (public.app_has_level(4)) with check (public.app_has_level(4));
create policy or_pelamar_delete on public.or_pelamar for delete to authenticated
  using (public.app_has_level(4));

-- Audit log: dicatat oleh pengurus atas namanya sendiri; dibaca level 5
create policy audit_select on public.audit_log for select to authenticated
  using (public.app_has_level(5));
create policy audit_insert on public.audit_log for insert to authenticated
  with check (public.app_has_level(3) and admin_id = auth.uid());

-- -----------------------------------------------------------------------------
-- 6. Storage: bucket yang dipakai aplikasi tetapi belum ada
-- -----------------------------------------------------------------------------
-- Aplikasi memakai URL publik (getPublicUrl) untuk keduanya.
insert into storage.buckets (id, name, public) values
  ('avatars', 'avatars', true),
  ('bukti-bayar', 'bukti-bayar', true)
on conflict (id) do update set public = true;

-- Hanya boleh menulis ke folder <user_id>/ miliknya sendiri.
drop policy if exists "app_upload_own_folder" on storage.objects;
create policy "app_upload_own_folder" on storage.objects for insert to authenticated
  with check (bucket_id in ('avatars', 'bukti-bayar')
              and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "app_update_own_folder" on storage.objects;
create policy "app_update_own_folder" on storage.objects for update to authenticated
  using (bucket_id in ('avatars', 'bukti-bayar')
         and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "app_read_own_folder" on storage.objects;
create policy "app_read_own_folder" on storage.objects for select to authenticated
  using (bucket_id in ('avatars', 'bukti-bayar')
         and ((storage.foldername(name))[1] = auth.uid()::text or public.app_has_level(4)));

drop policy if exists "app_delete_own_folder" on storage.objects;
create policy "app_delete_own_folder" on storage.objects for delete to authenticated
  using (bucket_id in ('avatars', 'bukti-bayar', 'absensi_sekret')
         and (storage.foldername(name))[1] = auth.uid()::text);
