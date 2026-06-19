# SPESIFIKASI KEBUTUHAN PERANGKAT LUNAK (SRS)
## POLICY CENTREPOINT — Aplikasi Mobile Manajemen UKM

**Nama Proyek:** POLICY – CENTREPOINT  
**Platform:** Flutter (Android & iOS)  
**Versi Dokumen:** 3.0 (Org Structure Update)  
**Tanggal:** 20 Juni 2026  
**Status:** In Development

---

## 1. PENDAHULUAN

### 1.1 Tujuan Dokumen
Dokumen Spesifikasi Kebutuhan Perangkat Lunak (SRS) ini mendefinisikan seluruh kebutuhan fungsional dan non-fungsional dari aplikasi mobile **POLICY CENTREPOINT** versi 3.0. Versi ini memperbarui model pengguna dan kontrol akses sesuai dengan struktur organisasi nyata UKM POLICY yang berbasis **jabatan per periode kepengurusan**.

### 1.2 Lingkup Produk
POLICY CENTREPOINT adalah aplikasi manajemen terpadu UKM POLICY yang mencakup:
- Autentikasi email/kata sandi dan Google Sign-In via Supabase Auth
- **Sistem peran berbasis jabatan & periode** — akses fitur ditentukan jabatan aktif di periode berjalan
- Absensi kegiatan via QR Code (`mobile_scanner`)
- Manajemen keuangan iuran anggota (uang khas) real-time
- Sistem poin keaktifan & level keanggotaan (Bronze → Silver → Gold → Platinum)
- Inbox: notifikasi personal + pengumuman organisasi
- Panel administrasi terbatas per domain jabatan

### 1.3 Definisi & Akronim

| Istilah | Keterangan |
|---------|------------|
| **BPH** | Badan Pengurus Harian: Ketua Umum, Sekretaris Umum, Bendahara Umum |
| **Kabid** | Ketua Bidang — pimpinan salah satu dari 6 bidang |
| **Bidang** | Divisi fungsional: Pemrograman, Jaringan, Multimedia, Humas, Pengembangan, Kaderisasi |
| **Periode** | Masa kepengurusan (±1 tahun akademik), hanya satu yang aktif (`is_aktif`) |
| **Kepengurusan** | Rekaman jabatan seorang user di suatu periode |
| **Anggota Umum** | Anggota aktif yang tidak memegang jabatan di periode berjalan |
| **Level Akses** | Angka 1–5 yang menentukan hak fitur; lihat Role User & Fiturnya.md |
| **RLS** | Row Level Security — kebijakan akses baris pada PostgreSQL Supabase |
| **RPC** | Remote Procedure Call — fungsi database server-side di Supabase |

### 1.4 Referensi
- [PRD.md](PRD.md) — Product Requirements Document v3.0
- [Role User & Fiturnya.md](Role%20User%20%26%20Fiturnya.md) — Matriks akses per jabatan
- [Planning.md](Planning.md) — Rencana implementasi UI

---

## 2. DESKRIPSI UMUM

### 2.1 Perspektif Produk

```
[Aplikasi Flutter]
       │
       ├── Supabase Auth    (Login, sesi, token)
       ├── PostgreSQL DB    (users, kepengurusan, jabatan, periode, absensi, dll.)
       ├── Supabase Storage (avatars, banners, activities, berita, absensi_sekret)
       └── Supabase Realtime (WebSocket: uang_khas, notifications)
```

### 2.2 Fungsi Produk (High-Level)
1. **Autentikasi & Role Detection** — Login + deteksi jabatan aktif di periode berjalan
2. **Absensi Cepat** — Scan QR kegiatan → catat kehadiran → tambah poin otomatis
3. **Uang Khas Real-Time** — Pantau & kelola iuran bulanan anggota
4. **Poin & Level** — Gamifikasi keaktifan anggota per jabatan/kegiatan
5. **Inbox & Pengumuman** — Notifikasi personal + broadcast resmi pengurus
6. **Administrasi Berbasis Jabatan** — Panel kelola terbatas sesuai domain jabatan

### 2.3 Struktur Organisasi & Segmentasi Pengguna

