# Planning Kelengkapan UI — POLICY CENTREPOINT

> Audit & Rencana Pengerjaan Screen yang Belum Ada / Belum Lengkap  
> Versi: 1.0 — 20 Juni 2026  
> Berdasarkan: Hasil audit seluruh screen di `lib/features/`

---

## 1. Ringkasan Audit

| Kategori | Jumlah |
|----------|--------|
| Screen sudah selesai & berfungsi penuh | 19 |
| Screen belum ada sama sekali (perlu dibuat baru) | 18 |
| Screen ada tapi butuh perbaikan besar | 9 |
| Elemen/tombol stub di dalam screen yang ada | 11 |

---

## 2. Legenda Prioritas

| Prioritas | Keterangan |
|-----------|------------|
| **P1** | Alur user utama — blocking jika tidak ada |
| **P2** | Fitur inti — sering diakses, perlu segera |
| **P3** | Admin & pelengkap — penting tapi bisa menyusul |
| **P4** | Tambahan — nice-to-have, tidak blocking |

---

## 3. Screen Belum Ada (Harus Dibuat)

### 3.1 Auth & Onboarding

| # | Nama Screen | Route | Prioritas | Keterangan |
|---|-------------|-------|-----------|------------|
| 1 | Lupa Password | `/forgot-password` | **P1** | Tombol "Lupa Password?" di login_screen sudah ada tapi belum ada route/screen tujuan |
| 2 | Pending Verifikasi | `/pending` | **P1** | Untuk User Public setelah register; direferensikan di `fitur_screen.dart` (`implemented: false`) |

#### Detail: Lupa Password (`/forgot-password`)
- Input email
- Tombol "Kirim Link Reset"
- Tampil konfirmasi "Email reset terkirim ke …"
- Link kembali ke Login

#### Detail: Pending Verifikasi (`/pending`)
- Banner besar "Akun Menunggu Verifikasi Pengurus"
- Info: nama, email yang didaftarkan
- Penjelasan proses verifikasi (menunggu Sekretaris/Ketua Umum)
- Tombol "Refresh Status"
- Tombol Logout

---

### 3.2 Profil & Pengaturan

| # | Nama Screen | Route | Prioritas | Keterangan |
|---|-------------|-------|-----------|------------|
| 3 | Edit Profil | `/profil/edit` | **P1** | Direferensikan di `menu_setelan` & `fitur_screen`; `implemented: false` |
| 4 | Notifikasi Settings | `/menu/notifikasi` | **P3** | Item di menu_setelan; belum ada screen |
| 5 | Tentang Aplikasi | `/menu/tentang` | **P4** | Item di menu_setelan; SnackBar placeholder |

#### Detail: Edit Profil (`/profil/edit`)
- Avatar besar dengan tombol ganti foto (kamera / galeri)
- Field: Nama Lengkap, NIM, Angkatan, Program Studi, No. WhatsApp
- Field bio/deskripsi diri
- Tombol "SIMPAN PERUBAHAN"
- AppBar: back (kiri) + judul "Edit Profil" (kanan)

#### Detail: Notifikasi Settings (`/menu/notifikasi`)
- Toggle per tipe notifikasi: Poin, Kegiatan, Absensi, Uang Khas, Pengumuman, Sistem
- Preferensi push notification (on/off global)

---

### 3.3 Admin — Pengguna & Keanggotaan

| # | Nama Screen | Route | Prioritas | Keterangan |
|---|-------------|-------|-----------|------------|
| 6 | Kelola Akun Pengguna | `/admin/users` | **P2** | Di `admin_screen`, `implemented: false`; 48 user terdaftar (mock) |
| 7 | Verifikasi Anggota Baru | `/admin/verifikasi` | **P2** | Badge counter `_kPendingVerif = 4` di admin_screen; belum ada screen |
| 8 | Assign Jabatan | `/admin/periode/jabatan` | **P3** | Di `fitur_screen` & `admin_screen`; stub |

