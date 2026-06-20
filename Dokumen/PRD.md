# Product Requirements Document (PRD)
## POLICY CENTREPOINT — Aplikasi Mobile Manajemen UKM

---

**Nama Proyek:** POLICY – CENTREPOINT  
**Platform:** Flutter (Android & iOS)  
**Versi Dokumen:** 4.0 (Kegiatan & Rapat Update)  
**Tanggal:** 20 Juni 2026  
**Status:** In Development

---

## 💡 Saran & Pilihan Teknologi Terbaik

| # | Kategori | Teknologi | Alasan |
|---|----------|-----------|--------|
| 1 | **Backend & Database (BaaS)** | `supabase_flutter` | PostgreSQL bawaan, Supabase Auth, Supabase Storage, Realtime Stream |
| 2 | **State Management** | `flutter_riverpod` | Cocok dengan Stream Supabase real-time, skalabel |
| 3 | **Pemindai QR (Absensi)** | `mobile_scanner` | Ringan, cepat, tidak ada konflik build Flutter terbaru |
| 4 | **Autentikasi Ekstra** | `google_sign_in` | Sign in with Google via Supabase Auth |
| 5 | **Keamanan Lokal** | Supabase SDK | Persistensi token session otomatis dan aman |

---

## 1. Gambaran Umum

### 1.1 Deskripsi Produk

POLICY CENTREPOINT adalah aplikasi mobile berbasis Flutter yang dirancang sebagai platform manajemen terpadu untuk **UKM POLICY** — Unit Kegiatan Mahasiswa yang berfokus pada bidang teknologi informasi (pemrograman, jaringan, multimedia, humas, pengembangan, dan kaderisasi).

Aplikasi ini menjadi pusat pengelolaan organisasi yang mencakup manajemen anggota, absensi kegiatan berbasis QR Code, iuran keanggotaan, poin keaktifan, sistem inbox/pengumuman, **manajemen kegiatan dengan struktur kepanitiaan**, **sistem rapat organisasi berbasis peran**, dan panel administrasi berbasis peran (role-based access). Seluruh infrastruktur backend ditenagai oleh **Supabase**.

### 1.2 Latar Belakang

UKM POLICY membutuhkan sistem digital yang dapat:
- Menggantikan proses absensi manual dengan sistem pemindaian QR Code
- Memudahkan anggota memantau status iuran (uang khas) secara real-time
- Memberikan visibilitas kegiatan organisasi kepada semua anggota
- Mengelola struktur kepanitiaan kegiatan (Panitia Inti + Susunan Sie)
- Memfasilitasi koordinasi rapat internal dengan visibilitas berbasis peran/posisi
- Menyediakan panel administrasi berbasis jabatan & periode kepengurusan
- Mengelola poin keaktifan dan level keanggotaan otomatis
- Mendistribusikan pengumuman dan notifikasi ke seluruh anggota

### 1.3 Tujuan Produk

| Tujuan | Deskripsi |
|--------|-----------|
| Efisiensi Absensi | Menggantikan absensi manual dengan pemindaian QR Code |
| Transparansi Keuangan | Anggota memantau status iuran (uang khas) secara mandiri |
| Centralisasi Informasi | Satu platform untuk berita, kegiatan, dan pengumuman |
| Manajemen Kepanitiaan | Struktur panitia kegiatan (Inti + Sie) terkelola terpadu |
| Koordinasi Rapat | Sistem rapat berbasis peran dengan visibilitas yang tepat sasaran |
| Manajemen Anggota | Data, level, poin, dan jabatan anggota terkelola terpadu |
| Kepengurusan Berbasis Periode | Jabatan dan akses berubah tiap pergantian periode kepengurusan |
| Kemudahan Administrasi | Panel admin sesuai domain jabatan masing-masing pengurus |

---

## 2. Struktur Organisasi & Target Pengguna

### 2.1 Struktur Kepengurusan UKM POLICY

Kepengurusan UKM POLICY berjalan per **periode akademik** (±1 tahun). Setiap pergantian periode, pemegang jabatan berganti. Riwayat jabatan tersimpan per periode.

