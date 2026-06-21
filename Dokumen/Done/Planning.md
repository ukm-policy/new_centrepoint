# Planning: Policy Centrepoint — Flutter UI Implementation

> Design System: **Neo-Centric Brutalism**  
> Stack: Flutter (Dart), `lib/` sebagai root source  
> Versi: 4.0 — Diperbarui 20 Juni 2026

---

## 1. Daftar Layar (Screens)

### Sudah Diimplementasi ✅

| # | Nama Layar | Route | Status |
|---|------------|-------|--------|
| 1 | Login | `/login` | ✅ Done |
| 2 | Beranda | `/` | ✅ Done |
| 3 | List Berita | `/berita` | ✅ Done |
| 4 | Detail Berita | `/berita/:id` | ✅ Done |
| 5 | List Kegiatan (Tab Acara + Rapat) | `/kegiatan` | ✅ Done |
| 6 | Detail Kegiatan | `/kegiatan/:id` | ✅ Done |
| 7 | Riwayat Kegiatan | `/kegiatan/riwayat` | ✅ Done |
| 8 | Buat Kegiatan | `/kegiatan/buat` | ✅ Done |
| 9 | Detail Rapat | `/kegiatan/rapat/:id` | ✅ Done |
| 10 | Buat Rapat | `/kegiatan/rapat/buat` | ✅ Done |
| 11 | Daftar Anggota | `/anggota` | ✅ Done |
| 12 | Profil Anggota | `/anggota/:id` | ✅ Done |
| 13 | Absensi | `/absensi` | ✅ Done |
| 14 | Riwayat Absensi Sekret | `/absensi/riwayat-sekret` | ✅ Done |
| 15 | Uang Khas | `/uang-khas` | ✅ Done |
| 16 | Menu & Setelan | `/menu` | ✅ Done |
| 17 | Poin Keaktifan | `/poin` | ✅ Done |
| 18 | Inbox | `/inbox` | ✅ Done |
| 19 | Detail Pengumuman | `/inbox/pengumuman/:id` | ✅ Done |

### Belum Diimplementasi 🔲

| # | Nama Layar | Route | Prioritas |
|---|------------|-------|-----------|
| 20 | Register | `/register` | Tinggi |
| 21 | Lupa Password | `/forgot-password` | Tinggi |
| 22 | Edit Profil | `/profil/edit` | Tinggi |
| 23 | Generate QR Absensi | `/admin/qr-generator` | Tinggi |
| 24 | Kelola Kegiatan (Admin) | `/admin/kegiatan` | Sedang |
| 25 | Kelola Anggota (Admin) | `/admin/anggota` | Sedang |
| 26 | Kelola Uang Khas (Admin) | `/admin/uang-khas` | Sedang |
| 27 | Kelola Berita (Admin) | `/admin/berita` | Sedang |
| 28 | Kirim Pengumuman | `/admin/pengumuman/buat` | Sedang |
| 29 | Kelola Periode | `/admin/periode` | Rendah |
| 30 | Assign Jabatan | `/admin/periode/:id/jabatan` | Rendah |
| 31 | Notifikasi Settings | `/menu/notifikasi` | Rendah |

---

## 2. Struktur Direktori `lib/` (Current)

```
lib/
├── main.dart
├── app.dart                         # GoRouter + ShellRoute + _AppShell
├── core/
│   ├── theme/
│   │   ├── app_colors.dart          # Semua konstanta warna + BoxShadow
│   │   ├── app_typography.dart      # TextStyle (Bricolage Grotesque)
│   │   └── app_theme.dart           # ThemeData utama
│   └── constants/
│       └── app_spacing.dart         # Spacing tokens
├── shared/
│   └── widgets/
│       ├── brutalist_card.dart      # Card 2px border + hard shadow + tap animation
│       ├── brutalist_button.dart    # Primary & secondary button
│       ├── my_divider.dart          # Dashed divider
│       ├── floating_app_bar.dart    # AppBar melayang — hamburger/back + mail badge
│       ├── bottom_nav_bar.dart      # Capsule bottom nav + Absensi FAB
│       └── app_drawer.dart          # Drawer navigasi dengan item kondisional
└── features/
    ├── auth/screens/
    │   └── login_screen.dart
    ├── beranda/screens/
    │   └── beranda_screen.dart
    ├── berita/screens/
    │   ├── list_berita_screen.dart
    │   └── detail_berita_screen.dart
    ├── kegiatan/
    │   ├── kegiatan_models.dart      # PanitiaItem, SieItem, KegiatanItem, kKegiatanList
    │   ├── rapat_models.dart         # RapatTipe, RapatStatus, AgendaItem, RapatItem, kRapatList
    │   └── screens/
    │       ├── list_kegiatan_screen.dart    # Tab Acara + Rapat, FAB, AppBar trailing Riwayat
    │       ├── detail_kegiatan_screen.dart  # Panitia Inti + Susunan Sie
    │       ├── create_kegiatan_screen.dart  # Form buat kegiatan lengkap
    │       ├── riwayat_kegiatan_screen.dart # Riwayat kegiatan yg diikuti
    │       ├── detail_rapat_screen.dart     # Detail rapat + agenda + peserta + notulensi
    │       └── create_rapat_screen.dart     # Form buat rapat dengan 5 tipe
    ├── anggota/screens/
    │   ├── list_members_screen.dart
    │   └── detail_member_screen.dart
    ├── absensi/screens/
    │   ├── absensi_screen.dart
    │   └── riwayat_sekret_screen.dart
    ├── uang_khas/screens/
    │   └── uang_khas_screen.dart
    ├── poin/screens/
    │   └── poin_screen.dart         # Tab Riwayat + Leaderboard
    ├── inbox/
    │   ├── inbox_data.dart          # Model & mock data (InboxNotifItem, InboxPengumumanItem)
    │   └── screens/
    │       ├── inbox_screen.dart
    │       └── detail_pengumuman_screen.dart
    └── menu/screens/
        └── menu_setelan_screen.dart
```