#### Detail: Kelola Akun Pengguna (`/admin/users`)
- Search bar + filter chip (Aktif / Pending / Suspended, per Bidang, per Angkatan)
- List user: avatar, nama, status badge, level badge, jabatan
- Tap → detail user dengan opsi edit data / ubah status / suspend
- AppBar trailing: jumlah total user

#### Detail: Verifikasi Anggota Baru (`/admin/verifikasi`)
- Filter chip: Semua / Menunggu / Diterima / Ditolak
- Kartu pendaftar: nama, email, NIM, angkatan, tanggal daftar
- Tap → detail + tombol "VERIFIKASI & ASSIGN JABATAN" / "TOLAK"
- Badge count di header (menunggu verifikasi)

#### Detail: Assign Jabatan (`/admin/periode/jabatan`)
- Dropdown pilih periode aktif
- List anggota aktif (belum dapat jabatan periode ini)
- Per anggota: dropdown jabatan + dropdown bidang (jika relevan)
- Tombol simpan

---

### 3.4 Admin — Kegiatan & Absensi

| # | Nama Screen | Route | Prioritas | Keterangan |
|---|-------------|-------|-----------|------------|
| 9 | Generator QR Absensi | `/admin/qr-generator` | **P2** | Di `fitur_screen` & `admin_screen`; `implemented: false` |
| 10 | Kelola Semua Kegiatan | `/admin/kegiatan` | **P2** | Di `fitur_screen` & `admin_screen`; `implemented: false` |

#### Detail: Generator QR Absensi (`/admin/qr-generator`)
- Dropdown pilih kegiatan (dari `kKegiatanList`)
- Input durasi berlaku QR (jam/menit)
- Tombol "GENERATE QR"
- Tampilkan QR besar + info kegiatan & waktu berlaku
- Tombol Share / Simpan gambar QR

#### Detail: Kelola Semua Kegiatan (`/admin/kegiatan`)
- Filter chip: Semua / Upcoming / Berlangsung / Selesai + filter bidang
- List kegiatan: judul, tanggal, bidang, status badge, peserta count
- Tap → detail dengan aksi admin: edit status, hapus
- FAB "Tambah Kegiatan" → `/kegiatan/buat`

---

### 3.5 Admin — Keuangan

| # | Nama Screen | Route | Prioritas | Keterangan |
|---|-------------|-------|-----------|------------|
| 11 | Uang Khas Semua Anggota | `/admin/uang-khas` | **P2** | Di `fitur_screen` (Bendahara); `implemented: false` |
| 12 | Verifikasi Pembayaran | `/admin/uang-khas/verifikasi` | **P2** | Di `admin_screen`; `implemented: false` |
| 13 | Rekap & Export Keuangan | `/admin/keuangan` | **P3** | Di `admin_screen`; `implemented: false` |

#### Detail: Uang Khas Semua Anggota (`/admin/uang-khas`)
- Search anggota + filter bidang
- Per anggota: avatar, nama, grid status 12 bulan (Lunas/Belum)
- Tap anggota → detail + opsi update status per bulan
- Summary: total terkumpul, total belum bayar

#### Detail: Verifikasi Pembayaran (`/admin/uang-khas/verifikasi`)
- List pengajuan masuk: nama, bulan, nominal, foto bukti, tanggal submit
- Aksi per item: "KONFIRMASI LUNAS" / "TOLAK"
- Filter: Menunggu / Dikonfirmasi / Ditolak

#### Detail: Rekap & Export Keuangan (`/admin/keuangan`)
- Dropdown tahun + pilihan bulan range
- Tabel rekapitulasi per bidang
- Total terkumpul vs target
- Tombol "EXPORT" (CSV/teks)

---

### 3.6 Admin — Konten & Komunikasi

| # | Nama Screen | Route | Prioritas | Keterangan |
|---|-------------|-------|-----------|------------|
| 14 | Kelola Berita | `/admin/berita` | **P2** | Di `admin_screen`; `implemented: false` |
| 15 | Kirim Pengumuman | `/admin/pengumuman/buat` | **P2** | Di `admin_screen` & `fitur_screen`; `implemented: false` |

