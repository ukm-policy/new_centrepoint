# Planning Penyesuaian UI & Fitur untuk Role Demisioner

> Rencana Kerja dan Detail Penyesuaian Antarmuka Aplikasi POLICY Centrepoint Khusus Pengguna dengan Hak Akses Demisioner.  
> Versi: 1.0 — 20 Juni 2026  

---

## 1. Latar Belakang & Tujuan

Role **Demisioner** dibuat untuk mengakomodasi alumni, mantan pengurus, atau penasihat UKM POLICY yang masih ingin menggunakan aplikasi Centrepoint guna memantau perkembangan organisasi, melihat agenda kegiatan, dan berinteraksi secara read-only. 

Tujuan utama dari penyesuaian ini adalah:
- **Exempt (Pembebasan Kewajiban)**: Menonaktifkan fitur wajib bagi pengurus/anggota aktif seperti iuran bulanan dan absensi kehadiran.
- **Archive Access (Akses Arsip)**: Memberikan akses data historis (riwayat kegiatan dan arsip poin keaktifan).
- **Clean UI**: Menyederhanakan tampilan menu agar bebas dari tombol/aksi manipulasi data (seperti pembuatan kegiatan atau rapat baru).

---

## 2. Rencana Penyesuaian Antarmuka (Screen-by-Screen)

### 2.1 Beranda (`/`)
**Kondisi Saat Ini**: Menampilkan banner berita terbaru, user card (nama, jabatan, level tier, poin), dan quick access grid (6 menu default).

**Rencana Penyesuaian**:
- [x] **User Card**: Membaca `AppSession.jabatan` ("Demisioner") dan merender status secara elegan.
- [ ] **Quick Access Grid**: Menyesuaikan menu cepat agar relevan. 
  - Ganti menu **Absensi** (yang tidak lagi diperlukan) dengan **Riwayat** secara langsung.
  - Ganti tautan **Uang Khas** menjadi info khusus atau mengarah ke halaman Uang Khas yang terlah disesuaikan (bebas iuran).

---

### 2.2 Layar Fitur (`/fitur`)
**Kondisi Saat Ini**: Menampilkan semua seksi role (Lv. 0 - Lv. 5) berdasarkan pengecekan `level <= AppSession.level`.

**Rencana Penyesuaian**:
- [x] **Seksi Khusus Demisioner**: Membuat kelompok menu terdedikasi untuk alumni/demisioner.
- [x] **Penyaringan Seksi**: Jika session memiliki `kodeRole == 'demisioner'`:
  - Hanya tampilkan seksi **User Public** (untuk Edit Profil) dan seksi **Demisioner**.
  - Sembunyikan seksi Anggota Umum, Anggota Bidang, Ketua Bidang, dan seluruh seksi BPH/Admin.
  - Sembunyikan banner akses penuh panel admin (`_AdminAccessBanner`).

---

### 2.3 Layar Uang Khas (`/uang-khas`)
**Kondisi Saat Ini**: Menampilkan saldo kas aktif, daftar riwayat transaksi kas, dan grid iuran 12 bulan (Januari - Desember) untuk melakukan pembayaran mandiri.

**Rencana Penyesuaian**:
- [x] **Papan Informasi Pembebasan**: Menyembunyikan Grid iuran 12 bulan dan tombol upload struk transfer bagi Demisioner.
- [x] **Notifikasi Neo-Brutalist**: Menampilkan banner penjelasan khusus:
  > 👤 **Sebagai Anggota Demisioner, Anda dibebaskan dari iuran uang khas organisasi. Terima kasih atas dedikasi Anda di periode sebelumnya!**
- [x] **Riwayat Transaksi**: Tetap menampilkan riwayat kas organisasi demi asas transparansi keuangan yang dapat dipantau oleh para alumni.

---

### 3.4 Layar Kegiatan & Rapat (`/kegiatan`)
**Kondisi Saat Ini**: Memiliki dua tab (Acara & Rapat). Memiliki FAB dinamis untuk membuat kegiatan baru ("Buat Acara") atau rapat baru ("Buat Rapat").

**Rencana Penyesuaian**:
- [ ] **Penyembunyian FAB**: Menghilangkan tombol melayang (FAB) "Buat Acara" maupun "Buat Rapat" karena Demisioner tidak memiliki wewenang administratif pembuatan kegiatan.
- [ ] **Penyaringan Rapat (Visibilitas)**: Memastikan logika `isRapatVisible()` menyaring rapat internal bidang kepengurusan aktif dan rapat stakeholder BPH agar tidak tampil di daftar rapat Demisioner (kecuali yang bersangkutan diundang secara eksplisit).

---

### 3.5 Layar Absensi (`/absensi`)
**Kondisi Saat Ini**: Menampilkan scanner QR untuk absen kegiatan dan tombol upload foto untuk absen kehadiran di sekretariat.

**Rencana Penyesuaian**:
- [ ] **Halaman Info Non-Aktif**: Jika diakses secara langsung (misal dari menu setelan/laci), tampilkan halaman placeholder Neo-Brutalist yang menyatakan:
  > 📷 **Status Absensi Tidak Aktif**  
  > Anggota Demisioner tidak memiliki kewajiban absensi kegiatan organisasi.

---

## 3. Matriks Perubahan Status Kerja (Checklist)

| Sprint / Halaman | Komponen UI | Status | Kode Terkait |
|------------------|-------------|:---:|--------------|
| **Fitur Screen** | Seksi Demisioner & Filter Menu | 01. Selesai | [fitur_screen.dart](file:///e:/PROJECT/UKM%20POLICY/New%20Neo%20Brutalism/centrepoint/lib/features/fitur/screens/fitur_screen.dart) |
| **Uang Khas** | Banner Bebas Pembayaran | 02. Selesai | [uang_khas_screen.dart](file:///e:/PROJECT/UKM%20POLICY/New%20Neo%20Brutalism/centrepoint/lib/features/uang_khas/screens/uang_khas_screen.dart) |
| **Beranda** | Kustomisasi Quick Access Grid | 03. Terencana | [beranda_screen.dart](file:///e:/PROJECT/UKM%20POLICY/New%20Neo%20Brutalism/centrepoint/lib/features/beranda/screens/beranda_screen.dart) |
| **Kegiatan** | Sembunyikan FAB & Filter Rapat | 04. Terencana | [list_kegiatan_screen.dart](file:///e:/PROJECT/UKM%20POLICY/New%20Neo%20Brutalism/centrepoint/lib/features/kegiatan/screens/list_kegiatan_screen.dart) |
| **Absensi** | Halaman Status Non-Aktif | 05. Terencana | [absensi_screen.dart](file:///e:/PROJECT/UKM%20POLICY/New%20Neo%20Brutalism/centrepoint/lib/features/absensi/screens/absensi_screen.dart) |

---

*Rencana ini disusun untuk menjaga konsistensi gaya Neo-Centric Brutalism (border 2px, offset shadow 4px, palette HSL teratur) dan memastikan transisi role di aplikasi berjalan mulus.*
