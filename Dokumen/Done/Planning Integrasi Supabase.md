# Planning Integrasi Supabase — Centrepoint

> Tujuan: Mengganti `DummyRepository` dengan `SupabaseRepository` pada setiap domain, menggunakan Supabase sebagai backend tunggal (Auth, Database PostgreSQL, Storage, Realtime). Setup database dilakukan via **Supabase MCP** langsung dari percakapan dengan Claude.

---

## Prasyarat

| Item | Detail |
|------|--------|
| Supabase Project | Buat project baru di supabase.com |
| Supabase MCP | Sudah terhubung di Claude Code (untuk execute DDL & config) |
| Package Flutter | `supabase_flutter`, `flutter_riverpod` (ganti `provider`) |
| State Management | Migrasi dari `Provider` → `Riverpod` (sesuai PRD) |

---

## Arsitektur Integrasi

```
Flutter App
  └── Riverpod Providers
        └── SupabaseRepository (implements existing abstract class)
              └── supabase_flutter SDK
                    ├── supabase.auth          → Login, Session, Token
                    ├── supabase.from(table)   → CRUD semua data
                    ├── supabase.storage       → Avatar, Bukti Bayar, Thumbnail
                    └── supabase.channel()     → Realtime (notif, absensi live)
```

Tidak ada perubahan pada layer screen — hanya swap implementasi repository.

---

## Fase Pengerjaan

- [x] **Fase A** — Setup Project & Schema (via MCP)
- [x] **Fase B** — Auth & Session
- [x] **Fase C** — Repository Swap per Domain
- [x] **Fase D** — Storage & Upload
- [x] **Fase E** — Realtime
- [x] **Fase F** — RLS & Security Hardening

---

## [x] Fase A — Setup Database Schema (via Supabase MCP)

Jalankan DDL berikut via MCP satu per satu, mulai dari tabel master hingga tabel transaksi.

### A.1 Tabel Master

```sql
-- Bidang (6 divisi)
create table bidang (
  id   serial primary key,
  nama text not null unique,
  deskripsi text
);

-- Jabatan (posisi dalam organisasi)
create table jabatan (
  id          serial primary key,
  nama        text not null,
  bidang_id   int references bidang(id),   -- null untuk jabatan inti (KU, SU, BU)
  level_akses int not null default 1,      -- 0-5
  kode_role   text not null unique
);

-- Periode kepengurusan
create table periode (
  id            uuid primary key default gen_random_uuid(),
  nama          text not null,
  tahun_mulai   int  not null,
  tahun_selesai int  not null,
  is_aktif      boolean not null default false,
  created_at    timestamptz default now()
);
```

### A.2 Tabel Users & Kepengurusan

```sql
-- Profil user (extends auth.users — 1:1)
create table profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  nama        text not null,
  nim         text unique,
  no_hp       text,
  prodi       text,
  angkatan    text,
  avatar_url  text,
  status      text not null default 'pending',  -- 'pending' | 'active' | 'suspended'
  created_at  timestamptz default now()
);

-- Kepengurusan: mapping user -> jabatan -> periode
create table kepengurusan (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references profiles(id) on delete cascade,
  jabatan_id      int  not null references jabatan(id),
  periode_id      uuid not null references periode(id),
  tanggal_mulai   date,
  tanggal_selesai date,
  created_at      timestamptz default now(),
  unique(user_id, jabatan_id, periode_id)
);

-- View: role aktif user saat ini
create or replace view current_user_role as
select
  p.id       as user_id,
  p.nama,
  p.status,
  j.kode_role,
  j.level_akses,
  b.nama     as bidang,
  pe.id      as periode_id
from profiles p
left join kepengurusan k on k.user_id = p.id
left join jabatan j      on j.id = k.jabatan_id
left join bidang b       on b.id = j.bidang_id
left join periode pe     on pe.id = k.periode_id and pe.is_aktif = true
where k.periode_id is null or pe.is_aktif = true;
```

### A.3 Tabel Konten

