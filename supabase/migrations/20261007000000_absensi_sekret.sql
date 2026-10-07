-- Absensi sekret: kehadiran fisik di sekretariat dengan foto bukti.
-- Dipakai oleh AbsensiScreen (absen) dan RiwayatSekretScreen (riwayat).
-- Jalankan sekali di Supabase (SQL Editor) sebelum memakai fitur ini.

-- 1. Kolom foto & kegiatan opsional untuk baris absensi bertipe 'sekret'.
alter table public.absensi add column if not exists foto_url text;
alter table public.absensi alter column kegiatan_id drop not null;

-- 2. Bucket privat untuk foto (akses lewat signed URL).
insert into storage.buckets (id, name, public)
values ('absensi_sekret', 'absensi_sekret', false)
on conflict (id) do nothing;

-- 3. Policy storage: user hanya boleh mengunggah ke folder miliknya
--    (<user_id>/<file>), semua user login boleh melihat foto.
--    Perketat policy SELECT jika foto hanya boleh dilihat pengurus.
drop policy if exists "absensi_sekret_insert_own" on storage.objects;
create policy "absensi_sekret_insert_own"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'absensi_sekret'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "absensi_sekret_select_authenticated" on storage.objects;
create policy "absensi_sekret_select_authenticated"
  on storage.objects for select to authenticated
  using (bucket_id = 'absensi_sekret');
