# SPESIFIKASI KEBUTUHAN PERANGKAT LUNAK (SRS)
## POLICY CENTREPOINT — Aplikasi Mobile Manajemen UKM

**Nama Proyek:** POLICY – CENTREPOINT  
**Platform:** Flutter (Android & iOS)  
**Versi Dokumen:** 4.0 (Kegiatan & Rapat Update)  
**Tanggal:** 20 Juni 2026  
**Status:** In Development

---

## 1. PENDAHULUAN

### 1.1 Tujuan Dokumen
Dokumen Spesifikasi Kebutuhan Perangkat Lunak (SRS) ini mendefinisikan seluruh kebutuhan fungsional dan non-fungsional dari aplikasi mobile **POLICY CENTREPOINT** versi 4.0. Versi ini memperbarui fitur Kegiatan (struktur kepanitiaan), menambahkan Sistem Rapat berbasis peran, dan merevisi navigasi layar Kegiatan.

### 1.2 Lingkup Produk
POLICY CENTREPOINT adalah aplikasi manajemen terpadu UKM POLICY yang mencakup:
- Autentikasi email/kata sandi dan Google Sign-In via Supabase Auth
- **Sistem peran berbasis jabatan & periode** — akses fitur ditentukan jabatan aktif di periode berjalan
- Absensi kegiatan via QR Code (`mobile_scanner`)
- **Manajemen kegiatan dengan struktur Panitia Inti + Susunan Sie**
- **Sistem rapat organisasi dengan 5 tipe dan visibilitas berbasis peran/posisi**
- Manajemen keuangan iuran anggota (uang khas) real-time
- Sistem poin keaktifan & level keanggotaan (Bronze → Silver → Gold → Platinum)
- Inbox: notifikasi personal + pengumuman organisasi
- Panel administrasi terbatas per domain jabatan

### 1.3 Definisi & Akronim

| Istilah | Keterangan |
|---------|------------|
| **BPH** | Badan Pengurus Harian: Ketua Umum, Sekretaris Umum, Bendahara Umum |
| **Kabid** | Ketua Bidang — pimpinan salah satu dari 6 bidang |
| **Panitia Inti** | Ketua Pelaksana, Sekretaris Pelaksana, Bendahara Pelaksana suatu kegiatan |
| **Sie** | Seksi kepanitiaan kegiatan, terdiri dari Ketua Sie + Anggota Sie |
| **Bidang** | Divisi fungsional: Pemrograman, Jaringan, Multimedia, Humas, Pengembangan, Kaderisasi |
| **Periode** | Masa kepengurusan (±1 tahun akademik), hanya satu yang aktif (`is_aktif`) |
| **Kepengurusan** | Rekaman jabatan seorang user di suatu periode |
| **Anggota Umum** | Anggota aktif yang tidak memegang jabatan di periode berjalan |
| **User Public** | Pengguna yang mendaftar akun namun belum diverifikasi pengurus (`users.status = 'pending'`) |
| **Level Akses** | Angka 0–5 yang menentukan hak fitur; lihat Role User & Fiturnya.md |
| **isAdmin** | Flag boolean terpisah dari level; admin melihat semua data tanpa filter |
| **RLS** | Row Level Security — kebijakan akses baris pada PostgreSQL Supabase |
| **RPC** | Remote Procedure Call — fungsi database server-side di Supabase |

### 1.4 Referensi
- [PRD.md](PRD.md) — Product Requirements Document v4.0
- [Role User & Fiturnya.md](Role%20User%20%26%20Fiturnya.md) — Matriks akses per jabatan
- [Planning.md](Planning.md) — Rencana implementasi UI

---

## 2. DESKRIPSI UMUM

### 2.1 Perspektif Produk

```
[Aplikasi Flutter]
       │
       ├── Supabase Auth    (Login, sesi, token)
       ├── PostgreSQL DB    (users, kepengurusan, jabatan, periode, activities, rapat, dll.)
       ├── Supabase Storage (avatars, banners, activities, berita, absensi_sekret)
       └── Supabase Realtime (WebSocket: uang_khas, notifications)
```