```sql
-- Berita & Pengumuman
create table berita (
  id              uuid primary key default gen_random_uuid(),
  judul           text not null,
  kategori        text not null default 'Berita',  -- 'Berita' | 'Pengumuman'
  konten          text not null,
  thumbnail_url   text,
  penulis_id      uuid references profiles(id),
  penulis_nama    text,
  tanggal_publish timestamptz default now(),
  is_draft        boolean not null default false,
  created_at      timestamptz default now()
);

-- Pengumuman inbox
create table pengumuman (
  id           uuid primary key default gen_random_uuid(),
  kategori     text not null,
  judul        text not null,
  ringkasan    text not null,
  konten       jsonb not null default '[]',
  tanggal      timestamptz default now(),
  is_new       boolean default true,
  action_label text,
  action_route text,
  created_by   uuid references profiles(id)
);

-- Notifikasi per-user
create table notifikasi (
  id       uuid primary key default gen_random_uuid(),
  user_id  uuid not null references profiles(id) on delete cascade,
  tipe     text not null,
  judul    text not null,
  isi      text not null,
  waktu    timestamptz default now(),
  is_read  boolean not null default false,
  route    text
);
```

### A.4 Tabel Kegiatan & Kepanitiaan

```sql
-- Kegiatan / Event
create table kegiatan (
  id                  uuid primary key default gen_random_uuid(),
  judul               text not null,
  deskripsi           text,
  tanggal             date not null,
  waktu               text,
  lokasi              text,
  status              text not null default 'Akan Datang',
  kuota               int  not null default 0,
  peserta_terdaftar   int  not null default 0,
  periode_id          uuid references periode(id),
  created_by          uuid references profiles(id),
  created_at          timestamptz default now()
);

-- Panitia Inti (Ketua / Sekretaris / Bendahara Pelaksana)
create table panitia_inti (
  id          uuid primary key default gen_random_uuid(),
  kegiatan_id uuid not null references kegiatan(id) on delete cascade,
  peran       text not null,   -- 'ketua' | 'sekretaris' | 'bendahara'
  member_id   uuid references profiles(id),
  nama        text not null,
  nim         text not null,
  unique(kegiatan_id, peran)
);

-- Sie (seksi kepanitiaan)
create table sie (
  id          uuid primary key default gen_random_uuid(),
  kegiatan_id uuid not null references kegiatan(id) on delete cascade,
  nama_sie    text not null
);

-- Anggota Sie
create table sie_anggota (
  id        uuid primary key default gen_random_uuid(),
  sie_id    uuid not null references sie(id) on delete cascade,
  member_id uuid references profiles(id),
  nama      text not null,
  nim       text not null,
  is_ketua  boolean not null default false
);
```

### A.5 Tabel Rapat

```sql
-- Rapat
create table rapat (
  id                   uuid primary key default gen_random_uuid(),
  judul                text not null,
  tipe                 text not null,
  status               text not null default 'terjadwal',
  tanggal              date not null,
  waktu                text,
  lokasi               text,
  notulensi            text,
  kegiatan_id          uuid references kegiatan(id),
  nama_sie             text,
  nama_bidang          text,
  dengan_ketua_bidang  boolean not null default false,
  created_by           uuid references profiles(id),
  created_at           timestamptz default now()
);

-- Agenda Rapat
create table agenda_rapat (
  id          uuid primary key default gen_random_uuid(),
  rapat_id    uuid not null references rapat(id) on delete cascade,
  judul       text not null,
  keterangan  text,
  urutan      int  not null default 0
);

-- Peserta Rapat
create table rapat_peserta (
  id        uuid primary key default gen_random_uuid(),
  rapat_id  uuid not null references rapat(id) on delete cascade,
  member_id uuid not null references profiles(id) on delete cascade,
  unique(rapat_id, member_id)
);
```

### A.6 Tabel Absensi

```sql
-- Record absensi per kegiatan/rapat
create table absensi (
  id              uuid primary key default gen_random_uuid(),
  member_id       uuid not null references profiles(id),
  kegiatan_id     uuid not null,
  tipe_kegiatan   text not null,   -- 'kegiatan' | 'rapat'
  status          text not null default 'belumAbsen',
  waktu_scan      timestamptz,
  keterangan      text,
  created_at      timestamptz default now(),
  unique(member_id, kegiatan_id, tipe_kegiatan)
);

-- QR Session
create table qr_session (
  id              uuid primary key default gen_random_uuid(),
  kegiatan_id     uuid not null,
  kegiatan_judul  text not null,
  tipe_kegiatan   text not null default 'kegiatan',
  tanggal         date not null,
  expired_at      timestamptz not null,
  is_active       boolean not null default true,
  created_by      uuid references profiles(id),
  created_at      timestamptz default now()
);
```

### A.7 Tabel Poin & Keuangan