#### Pengurus Inti (Badan Pengurus Harian)
| Jabatan | Singkatan |
|---------|-----------|
| Ketua Umum | KU |
| Sekretaris Umum | SU |
| Bendahara Umum | BU |

#### Pengurus Bidang (per 6 Bidang)
| Bidang | Fokus |
|--------|-------|
| **Pemrograman** | Pengembangan software & aplikasi |
| **Jaringan** | Infrastruktur jaringan & keamanan siber |
| **Multimedia** | Desain grafis, video, konten kreatif |
| **Humas** | Hubungan masyarakat & media sosial |
| **Pengembangan** | Riset, inovasi & pengembangan SDM |
| **Kaderisasi** | Rekrutmen, orientasi & pembinaan anggota baru |

Setiap bidang dipimpin 1 **Ketua Bidang (Kabid)** dan memiliki beberapa **Anggota Bidang**.

#### Non-Pengurus
- **Anggota Umum** — Anggota aktif yang tidak memegang jabatan di periode berjalan
- **User Public** — Pengguna yang mendaftar akun tetapi belum diverifikasi pengurus; akses sangat terbatas

### 2.2 Segmentasi Pengguna & Level Akses

| Level | Kode Role | Jabatan | Hak Akses Utama |
|-------|-----------|---------|-----------------|
| 5 | `ketua_umum` | Ketua Umum | Full access: semua fitur + kelola sistem & periode |
| 4 | `sekretaris_umum` | Sekretaris Umum | Konten, berita, kegiatan semua bidang, kelola anggota, verifikasi user |
| 4 | `bendahara_umum` | Bendahara Umum | Uang khas & keuangan semua anggota |
| 3 | `ketua_bidang` | Ketua Bidang | Kelola kegiatan, absensi, poin bidangnya |
| 2 | `anggota_bidang` | Anggota Bidang | Fitur anggota + info internal bidang |
| 1 | `anggota_umum` | Anggota Umum | Baca, scan absensi, pantau data pribadi |
| 0 | `user_public` | — | Profil pribadi saja; menunggu verifikasi pengurus |

> Selengkapnya lihat **Dokumen/Role User & Fiturnya.md**

### 2.3 Karakteristik Pengguna
- Mahasiswa aktif perguruan tinggi, usia 18–25 tahun
- Familiar dengan smartphone Android/iOS
- Membutuhkan akses cepat ke informasi dan administrasi organisasi

---

## 3. Fitur & Spesifikasi Fungsional

### 3.1 Autentikasi & Manajemen Akun (Supabase Auth)

#### F-01: Login & Google Sign-In
- **Metode:** Email/Password & Google Sign-In via Supabase Auth
- **Package:** `supabase_flutter` + `google_sign_in`
- **Output:** Sesi dikelola otomatis Supabase SDK
- **Role Detection:** Ambil jabatan aktif dari tabel `kepengurusan` berdasarkan `periode.is_aktif`

#### F-02: Registrasi & Verifikasi Email
- Default status baru: `status = 'pending'` → role = `user_public` (level 0)
- Setelah Sekretaris Umum / Ketua Umum memverifikasi → `status = 'active'`

#### F-03: Manajemen Sesi & Logout
- Auto-refresh token oleh Supabase SDK
- Logout: `supabase.auth.signOut()` → redirect ke `LoginPage`

---

### 3.2 Beranda

#### F-04: Carousel Banner
- Data dari tabel `banners`, gambar dari Supabase Storage bucket `banners`

#### F-05: User Card
- Foto profil, nama, jabatan & bidang (dari periode aktif), total poin, badge level

#### F-06: Quick Access Menu
| Menu | Role Min | Navigasi |
|------|----------|----------|
| All Members | 1 | `/anggota` |
| Kegiatan | 1 | `/kegiatan` |
| Uang Khas | 1 | `/uang-khas` |
| Absensi | 1 | `/absensi` |
| Berita | 1 | `/berita` |
| Poin | 1 | `/poin` |

---

### 3.3 Absensi