### 2.2 Fungsi Produk (High-Level)
1. **Autentikasi & Role Detection** — Login + deteksi jabatan aktif di periode berjalan
2. **Absensi Cepat** — Scan QR kegiatan → catat kehadiran → tambah poin otomatis
3. **Manajemen Kegiatan** — CRUD kegiatan dengan Panitia Inti + Susunan Sie dinamis
4. **Sistem Rapat** — 5 tipe rapat dengan visibilitas berbasis peran/posisi kepanitiaan
5. **Uang Khas Real-Time** — Pantau & kelola iuran bulanan anggota
6. **Poin & Level** — Gamifikasi keaktifan anggota
7. **Inbox & Pengumuman** — Notifikasi personal + broadcast resmi pengurus
8. **Administrasi Berbasis Jabatan** — Panel kelola terbatas sesuai domain jabatan

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
| 4 | `sekretaris_umum` | Sekretaris Umum | Konten, kegiatan, anggota (lintas bidang), verifikasi user |
| 4 | `bendahara_umum` | Bendahara Umum | Uang khas & keuangan semua anggota |
| 3 | `ketua_bidang` | Ketua Bidang | Kelola bidangnya: kegiatan, absensi, poin |
| 2 | `anggota_bidang` | Anggota Bidang | Fitur anggota + info internal bidang + edit kegiatan |
| 1 | `anggota_umum` | Anggota Umum | Baca, scan, buat kegiatan, pantau data pribadi |
| 1 | `demisioner` | Demisioner | Alumni/mantan pengurus, akses arsip read-only, bebas iuran |
| 0 | `user_public` | — | Profil sendiri saja; menunggu verifikasi |

#### Sistem Periode
- Hanya satu periode yang `is_aktif = true` pada satu waktu
- User `status = 'pending'` → `user_public` (level 0)
- User dengan status `demisioner` → `demisioner` (level 1 dengan penanganan khusus bebas iuran dan arsip)
- User `status = 'active'` tanpa entri `kepengurusan` di periode aktif → `anggota_umum` (level 1) otomatis
- Riwayat jabatan periode lama tetap tersimpan

### 2.4 Batasan Sistem
- OS minimal: Android 5.0 / iOS 12.0
- Koneksi internet wajib untuk fitur utama
- Kamera diperlukan untuk scan QR & foto absensi sekret
- Foto profil maksimal 2 MB

---

## 3. PERSYARATAN ANTARMUKA EKSTERNAL

### 3.1 Antarmuka Pengguna
- **Desain:** Neo-Centric Brutalism — border 2px charcoal, hard shadow `Offset(4,4) blurRadius:0`, BrutalistCard
- **Navigasi:** Floating Bottom Navbar (4 tab + FAB) + App Drawer (item kondisional per level akses)
- **AppBar:** Floating, radius 16px, ikon mail (inbox) dengan badge unread, back button pada sub-screen
- **FAB Kegiatan:** Stack + Positioned di ListKegiatanScreen; label/icon berubah per tab aktif
- **Create Screens:** Judul AppBar di kanan (`Spacer() + Text(...)`), back button di kiri
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
3. Cek `users.status`: `'pending'` → level 0 (pending screen); `'active'` → lanjut
4. Query `kepengurusan` JOIN `jabatan` WHERE `user_id = current` AND `periode.is_aktif = true`
5. Jika ada → set `kode_role` + `level_akses` + `bidang_id`; jika kosong → `anggota_umum` (level 1)
6. Simpan ke Riverpod `currentUserProvider`

#### F-02: Registrasi
1. Isi form: Nama, Email, NIM, Angkatan, Password
2. `supabase.auth.signUp(email, password)` + insert profil ke tabel `users` (`status = 'pending'`)
3. User diarahkan ke `PendingVerificationScreen`

#### F-03: Manajemen Sesi
- Auto-detect session saat startup; auto-refresh token; logout → redirect `/login`

---

### 4.2 Beranda

#### F-04–F-06: Carousel Banner, User Card, Quick Access Menu
- Sesuai PRD v4.0 — tidak ada perubahan signifikan dari v3.0

---

### 4.3 Absensi

#### F-07: Absen Cepat (via QR)
1. Scan QR → validasi `attendance_codes` (kode ada + `now() < expires_at`)
2. Insert ke `absensi` + RPC `add_points`

#### F-08: Absensi Sekret
- Ambil foto via kamera → upload ke `absensi_sekret` → insert `absensi` (type='sekret')

#### F-09: Riwayat Absensi
- Ketua Bidang: bisa lihat riwayat anggota bidangnya
- Sekretaris / Ketua Umum: bisa lihat semua

---

### 4.4 Berita & Pengumuman