```sql
-- Riwayat Poin
create table poin_entry (
  id          uuid primary key default gen_random_uuid(),
  member_id   uuid not null references profiles(id),
  member_nama text not null,
  label       text not null,
  tipe        text not null,   -- 'hadir' | 'absen' | 'panitia' | 'bonus' | 'penalti'
  poin        int  not null,
  tanggal     date not null,
  kegiatan_id uuid,
  created_by  uuid references profiles(id),
  created_at  timestamptz default now()
);

-- Status Uang Khas per bulan per anggota
create table uang_khas_bulan (
  id            uuid primary key default gen_random_uuid(),
  member_id     uuid not null references profiles(id),
  bulan         text not null,
  tahun         int  not null,
  nominal       int  not null default 0,
  status        text not null default 'belumBayar',
  tanggal_bayar timestamptz,
  bukti_url     text,
  is_verified   boolean not null default false,
  verified_by   uuid references profiles(id),
  unique(member_id, bulan, tahun)
);

-- Transaksi Kas Organisasi
create table transaksi_khas (
  id            uuid primary key default gen_random_uuid(),
  label         text not null,
  tanggal       date not null,
  jumlah        int  not null,
  is_pemasukan  boolean not null,
  is_pending    boolean not null default false,
  keterangan    text,
  created_by    uuid references profiles(id),
  created_at    timestamptz default now()
);
```

### A.8 Tabel Open Recruitment

```sql
-- Periode OR
create table or_periode (
  id                uuid primary key default gen_random_uuid(),
  nama              text not null,
  tanggal_buka      timestamptz not null,
  tanggal_tutup     timestamptz not null,
  kuota             int  not null,
  deskripsi         text,
  bidang_tersedia   jsonb not null default '[]',
  is_manually_open  boolean not null default false,
  created_at        timestamptz default now()
);

-- Pelamar OR
create table or_pelamar (
  id               uuid primary key default gen_random_uuid(),
  periode_id       uuid not null references or_periode(id) on delete cascade,
  nama             text not null,
  nim              text not null,
  prodi            text not null,
  angkatan         text not null,
  no_hp            text not null,
  bidang_minat     text not null,
  motivasi         text not null,
  pengalaman_org   text,
  status           text not null default 'pending',
  tanggal_daftar   timestamptz default now(),
  catatan          text
);
```

### A.9 Seed Data Jabatan & Bidang

```sql
insert into bidang (nama) values
  ('Pemrograman'), ('Jaringan'), ('Multimedia'),
  ('Pengembangan'), ('Kaderisasi'), ('Humas');

insert into jabatan (nama, bidang_id, level_akses, kode_role) values
  ('Ketua Umum',              null, 5, 'ketua_umum'),
  ('Sekretaris Umum',         null, 4, 'sekretaris_umum'),
  ('Bendahara Umum',          null, 4, 'bendahara_umum'),
  ('Ketua Bidang Pemrograman',(select id from bidang where nama='Pemrograman'),3,'ketua_bidang_pemrograman'),
  ('Ketua Bidang Jaringan',   (select id from bidang where nama='Jaringan'),   3,'ketua_bidang_jaringan'),
  ('Ketua Bidang Multimedia', (select id from bidang where nama='Multimedia'), 3,'ketua_bidang_multimedia'),
  ('Ketua Bidang Pengembangan',(select id from bidang where nama='Pengembangan'),3,'ketua_bidang_pengembangan'),
  ('Ketua Bidang Kaderisasi', (select id from bidang where nama='Kaderisasi'), 3,'ketua_bidang_kaderisasi'),
  ('Ketua Bidang Humas',      (select id from bidang where nama='Humas'),      3,'ketua_bidang_humas'),
  ('Anggota Bidang Pemrograman',(select id from bidang where nama='Pemrograman'),2,'anggota_bidang'),
  ('Anggota Bidang Jaringan', (select id from bidang where nama='Jaringan'),   2,'anggota_bidang'),
  ('Anggota Bidang Multimedia',(select id from bidang where nama='Multimedia'),2,'anggota_bidang'),
  ('Anggota Bidang Pengembangan',(select id from bidang where nama='Pengembangan'),2,'anggota_bidang'),
  ('Anggota Bidang Kaderisasi',(select id from bidang where nama='Kaderisasi'),2,'anggota_bidang'),
  ('Anggota Bidang Humas',    (select id from bidang where nama='Humas'),      2,'anggota_bidang'),
  ('Anggota Umum',            null, 1, 'anggota_umum'),
  ('Demisioner',              null, 1, 'demisioner');
```

---

## [x] Fase B — Auth & Session

### B.1 Trigger: Buat profil saat signup

