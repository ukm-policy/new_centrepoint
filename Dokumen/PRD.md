# Product Requirements Document (PRD)
## POLICY CENTREPOINT — Aplikasi Mobile Manajemen UKM

---

**Nama Proyek:** POLICY – CENTREPOINT  
**Platform:** Flutter (Android & iOS)  
**Versi Dokumen:** 3.0 (Org Structure Update)  
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

Aplikasi ini menjadi pusat pengelolaan organisasi yang mencakup manajemen anggota, absensi kegiatan berbasis QR Code, iuran keanggotaan, poin keaktifan, sistem inbox/pengumuman, dan panel administrasi berbasis peran (role-based access). Seluruh infrastruktur backend ditenagai oleh **Supabase**.

### 1.2 Latar Belakang

UKM POLICY membutuhkan sistem digital yang dapat:
- Menggantikan proses absensi manual dengan sistem pemindaian QR Code
- Memudahkan anggota memantau status iuran (uang khas) secara real-time
- Memberikan visibilitas kegiatan organisasi kepada semua anggota
- Menyediakan panel administrasi berbasis jabatan & periode kepengurusan
- Mengelola poin keaktifan dan level keanggotaan otomatis
- Mendistribusikan pengumuman dan notifikasi ke seluruh anggota

### 1.3 Tujuan Produk

| Tujuan | Deskripsi |
|--------|-----------|
| Efisiensi Absensi | Menggantikan absensi manual dengan pemindaian QR Code |
| Transparansi Keuangan | Anggota memantau status iuran (uang khas) secara mandiri |
| Centralisasi Informasi | Satu platform untuk berita, kegiatan, dan pengumuman |
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

### 2.2 Segmentasi Pengguna & Level Akses

| Level | Kode Role | Jabatan | Hak Akses Utama |
|-------|-----------|---------|-----------------|
| 5 | `ketua_umum` | Ketua Umum | Full access: semua fitur + kelola sistem & periode |
| 4 | `sekretaris_umum` | Sekretaris Umum | Konten, berita, kegiatan semua bidang, kelola anggota |
| 4 | `bendahara_umum` | Bendahara Umum | Uang khas & keuangan semua anggota |
| 3 | `ketua_bidang` | Ketua Bidang | Kelola kegiatan, absensi, poin bidangnya |
| 2 | `anggota_bidang` | Anggota Bidang | Fitur anggota + info internal bidang |
| 1 | `anggota_umum` | Anggota Umum | Baca, scan absensi, pantau data pribadi |

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
- **Supabase:** `supabase.auth.signInWithPassword()` / `supabase.auth.signInWithOAuth(OAuthProvider.google)`

#### F-02: Registrasi & Verifikasi Email
- Pendaftaran akun baru ke Supabase Auth
- Insert data profil ke tabel `users` via trigger atau manual setelah signup
- Default role baru: `anggota_umum` (belum terdaftar kepengurusan)

#### F-03: Manajemen Sesi & Logout
- Cek `supabase.auth.currentSession` saat startup
- Auto-refresh token oleh Supabase SDK
- Logout: `supabase.auth.signOut()` → redirect ke `LoginPage`

---

### 3.2 Beranda

#### F-04: Carousel Banner
- Data dari tabel `banners`, gambar dari Supabase Storage bucket `banners`
- Auto-play dengan shimmer loading

#### F-05: User Card
- Foto profil, nama, jabatan & bidang (dari periode aktif), total poin, badge level
- Tap → halaman Poin Keaktifan

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
- Validasi `attendance_codes`: kode valid + belum `expires_at`
- Insert ke tabel `absensi`, auto tambah poin via RPC

#### F-08: Jenis Absensi
| Jenis | Keterangan |
|-------|------------|
| Absensi Rapat | Pertemuan rutin / koordinasi |
| Absensi Kegiatan | Event atau kepanitiaan |
| Absensi Sekret | Kehadiran fisik di sekretariat (dengan foto bukti) |

#### F-09: Riwayat Absensi
- Daftar absensi user dari tabel `absensi` join `activities`
- Diurutkan dari terbaru

---

### 3.4 Berita & Pengumuman

#### F-10: Daftar Berita
- Artikel dari tabel `berita`, thumbnail dari bucket `berita`
- **Baca:** semua role  
- **Tulis/Edit/Hapus:** Sekretaris Umum (level ≥ 4 domain konten) & Ketua Umum

---

### 3.5 Kegiatan