#### F-10: Daftar & Detail Berita
- Baca: semua role; CRUD: Sekretaris Umum & Ketua Umum

---

### 4.5 Kegiatan

#### F-11: List Kegiatan — Tab "Acara" + "Rapat"

**Screen:** `ListKegiatanScreen` (`/kegiatan`)

**Tab Acara:**
- Filter chip: Semua / Upcoming / Berlangsung / Selesai
- Kartu kegiatan: judul, tanggal, lokasi, badge status, pesertaTerdaftar/kuota, nama Ketua Pelaksana
- Tap → `/kegiatan/:id`

**Tab Rapat:**
- Filter: Semua / Acara / Kepengurusan
- List rapat difilter via `isRapatVisible()` sebelum ditampilkan
- Kartu rapat: tipe badge (warna berbeda), status badge, judul, waktu, nama acara terkait (jika ada)
- Tap → `/kegiatan/rapat/:id`
- Empty state jika tidak ada rapat yang relevan

**FAB (Stack + Positioned):**
- Tab Acara aktif → label "Buat Acara", icon add → `context.push('/kegiatan/buat')`
- Tab Rapat aktif → label "Buat Rapat", icon meeting → `context.push('/kegiatan/rapat/buat')`
- Padding bottom ListView 80px agar tidak tertutup FAB

**AppBar trailing:** icon Riwayat → `context.push('/kegiatan/riwayat')`

#### F-12: Detail Kegiatan (`/kegiatan/:id`)

**Screen:** `DetailKegiatanScreen`

1. Lookup kegiatan: `kKegiatanList.firstWhere((k) => k.id == id)`
2. SliverAppBar dengan back button + tombol Edit (jika `isAdmin || level >= 2`)
3. Header info: judul, badge status, tanggal, waktu, lokasi, kuota, deskripsi
4. **Seksi Panitia Inti** (`_PanitiaRow`):
   - Ketua Pelaksana (ditampilkan dengan styling `isPrimary`)
   - Sekretaris Pelaksana
   - Bendahara Pelaksana
5. **Seksi Susunan Sie** (`_SieSection`):
   - Per Sie: nama sie, nama ketua (styling `isKetua`), daftar anggota (`_MemberTile`)
6. **Tombol Aksi:** "DAFTAR SEKARANG" (upcoming) / "ABSEN SEKARANG" (berlangsung)

#### F-13: Buat Kegiatan (`/kegiatan/buat`)

**Screen:** `CreateKegiatanScreen`  
**Akses:** `level >= 1` (semua anggota aktif; User Public tidak bisa)

**AppBar:**
- Row: `[BackButton, Spacer(), Text('Buat Kegiatan')]`

**Form Seksi 1 — Info Dasar:**
- Nama kegiatan (text field)
- Tanggal (tap → `showDatePicker`)
- Waktu (text field)
- Lokasi (text field)
- Deskripsi (multiline)
- Kuota (number field)

**Form Seksi 2 — Panitia Inti:**
- Ketua Pelaksana (text field)
- Sekretaris Pelaksana (text field)
- Bendahara Pelaksana (text field)

**Form Seksi 3 — Susunan Sie:**
- Daftar `_SieEntry` (dinamis, dapat ditambah/dihapus)
- Per `_SieEntry`: nama sie, ketua sie, list anggota (tambah/hapus individu)
- `_SieEntry.dispose()` membersihkan semua TextEditingController

**Submit:** SnackBar "Kegiatan berhasil dibuat" + `context.pop()`

#### F-14: Riwayat Kegiatan (`/kegiatan/riwayat`)

**Screen:** `RiwayatKegiatanScreen`
- Timeline kegiatan yang sudah diikuti user
- Badge kehadiran per kegiatan

---

### 4.6 Rapat

#### F-15: Detail Rapat (`/kegiatan/rapat/:id`)

**Screen:** `DetailRapatScreen`  
**Akses edit:** `isAdmin || level >= 3`

1. Lookup rapat: `kRapatList.firstWhere((r) => r.id == id)`
2. SliverAppBar (pinned, tidak expanded): back + Edit button (jika canEdit)
3. **Header:** tipe badge (warna dari `rapat.tipe.badgeColor`) + status badge, judul
4. **Konteks Acara** (jika `rapat.kegiatanId != null`):
   - Card dengan nama kegiatan, optional nama Sie
5. **Konteks Kepengurusan** (jika org rapat):
   - Info bidang atau stakeholder + toggle status "Dengan Ketua Bidang"