#### Detail: Kelola Berita (`/admin/berita`)
- Daftar berita dari `kBeritaList` dengan status (Draf / Terbit)
- FAB "Tulis Berita Baru"
- Form berita: judul, kategori (Berita/Pengumuman), thumbnail (placeholder), konten multiline
- Aksi per item: edit, hapus, ubah status terbit

#### Detail: Kirim Pengumuman (`/admin/pengumuman/buat`)
- AppBar: back (kiri) + judul "Buat Pengumuman" (kanan)
- Dropdown kategori: PENTING / KEGIATAN / KEUANGAN / REKRUTMEN / PRESTASI
- Field judul + konten (multiline)
- Optional action card: label tombol + route tujuan
- Tombol "KIRIM SEKARANG"

---

### 3.7 Admin — Poin

| # | Nama Screen | Route | Prioritas | Keterangan |
|---|-------------|-------|-----------|------------|
| 16 | Kelola Poin Anggota | `/admin/poin` | **P3** | Di `admin_screen` & `fitur_screen`; `implemented: false` |

#### Detail: Kelola Poin Anggota (`/admin/poin`)
- Search anggota + filter bidang
- Per anggota: avatar, nama, total poin, level badge
- Tap → dialog tambah/kurangi poin (field jumlah + alasan)
- Riwayat mutasi poin per anggota (expandable)

---

### 3.8 Admin — Sistem

| # | Nama Screen | Route | Prioritas | Keterangan |
|---|-------------|-------|-----------|------------|
| 17 | Kelola Periode Kepengurusan | `/admin/periode` | **P3** | Di `fitur_screen` & `admin_screen`; `implemented: false` |
| 18 | Log Aktivitas Sistem | `/admin/log` | **P4** | Di `admin_screen`; `implemented: false` |

#### Detail: Kelola Periode Kepengurusan (`/admin/periode`)
- Daftar periode dengan badge Aktif/Tidak Aktif + tanggal mulai-selesai
- Tombol "Buat Periode Baru" → form nama + tahun
- Toggle "Jadikan Aktif" (otomatis non-aktifkan periode lain)
- Tombol "Tutup Periode"

#### Detail: Log Aktivitas Sistem (`/admin/log`)
- Timeline aksi admin: siapa, tipe aksi, kapan
- Filter by tipe (Login, CRUD Kegiatan, Verifikasi, Poin, dll.)
- Search by nama / tanggal

---

### 3.9 Fitur — Info Bidang

| # | Nama Screen | Route | Prioritas | Keterangan |
|---|-------------|-------|-----------|------------|
| 19 | Info Internal Bidang | `/fitur/bidang` | **P4** | Di `fitur_screen` untuk Anggota Bidang; `implemented: false` |

#### Detail: Info Internal Bidang (`/fitur/bidang`)
- Nama & deskripsi bidang user
- Daftar anggota bidang: Ketua + Anggota (dengan avatar)
- Progres/timeline kegiatan bidang
- Statistik absensi bidang

---

## 4. Screen Ada → Perlu Perbaikan Besar

### 4.1 Beranda Screen (`/`)
**Masalah:** Semua data hardcoded — user card, banner, berita terbaru bukan dari source yang sama dengan `/berita`.

**Yang perlu diperbaiki:**
- [x] User card: ganti hardcoded dengan `AppSession.nama`, jabatan, poin, level badge
- [x] Berita terbaru: load dari `kBeritaList` (sama dengan list_berita_screen)
- [x] Quick access: sesuaikan ikon/navigasi agar konsisten dengan bottom nav & fitur yang ada
- [x] Periksa navigasi 6 quick access item sudah mengarah ke route yang benar

---

### 4.2 List Anggota & Detail Anggota (`/anggota`, `/anggota/:id`)
**Masalah:** 6 anggota hardcoded inline; `detail_member_screen` tidak melakukan ID lookup sama sekali — selalu menampilkan satu user yang sama.

