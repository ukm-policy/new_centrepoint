# Planning: Policy Centrepoint — Flutter UI Implementation

> Design System: **Neo-Centric Brutalism**
> Stack: Flutter (Dart), `lib/` sebagai root source

---

## 1. Daftar Layar (Screens)

| # | Folder UI | Nama Layar | Route |
|---|-----------|------------|-------|
| 1 | `login_policy_centrepoint` | Login | `/login` |
| 2 | `beranda_policy_centrepoint` | Beranda (Home) | `/` |
| 3 | `absensi_policy_centrepoint` | Absensi | `/absensi` |
| 4 | `list_berita_policy_centrepoint_refined` | Berita & Pengumuman | `/berita` |
| 5 | `detail_berita_policy_centrepoint` | Detail Berita | `/berita/:id` |
| 6 | `list_kegiatan_policy_centrepoint` | List Kegiatan | `/kegiatan` |
| 7 | `detail_kegiatan_policy_centrepoint` | Detail Kegiatan | `/kegiatan/:id` |
| 8 | `riwayat_kegiatan_policy_centrepoint` | Riwayat Kegiatan | `/kegiatan/riwayat` |
| 9 | `list_members_policy_centrepoint` | Daftar Anggota | `/anggota` |
| 10 | `detail_member_policy_centrepoint` | Profil Anggota | `/anggota/:id` |
| 11 | `uang_khas_policy_centrepoint` | Uang Khas | `/uang-khas` |
| 12 | `menu_setelan_policy_centrepoint` | Menu & Setelan | `/menu` |

---

## 2. Struktur Direktori `lib/`

```
lib/
├── main.dart
├── app.dart                        # MaterialApp + ThemeData + routing
├── core/
│   ├── theme/
│   │   ├── app_colors.dart         # Semua konstanta warna
│   │   ├── app_typography.dart     # TextStyle (Bricolage Grotesque)
│   │   └── app_theme.dart          # ThemeData utama
│   └── constants/
│       └── app_spacing.dart        # Spacing tokens (margin, gutter, dll)
├── shared/
│   └── widgets/
│       ├── brutalist_card.dart     # Card dengan 2px border + hard shadow
│       ├── brutalist_button.dart   # Primary & secondary button + BounceTapper
│       ├── my_divider.dart         # Dashed/dotted divider
│       ├── floating_app_bar.dart   # AppBar melayang dengan border+shadow
│       └── bottom_nav_bar.dart     # Capsule bottom nav melayang
└── features/
    ├── auth/
    │   └── screens/
    │       └── login_screen.dart
    ├── beranda/
    │   └── screens/
    │       └── beranda_screen.dart
    ├── berita/
    │   └── screens/
    │       ├── list_berita_screen.dart
    │       └── detail_berita_screen.dart
    ├── kegiatan/
    │   └── screens/
    │       ├── list_kegiatan_screen.dart
    │       ├── detail_kegiatan_screen.dart
    │       └── riwayat_kegiatan_screen.dart
    ├── anggota/
    │   └── screens/
    │       ├── list_members_screen.dart
    │       └── detail_member_screen.dart
    ├── absensi/
    │   └── screens/
    │       └── absensi_screen.dart
    ├── uang_khas/
    │   └── screens/
    │       └── uang_khas_screen.dart
    └── menu/
        └── screens/
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

### Fase 1 — Fondasi (Setup)
- [ ] Tambah dependencies `pubspec.yaml`: `google_fonts`, `go_router`
- [ ] Buat `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`
- [ ] Buat `app_theme.dart` (ThemeData dengan warna & font)
- [ ] Buat `app.dart` dengan routing dasar
- [ ] Buat semua shared widgets

### Fase 2 — Auth
- [ ] `login_screen.dart`
  - Logo / headline "POLICY CENTREPOINT"
  - Input NIM / Email (2px border, label bold di atas)
  - Input Password
  - Button Login (BrutalistButton primary)

### Fase 3 — Shell & Beranda
- [ ] Buat `ShellRoute` / scaffold dengan `FloatingAppBar` + `BottomNavBar`
- [ ] `beranda_screen.dart`
  - Carousel Banner (PageView)
  - User Card (avatar, nama, jabatan, poin, badge member)
  - Quick Access Bento Grid 3 kolom (Members, Kegiatan, Uang Khas)
  - Horizontal scroll "Berita Terbaru" dengan news card

### Fase 4 — Berita
- [ ] `list_berita_screen.dart`
  - AppBar dengan judul "Berita & Pengumuman"
  - Search bar
  - Filter chip (Semua / Berita / Pengumuman)
  - ListView BrutalistCard berita
- [ ] `detail_berita_screen.dart`
  - Hero image
  - Judul, tanggal, badge kategori
  - Body teks artikel
  - Share/Simpan action

### Fase 5 — Kegiatan
- [ ] `list_kegiatan_screen.dart`
  - Filter chip: Upcoming / Selesai
  - Card kegiatan (nama, tanggal, lokasi, badge status)
- [ ] `detail_kegiatan_screen.dart`
  - Header kegiatan (banner/gambar)
  - Info detail (tanggal, lokasi, deskripsi)
  - Tombol Daftar / Absensi
  - Daftar peserta (preview)
- [ ] `riwayat_kegiatan_screen.dart`
  - Timeline riwayat kegiatan yang sudah diikuti
  - Badge kehadiran (Hadir / Tidak Hadir)

### Fase 6 — Anggota
- [ ] `list_members_screen.dart`
  - Search bar
  - Grid/List anggota dengan avatar + nama + divisi
  - Filter berdasarkan divisi / angkatan
- [ ] `detail_member_screen.dart`
  - Avatar besar + nama + jabatan
  - Info kontak (NIM, email, no. HP)
  - Badge member tier
  - Statistik kehadiran & poin
  - Riwayat kegiatan anggota

### Fase 7 — Absensi
- [ ] `absensi_screen.dart`
  - QR Scanner atau kode manual
  - Status absensi hari ini
  - Daftar hadir per kegiatan

### Fase 8 — Uang Khas
- [ ] `uang_khas_screen.dart`
  - Ringkasan saldo kas
  - Status iuran anggota saat ini (Lunas / Belum)
  - History transaksi masuk/keluar
  - Badge "Lunas" warna success (#198754)

### Fase 9 — Menu & Setelan
- [ ] `menu_setelan_screen.dart`
  - Profil user (mini card)
  - List menu item (icon + label) dengan MyDivider
  - Menu: Edit Profil, Notifikasi, Tentang Aplikasi, Logout

---

## 6. Dependencies yang Dibutuhkan

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

## 7. Urutan Prioritas Implementasi

```
1. Setup (theme, token, shared widgets)    ← blockers semua layar
2. Login                                   ← entry point
3. Shell + Beranda                         ← home screen
4. Berita (list + detail)
5. Kegiatan (list + detail + riwayat)
6. Anggota (list + detail)
7. Absensi
8. Uang Khas
9. Menu & Setelan
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