#### F-11: Tab View Kegiatan
| Tab | Filter |
|-----|--------|
| Berlangsung | `status = 'berlangsung'` |
| Selesai | `status = 'selesai'` |

#### F-12: Kartu & Detail Kegiatan
- Banner dari bucket `activities`, judul, tanggal, lokasi, status, deskripsi

#### F-13: Kelola Kegiatan (Admin)
- **Ketua Bidang:** buat & kelola kegiatan bidangnya
- **Sekretaris Umum & Ketua Umum:** kelola kegiatan semua bidang

---

### 3.6 Uang Khas

#### F-14: Status Per Bulan (Real-Time)
- Status per bulan: Lunas / Belum Bayar dari tabel `uang_khas`
- Real-time via Supabase Realtime stream
- **View milik sendiri:** semua role
- **View & kelola semua anggota:** Bendahara Umum & Ketua Umum

#### F-15: Rekap Keuangan
- Akumulasi bayar per tahun (Rp 50.000/bulan)
- **Export laporan:** Bendahara Umum & Ketua Umum

---

### 3.7 Profil & Edit Akun

#### F-16: Header Profil
- Avatar dari bucket `avatars`, nama, jabatan di periode aktif, badge level

#### F-17: Edit Profil
- Edit nama, bio, upload foto profil (maks 2 MB ke bucket `avatars`)

---

### 3.8 Poin Keaktifan

#### F-18: Sistem Poin
- Tambah/kurang poin via **Supabase RPC**
- Riwayat mutasi poin di tabel `point_history`
- **Tambah poin otomatis:** saat absensi berhasil
- **Tambah/kurang manual:** Ketua Bidang (bidangnya), Sekretaris, Ketua Umum

#### F-19: Level Keanggotaan
| Level | Min Poin | Max Poin |
|-------|----------|----------|
| Bronze | 0 | 499 |
| Silver | 500 | 1499 |
| Gold | 1500 | 2999 |
| Platinum | 3000 | ∞ |

#### F-20: Leaderboard
- Peringkat poin semua anggota (podium top 3 + daftar lengkap)
- Akses: semua role

---

### 3.9 Inbox & Notifikasi

#### F-21: Inbox
- Tab **Notifikasi:** aktivitas personal (poin, absensi, uang khas, kegiatan, sistem)
- Tab **Pengumuman:** broadcast resmi dari pengurus
- Badge unread count di AppBar
- Notif item: tap → navigate ke halaman relevan

#### F-22: Kirim Pengumuman
- Sekretaris Umum & Ketua Umum dapat broadcast pengumuman ke semua anggota

---

### 3.10 Panel Admin

#### F-23: Generate QR Absensi
- **Ketua Bidang:** generate QR untuk kegiatan bidangnya
- **Sekretaris & Ketua Umum:** semua kegiatan
- Kode UUID + `expires_at`, render QR via `qr_flutter`

#### F-24: Manage Kegiatan
- CRUD kegiatan, upload banner, set status

#### F-25: Kelola Periode Kepengurusan
- **Hanya Ketua Umum**
- Buka periode baru, assign jabatan ke user, tutup periode lama
- Data jabatan periode lama tetap tersimpan (riwayat)

#### F-26: Manajemen Anggota
- Lihat semua anggota dengan filter bidang & status
- **Sekretaris & Ketua Umum:** edit data, assign bidang, verifikasi anggota baru

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
users            → id, username, fullname, email, nim, angkatan, points, profile_photo, created_at
bidang           → id, nama_bidang, deskripsi, icon
jabatan          → id, nama_jabatan, bidang_id (nullable), level_akses, kode_role
periode          → id, nama_periode, tahun_mulai, tahun_selesai, is_aktif, created_at
kepengurusan     → id, user_id, jabatan_id, periode_id, tanggal_mulai, tanggal_selesai
activities       → activity_id, name, date_start, date_end, location, type, status, image, bidang_id, created_by
attendance_codes → code_id, code, activity_id, expires_at, created_at
absensi          → id, user_id, activity_id, scanned_at, type, foto_sekret (nullable)
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
uangKhasProvider         → Stream status iuran per user
absensiHistoryProvider   → Riwayat absensi
leaderboardProvider      → Data poin semua anggota
inboxProvider            → Stream notifikasi & pengumuman
```

### 4.4 Supabase Storage Buckets

| Bucket | Isi | Akses |
|--------|-----|-------|
| `avatars` | Foto profil anggota | Private (authenticated) |
| `banners` | Gambar carousel beranda | Public |
| `activities` | Banner kegiatan | Public |
| `berita` | Thumbnail artikel | Public |
| `absensi_sekret` | Foto bukti absensi sekretariat | Private (authenticated) |

### 4.5 Struktur Direktori (Feature-First)

```
lib/
├── main.dart
├── app.dart                          # Routing + ShellRoute + AppShell
├── core/
│   ├── theme/                        # Colors, Typography, Spacing, Theme
│   ├── constants/
│   └── network/
│       └── supabase_client.dart
├── shared/
│   └── widgets/
│       ├── brutalist_card.dart
│       ├── floating_app_bar.dart
│       ├── bottom_nav_bar.dart
│       ├── app_drawer.dart
│       └── my_divider.dart
└── features/
    ├── auth/screens/
    ├── beranda/screens/
    ├── berita/screens/
    ├── kegiatan/screens/
    ├── anggota/screens/
    ├── absensi/screens/
    ├── uang_khas/screens/
    ├── poin/screens/
    ├── inbox/
    │   ├── inbox_data.dart
    │   └── screens/
    │       ├── inbox_screen.dart
    │       └── detail_pengumuman_screen.dart
    └── menu/screens/