```sql
create or replace function handle_new_user()
returns trigger as $$
begin
  insert into profiles (id, nama, status)
  values (new.id, new.raw_user_meta_data->>'nama', 'pending');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure handle_new_user();
```

### B.2 Custom JWT Claims (Auth Hook)

Menambahkan `level`, `kode_role`, `bidang` ke JWT agar RLS bisa pakai tanpa query tambahan:

```sql
create or replace function custom_access_token_hook(event jsonb)
returns jsonb as $$
declare
  uid  uuid := (event->>'user_id')::uuid;
  rec  record;
begin
  select j.level_akses, j.kode_role, b.nama as bidang, p.status
  into rec
  from profiles p
  left join kepengurusan k on k.user_id = p.id
  left join jabatan j      on j.id = k.jabatan_id
  left join bidang b       on b.id = j.bidang_id
  left join periode pe     on pe.id = k.periode_id and pe.is_aktif = true
  where p.id = uid;

  return jsonb_set(
    event, '{claims}',
    event->'claims' || jsonb_build_object(
      'level',     coalesce(rec.level_akses, 0),
      'kode_role', coalesce(rec.kode_role, 'user_public'),
      'bidang',    coalesce(rec.bidang, ''),
      'status',    coalesce(rec.status, 'pending')
    )
  );
end;
$$ language plpgsql security definer;
```

Daftarkan hook ini di: Supabase Dashboard → Authentication → Hooks → `custom_access_token`.

### B.3 Flutter — AppSession (ganti mock)

```dart
// lib/core/session/app_session.dart
class AppSession {
  static User? get currentUser =>
      Supabase.instance.client.auth.currentUser;

  static Map<String, dynamic> get _claims {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) return {};
    return JwtDecoder.decode(token)['claims'] ?? {};
  }

  static int    get level    => (_claims['level'] as int?) ?? 0;
  static String get kodeRole => (_claims['kode_role'] as String?) ?? 'user_public';
  static String get bidang   => (_claims['bidang'] as String?) ?? '';
  static bool   get isAdmin  => level >= 5;
  static String get nama     => currentUser?.userMetadata?['nama'] ?? '';
}
```

### B.4 GoRouter Auth Guard

```dart
redirect: (context, state) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return '/login';
  if (AppSession.level == 0) return '/pending';
  return null;
},
```

---

## [x] Fase C — Repository Swap per Domain

### Pola Dasar SupabaseRepository

```dart
class SupabaseMemberRepository extends MemberRepository {
  final _db = Supabase.instance.client;

  @override
  List<MemberModel> get members => _members;
  List<MemberModel> _members = [];

  SupabaseMemberRepository() { _load(); }

  Future<void> _load() async {
    final data = await _db
        .from('profiles')
        .select('*, kepengurusan(jabatan(*,bidang(*)),periode(*))')
        .eq('status', 'active');
    _members = data.map(MemberModel.fromSupabase).toList();
    notifyListeners();
  }
  // ... addMember, updateMember, dll
}
```

Setiap model perlu tambah `factory MemberModel.fromSupabase(Map<String,dynamic> json)` untuk mapping snake_case Supabase → camelCase Flutter.

### Inject di main.dart

```dart
// Ganti semua DummyXxxRepository -> SupabaseXxxRepository
MultiProvider(providers: [
  ChangeNotifierProvider<MemberRepository>(
    create: (_) => SupabaseMemberRepository()),
  ChangeNotifierProvider<KegiatanRepository>(
    create: (_) => SupabaseKegiatanRepository()),
  // ... semua 11 domain
])
```

### Peta Tabel per Repository

| Repository | Tabel Utama | Join |
|------------|-------------|------|
| `UserRepository` | `profiles` | `auth.users` |
| `MemberRepository` | `profiles` | `kepengurusan`, `jabatan`, `bidang` |
| `BeritaRepository` | `berita` | — |
| `KegiatanRepository` | `kegiatan` | `panitia_inti`, `sie`, `sie_anggota` |
| `RapatRepository` | `rapat` | `agenda_rapat`, `rapat_peserta` |
| `AbsensiRepository` | `absensi`, `qr_session` | `kegiatan` |
| `PoinRepository` | `poin_entry` | `profiles` |
| `UangKhasRepository` | `uang_khas_bulan`, `transaksi_khas` | `profiles` |
| `InboxRepository` | `notifikasi`, `pengumuman` | — |
| `ORRepository` | `or_periode`, `or_pelamar` | — |
| `PeriodeRepository` | `periode` | `kepengurusan` |

---

## [x] Fase D — Storage