---

## 3. Design System Token

### 3.1 Warna (`app_colors.dart`)
```
primary          = #B9172F
primaryContainer = #DC3545
onPrimary        = #FFFFFF
secondary        = #006D41
secondaryContainer = #90F4B7
background       = #F9F9F9
bgGray           = #EFECEC
blackCharcoal    = #222222
surface          = #F9F9F9
onSurface        = #1A1C1C
tertiary         = #5E5D5D
error            = #BA1A1A
```

### 3.2 Tipografi (`app_typography.dart`)
Font: **Bricolage Grotesque** (via `google_fonts` package)

| Token | Size | Weight | Line Height |
|-------|------|--------|-------------|
| `displayLg` | 32px | 800 | 40px |
| `headlineMd` | 24px | 700 | 32px |
| `headlineSm` | 20px | 700 | 28px |
| `bodyLg` | 16px | 500 | 24px |
| `bodyMd` | 14px | 400 | 20px |
| `labelBold` | 12px | 700 | 16px |

### 3.3 Spacing (`app_spacing.dart`)
```
marginPage    = 16.0
gutterGrid    = 12.0
appbarPadding = 12.0
stackGap      = 16.0
innerPadding  = 12.0
```

### 3.4 Border Radius
```
sm      = 4px
DEFAULT = 8px (0.5rem)
md      = 12px
lg      = 16px
xl      = 24px (30px untuk bottom nav)
full    = circular
```

---

## 4. Shared Widgets

### `BrutalistCard`
- Background: `#FFFFFF`
- Border: `2px solid #222222`
- Shadow: `BoxShadow(offset: Offset(4,4), color: #222222)` — **solid, bukan blur**
- Interaksi tap: shadow menyusut ke `Offset(1,1)` + `translate(3,3)` (efek "tertekan")

### `BrutalistButton`
- **Primary**: bg `#DC3545`, text putih, border charcoal, hard shadow 4px
- **Secondary**: bg `#FFFFFF`, text charcoal, border charcoal
- Efek tap: scale 0.95 + shadow 1px (BounceTapper)

### `MyDivider`
- Dashed `2px` menggunakan `CustomPainter` atau `DashedLine`
- Warna: `#222222` atau `#E2E8F0` (Slate-200)

### `FloatingAppBar`
- Margin atas & samping: 16px
- Border radius: 16px (lg)
- Border: 2px charcoal
- Shadow: 4px hard

### `BottomNavBar`
- Shape: capsule / pill (radius ~30px)
- Floating: 16px dari bawah, centered, lebar `fit`
- Border: 2px charcoal
- Item aktif: `secondaryContainer` rounded-full

---

## 5. Rencana Implementasi per Layar

### Fase 1 — Fondasi (Setup) ✅
- [x] Tambah dependencies `pubspec.yaml`: `google_fonts`, `go_router`
- [x] Buat `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`
- [x] Buat `app_theme.dart` (ThemeData dengan warna & font)
- [x] Buat `app.dart` dengan routing dasar
- [x] Buat semua shared widgets

### Fase 2 — Auth ✅
- [x] `login_screen.dart`

### Fase 3 — Shell & Beranda ✅
- [x] Buat `ShellRoute` / scaffold dengan `FloatingAppBar` + `BottomNavBar`
- [x] `beranda_screen.dart`

### Fase 4 — Berita ✅
- [x] `list_berita_screen.dart`
- [x] `detail_berita_screen.dart`

### Fase 5 — Kegiatan ✅
- [x] `kegiatan_models.dart` — `PanitiaItem`, `SieItem`, `KegiatanItem`, mock data `kKegiatanList`
- [x] `rapat_models.dart` — `RapatTipe`, `RapatStatus`, `AgendaItem`, `RapatItem`, `kRapatList`, `isRapatVisible()`
- [x] `list_kegiatan_screen.dart`
  - Tab **Acara** (filter chip Semua/Upcoming/Berlangsung/Selesai, pesertaTerdaftar/kuota, nama ketua)
  - Tab **Rapat** (filter Semua/Acara/Kepengurusan, tipe badge + status badge + label acara)
  - FAB di bawah kanan: label & icon berubah sesuai tab aktif ("Buat Acara" → `/kegiatan/buat` / "Buat Rapat" → `/kegiatan/rapat/buat`)
  - AppBar trailing: icon Riwayat → `/kegiatan/riwayat`