**Yang perlu diperbaiki:**
- [x] Pindahkan mock data anggota ke satu file `anggota_data.dart` dengan `kMemberList`
- [x] `detail_member_screen.dart`: `kMemberList.firstWhere((m) => m.id == id)`
- [x] Filter bidang di list_members harus benar-benar filter `kMemberList`, bukan dekoratif
- [x] Search bar: filter nama/NIM dari `kMemberList`

---

### 4.3 Detail Berita (`/berita/:id`)
**Masalah:** Konten 100% Lorem ipsum hardcoded; share & save button hanya SnackBar.

**Yang perlu diperbaiki:**
- [x] Lookup konten berdasarkan `:id` dari `kBeritaList` yang dibagi dengan list_berita_screen
- [x] Tampilkan judul, tanggal, kategori, konten sesuai data berita
- [x] Tombol Share → `Share.share(...)` (atau SnackBar informatif)
- [x] Tombol Simpan → toggle state bookmark lokal

---

### 4.4 Absensi Screen (`/absensi`)
**Masalah:** QR scanner adalah animasi visual saja (scan line + corner marker); tidak ada kamera aktif; tombol foto sekret adalah placeholder kosong.

**Yang perlu diperbaiki:**
- [ ] Ganti animasi QR scanner dengan widget `mobile_scanner` nyata
- [ ] Tombol "Absen Cepat" buka kamera scanner
- [ ] Absensi sekret: tombol kamera buka `image_picker`
- [ ] Status kegiatan hari ini: load dari `kKegiatanList` yang statusnya `berlangsung`

---

### 4.5 Uang Khas Screen (`/uang-khas`)
**Masalah:** Data 100% hardcoded; tidak ada pembagian tampilan user biasa vs Bendahara Umum.

**Yang perlu diperbaiki:**
- [x] Kondisikan dengan `AppSession.level`:
  - Level 1–3: hanya data milik sendiri
  - Level 4 (bendahara) / Level 5: tambah akses ke `/admin/uang-khas`
- [x] Status bulan: load dari mock status dan allow stateful updates per user
- [x] Tombol "Upload Bukti Bayar" untuk bulan yang belum lunas

---

### 4.6 Menu Setelan (`/menu`)
**Masalah:** Banyak item menampilkan SnackBar "Segera hadir"; notifikasi count hardcoded angka 3.

**Yang perlu diperbaiki:**
- [x] "Edit Profil" → `context.push('/profil/edit')`
- [x] "Notifikasi" → `context.push('/menu/notifikasi')`
- [x] "Tentang Aplikasi" → dialog atau screen `/menu/tentang`
- [ ] Item "Kelola Periode" & "Panel Admin" → kondisikan dengan `AppSession.level >= 4`
- [ ] Notifikasi count: ambil dari jumlah inbox yang belum dibaca

---

### 4.7 OR Status Screen (`/or/status`)
**Masalah:** Hardcoded ke `kApplicants[0]`; bukan ID-based lookup.

**Yang perlu diperbaiki:**
- [x] Simpan ID/NIM pelamar saat submit form `/or/daftar`
- [x] `or_status_screen.dart`: lookup dari `kApplicants.firstWhere((a) => a.nim == savedNim)`
- [x] Tampilkan state jika belum pernah daftar

---

### 4.8 Riwayat Kegiatan (`/kegiatan/riwayat`)
**Masalah:** 5 item hardcoded; tidak ada filter; data tidak terhubung ke `kKegiatanList`.

**Yang perlu diperbaiki:**
- [x] Load kegiatan yang `AppSession.nama` tercantum sebagai peserta/panitia dari `kKegiatanList`
- [x] Filter chip: Semua / Tahun Ini / Tahun Lalu
- [x] Summary stats: total kegiatan, hadir, tidak hadir

---

### 4.9 Fitur Screen (`/fitur`)
**Masalah:** Menampilkan semua section role tanpa filter level — user biasa melihat semua menu termasuk yang admin.