Setup bucket via MCP atau Dashboard:

| Bucket | Isi | Akses |
|--------|-----|-------|
| `avatars` | Foto profil | Public read, auth write (own folder) |
| `bukti-bayar` | Foto bukti transfer uang khas | Auth read (own + level ≥ 4), auth write (own) |
| `thumbnail-berita` | Thumbnail artikel | Public read, auth write (level ≥ 4) |

```sql
-- Contoh policy storage: user hanya upload ke folder ID-nya sendiri
-- Path konvensi: avatars/{user_id}/avatar.jpg
create policy "upload avatar sendiri"
  on storage.objects for insert
  with check (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
```

```dart
// Flutter — Upload & Get URL
final path = 'avatars/${user.id}/avatar.jpg';
await supabase.storage.from('avatars')
    .upload(path, file, fileOptions: const FileOptions(upsert: true));
final url = supabase.storage.from('avatars').getPublicUrl(path);
```

---

## [x] Fase E — Realtime

| Fitur | Channel | Event |
|-------|---------|-------|
| Notifikasi baru masuk | `notifikasi:user_id=eq.{uid}` | INSERT |
| Status absensi live (admin) | `absensi:kegiatan_id=eq.{id}` | INSERT, UPDATE |
| QR aktif/nonaktif | `qr_session:id=eq.{id}` | UPDATE |

```dart
// Contoh subscribe notifikasi
supabase
  .channel('notif-$userId')
  .onPostgresChanges(
    event: PostgresChangeEvent.insert,
    schema: 'public',
    table: 'notifikasi',
    filter: PostgresChangeFilter(
      type: FilterType.eq,
      column: 'user_id',
      value: userId,
    ),
    callback: (payload) => _handleNewNotif(payload.newRecord),
  )
  .subscribe();
```

---

## [x] Fase F — RLS (Row Level Security)

### Helper Functions

```sql
-- Baca level dari JWT claims (tanpa query ke DB)
create or replace function auth_level() returns int as $$
  select coalesce((auth.jwt()->'claims'->>'level')::int, 0);
$$ language sql stable;

create or replace function auth_bidang() returns text as $$
  select coalesce(auth.jwt()->'claims'->>'bidang', '');
$$ language sql stable;
```

### Policy per Tabel (Ringkasan)

```sql
-- PROFILES
alter table profiles enable row level security;
create policy "baca semua anggota aktif"
  on profiles for select using (auth_level() >= 1);
create policy "edit profil sendiri"
  on profiles for update using (auth.uid() = id);

-- BERITA
alter table berita enable row level security;
create policy "baca berita"
  on berita for select
  using (auth_level() >= 1 and (is_draft = false or auth_level() >= 4));
create policy "tulis berita"
  on berita for insert with check (auth_level() >= 4);

-- KEGIATAN
alter table kegiatan enable row level security;
create policy "baca kegiatan"   on kegiatan for select using (auth_level() >= 1);
create policy "buat kegiatan"   on kegiatan for insert with check (auth_level() >= 1);
create policy "edit kegiatan"   on kegiatan for update
  using (auth_level() >= 2 or auth.uid() = created_by);
create policy "hapus kegiatan"  on kegiatan for delete using (auth_level() >= 4);

-- RAPAT (paling kompleks — cek kepanitiaan via join)
alter table rapat enable row level security;
create policy "visibilitas rapat"
  on rapat for select using (
    auth_level() >= 5   -- admin lihat semua
    or (tipe = 'rapatInternalBidang' and nama_bidang = auth_bidang() and auth_level() >= 2)
    or (tipe = 'rapatStakeholderOrg' and (
          auth_level() >= 4
          or (auth_level() = 3 and dengan_ketua_bidang = true)
        ))
    or exists (
        select 1 from panitia_inti
        where kegiatan_id = rapat.kegiatan_id and member_id = auth.uid()
      )
    or exists (
        select 1 from sie_anggota sa
        join sie s on s.id = sa.sie_id
        where s.kegiatan_id = rapat.kegiatan_id
          and sa.member_id = auth.uid()
          and (tipe = 'rapatUmumAcara' or s.nama_sie = rapat.nama_sie)
      )
  );

-- ABSENSI
alter table absensi enable row level security;
create policy "baca absensi"
  on absensi for select
  using (member_id = auth.uid() or auth_level() >= 3);
create policy "scan absensi"
  on absensi for insert
  with check (member_id = auth.uid() and auth_level() >= 1);

-- UANG KHAS
alter table uang_khas_bulan enable row level security;
create policy "baca uang khas"
  on uang_khas_bulan for select
  using (member_id = auth.uid() or auth_level() >= 4);
create policy "upload bukti"
  on uang_khas_bulan for update
  using (member_id = auth.uid());

-- POIN
alter table poin_entry enable row level security;
create policy "baca poin"
  on poin_entry for select
  using (member_id = auth.uid() or auth_level() >= 2);
create policy "tambah poin"
  on poin_entry for insert
  with check (auth_level() >= 3);

-- NOTIFIKASI
alter table notifikasi enable row level security;
create policy "baca notif sendiri"
  on notifikasi for select using (user_id = auth.uid());
create policy "mark read"
  on notifikasi for update using (user_id = auth.uid());
```