#### Bagan Kepengurusan
```
Ketua Umum
├── Sekretaris Umum
├── Bendahara Umum
└── Bidang-Bidang
    ├── Ketua Bidang Pemrograman  + Anggota Bidang
    ├── Ketua Bidang Jaringan     + Anggota Bidang
    ├── Ketua Bidang Multimedia   + Anggota Bidang
    ├── Ketua Bidang Humas        + Anggota Bidang
    ├── Ketua Bidang Pengembangan + Anggota Bidang
    └── Ketua Bidang Kaderisasi   + Anggota Bidang

Anggota Umum (tidak menjabat di periode berjalan)
```

#### Tabel Level Akses

| Level | Kode Role | Jabatan | Domain Akses |
|-------|-----------|---------|--------------|
| 5 | `ketua_umum` | Ketua Umum | Semua fitur + kelola sistem & periode |
| 4 | `sekretaris_umum` | Sekretaris Umum | Konten, kegiatan, anggota (lintas bidang) |
| 4 | `bendahara_umum` | Bendahara Umum | Uang khas & keuangan semua anggota |
| 3 | `ketua_bidang` | Ketua Bidang | Kelola bidangnya: kegiatan, absensi, poin |
| 2 | `anggota_bidang` | Anggota Bidang | Fitur anggota + info internal bidang |
| 1 | `anggota_umum` | Anggota Umum | Baca, scan, pantau data pribadi |

#### Sistem Periode
- Hanya satu periode yang `is_aktif = true` pada satu waktu
- User tidak terdaftar di `kepengurusan` periode aktif → otomatis `anggota_umum`
- Riwayat jabatan periode lama tetap tersimpan (tidak dihapus)

### 2.4 Batasan Sistem
- OS minimal: Android 5.0 / iOS 12.0
- Koneksi internet wajib untuk fitur utama
- Kamera diperlukan untuk scan QR & foto absensi sekret
- Foto profil maksimal 2 MB

---

## 3. PERSYARATAN ANTARMUKA EKSTERNAL

### 3.1 Antarmuka Pengguna
- **Desain:** Neo-Centric Brutalism — border 2px charcoal, hard shadow `Offset(4,4) blurRadius:0`, BrutalistCard
- **Navigasi:** Floating Bottom Navbar (5 tab) + App Drawer (item kondisional per level akses)
- **AppBar:** Floating, radius 16px, ikon mail (inbox) dengan badge unread, back button pada sub-screen
- **Feedback:** Efek tekan (`Matrix4.translationValues(3,3,0)` + shadow shrink)

### 3.2 Antarmuka Perangkat Keras
- **Kamera:** Resolusi min 720p, auto-fokus (untuk QR & foto sekret)
- **Storage:** Min 50 MB untuk instalasi + cache gambar

### 3.3 Antarmuka Perangkat Lunak
- `supabase_flutter` — DB, Auth, Storage, Realtime
- `google_sign_in` — OAuth Google
- `mobile_scanner` — scan QR absensi
- `qr_flutter` — render QR (sisi admin)
- `cached_network_image` — cache gambar dari Storage

### 3.4 Komunikasi
- **HTTPS (port 443)** — REST API & RPC Supabase
- **WSS (WebSocket Secure)** — Supabase Realtime untuk uang khas & notifikasi

---

## 4. FITUR DAN SPESIFIKASI FUNGSIONAL

### 4.1 Autentikasi & Deteksi Role

#### F-01: Login & Google Sign-In
1. User buka halaman Login
2. Masuk via Email/Password atau Google Sign-In
3. `supabase.auth.signInWithPassword()` / `signInWithOAuth(google)`
4. Query `kepengurusan` JOIN `jabatan` WHERE `user_id = current` AND `periode.is_aktif = true`
5. Jika ada → set `kode_role` + `level_akses` + `bidang_id` dari jabatan
6. Jika kosong → set `kode_role = 'anggota_umum'`, `level_akses = 1`
7. Simpan ke Riverpod `currentUserProvider`

#### F-02: Registrasi
1. Isi form: Nama, Email, NIM, Angkatan, Password
2. `supabase.auth.signUp(email, password)`
3. Verifikasi email via Supabase magic link / OTP
4. Insert profil ke tabel `users` (poin default 0, belum ada kepengurusan)

#### F-03: Manajemen Sesi
- Auto-detect session saat startup via `authStateProvider`
- Auto-refresh token oleh Supabase SDK
- Logout: `supabase.auth.signOut()` → redirect `/login`

---

### 4.2 Beranda

#### F-04: Carousel Banner
- Dari tabel `banners`, gambar di bucket `banners`
- Shimmer loading, auto-play, dot indicator