**Yang perlu diperbaiki:**
- [x] Filter section berdasarkan `AppSession.level`: hanya tampilkan section ≤ level user
- [x] Atau: section di atas level user di-collapse/dim dengan label "Perlu Jabatan Lebih Tinggi"
- [x] Tambahkan dukungan role khusus "Demisioner" (level 1 dengan check kodeRole) untuk membatasi akses fitur aktif dan menampilkan menu arsip alumni

---

## 5. Elemen Stub di Screen yang Ada

| # | Screen | Elemen Stub | Yang Perlu Dilakukan | Prioritas |
|---|--------|-------------|----------------------|-----------|
| 1 | Login | Tombol "Lupa Password?" | Navigasi ke `/forgot-password` | P1 |
| 2 | Menu Setelan | "Edit Profil" | Navigasi ke `/profil/edit` | P1 |
| 3 | Menu Setelan | "Notifikasi" | Navigasi ke `/menu/notifikasi` | P3 |
| 4 | Menu Setelan | "Tentang Aplikasi" | Dialog/screen info | P4 |
| 5 | Detail Berita | Tombol Share | `Share.share()` | P2 |
| 6 | Detail Berita | Tombol Simpan | Toggle bookmark state | P3 |
| 7 | Absensi | Tombol "Absen Cepat" | Buka kamera `mobile_scanner` | P2 |
| 8 | Absensi | Tombol foto Absen Sekret | Buka `image_picker` | P2 |
| 9 | Detail Kegiatan | Tombol "DAFTAR SEKARANG" | Insert pendaftaran ke data | P2 |
| 10 | Detail Rapat | Tombol "KONFIRMASI HADIR" | Update status konfirmasi peserta | P2 |
| 11 | Detail Rapat | Tombol "TAMBAH NOTULENSI" | Form input notulensi | P3 |

---

## 6. Tabel Prioritas Konsolidasi

### P1 — Harus Ada (Blocking Alur Utama)

| Route | Screen | Jenis |
|-------|--------|-------|
| `/forgot-password` | Lupa Password | Baru |
| `/pending` | Pending Verifikasi | Baru |
| `/profil/edit` | Edit Profil | Baru |
| `/anggota/:id` | Detail Anggota — ID lookup | Perbaikan besar |
| `/berita/:id` | Detail Berita — konten dinamis | Perbaikan besar |
| Login → "Lupa Password?" | Stub → navigasi real | Elemen stub |
| Menu Setelan → "Edit Profil" | Stub → navigasi real | Elemen stub |

### P2 — Fitur Inti Segera

| Route | Screen | Jenis |
|-------|--------|-------|
| `/admin/verifikasi` | Verifikasi Anggota Baru | Baru |
| `/admin/berita` | Kelola Berita | Baru |
| `/admin/pengumuman/buat` | Kirim Pengumuman | Baru |
| `/admin/qr-generator` | Generator QR Absensi | Baru |
| `/admin/kegiatan` | Kelola Semua Kegiatan | Baru |
| `/admin/uang-khas` | Uang Khas Semua Anggota | Baru |
| `/admin/uang-khas/verifikasi` | Verifikasi Pembayaran | Baru |
| `/admin/users` | Kelola Akun Pengguna | Baru |
| `/absensi` | Kamera nyata (QR + foto sekret) | Perbaikan besar |
| `/uang-khas` | View kondisional role | Perbaikan besar |
| `/menu` | Navigasi real ke screen yang ada | Perbaikan besar |
| `/` | Beranda — data dari AppSession | Perbaikan besar |

### P3 — Admin Pelengkap

| Route | Screen | Jenis |
|-------|--------|-------|
| `/admin/poin` | Kelola Poin Anggota | Baru |
| `/admin/keuangan` | Rekap & Export Keuangan | Baru |
| `/admin/periode/jabatan` | Assign Jabatan | Baru |
| `/admin/periode` | Kelola Periode Kepengurusan | Baru |
| `/menu/notifikasi` | Notifikasi Settings | Baru |
| `/or/status` | OR Status — ID-based lookup | Perbaikan besar |
| `/kegiatan/riwayat` | Riwayat Kegiatan — data dinamis | Perbaikan besar |
| `/fitur` | Filter section per level | Perbaikan besar |