---

## Perubahan pubspec.yaml

```yaml
dependencies:
  supabase_flutter: ^2.5.0
  flutter_riverpod: ^2.5.1    # ganti provider
  jwt_decoder: ^2.0.1         # decode JWT claims untuk AppSession
  image_picker: ^1.1.2        # upload avatar & bukti bayar
  mobile_scanner: ^5.2.1      # scan QR absensi (sudah di PRD)
  flutter_dotenv: ^5.1.0      # env variables (SUPABASE_URL, ANON_KEY)
```

---

## Struktur File Baru

```
lib/
├── core/
│   ├── env/
│   │   └── env.dart                    # load .env
│   └── supabase/
│       └── supabase_client.dart        # Supabase.instance.client helper
├── data/
│   ├── models/
│   │   └── (tambah factory fromSupabase ke setiap model)
│   └── repositories/
│       ├── supabase/
│       │   ├── supabase_member_repository.dart
│       │   ├── supabase_berita_repository.dart
│       │   ├── supabase_kegiatan_repository.dart
│       │   ├── supabase_rapat_repository.dart
│       │   ├── supabase_absensi_repository.dart
│       │   ├── supabase_poin_repository.dart
│       │   ├── supabase_uang_khas_repository.dart
│       │   ├── supabase_inbox_repository.dart
│       │   ├── supabase_or_repository.dart
│       │   └── supabase_periode_repository.dart
│       └── dummy/   (tetap ada untuk dev offline)
```

---

## Roadmap Prioritas Domain

| # | Domain | Prioritas | Status | Alasan |
|---|--------|-----------|--------|--------|
| 1 | Auth & Profile | Tinggi | [x] Selesai | Gerbang utama semua fitur |
| 2 | Member | Tinggi | [x] Selesai | Dipakai picker semua form |
| 3 | Kegiatan | Tinggi | [x] Selesai | Fitur utama aplikasi |
| 4 | Absensi | Tinggi | [x] Selesai | Butuh Realtime + QR |
| 5 | Poin | Menengah | [x] Selesai | Tergantung Kegiatan & Absensi |
| 6 | Uang Khas | Menengah | [x] Selesai | Tergantung Storage (bukti) |
| 7 | Berita & Pengumuman | Menengah | [x] Selesai | Tergantung Storage (thumbnail) |
| 8 | Rapat | Menengah | [x] Selesai | RLS paling kompleks |
| 9 | Notifikasi (Inbox) | Rendah | [x] Selesai | Tergantung Realtime |
| 10 | OR (Rekrutmen) | Rendah | [x] Selesai | Fitur terisolasi |
| 11 | Periode | Rendah | [x] Selesai | Admin only |

---

## Catatan Penting

- **Secrets** — Jangan hardcode URL dan ANON_KEY. Gunakan `flutter_dotenv` atau `--dart-define` saat build. Tambahkan `.env` ke `.gitignore`.
- **`fromSupabase` factory** — Tambahkan ke setiap model untuk mapping `snake_case` DB → `camelCase` Dart. Field `fromJson` tetap ada untuk kompatibilitas.
- **Denormalized fields** (`nama`, `nim` di `panitia_inti` dan `sie_anggota`) — Pertahankan untuk performa. Gunakan DB trigger untuk sinkronisasi jika `profiles.nama` berubah.
- **Migrasi Provider → Riverpod** — Lakukan bersamaan dengan swap repository domain pertama (Auth), bukan setelah semua domain selesai.
- **Dummy data sebagai seed** — Data di `lib/data/dummy/` bisa dikonversi ke SQL `INSERT` statements via MCP untuk seed awal database.
- **`profiles.status = 'pending'`** — Semua akun baru selalu pending; GoRouter redirect ke `/pending` sampai admin verifikasi.