6. Tanggal, waktu, lokasi
7. **Agenda** — List bernomor (circle `primaryContainer`), optional keterangan per agenda
8. **Peserta** — ListTile dengan avatar, badge "Anda" jika `p == AppSession.nama`
9. **Notulensi** — Container styled jika `rapat.notulensi != null`
10. **Aksi kontekstual:**
    - `terjadwal` → "KONFIRMASI HADIR"
    - `berlangsung` → "ABSEN SEKARANG"
    - `selesai` + canEdit + `notulensi == null` → "TAMBAH NOTULENSI"

#### F-16: Buat Rapat (`/kegiatan/rapat/buat`)

**Screen:** `CreateRapatScreen`  
**Akses:** `level >= 1` (tipe tersedia disesuaikan level)

**AppBar:**
- Row: `[BackButton, Spacer(), Text('Buat Rapat')]`

**Tipe tersedia per level:**
- `isAdmin` / level ≥ 4 → semua 5 tipe
- level == 3 → 4 tipe (kecuali `rapatStakeholderOrg` tanpa Ketua Bidang)
- level ≥ 1 → 2 tipe (`rapatUmumAcara`, `rapatSie`)

**Form Seksi 1 — Tipe Rapat:**
- Daftar `_TipeOption` cards (icon box + label + deskripsi + check saat dipilih)
- `_availableTipes` dihitung dari `AppSession.level`

**Form Seksi 2 — Konteks** (tampil setelah tipe dipilih, `AnimatedSize`):
- `rapatUmumAcara` / `rapatStakeholderAcara`: `DropdownButtonFormField` pilih kegiatan
- `rapatSie`: dropdown kegiatan + cascade dropdown sie (dari `_sieFromKegiatan`)
  - Reset `_selectedSie = null` saat kegiatan berubah
- `rapatStakeholderOrg`: info peserta default + `AnimatedContainer` toggle "Dengan Ketua Bidang"
- `rapatInternalBidang`: `DropdownButtonFormField` pilih bidang dari `_kBidangList`

**Form Seksi 3 — Info Dasar:**
- Judul rapat (text field)
- Row: Tanggal (date picker icon) + Waktu (text field)
- Lokasi (text field)

**Form Seksi 4 — Agenda:**
- List dinamis bernomor
- Tiap item: number circle + text field judul
- Tombol tambah agenda / hapus agenda terakhir

**Submit:** `BrutalistButton` "BUAT RAPAT" → SnackBar + `context.pop()`

#### F-17: isRapatVisible (Logika Filter)

```dart
bool isRapatVisible(RapatItem rapat) {
  if (AppSession.isAdmin) return true;
  
  switch (rapat.tipe) {
    case rapatUmumAcara:
    case rapatStakeholderAcara:
      // Cek apakah user adalah panitia inti kegiatan terkait
      final kegiatan = kKegiatanList.firstWhereOrNull((k) => k.id == rapat.kegiatanId);
      if (kegiatan == null) return false;
      return kegiatan.ketuaPelaksana?.nama == AppSession.nama ||
             kegiatan.sekretarisPelaksana?.nama == AppSession.nama ||
             kegiatan.bendaharaPelaksana?.nama == AppSession.nama;
    
    case rapatSie:
      // Cek apakah user adalah ketua/anggota sie yang disebutkan
      final kegiatan = kKegiatanList.firstWhereOrNull((k) => k.id == rapat.kegiatanId);
      if (kegiatan == null) return false;
      final sie = kegiatan.sie.firstWhereOrNull((s) => s.namaSie == rapat.namaSie);
      if (sie == null) return false;
      return sie.ketua?.nama == AppSession.nama ||
             sie.anggota.any((a) => a.nama == AppSession.nama);
    
    case rapatStakeholderOrg:
      if (AppSession.level >= 4) return true;
      if (AppSession.level == 3 && rapat.denganKetuaBidang) return true;
      return false;
    
    case rapatInternalBidang:
      return AppSession.bidang == rapat.namaBidang && AppSession.level >= 2;
  }
}
```

---

### 4.7 Uang Khas

#### F-18: Ringkasan & Status Per Bulan (Real-Time)
- View milik sendiri: semua role
- View & update semua anggota: Bendahara Umum & Ketua Umum

---

### 4.8 Profil Anggota