### P4 — Nice-to-Have

| Route | Screen | Jenis |
|-------|--------|-------|
| `/admin/log` | Log Aktivitas Sistem | Baru |
| `/fitur/bidang` | Info Internal Bidang | Baru |
| `/menu/tentang` | Tentang Aplikasi | Baru |

---

## 7. Urutan Pengerjaan yang Disarankan

```
Sprint 1 — Auth & Profil Dasar (P1)
  1. /forgot-password          → Lupa Password
  2. /pending                  → Pending Verifikasi
  3. /profil/edit              → Edit Profil
  4. Login screen              → tombol "Lupa Password?" → navigasi real
  5. Menu Setelan              → navigasi real: Edit Profil, Notifikasi, Tentang

Sprint 2 — Fix Data Layer Screen Utama (P1-P2)
  6. anggota_data.dart         → centralize kMemberList
  7. /anggota/:id              → ID-based lookup
  8. /berita/:id               → konten dari kBeritaList
  9. Beranda                   → user card dari AppSession + berita dari kBeritaList
 10. Fitur Screen              → filter section per AppSession.level

Sprint 3 — Admin Konten & Verifikasi (P2)
 11. /admin/verifikasi         → Verifikasi Anggota Baru
 12. /admin/berita             → Kelola Berita
 13. /admin/pengumuman/buat    → Kirim Pengumuman

Sprint 4 — Admin Kegiatan & Keuangan (P2)
 14. /admin/qr-generator       → Generator QR Absensi
 15. /admin/kegiatan           → Kelola Semua Kegiatan
 16. /admin/uang-khas          → Uang Khas Semua Anggota
 17. /admin/uang-khas/verifikasi → Verifikasi Pembayaran
 18. /uang-khas                → kondisikan view user vs Bendahara

Sprint 5 — Admin Pengguna & Poin (P2-P3)
 19. /admin/users              → Kelola Akun Pengguna
 20. /admin/poin               → Kelola Poin Anggota
 21. /admin/periode/jabatan    → Assign Jabatan
 22. /admin/keuangan           → Rekap & Export Keuangan

Sprint 6 — Sistem & Pelengkap (P3-P4)
 23. /admin/periode            → Kelola Periode Kepengurusan
 24. /menu/notifikasi          → Notifikasi Settings
 25. /or/status                → ID-based lookup
 26. /kegiatan/riwayat         → data dinamis dari kKegiatanList
 27. /admin/log                → Log Aktivitas Sistem
 28. /fitur/bidang             → Info Internal Bidang
 29. /absensi                  → integrasi kamera nyata (mobile_scanner)
```

---

## 8. Konvensi Screen Baru

Seluruh screen baru mengikuti konvensi yang sudah ada di project:

- **AppBar form/create:** judul di **kanan** (`Spacer() + Text(...)`), back button di kiri
- **Design system:** Neo-Centric Brutalism — border 2px `#222222`, shadow `Offset(4,4) blurRadius:0`, `BrutalistCard`, `BrutalistButton`
- **Route:** daftarkan di `app.dart` di bawah `ShellRoute` (jika pakai shell/nav); admin screen yang punya Scaffold sendiri didaftarkan sebagai nested route di bawah `/admin`
- **Mock data:** buat `k[NamaData]List` di file `[fitur]_data.dart` atau `[fitur]_models.dart` terpisah; jangan hardcode inline di widget
- **Guard akses:** cek `AppSession.level` dan/atau `AppSession.isAdmin` untuk kondisikan UI, navigasi, dan tombol yang tampil
- **GoRouter:** setiap `GoRoute` wajib punya `builder`, `pageBuilder`, atau `redirect` — gunakan `builder` (bukan `redirect`) untuk parent route yang punya child routes