```

### 4.6 Pola Navigasi & UI Layout
- **Floating Rounded AppBar** — melayang, margin `16px`, radius `16px`, 2px border, hard shadow
- **Floating Rounded Bottom Navbar** — kapsul melayang, 5 tab utama (Beranda, Berita, Kegiatan, Menu, Absensi)
- **App Drawer** — navigasi samping dengan item kondisional berdasarkan level akses
- **GoRouter ShellRoute** — shell dengan drawer + bottom nav, badge inbox di AppBar

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

### 5.2 Font
- **Bricolage Grotesque** (via `google_fonts`) — semua teks, heading weight 700–800

### 5.3 Neo-Centric Brutalism
- Border: `2px solid #222222`
- Shadow: `BoxShadow(offset: Offset(4,4), blurRadius: 0)` — hard shadow, tidak blur
- Tap: shadow menyusut + `Matrix4.translationValues(3,3,0)`

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

## 7. Alur Autentikasi & Role Detection

```
[Startup]
    │
    ├── supabase.auth.currentSession ada?
    │       ├── Ya  → load user profile + jabatan aktif
    │       └── Tidak → [LoginPage]
    │
[LoginPage]
    ├── Email & Password → signInWithPassword()
    ├── Google Sign-In   → signInWithOAuth(Google)
    └── Keduanya → [DeteksiRole]
                      │
                      ├── Query kepengurusan WHERE user_id = current AND periode.is_aktif = true
                      ├── Ditemukan → set kode_role + bidang_id dari jabatan
                      └── Tidak ditemukan → set kode_role = 'anggota_umum'
```

---

## 8. Persyaratan Non-Fungsional

- **Performa:** Loading beranda < 3 detik pada 4G/LTE
- **Animasi:** 60 FPS, transisi 200ms easeInOut
- **Keamanan:** RLS Supabase di semua tabel sensitif, token aman via SDK
- **Real-time:** Uang khas & notifikasi via Supabase Realtime WebSocket
- **Offline:** Cache gambar via `CachedNetworkImage`, data kritis butuh koneksi

---

## 9. Kriteria Penerimaan (MVP)

- [ ] Login via email & Google Sign-In terintegrasi Supabase
- [ ] Role detection berdasarkan jabatan di periode aktif berjalan
- [ ] Absensi QR Code tercatat ke tabel `absensi`, poin bertambah otomatis
- [ ] Status uang khas per bulan real-time dari Supabase
- [ ] Ketua Bidang dapat generate QR dan kelola kegiatan bidangnya
- [ ] Bendahara Umum dapat lihat & update uang khas semua anggota
- [ ] Sekretaris Umum dapat publish berita & pengumuman
- [ ] Ketua Umum dapat kelola periode kepengurusan & assign jabatan

### Release v1.0
- [ ] Upload foto profil ke Supabase Storage
- [ ] Sistem poin & level via Supabase RPC
- [ ] Leaderboard poin anggota
- [ ] Inbox notifikasi personal & pengumuman broadcast
- [ ] Periode kepengurusan: buka, assign jabatan, tutup
- [ ] RLS dikonfigurasi untuk semua tabel sensitif

---

*Dokumen PRD v3.0 — Diperbarui dengan struktur organisasi UKM POLICY (6 bidang, sistem periode kepengurusan, 6 level akses berbasis jabatan).*