- [x] `detail_kegiatan_screen.dart`
  - Panitia Inti: Ketua Pelaksana (highlight), Sekretaris Pelaksana, Bendahara Pelaksana
  - Susunan Sie: tiap sie dengan Ketua Sie + daftar Anggota Sie
  - Tombol Edit hanya tampil jika `isAdmin || level >= 2`
  - Tombol aksi: "DAFTAR SEKARANG" (upcoming) / "ABSEN SEKARANG" (berlangsung)
- [x] `create_kegiatan_screen.dart`
  - AppBar: back (kiri) + judul "Buat Kegiatan" (kanan, via `Spacer()`)
  - Seksi Info Dasar: nama, tanggal (date picker), waktu, lokasi, deskripsi, kuota
  - Seksi Panitia Inti: 3 field (Ketua, Sekretaris, Bendahara Pelaksana)
  - Seksi Susunan Sie: form dinamis (_SieEntry) — nama sie, ketua sie, tambah/hapus anggota
- [x] `riwayat_kegiatan_screen.dart` — timeline kegiatan yang diikuti
- [x] `detail_rapat_screen.dart`
  - SliverAppBar: back + edit (jika `isAdmin || level >= 3`)
  - Header: tipe badge + status badge, judul, konteks (acara atau kepengurusan)
  - Agenda bernomor (primaryContainer circle), daftar peserta dengan badge "Anda", notulensi
  - Aksi kontekstual: KONFIRMASI HADIR / ABSEN SEKARANG / TAMBAH NOTULENSI
- [x] `create_rapat_screen.dart`
  - AppBar: back (kiri) + judul "Buat Rapat" (kanan, via `Spacer()`)
  - Seksi Tipe: 5 jenis rapat (card _TipeOption dengan icon + label + deskripsi)
  - Seksi Konteks: dinamis sesuai tipe (dropdown kegiatan, dropdown sie cascade, bidang, toggle)
  - Seksi Info Dasar: judul, tanggal+waktu (row), lokasi
  - Seksi Agenda: list dinamis bernomor

### Fase 6 — Anggota ✅
- [x] `list_members_screen.dart`
- [x] `detail_member_screen.dart`

### Fase 7 — Absensi ✅
- [x] `absensi_screen.dart`
- [x] `riwayat_sekret_screen.dart`

### Fase 8 — Uang Khas ✅
- [x] `uang_khas_screen.dart`

### Fase 9 — Menu & Setelan ✅
- [x] `menu_setelan_screen.dart`

---

## 6. Routing Kegiatan (GoRouter)

```dart
GoRoute(
  path: '/kegiatan',
  builder: (_, _) => const ListKegiatanScreen(),
  routes: [
    GoRoute(path: 'buat',    builder: (_, _) => const CreateKegiatanScreen()),
    GoRoute(path: 'riwayat', builder: (_, _) => const RiwayatKegiatanScreen()),
    GoRoute(
      path: 'rapat',
      // builder (bukan redirect) agar child routes tidak terintercept
      builder: (_, _) => const ListKegiatanScreen(),
      routes: [
        GoRoute(path: 'buat', builder: (_, _) => const CreateRapatScreen()),
        GoRoute(path: ':id',  builder: (_, s) => DetailRapatScreen(id: s.pathParameters['id']!)),
      ],
    ),
    GoRoute(path: ':id', builder: (_, s) => DetailKegiatanScreen(id: s.pathParameters['id']!)),
  ],
),
```

> **Catatan GoRouter:** Setiap `GoRoute` wajib memiliki `builder`, `pageBuilder`, atau `redirect`. Parent route `rapat` menggunakan `builder` (bukan `redirect`) agar navigasi ke `/kegiatan/rapat/buat` dan `/kegiatan/rapat/:id` tidak terintercept.

---

## 7. Dependencies yang Dibutuhkan

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  google_fonts: ^6.2.1       # Bricolage Grotesque
  go_router: ^14.0.0         # Routing deklaratif
  cached_network_image: ^3.3.1  # Gambar dari network dengan cache

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

---

## 8. Catatan Desain Penting

- **Tidak ada Gaussian blur / soft shadow** — selalu gunakan `BoxShadow` dengan `blurRadius: 0`
- **Semua card & button interaktif** wajib ada efek BounceTapper (scale + shadow shrink)
- `FloatingAppBar` dan `BottomNavBar` tidak full-width, ada margin dari pinggir layar
- `MyDivider` menggunakan dashed/dotted, bukan solid line
- Warna **success = #198754** untuk status "Lunas", "Hadir", dll
- Warna **primary = #DC3545** untuk aksi utama dan branding
- Semua teks heading weight minimal 700 (Bold)
- **FAB di ListKegiatanScreen** diimplementasi sebagai `Stack` + `Positioned` karena Scaffold dimiliki `_AppShell` — ListView item diberi padding `bottom: 80` agar tidak tertutup FAB
- **AppBar di create screens** — judul di kanan (`Spacer() + Text(...)`), back button di kiri