#### F-19: Lihat Profil + Edit Profil & Upload Foto
- Edit nama, bio; upload foto ke `avatars/{user_id}/avatar.jpg` (max 2 MB)

---

### 4.9 Poin Keaktifan & Level

#### F-20–F-22: Riwayat Poin, Kelola Poin, Level, Leaderboard
- Sesuai PRD v4.0

---

### 4.10 Inbox & Notifikasi

#### F-23–F-25: Tab Notifikasi, Tab Pengumuman, Kirim Pengumuman
- Sesuai PRD v4.0

---

### 4.11 Panel Admin

#### F-26: Manage Kegiatan & QR (sudah dijabarkan di F-12 & F-13)

#### F-27: Manage Anggota
- Sekretaris & Ketua Umum: lihat semua anggota, edit data, assign bidang

#### F-28: Kelola Periode Kepengurusan (Ketua Umum only)
1. Buat periode baru
2. Assign jabatan ke user
3. Set periode aktif / tutup periode lama

---

## 5. ARSITEKTUR & STRUKTUR DATA

### 5.1 Skema Database Lengkap

#### Tabel Kepengurusan & Org (tidak berubah dari v3.0)
- `bidang`, `jabatan`, `periode`, `kepengurusan`, `users` — lihat SRS v3.0

#### Tabel `activities` (Kegiatan)
- `activity_id` (uuid, PK)
- `name`, `date_start`, `date_end`, `location`, `type`, `status`, `image`, `bidang_id`, `created_by`

#### Tabel `panitia_kegiatan` (Baru)
- `id` (uuid, PK)
- `activity_id` (uuid, FK → activities)
- `posisi` (varchar) — `ketua_pelaksana` / `sekretaris_pelaksana` / `bendahara_pelaksana`
- `user_id` (uuid, nullable, FK → users)
- `nama` (varchar) — nama panitia (bisa non-member)
- `nim` (varchar, nullable)

#### Tabel `sie_kegiatan` (Baru)
- `id` (uuid, PK)
- `activity_id` (uuid, FK → activities)
- `nama_sie` (varchar)

#### Tabel `sie_anggota` (Baru)
- `id` (uuid, PK)
- `sie_id` (uuid, FK → sie_kegiatan)
- `is_ketua` (bool, default false)
- `user_id` (uuid, nullable, FK → users)
- `nama` (varchar)
- `nim` (varchar, nullable)

#### Tabel `rapat` (Baru)
- `id` (uuid, PK)
- `judul` (varchar)
- `tipe` (varchar) — `rapat_umum_acara` / `rapat_stakeholder_acara` / `rapat_sie` / `rapat_stakeholder_org` / `rapat_internal_bidang`
- `status` (varchar) — `terjadwal` / `berlangsung` / `selesai` / `dibatalkan`
- `tanggal` (date)
- `waktu` (varchar)
- `lokasi` (varchar)
- `activity_id` (uuid, nullable, FK → activities)
- `nama_sie` (varchar, nullable) — untuk rapatSie
- `nama_bidang` (varchar, nullable) — untuk rapatInternalBidang
- `dengan_ketua_bidang` (bool, default false) — untuk rapatStakeholderOrg
- `notulensi` (text, nullable)
- `created_by` (uuid, FK → users)
- `created_at` (timestamptz)

#### Tabel `rapat_agenda` (Baru)
- `id` (uuid, PK)
- `rapat_id` (uuid, FK → rapat)
- `urutan` (int2)
- `judul` (varchar)
- `keterangan` (text, nullable)

#### Tabel `rapat_peserta` (Baru)
- `id` (uuid, PK)
- `rapat_id` (uuid, FK → rapat)
- `user_id` (uuid, nullable, FK → users)
- `nama` (varchar)
- `hadir` (bool, nullable) — null = belum konfirmasi

#### Tabel lain (tidak berubah)
- `attendance_codes`, `absensi`, `uang_khas`, `berita`, `banners`, `point_history`, `level_config`, `notifications`, `pengumuman`

### 5.2 Model Dart (Mock)

#### `kegiatan_models.dart`
```dart
class PanitiaItem { String nama; String nim; }
class SieItem { String namaSie; PanitiaItem? ketua; List<PanitiaItem> anggota; }
class KegiatanItem {
  String id, title, tanggal, waktu, lokasi, status, deskripsi;
  int kuota, pesertaTerdaftar;
  PanitiaItem? ketuaPelaksana, sekretarisPelaksana, bendaharaPelaksana;
  List<SieItem> sie;
}
List<KegiatanItem> kKegiatanList; // 4 mock events
```