#### F-07: Absen Cepat (via QR)
- FAB "ABSEN CEPAT" buka kamera via `mobile_scanner`
- Validasi `attendance_codes`, insert ke `absensi`, auto tambah poin via RPC

#### F-08: Jenis Absensi
| Jenis | Keterangan |
|-------|------------|
| Absensi Rapat | Pertemuan rutin / koordinasi |
| Absensi Kegiatan | Event atau kepanitiaan |
| Absensi Sekret | Kehadiran fisik di sekretariat (dengan foto bukti) |

---

### 3.4 Berita & Pengumuman

#### F-10: Daftar Berita
- **Baca:** semua role  
- **Tulis/Edit/Hapus:** Sekretaris Umum & Ketua Umum

---

### 3.5 Kegiatan & Rapat

#### F-11: Tab View Kegiatan — "Acara" + "Rapat"
Layar List Kegiatan (`/kegiatan`) memiliki dua tab utama:

| Tab | Konten |
|-----|--------|
| **Acara** | Daftar kegiatan/event dengan filter chip (Semua / Upcoming / Berlangsung / Selesai) |
| **Rapat** | Daftar rapat yang relevan untuk user, filter (Semua / Acara / Kepengurusan) |

**FAB** di pojok kanan bawah (Stack + Positioned, bukan Scaffold.floatingActionButton):
- Tab Acara aktif → FAB "Buat Acara" → `context.push('/kegiatan/buat')`
- Tab Rapat aktif → FAB "Buat Rapat" → `context.push('/kegiatan/rapat/buat')`

**AppBar trailing:** icon Riwayat → `context.push('/kegiatan/riwayat')`

#### F-12: Struktur Kepanitiaan Kegiatan

**Panitia Inti (per kegiatan):**
| Posisi | Keterangan |
|--------|------------|
| Ketua Pelaksana | Penanggung jawab utama (ditampilkan highlight di detail) |
| Sekretaris Pelaksana | Administrasi & dokumentasi kegiatan |
| Bendahara Pelaksana | Keuangan & anggaran kegiatan |

**Susunan Sie (dinamis):** Satu kegiatan dapat memiliki banyak Sie, masing-masing terdiri dari:
- Nama Sie (mis. Sie Acara, Sie Konsumsi)
- 1 orang **Ketua Sie**
- N orang **Anggota Sie**

#### F-13: Detail Kegiatan
- Header: judul, tanggal, waktu, lokasi, deskripsi, kuota, pesertaTerdaftar, badge status
- Seksi **Panitia Inti**: 3 posisi (Ketua highlight `isPrimary`)
- Seksi **Susunan Sie**: expand tiap sie dengan ketua + anggota
- **Edit** muncul jika `isAdmin || AppSession.level >= 2`
- Aksi: "DAFTAR SEKARANG" (upcoming) / "ABSEN SEKARANG" (berlangsung)

#### F-14: Buat Kegiatan
- **Akses:** level ≥ 1 (semua anggota aktif, bukan User Public)
- AppBar: judul "Buat Kegiatan" di **kanan** (Spacer + Text), back button di kiri
- Form 3 seksi:
  1. **Info Dasar** — nama, tanggal (date picker), waktu, lokasi, deskripsi, kuota
  2. **Panitia Inti** — 3 text field (Ketua, Sekretaris, Bendahara Pelaksana)
  3. **Susunan Sie** — form dinamis `_SieEntry` (nama sie, ketua sie, list anggota sie)

#### F-15: Sistem Rapat — 5 Jenis

| Tipe | Nama Lengkap | Peserta yang Diundang |
|------|-------------|----------------------|
| `rapatUmumAcara` | Rapat Umum Acara | Seluruh panitia kegiatan (Inti + semua Sie) |
| `rapatStakeholderAcara` | Rapat Stakeholder Acara | Ketua, Sekretaris, Bendahara Pelaksana saja |
| `rapatSie` | Rapat Internal Sie | Ketua Sie + Anggota Sie dari satu Sie tertentu |
| `rapatStakeholderOrg` | Rapat Stakeholder Org | KU + SU + BU, opsional dengan seluruh Ketua Bidang |
| `rapatInternalBidang` | Rapat Internal Bidang | Seluruh anggota satu bidang tertentu |