#### F-05: User Card
- Foto profil, nama, **jabatan & bidang aktif** (dari `kepengurusan` periode aktif), poin, badge level
- Tap → `/poin`

#### F-06: Quick Access Menu
- 6 shortcut: All Members, Kegiatan, Uang Khas, Absensi, Berita, Poin
- Semua role dapat akses; fitur write di dalam screen dikontrol level

---

### 4.3 Absensi

#### F-07: Absen Cepat (via QR)
1. User tekan "ABSEN CEPAT"
2. Kamera aktif via `mobile_scanner`
3. Scan QR → baca UUID dari kode
4. Validasi `attendance_codes`: kode ada + `now() < expires_at`
5. Insert ke `absensi` (`user_id`, `activity_id`, `scanned_at`, `type`)
6. `supabase.rpc('add_points', {user_id, amount})` → tambah poin
7. Toast sukses / error

#### F-08: Absensi Sekret (Foto Bukti)
1. User buka tab Absen Sekret di halaman Absensi
2. Ambil foto via kamera (`image_picker`)
3. Upload foto ke bucket `absensi_sekret`
4. Insert ke `absensi` dengan `type = 'sekret'` + `foto_sekret = url`

#### F-09: Riwayat Absensi
- `supabase.from('absensi').select('*, activities(*)').eq('user_id', userId).order('scanned_at', desc)`
- Tampil tipe, nama kegiatan, tanggal, jam
- **Ketua Bidang:** bisa lihat riwayat anggota bidangnya
- **Sekretaris / Ketua Umum:** bisa lihat semua

---

### 4.4 Berita & Pengumuman

#### F-10: Daftar & Detail Berita
- `supabase.from('berita').select().order('created_at', ascending: false)`
- Semua role: baca
- **Sekretaris Umum & Ketua Umum:** CRUD berita

---

### 4.5 Kegiatan

#### F-11: Tab View Kegiatan
- Tab Berlangsung: `status = 'berlangsung'`
- Tab Selesai: `status = 'selesai'`

#### F-12: Detail Kegiatan
- Banner, judul, tanggal, lokasi, bidang, deskripsi

#### F-13: Kelola Kegiatan
- **Ketua Bidang:** CRUD kegiatan dengan `bidang_id` miliknya
- **Sekretaris Umum & Ketua Umum:** CRUD kegiatan semua bidang
- Insert ke `activities` + upload banner ke bucket `activities`

#### F-14: Generate QR Absensi
- Buat UUID, set `expires_at`, insert ke `attendance_codes`
- Render QR via `qr_flutter`
- **Ketua Bidang:** kegiatan bidangnya
- **Sekretaris & Ketua Umum:** semua kegiatan

---

### 4.6 Uang Khas

#### F-15: Ringkasan & Filter
- Dropdown tahun (2023 – sekarang)
- Total terbayar: count bulan `lunas` × Rp 50.000

#### F-16: Status Per Bulan (Real-Time)
- `supabase.from('uang_khas').stream(primaryKey:['id']).eq('user_id', userId)`
- Badge per bulan: Lunas (hijau) / Belum Bayar (merah)
- **View milik sendiri:** semua role
- **View semua anggota:** Bendahara Umum & Ketua Umum

#### F-17: Verifikasi & Update Status
- **Bendahara Umum & Ketua Umum**
- Update `status` + `tanggal_bayar` + `verified_by`
- `supabase.from('uang_khas').update({...}).eq('id', id)`

---

### 4.7 Profil Anggota

#### F-18: Lihat Profil
- Avatar, nama, NIM, angkatan, jabatan aktif + bidang, level, poin, riwayat kegiatan

#### F-19: Edit Profil & Upload Foto
- Edit nama, bio
- Upload foto ke `avatars/{user_id}/avatar.jpg` (upsert, max 2 MB)
- Update `profile_photo` di tabel `users`

---

### 4.8 Poin Keaktifan & Level

#### F-20: Riwayat Poin
- `supabase.from('point_history').select().eq('user_id', userId).order('created_at', desc)`
- Tampil: alasan, jumlah (+ / −), tanggal

#### F-21: Kelola Poin
- **Ketua Bidang:** tambah/kurang poin anggota bidangnya
- **Sekretaris & Ketua Umum:** semua anggota
- Via RPC: `supabase.rpc('add_points', {user_id, amount, reason})`