#### `rapat_models.dart`
```dart
enum RapatTipe { rapatUmumAcara, rapatStakeholderAcara, rapatSie, rapatStakeholderOrg, rapatInternalBidang }
enum RapatStatus { terjadwal, berlangsung, selesai, dibatalkan }
class AgendaItem { String judul; String? keterangan; }
class RapatItem {
  String id, judul, tanggal, waktu, lokasi;
  RapatTipe tipe; RapatStatus status;
  List<AgendaItem> agenda; List<String> peserta;
  String? notulensi, kegiatanId, namaSie, namaBidang;
  bool denganKetuaBidang;
}
List<RapatItem> kRapatList; // 10 mock meetings
bool isRapatVisible(RapatItem rapat); // filter berbasis AppSession
```

### 5.3 Riverpod Providers

```dart
authStateProvider         // Stream<AuthState> dari Supabase Auth
currentUserProvider       // AsyncValue<UserModel> — profil + jabatan + level
currentPeriodeProvider    // AsyncValue<Periode> — periode aktif
activitiesProvider        // AsyncValue<List<KegiatanItem>>
rapatProvider             // AsyncValue<List<RapatItem>> — sudah difilter isRapatVisible
uangKhasProvider          // Stream uang khas per user (realtime)
inboxProvider             // AsyncValue<InboxData> — notif + pengumuman
leaderboardProvider       // AsyncValue<List<UserScore>>
absensiHistoryProvider    // AsyncValue<List<Absensi>>
```

### 5.4 Row Level Security (RLS) Utama

| Tabel | Policy |
|-------|--------|
| `users` | Baca: level ≥ 1. Update: pemilik atau level ≥ 4. Update status: level ≥ 4 |
| `activities` | Baca: level ≥ 1. Insert: level ≥ 1. Update: level ≥ 2 atau created_by |
| `panitia_kegiatan` | Baca: level ≥ 1. Insert/Update: level ≥ 1 (panitia sendiri) atau level ≥ 3 |
| `sie_kegiatan` / `sie_anggota` | Baca: level ≥ 1. Insert/Update: level ≥ 1 |
| `rapat` | Baca: server-side check isRapatVisible. Insert: level ≥ 1. Update (notulensi): level ≥ 3 |
| `rapat_agenda` | Baca + Insert: level ≥ 1. Update/Delete: created_by atau level ≥ 3 |
| `rapat_peserta` | Baca: terkait rapat. Update hadir: pemilik user_id |
| `absensi` | Baca: level ≥ 1 (user_id sendiri) atau Kabid bidang atau level ≥ 4 |
| `uang_khas` | Baca milik sendiri: level ≥ 1. Baca semua: bendahara/KU. Update: bendahara/KU |
| `point_history` | Baca: level ≥ 1 (sendiri) atau level ≥ 3. Insert: level ≥ 3 |
| `berita` | Baca: level ≥ 1. Insert/Update: level ≥ 4 |
| `pengumuman` | Baca: level ≥ 1. Insert: level ≥ 4 |
| `kepengurusan` / `periode` | Baca: level ≥ 1. Insert/Update: ketua_umum |

### 5.5 Supabase Storage Buckets

| Bucket | Akses Tulis | Akses Baca |
|--------|------------|------------|
| `avatars` | Pemilik akun | Authenticated |
| `banners` | level ≥ 4 | Public |
| `activities` | level ≥ 1 | Public |
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
**Bricolage Grotesque** (via `google_fonts`)

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
- Kiri: hamburger / back arrow; Kanan: inbox mail icon + badge

#### FloatingBottomNavBar
- 4 tab + FAB Absensi: Beranda | Kegiatan | [QR FAB] | Fitur | Menu
- Capsule shape, radius 30px, floating

#### FAB Kontekstual (ListKegiatanScreen)
- Implementasi: `Stack` + `Positioned(bottom: 16, right: marginPage)`
- Label & icon: berganti sesuai tab aktif ("Buat Acara" / "Buat Rapat")
- ListView padding `bottom: 80` agar konten tidak tertutup FAB

#### AppBar Create Screens
- Layout: `Row([BackButton, Spacer(), Text(title)])`
- Berlaku untuk `CreateKegiatanScreen` dan `CreateRapatScreen`