**Visibilitas rapat** (`isRapatVisible`):

| Tipe | Kondisi Tampil |
|------|----------------|
| `rapatUmumAcara` / `rapatStakeholderAcara` | User adalah panitia inti kegiatan terkait |
| `rapatSie` | User adalah ketua/anggota sie yang disebutkan |
| `rapatStakeholderOrg` | level ≥ 4, atau level == 3 jika `denganKetuaBidang = true` |
| `rapatInternalBidang` | `AppSession.bidang == rapat.namaBidang` dan level ≥ 2 |
| Semua | `isAdmin = true` → selalu tampil |

**Akses Buat Rapat per level:**
- `isAdmin` / level ≥ 4 → semua 5 tipe
- level == 3 → 4 tipe (kecuali `rapatStakeholderOrg` full)
- level ≥ 1 → 2 tipe (`rapatUmumAcara` & `rapatSie`)

#### F-16: Detail Rapat
- SliverAppBar: back + edit (jika `isAdmin || level >= 3`)
- Header: tipe badge (warna berbeda tiap tipe) + status badge, judul
- Konteks acara (nama kegiatan + sie) atau konteks kepengurusan (bidang/stakeholder)
- Tanggal, waktu, lokasi
- **Agenda** bernomor (circle `primaryContainer` + optional keterangan)
- **Peserta** dengan avatar, badge "Anda" jika nama match `AppSession.nama`
- **Notulensi** (jika tersedia)
- Aksi kontekstual: KONFIRMASI HADIR / ABSEN SEKARANG / TAMBAH NOTULENSI

#### F-17: Buat Rapat
- **Akses:** level ≥ 1 (tipe yang tersedia disesuaikan level)
- AppBar: judul "Buat Rapat" di **kanan** (Spacer + Text), back button di kiri
- Form 4 seksi:
  1. **Tipe** — pilih dari tipe yang tersedia (card `_TipeOption`: icon + label + deskripsi)
  2. **Konteks** — dinamis berdasarkan tipe terpilih:
     - Acara-based: dropdown kegiatan (+ cascade dropdown sie untuk `rapatSie`)
     - `rapatStakeholderOrg`: info peserta + animated toggle "Dengan Ketua Bidang"
     - `rapatInternalBidang`: dropdown pilih bidang
  3. **Info Dasar** — judul, tanggal + waktu (row), lokasi
  4. **Agenda** — list dinamis bernomor

#### F-18: Riwayat Kegiatan
- Timeline kegiatan yang sudah diikuti user
- Diakses via AppBar trailing icon Riwayat di `ListKegiatanScreen`

---

### 3.6 Uang Khas

#### F-19: Status Per Bulan (Real-Time)
- **View milik sendiri:** semua role; **View & kelola semua anggota:** Bendahara Umum & Ketua Umum

#### F-20: Rekap Keuangan
- **Export laporan:** Bendahara Umum & Ketua Umum

---

### 3.7 Profil & Edit Akun

#### F-21: Header Profil + Edit Profil
- Edit nama, bio, upload foto profil (maks 2 MB)

---

### 3.8 Poin Keaktifan

#### F-22: Sistem Poin & Level
| Level | Min Poin | Max Poin |
|-------|----------|----------|
| Bronze | 0 | 499 |
| Silver | 500 | 1499 |
| Gold | 1500 | 2999 |
| Platinum | 3000 | ∞ |

#### F-23: Leaderboard
- Podium top 3 + daftar penuh. Akses: semua role.

---

### 3.9 Inbox & Notifikasi

#### F-24: Inbox
- Tab Notifikasi (personal) + Tab Pengumuman (broadcast)
- **Kirim pengumuman:** Sekretaris Umum & Ketua Umum

---

### 3.10 Panel Admin

#### F-25: Generate QR Absensi
- Ketua Bidang (bidangnya) / Sekretaris & Ketua Umum (semua)