#### F-22: Level Keanggotaan
| Level | Min Poin | Max Poin |
|-------|----------|----------|
| Bronze | 0 | 499 |
| Silver | 500 | 1499 |
| Gold | 1500 | 2999 |
| Platinum | 3000 | ∞ |

#### F-23: Leaderboard
- Podium top 3 + daftar penuh, badge "Kamu" di posisi sendiri
- Akses: semua role

---

### 4.9 Inbox & Notifikasi

#### F-24: Tab Notifikasi
- Daftar notifikasi personal dari tabel `notifications`
- Tipe: `poin`, `kegiatan`, `absensi`, `uang_khas`, `sistem`
- Tap → navigate ke halaman relevan (sesuai field `route`)
- Fitur: filter belum dibaca, tandai semua dibaca

#### F-25: Tab Pengumuman
- Daftar dari tabel `pengumuman`, tap → `DetailPengumumanScreen`
- Kategori: PENTING, KEGIATAN, KEUANGAN, REKRUTMEN, PRESTASI
- Action card jika ada `action_route` (misal: Bayar Uang Khas → `/uang-khas`)

#### F-26: Kirim Pengumuman (Admin)
- **Sekretaris Umum & Ketua Umum**
- Insert ke `pengumuman` + broadcast insert ke `notifications` semua user

---

### 4.10 Panel Admin

#### F-27: Manage Kegiatan & QR (sudah dijabarkan di F-13 & F-14)

#### F-28: Manage Anggota
- **Sekretaris & Ketua Umum:** lihat semua anggota, edit data, assign bidang
- Filter: bidang, angkatan, status

#### F-29: Kelola Periode Kepengurusan (Ketua Umum only)
1. Buat periode baru (nama, tahun_mulai, tahun_selesai)
2. Assign jabatan: pilih user → pilih jabatan → simpan ke `kepengurusan`
3. Set periode aktif: `UPDATE periode SET is_aktif = false (semua); SET is_aktif = true (dipilih)`
4. Tutup periode: set `is_aktif = false` (data tetap tersimpan)

---

## 5. ARSITEKTUR & STRUKTUR DATA

### 5.1 Skema Database Lengkap

#### Tabel `bidang`
- `id` (int8, PK)
- `nama_bidang` (varchar) — Pemrograman, Jaringan, Multimedia, Humas, Pengembangan, Kaderisasi
- `deskripsi` (text)
- `icon` (varchar, nullable)

#### Tabel `jabatan`
- `id` (int8, PK)
- `nama_jabatan` (varchar) — Ketua Umum, Sekretaris Umum, dst
- `bidang_id` (int8, nullable, FK → bidang)
- `level_akses` (int2) — 1 s.d. 5
- `kode_role` (varchar) — `ketua_umum`, `sekretaris_umum`, `bendahara_umum`, `ketua_bidang`, `anggota_bidang`, `anggota_umum`

#### Tabel `periode`
- `id` (uuid, PK)
- `nama_periode` (varchar) — contoh: "2025/2026"
- `tahun_mulai` (int2)
- `tahun_selesai` (int2)
- `is_aktif` (bool, default false)
- `created_at` (timestamptz)

#### Tabel `kepengurusan`
- `id` (uuid, PK)
- `user_id` (uuid, FK → users)
- `jabatan_id` (int8, FK → jabatan)
- `periode_id` (uuid, FK → periode)
- `tanggal_mulai` (timestamptz)
- `tanggal_selesai` (timestamptz, nullable)

#### Tabel `users`
- `id` (uuid, PK, FK → auth.users)
- `username` (varchar, unique)
- `fullname` (varchar)
- `email` (varchar, unique)
- `nim` (varchar, nullable)
- `angkatan` (int2, nullable)
- `points` (int4, default 0)
- `profile_photo` (text, nullable)
- `created_at` (timestamptz)

#### Tabel `activities`
- `activity_id` (uuid, PK)
- `name` (varchar)
- `date_start` (timestamptz)
- `date_end` (timestamptz)
- `location` (varchar)
- `type` (varchar)
- `status` (varchar) — berlangsung / selesai
- `image` (text, nullable)
- `bidang_id` (int8, nullable, FK → bidang)
- `created_by` (uuid, FK → users)

#### Tabel `attendance_codes`
- `code_id` (uuid, PK)
- `code` (varchar, unique)
- `activity_id` (uuid, FK → activities)
- `expires_at` (timestamptz)
- `created_at` (timestamptz)

