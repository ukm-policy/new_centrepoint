# Centrepoint — UKM POLICY Mobile App

Aplikasi mobile resmi **UKM POLICY** (Unit Kegiatan Mahasiswa) berbasis Flutter dengan desain sistem **Neo-Brutalism**. Centrepoint hadir sebagai platform terpusat untuk manajemen organisasi: absensi kegiatan, pengelolaan keuangan iuran, informasi anggota, berita, poin partisipasi, hingga panel admin.

---

## Fitur Utama

| Modul | Deskripsi |
|---|---|
| **Beranda** | Dashboard dengan carousel berita, kartu profil anggota, dan quick menu |
| **Berita** | Daftar dan detail berita/pengumuman organisasi |
| **Kegiatan** | Jadwal kegiatan, rapat, riwayat partisipasi, dan form pembuatan kegiatan |
| **Absensi** | Check-in via QR Code, riwayat absensi sekretariat |
| **Uang Khas** | Saldo, status iuran anggota, dan riwayat transaksi keuangan |
| **Poin** | Sistem poin partisipasi anggota |
| **Anggota** | Direktori anggota dan detail profil |
| **Inbox** | Notifikasi dan pengumuman internal |
| **OR (Organisasi)** | Manajemen struktur organisasi |
| **Admin Panel** | Verifikasi anggota, kelola kegiatan/berita/poin/keuangan, audit log, generate QR |
| **Pengaturan** | Profil pengguna, notifikasi, dan informasi aplikasi |

---

## Tech Stack

- **Framework:** Flutter (Dart SDK ^3.12.1)
- **State Management:** Provider `^6.1.2`
- **Navigasi:** GoRouter `^14.6.3`
- **Backend:** Firebase (Firebase Core `^4.11.0`)
- **Font:** Bricolage Grotesque via Google Fonts `^6.2.1`
- **Image Caching:** cached_network_image `^3.4.1`

---

## Desain Sistem — Neo-Brutalism

Aplikasi menggunakan design language Neo-Brutalism yang konsisten:

- **Hard shadow:** `BoxShadow(offset: Offset(4,4), blurRadius: 0, color: #222222)`
- **Tap feedback:** translasi `Matrix4.translationValues(3,3,0)` + shadow mengecil ke `Offset(1,1)`
- **AppBar:** floating, margin 16px semua sisi, border-radius 16px
- **BottomNavBar:** capsule pill floating 16px dari bawah layar

---

## Struktur Proyek

```
lib/
├── core/
│   ├── session/          # AppSession (state login pengguna)
│   └── theme/            # AppColors, AppTypography, AppSpacing, AppTheme
├── data/
│   ├── dummy/            # Data dummy untuk development
│   ├── models/           # Model data (User, Member, Berita, Kegiatan, dll)
│   └── repositories/     # Repository pattern (Dummy & API interface)
├── features/
│   ├── admin/            # Panel admin & manajemen organisasi
│   ├── absensi/          # Absensi QR & riwayat
│   ├── anggota/          # Direktori anggota
│   ├── auth/             # Login, register, setup profil
│   ├── beranda/          # Dashboard utama
│   ├── berita/           # Berita & pengumuman
│   ├── fitur/            # Halaman fitur & info bidang
│   ├── inbox/            # Notifikasi internal
│   ├── kegiatan/         # Kegiatan & rapat
│   ├── menu/             # Pengaturan & about
│   ├── or/               # Organisasi
│   ├── poin/             # Sistem poin
│   └── uang_khas/        # Keuangan iuran
└── shared/
    └── widgets/          # Komponen reusable (BrutalistCard, BrutalistButton, dll)
```

---

## Memulai Development

### Prasyarat

- Flutter SDK >= 3.12.1
- Dart SDK >= 3.12.1
- Android Studio / VS Code dengan Flutter extension
- Akun Firebase (untuk konfigurasi `firebase_options.dart`)

### Instalasi

```bash
# Clone repositori
git clone <repo-url>
cd centrepoint

# Install dependencies
flutter pub get

# Jalankan aplikasi (mode dummy data)
flutter run
```

### Mode Backend

Di [lib/main.dart](lib/main.dart), ubah flag `useApiBackend`:

```dart
const bool useApiBackend = false; // false = dummy data, true = API/Firebase
```

---

## Package ID

`com.parzello.centrepoint`