#### F-26: Kelola Periode Kepengurusan (Ketua Umum only)
- Buka periode baru, assign jabatan, tutup periode lama

---

## 4. Arsitektur Aplikasi

### 4.1 Backend: Supabase

| Layanan | Penggunaan |
|---------|------------|
| **PostgreSQL** | Database utama |
| **Supabase Auth** | Login Email/Password & Google Sign-In |
| **Supabase Storage** | Gambar profil, banner, kegiatan, berita |
| **Supabase Realtime** | Stream real-time uang khas & absensi |
| **Supabase RPC** | Fungsi poin & kalkulasi level |

### 4.2 Skema Database (Supabase PostgreSQL)

```
users            → id, username, fullname, email, nim, angkatan, points, profile_photo, status, created_at
bidang           → id, nama_bidang, deskripsi, icon
jabatan          → id, nama_jabatan, bidang_id (nullable), level_akses, kode_role
periode          → id, nama_periode, tahun_mulai, tahun_selesai, is_aktif, created_at
kepengurusan     → id, user_id, jabatan_id, periode_id, tanggal_mulai, tanggal_selesai
activities       → activity_id, name, date_start, date_end, location, type, status, image, bidang_id, created_by
panitia_kegiatan → id, activity_id, posisi (ketua_pelaksana/sekretaris/bendahara), nama, nim
sie_kegiatan     → id, activity_id, nama_sie
sie_anggota      → id, sie_id, is_ketua, nama, nim
attendance_codes → code_id, code, activity_id, expires_at, created_at
absensi          → id, user_id, activity_id, scanned_at, type, foto_sekret (nullable)
rapat            → id, judul, tipe, status, tanggal, waktu, lokasi, activity_id (nullable), sie_id (nullable), bidang_id (nullable), dengan_ketua_bidang, notulensi (nullable), created_by, created_at
rapat_agenda     → id, rapat_id, urutan, judul, keterangan (nullable)
rapat_peserta    → id, rapat_id, user_id, nama, hadir (nullable)
uang_khas        → id, user_id, bulan, tahun, status, tanggal_bayar, verified_by
berita           → id, title, content, thumbnail, category, created_by, created_at
banners          → id, image_url, order, link_route (nullable), created_at
point_history    → id, user_id, amount, reason, activity_id (nullable), created_by, created_at
level_config     → id, level_name, min_points, max_points
notifications    → id, user_id, type, title, body, route (nullable), is_read, created_at
pengumuman       → id, category, title, content, created_by, created_at
```

### 4.3 State Management: Riverpod

```
authStateProvider        → Status sesi Supabase Auth
currentUserProvider      → Profil + jabatan + level akses user aktif
currentPeriodeProvider   → Periode aktif saat ini
activitiesProvider       → Daftar kegiatan
rapatProvider            → Daftar rapat yang visible untuk user aktif
uangKhasProvider         → Stream status iuran per user
absensiHistoryProvider   → Riwayat absensi
leaderboardProvider      → Data poin semua anggota
inboxProvider            → Stream notifikasi & pengumuman
```

### 4.4 Struktur Direktori (Feature-First)

```
lib/
├── main.dart
├── app.dart
├── core/theme/ + constants/
├── shared/widgets/
└── features/
    ├── auth/screens/
    ├── beranda/screens/
    ├── berita/screens/
    ├── kegiatan/
    │   ├── kegiatan_models.dart    # PanitiaItem, SieItem, KegiatanItem, kKegiatanList
    │   ├── rapat_models.dart       # RapatTipe, RapatStatus, AgendaItem, RapatItem, kRapatList
    │   └── screens/
    │       ├── list_kegiatan_screen.dart
    │       ├── detail_kegiatan_screen.dart
    │       ├── create_kegiatan_screen.dart
    │       ├── riwayat_kegiatan_screen.dart
    │       ├── detail_rapat_screen.dart
    │       └── create_rapat_screen.dart
    ├── anggota/screens/
    ├── absensi/screens/
    ├── uang_khas/screens/
    ├── poin/screens/
    ├── inbox/ + screens/
    └── menu/screens/
```