#### Tabel `absensi`
- `id` (uuid, PK)
- `user_id` (uuid, FK → users)
- `activity_id` (uuid, FK → activities)
- `scanned_at` (timestamptz)
- `type` (varchar) — rapat / kegiatan / sekret
- `foto_sekret` (text, nullable) — URL foto dari bucket `absensi_sekret`

#### Tabel `uang_khas`
- `id` (uuid, PK)
- `user_id` (uuid, FK → users)
- `bulan` (int2) — 1 s.d. 12
- `tahun` (int2)
- `status` (varchar) — lunas / belum_bayar
- `tanggal_bayar` (timestamptz, nullable)
- `verified_by` (uuid, nullable, FK → users)

#### Tabel `berita`
- `id` (uuid, PK)
- `title` (varchar)
- `content` (text)
- `thumbnail` (text, nullable)
- `category` (varchar)
- `created_by` (uuid, FK → users)
- `created_at` (timestamptz)

#### Tabel `banners`
- `id` (uuid, PK)
- `image_url` (text)
- `order` (int2)
- `link_route` (text, nullable)
- `created_at` (timestamptz)

#### Tabel `point_history`
- `id` (uuid, PK)
- `user_id` (uuid, FK → users)
- `amount` (int4) — positif / negatif
- `reason` (varchar)
- `activity_id` (uuid, nullable, FK → activities)
- `created_by` (uuid, FK → users)
- `created_at` (timestamptz)

#### Tabel `level_config`
- `id` (int8, PK)
- `level_name` (varchar)
- `min_points` (int4)
- `max_points` (int4)

#### Tabel `notifications`
- `id` (uuid, PK)
- `user_id` (uuid, FK → users)
- `type` (varchar) — poin / kegiatan / absensi / uang_khas / sistem
- `title` (varchar)
- `body` (text)
- `route` (text, nullable) — deep link target
- `is_read` (bool, default false)
- `created_at` (timestamptz)

#### Tabel `pengumuman`
- `id` (uuid, PK)
- `category` (varchar) — PENTING / KEGIATAN / KEUANGAN / REKRUTMEN / PRESTASI
- `title` (varchar)
- `content` (text)
- `action_label` (varchar, nullable)
- `action_route` (text, nullable)
- `created_by` (uuid, FK → users)
- `created_at` (timestamptz)

### 5.2 Riverpod Providers

```dart
authStateProvider         // Stream<AuthState> dari Supabase Auth
currentUserProvider       // AsyncValue<UserModel> — profil + jabatan + level
currentPeriodeProvider    // AsyncValue<Periode> — periode aktif
activitiesProvider        // AsyncValue<List<Activity>> — daftar kegiatan
uangKhasProvider          // Stream uang khas per user (realtime)
inboxProvider             // AsyncValue<InboxData> — notif + pengumuman
leaderboardProvider       // AsyncValue<List<UserScore>>
absensiHistoryProvider    // AsyncValue<List<Absensi>>
```

### 5.3 Row Level Security (RLS) Utama

| Tabel | Policy |
|-------|--------|
| `users` | Baca: authenticated. Update: `auth.uid() = id` atau level ≥ 4 |
| `absensi` | Baca: `user_id = auth.uid()` atau (Kabid AND `bidang_sesuai`) atau level ≥ 4 |
| `uang_khas` | Baca: `user_id = auth.uid()` atau `bendahara_umum` / `ketua_umum` |
| `uang_khas` | Update: `bendahara_umum` / `ketua_umum` |
| `point_history` | Baca: `user_id = auth.uid()` atau level ≥ 3 |
| `activities` | Baca: authenticated. Insert/Update: level ≥ 3 |
| `berita` | Baca: authenticated. Insert/Update: level ≥ 4 (sekretaris domain) |
| `pengumuman` | Baca: authenticated. Insert: level ≥ 4 (sekretaris domain) |
| `kepengurusan` | Baca: authenticated. Insert/Update: `ketua_umum` |
| `periode` | Baca: authenticated. Insert/Update: `ketua_umum` |

### 5.4 Supabase Storage Buckets

| Bucket | Akses Tulis | Akses Baca |
|--------|------------|------------|
| `avatars` | Pemilik akun | Authenticated |
| `banners` | level ≥ 4 | Public |
| `activities` | level ≥ 3 | Public |
| `berita` | level ≥ 4 | Public |
| `absensi_sekret` | Pemilik akun (saat absen) | Pemilik + level ≥ 3 bidang terkait |