#### AppDrawer
- Lebar 300px, border kanan 2.5px + hard shadow kanan
- Item kondisional berdasarkan level akses user

### 6.4 Badge Tipe Rapat (Warna)

| Tipe | Badge Color | Badge Text Color |
|------|-------------|-----------------|
| `rapatUmumAcara` | `#1565C0` (biru gelap) | putih |
| `rapatStakeholderAcara` | `#6A1B9A` (ungu) | putih |
| `rapatSie` | `#00695C` (teal) | putih |
| `rapatStakeholderOrg` | `#B71C1C` (merah gelap) | putih |
| `rapatInternalBidang` | `#E65100` (oranye) | putih |

---

## 7. PERSYARATAN NON-FUNGSIONAL

### 7.1 Kinerja
- Loading beranda < 3 detik (jaringan 4G/LTE)
- Animasi 60 FPS, transisi 200ms easeInOut
- Filter `isRapatVisible` dijalankan client-side pada mock data; server-side via RLS + query filter

### 7.2 Keamanan
- Token sesi dikelola Supabase SDK, tidak disimpan manual
- RLS aktif semua tabel sensitif
- Visibilitas rapat divalidasi di sisi server (bukan hanya UI)
- `isAdmin` flag hanya ditetapkan server-side

### 7.3 Real-Time
- Uang khas & notifikasi via Supabase Realtime WebSocket
- Auto-reconnect jika koneksi putus (tiap 5 detik)

### 7.4 Offline
- Cache gambar via `CachedNetworkImage`
- Data kritis (absensi, rapat, uang khas) wajib koneksi internet
- Tampilkan banner "Tidak ada koneksi" jika offline

---

## 8. KRITERIA PENERIMAAN

### MVP
- [ ] Login via email & Google, deteksi jabatan aktif periode berjalan
- [ ] Registrasi → `status = 'pending'` → tampil `PendingVerificationScreen`
- [ ] Sekretaris / Ketua Umum dapat verifikasi user → `status = 'active'`
- [ ] GoRouter redirect: `user_public` tidak bisa akses route internal
- [ ] User `status = 'active'` tanpa jabatan aktif → anggota_umum (level 1) otomatis
- [ ] Scan QR → absensi tercatat + poin bertambah via RPC
- [ ] Uang khas per bulan real-time dari Supabase Stream
- [ ] Ketua Bidang: generate QR & kelola kegiatan bidangnya
- [ ] Bendahara: lihat & update uang khas semua anggota
- [ ] Sekretaris: publish berita & kirim pengumuman
- [ ] Ketua Umum: buka/tutup periode, assign jabatan
- [ ] **[Baru]** Kegiatan memiliki Panitia Inti (3 posisi) + Susunan Sie (dinamis)
- [ ] **[Baru]** Semua level ≥ 1 dapat membuat kegiatan
- [ ] **[Baru]** ListKegiatanScreen memiliki Tab Acara + Tab Rapat
- [ ] **[Baru]** FAB label/icon berganti sesuai tab aktif
- [ ] **[Baru]** AppBar trailing icon → RiwayatKegiatanScreen
- [ ] **[Baru]** 5 tipe rapat dengan visibilitas berbasis posisi/peran
- [ ] **[Baru]** `isRapatVisible()` memfilter list rapat sesuai user
- [ ] **[Baru]** Detail Rapat: agenda + peserta + notulensi + aksi kontekstual
- [ ] **[Baru]** Create Rapat: tipe selection + konteks dinamis + agenda dinamis

### Release v1.0
- [ ] Upload foto profil & foto absensi sekret ke Storage
- [ ] Sistem poin & level otomatis via Supabase RPC
- [ ] Leaderboard poin semua anggota
- [ ] Inbox: notif personal + pengumuman broadcast
- [ ] RLS dikonfigurasi & diuji untuk semua tabel sensitif
- [ ] Riwayat kepengurusan tersimpan lintas periode
- [ ] Notulensi rapat tersimpan & dapat diedit oleh yang berwenang (level ≥ 3)

---

*Dokumen SRS v4.0 — Diperbarui dengan spesifikasi Kegiatan (Panitia Inti + Sie), Sistem Rapat (5 tipe, `isRapatVisible`, Detail & Buat Rapat), perubahan navigasi ListKegiatanScreen (Tab Acara/Rapat, FAB kontekstual, AppBar Riwayat), dan konvensi judul create screen di kanan.*