### 4.5 Routing Kegiatan

| Route | Screen |
|-------|--------|
| `/kegiatan` | ListKegiatanScreen (Tab Acara + Rapat) |
| `/kegiatan/buat` | CreateKegiatanScreen |
| `/kegiatan/riwayat` | RiwayatKegiatanScreen |
| `/kegiatan/rapat/buat` | CreateRapatScreen |
| `/kegiatan/rapat/:id` | DetailRapatScreen |
| `/kegiatan/:id` | DetailKegiatanScreen |

---

## 5. Desain Sistem & UI

### 5.1 Design Tokens

| Token | Nilai | Keterangan |
|-------|-------|-----------|
| `Primary` | `#B9172F` / `#DC3545` | Merah POLICY |
| `Secondary` | `#006D41` | Hijau aksen |
| `BG` | `#EFECEC` | Background utama |
| `Charcoal` | `#222222` | Border & teks |
| `Success` | `#198754` | Status sukses/lunas |

### 5.2 Neo-Centric Brutalism
- Border: `2px solid #222222`
- Shadow: `BoxShadow(offset: Offset(4,4), blurRadius: 0)` — hard shadow, tidak blur
- Tap: shadow menyusut + `Matrix4.translationValues(3,3,0)`

### 5.3 Konvensi AppBar Create Screens
- Judul di **kanan** AppBar: `Row([BackButton, Spacer(), Text(title)])`
- Berlaku untuk `CreateKegiatanScreen` dan `CreateRapatScreen`

---

## 6. Dependensi Teknis

| Package | Kegunaan |
|---------|----------|
| `supabase_flutter` | SDK Backend: DB, Auth, Storage, Realtime |
| `flutter_riverpod` | State management |
| `go_router` | Routing deklaratif |
| `google_sign_in` | Google OAuth |
| `mobile_scanner` | Pemindai QR absensi |
| `google_fonts` | Bricolage Grotesque |
| `cached_network_image` | Cache gambar dari Storage |
| `qr_flutter` | Render QR Code (admin) |
| `image_picker` | Upload foto profil & sekret |
| `intl` | Format Rupiah & tanggal |
| `uuid` | Generate kode QR unik |

---

## 7. Kriteria Penerimaan (MVP)

- [ ] Login via email & Google Sign-In terintegrasi Supabase
- [ ] Registrasi → status `pending` → tampil pending screen
- [ ] Role detection berdasarkan jabatan di periode aktif berjalan
- [ ] Absensi QR Code tercatat, poin bertambah otomatis
- [ ] Status uang khas per bulan real-time
- [ ] Kegiatan memiliki struktur Panitia Inti (3 posisi) + Susunan Sie (dinamis)
- [ ] Semua anggota aktif (level ≥ 1) dapat membuat kegiatan
- [ ] Tab Acara + Rapat di layar Kegiatan
- [ ] List Rapat hanya menampilkan rapat yang relevan berdasarkan posisi/peran user
- [ ] 5 tipe rapat dengan konteks dan peserta yang tepat
- [ ] FAB kontekstual (label berbeda per tab)
- [ ] AppBar trailing → Riwayat Kegiatan

### Release v1.0
- [ ] Upload foto profil ke Supabase Storage
- [ ] Sistem poin & level via Supabase RPC
- [ ] Leaderboard poin anggota
- [ ] Inbox notifikasi personal & pengumuman broadcast
- [ ] Periode kepengurusan: buka, assign jabatan, tutup
- [ ] RLS dikonfigurasi untuk semua tabel sensitif
- [ ] Notulensi rapat dapat ditambahkan oleh yang berwenang

---

*Dokumen PRD v4.0 — Diperbarui dengan fitur Kegiatan (Panitia Inti + Sie), Sistem Rapat (5 tipe + visibilitas berbasis peran), perubahan navigasi Tab Acara/Rapat, FAB kontekstual, AppBar Riwayat, dan konvensi judul create screen di kanan.*