---

## 6. DESAIN SISTEM & PANDUAN GAYA

### 6.1 Skema Warna

| Token | Hex | Keterangan |
|-------|-----|-----------|
| `primary` | `#B9172F` | Merah POLICY (dark) |
| `primaryContainer` | `#DC3545` | Merah POLICY (bright) — CTA |
| `secondary` | `#006D41` | Hijau aksen |
| `secondaryContainer` | `#90F4B7` | Hijau muda — badge level |
| `bgGray` | `#EFECEC` | Background halaman |
| `blackCharcoal` | `#222222` | Border, teks heading |
| `success` | `#198754` | Status lunas, hadir |
| `surface` | `#F9F9F9` | Card surface |

### 6.2 Tipografi
**Bricolage Grotesque** (via `google_fonts`) — satu font untuk semua teks.

| Token | Size | Weight |
|-------|------|--------|
| `displayLg` | 32px | 800 |
| `headlineMd` | 24px | 700 |
| `headlineSm` | 20px | 700 |
| `bodyLg` | 16px | 500 |
| `bodyMd` | 14px | 400 |
| `labelBold` | 12px | 700 |

### 6.3 Komponen UI

#### BrutalistCard
- `bg: #FFFFFF`, border `2px #222222`, shadow `Offset(4,4) blurRadius:0`
- Tap: shadow ke `Offset(1,1)` + `Matrix4.translationValues(3,3,0)`

#### FloatingAppBar
- Margin: 16px atas & samping, radius 16px, border 2px, hard shadow
- Kiri: hamburger (halaman utama) / back arrow (sub-screen)
- Kanan: inbox mail icon + badge unread count (merah)

#### FloatingBottomNavBar
- 5 tab: Beranda | Berita | Kegiatan | Menu | Absensi
- Capsule shape, radius 30px, floating dengan sistem inset

#### AppDrawer
- Lebar 300px, border kanan 2.5px + hard shadow kanan
- Item kondisional berdasarkan level akses user
- Seksi: UTAMA / FITUR / LAINNYA / (ADMIN jika level ≥ 3)

---

## 7. PERSYARATAN NON-FUNGSIONAL

### 7.1 Kinerja
- Loading beranda < 3 detik (jaringan 4G/LTE)
- Animasi 60 FPS, transisi 200ms easeInOut

### 7.2 Keamanan
- Token sesi dikelola Supabase SDK, tidak disimpan manual
- RLS aktif semua tabel sensitif
- Batasan akses per jabatan divalidasi di sisi server (RLS + RPC), bukan hanya UI

### 7.3 Real-Time
- Uang khas & notifikasi via Supabase Realtime WebSocket
- Auto-reconnect jika koneksi putus (tiap 5 detik)

### 7.4 Offline
- Cache gambar via `CachedNetworkImage`
- Data kritis (absensi, uang khas) wajib koneksi internet
- Tampilkan banner "Tidak ada koneksi" jika offline

---

## 8. KRITERIA PENERIMAAN

### MVP
- [ ] Login via email & Google, deteksi jabatan aktif periode berjalan
- [ ] User tanpa jabatan aktif → anggota_umum (level 1) otomatis
- [ ] Scan QR → absensi tercatat + poin bertambah via RPC
- [ ] Uang khas per bulan real-time dari Supabase Stream
- [ ] Ketua Bidang: generate QR & kelola kegiatan bidangnya
- [ ] Bendahara: lihat & update uang khas semua anggota
- [ ] Sekretaris: publish berita & kirim pengumuman
- [ ] Ketua Umum: buka/tutup periode, assign jabatan

### Release v1.0
- [ ] Upload foto profil & foto absensi sekret ke Storage
- [ ] Sistem poin & level otomatis via Supabase RPC
- [ ] Leaderboard poin semua anggota
- [ ] Inbox: notif personal + pengumuman broadcast
- [ ] RLS dikonfigurasi & diuji untuk semua tabel sensitif
- [ ] Riwayat kepengurusan tersimpan lintas periode

---

*Dokumen SRS v3.0 — Diperbarui dengan struktur organisasi UKM POLICY (6 bidang, 16 jabatan, sistem periode kepengurusan, 6 level akses berbasis jabatan).*
