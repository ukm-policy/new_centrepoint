# Role, User & Fiturnya — POLICY CENTREPOINT

**Versi:** 4.0  
**Tanggal:** 20 Juni 2026  
**Status:** In Development

---

## 1. Struktur Organisasi UKM POLICY

UKM POLICY adalah Unit Kegiatan Mahasiswa yang berfokus pada bidang teknologi informasi dan kebijakan digital. Struktur kepengurusan berjalan per **periode** (1 tahun akademik). Setiap pergantian periode, pemegang posisi berganti dan tercatat di database dengan keterangan periode aktif.

### 1.1 Bagan Struktur Kepengurusan

```
                    ┌─────────────────┐
                    │   Ketua Umum    │
                    └────────┬────────┘
             ┌───────────────┼───────────────┐
    ┌─────────┴────────┐              ┌──────┴──────────┐
    │ Sekretaris Umum  │              │ Bendahara Umum  │
    └──────────────────┘              └─────────────────┘
             │
    ┌────────┴──────────────────────────────────────────────────────┐
    │                    BIDANG-BIDANG                               │
    ├──────────────┬──────────┬───────────┬────────┬────────────────┤
    │  Pemrograman │ Jaringan │ Multimedia│  Humas │ Pengembangan   │ Kaderisasi
    │  Ketua+      │ Ketua+   │ Ketua+    │ Ketua+ │ Ketua+         │ Ketua+
    │  Anggota     │ Anggota  │ Anggota   │ Anggota│ Anggota        │ Anggota
    └──────────────┴──────────┴───────────┴────────┴────────────────┘
             │
    ┌────────┴──────────┐
    │   Anggota Umum    │  (Bukan pengurus aktif periode berjalan)
    └───────────────────┘
```

### 1.2 Daftar Jabatan & Bidang

#### Pengurus Inti (Badan Pengurus Harian)
| Jabatan | Singkatan | Jumlah |
|---------|-----------|--------|
| Ketua Umum | KU | 1 |
| Sekretaris Umum | SU | 1 |
| Bendahara Umum | BU | 1 |

#### Pengurus Bidang
| Bidang | Deskripsi |
|--------|-----------|
| **Pemrograman** | Pengembangan software, coding, aplikasi |
| **Jaringan** | Infrastruktur jaringan, server, keamanan siber |
| **Multimedia** | Desain grafis, video, konten kreatif |
| **Humas** | Hubungan masyarakat, media sosial, publikasi eksternal |
| **Pengembangan** | Riset, inovasi, pengembangan SDM anggota |
| **Kaderisasi** | Rekrutmen, orientasi, pembinaan anggota baru |

Setiap bidang memiliki:
- 1 orang **Ketua Bidang (Kabid)**
- Beberapa orang **Anggota Bidang**

#### Non-Pengurus
| Status | Keterangan |
|--------|------------|
| **Anggota Umum** | Anggota aktif UKM POLICY yang tidak memegang jabatan di periode berjalan |
| **User Public** | Pengguna yang telah mendaftar akun tetapi belum diverifikasi sebagai anggota oleh pengurus |

---

## 2. Sistem Periode Kepengurusan

Kepengurusan berjalan per **periode akademik** (contoh: 2024/2025, 2025/2026). Setiap periode:
- Dilakukan pemilihan/penunjukan pemegang jabatan baru
- Data jabatan periode lama tetap tersimpan (riwayat)
- Hanya satu periode yang berstatus **aktif** (`is_aktif = true`)
- Hak akses fitur ditentukan oleh jabatan di **periode aktif**

### Skema Database Periode

```sql
bidang       → id, nama_bidang, deskripsi
jabatan      → id, nama_jabatan, bidang_id (nullable), level_akses (1-5), kode_role
periode      → id, nama_periode, tahun_mulai, tahun_selesai, is_aktif
kepengurusan → id, user_id, jabatan_id, periode_id, tanggal_mulai, tanggal_selesai
```

---

## 3. Hierarki Akses (Level)

Sistem menggunakan **8 level/posisi akses** (termasuk Demisioner). Level 0 adalah User Public (belum terverifikasi). Level 1–5 ditentukan dari jabatan di periode aktif. User yang merupakan alumni atau mantan pengurus berstatus Demisioner (level 1 dengan role `demisioner`), sedangkan anggota biasa non-pengurus berstatus Anggota Umum (level 1).

| Level | Kode Role | Jabatan | Catatan |
|-------|-----------|---------|---------|
| **5** | `ketua_umum` | Ketua Umum | Akses penuh semua fitur |
| **4** | `sekretaris_umum` | Sekretaris Umum | Administrasi, anggota, berita, kegiatan |
| **4** | `bendahara_umum` | Bendahara Umum | Keuangan & uang khas |
| **3** | `ketua_bidang` | Ketua Bidang (semua bidang) | Kelola bidang masing-masing |
| **2** | `anggota_bidang` | Anggota Bidang (semua bidang) | Fitur anggota + info bidang |
| **1** | `anggota_umum` | Anggota Umum | Fitur dasar saja |
| **1** | `demisioner` | Demisioner | Alumni/mantan pengurus, bebas iuran khas, read-only |
| **0** | `user_public` | — (belum terverifikasi) | Hanya akses profil & menunggu verifikasi |

> **Catatan:** Level 4 (Sekretaris & Bendahara) memiliki domain akses berbeda, bukan hierarki vertikal.  
> **Catatan:** `isAdmin` adalah flag terpisah dari `level` — admin selalu bisa lihat/edit semua data.

---

## 4. Struktur Kepanitiaan Kegiatan

Setiap kegiatan/event memiliki dua lapisan kepanitiaan:

### 4.1 Panitia Inti
| Posisi | Keterangan |
|--------|------------|
| **Ketua Pelaksana** | Penanggung jawab utama kegiatan |
| **Sekretaris Pelaksana** | Administrasi & dokumentasi kegiatan |
| **Bendahara Pelaksana** | Keuangan & anggaran kegiatan |

### 4.2 Susunan Sie (Dinamis)
Satu kegiatan dapat memiliki banyak Sie. Setiap Sie terdiri dari:
- **Nama Sie** (mis. Sie Acara, Sie Konsumsi, Sie Perlengkapan, Sie Dokumentasi)
- 1 orang **Ketua Sie**
- N orang **Anggota Sie**

Posisi dalam kepanitiaan kegiatan menentukan visibilitas rapat terkait kegiatan tersebut.

---

## 5. Matriks Fitur per Role

### 5.1 Akses Baca / View

| Fitur | User Public | Demisioner | Anggota Umum | Anggota Bidang | Ketua Bidang | Bendahara | Sekretaris | Ketua Umum |
|-------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Beranda (terbatas) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Profil Sendiri | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Berita & Pengumuman | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| List Acara (Kegiatan) | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Detail Kegiatan | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Riwayat Kegiatan | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| List Rapat (hanya yg relevan) | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Detail Rapat (hanya yg relevan) | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Daftar Anggota | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Profil Anggota Lain | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Uang Khas (milik sendiri) | ❌ | ❌ (Bebas) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Poin & Level (milik sendiri) | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Leaderboard Poin | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Inbox & Pengumuman | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Absensi (riwayat milik sendiri) | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Riwayat Anggota Bidang | ❌ | ❌ | ❌ | ✅ (bidangnya) | ✅ (bidangnya) | ❌ | ✅ | ✅ |
| Semua Rapat (tanpa filter) | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ (isAdmin) |

### 5.2 Aksi / Manage

| Fitur | User Public | Demisioner | Anggota Umum | Anggota Bidang | Ketua Bidang | Bendahara | Sekretaris | Ketua Umum |
|-------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Edit Profil Sendiri | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Absensi (scan QR) | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Absensi Sekret (foto) | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Buat Kegiatan** | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Buat Rapat** (tipe terbatas) | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Edit Kegiatan** | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Edit Rapat** | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ |
| **Generate QR Absensi** | ❌ | ❌ | ❌ | ❌ | ✅ (bidangnya) | ❌ | ✅ | ✅ |
| **Kelola Kegiatan (Admin)** | ❌ | ❌ | ❌ | ❌ | ✅ (bidangnya) | ❌ | ✅ | ✅ |
| **Buat Rapat Stakeholder Org** | ❌ | ❌ | ❌ | ❌ | ✅ (dgn kabid) | ✅ | ✅ | ✅ |
| **Buat Rapat Internal Bidang** | ❌ | ❌ | ❌ | ❌ | ✅ (bidangnya) | ❌ | ✅ | ✅ |
| **Tambah Notulensi Rapat** | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ |
| **Kelola Berita / Pengumuman** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Kelola Uang Khas** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ |
| **Verifikasi Pembayaran** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ |
| **Lihat Uang Khas Semua** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ |
| **Kelola Poin Anggota** | ❌ | ❌ | ❌ | ❌ | ✅ (bidangnya) | ❌ | ✅ | ✅ |
| **Kelola Data Anggota** | ❌ | ❌ | ❌ | ❌ | ✅ (bidangnya) | ❌ | ✅ | ✅ |
| **Kirim Pengumuman** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Verifikasi & Promosi User Public** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Panel Admin Penuh** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Kelola Periode Kepengurusan** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Manajemen Role & Jabatan** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |

---

## 6. Sistem Rapat — Visibilitas & Akses per Tipe

### 6.1 Lima Jenis Rapat

| Tipe | Nama | Peserta Default |
|------|------|----------------|
| `rapatUmumAcara` | Rapat Umum Acara | Semua panitia kegiatan (Inti + semua Sie) |
| `rapatStakeholderAcara` | Rapat Stakeholder Acara | Ketua, Sekretaris, Bendahara Pelaksana saja |
| `rapatSie` | Rapat Internal Sie | Ketua Sie + Anggota Sie dari satu Sie tertentu |
| `rapatStakeholderOrg` | Rapat Stakeholder Org | KU + SU + BU, opsional + semua Ketua Bidang |
| `rapatInternalBidang` | Rapat Internal Bidang | Semua anggota satu bidang tertentu |

### 6.2 Aturan Visibilitas Rapat

| Tipe | Siapa yang Bisa Melihat |
|------|------------------------|
| `rapatUmumAcara` | Panitia Inti kegiatan terkait (Ketua/Sekretaris/Bendahara Pelaksana) |
| `rapatStakeholderAcara` | Panitia Inti kegiatan terkait |
| `rapatSie` | Ketua Sie atau Anggota Sie dari Sie yang disebutkan di kegiatan terkait |
| `rapatStakeholderOrg` | level ≥ 4 (KU/SU/BU), atau level == 3 jika `denganKetuaBidang = true` |
| `rapatInternalBidang` | Anggota dengan `bidang == namaBidang` dan level ≥ 2 |
| Semua | `isAdmin = true` → selalu tampil |

### 6.3 Akses Buat Rapat per Level

| Level | Tipe Rapat yang Bisa Dibuat |
|-------|---------------------------|
| `isAdmin` / level ≥ 4 | Semua 5 tipe |
| level == 3 (Ketua Bidang) | `rapatUmumAcara`, `rapatStakeholderAcara`, `rapatSie`, `rapatStakeholderOrg` (dengan Ketua Bidang), `rapatInternalBidang` (bidangnya) |
| level ≥ 1 (Anggota Umum / Anggota Bidang) | `rapatUmumAcara`, `rapatSie` |
| level 0 (User Public) | Tidak bisa |

---

## 7. Deskripsi Detail Fitur per Role

### 7.0 User Public (Level 0)
Pengguna yang telah mengunduh aplikasi dan mendaftarkan akun, **namun belum diverifikasi** oleh pengurus sebagai anggota resmi UKM POLICY.

**Bisa:**
- Login & logout
- Melihat & mengedit profil pribadi (nama, foto)
- Melihat halaman "Menunggu Verifikasi"
- Mengubah password

**Tidak Bisa:**
- Mengakses seluruh data internal organisasi (kegiatan, anggota, rapat, uang khas, dll.)

---

### 7.1 Anggota Umum (Level 1)

**Bisa:**
- Melihat beranda, berita, kegiatan, daftar anggota
- Scan QR absensi
- Memantau uang khas & poin milik sendiri
- Inbox / pengumuman
- **Membuat kegiatan** (baru di v4.0)
- **Membuat rapat** (tipe `rapatUmumAcara` & `rapatSie`)
- **Melihat rapat** yang relevan (jika menjadi panitia/anggota sie kegiatan)

**Tidak Bisa:**
- Edit kegiatan orang lain
- Generate QR, kelola anggota, kirim pengumuman

---

### 7.1a Demisioner (Level 1 — Special)
Mantan pengurus atau alumni UKM POLICY yang diberikan akses arsip untuk memantau kemajuan organisasi.

**Bisa:**
- Melihat beranda, berita, kegiatan, daftar anggota
- Melihat inbox / pengumuman
- Melihat riwayat kegiatan & poin keaktifan masa lalunya secara read-only
- Dibebaskan (exempt) dari kewajiban iuran uang khas organisasi

**Tidak Bisa:**
- Melakukan absensi (scan QR maupun foto sekret)
- Membuat atau mengedit kegiatan dan rapat
- Mengakses panel admin atau dashboard pengelolaan kepengurusan aktif

---

### 7.2 Anggota Bidang (Level 2)

**Tambahan dari Anggota Umum:**
- Melihat riwayat absensi & poin anggota lain di bidangnya
- Akses info internal bidang
- **Edit kegiatan** (baru di v4.0)
- Melihat rapat internal bidangnya (jika `bidang` sesuai)

---

### 7.3 Ketua Bidang (Level 3)

**Tambahan dari Anggota Bidang:**
- Generate QR absensi untuk kegiatan bidangnya
- Membuat & mengelola kegiatan untuk bidangnya
- Melihat & mengelola data absensi anggota di bidangnya
- Memberikan atau mengurangi poin anggota di bidangnya
- **Edit & tambah notulensi rapat** (baru di v4.0)
- **Buat rapat** (semua tipe yang relevan dengan bidang dan kegiatan)
- Diundang ke `rapatStakeholderOrg` jika `denganKetuaBidang = true`

---

### 7.4 Bendahara Umum (Level 4 — Domain Keuangan)

**Tambahan:**
- Melihat status uang khas **semua anggota**
- Memperbarui status pembayaran uang khas
- Export laporan keuangan
- **Buat semua jenis rapat** termasuk `rapatStakeholderOrg`
- Otomatis diundang ke semua `rapatStakeholderOrg`

---

### 7.5 Sekretaris Umum (Level 4 — Domain Administrasi)

**Tambahan:**
- Membuat & mengelola kegiatan untuk semua bidang
- Membuat & mengelola berita / pengumuman
- Kirim notifikasi pengumuman ke semua anggota
- Melihat & mengelola data absensi semua anggota
- Kelola data profil anggota
- Memberikan atau mengurangi poin untuk semua anggota
- **Buat semua jenis rapat** termasuk `rapatStakeholderOrg`
- Otomatis diundang ke semua `rapatStakeholderOrg`

---

### 7.6 Ketua Umum (Level 5 — Full Access)

**Tambahan dari Sekretaris & Bendahara:**
- Seluruh akses Sekretaris Umum dan Bendahara Umum
- Kelola periode kepengurusan (buka/tutup periode, assign jabatan)
- Panel Admin penuh
- `isAdmin = true` → melihat semua rapat tanpa filter

---

## 8. Implementasi di Aplikasi

### 8.1 Cara Menentukan Role Aktif
1. Cek `users.status`:
   - `'pending'` → role = `user_public` (level 0) → tampilkan pending screen
   - `'active'` → lanjut ke langkah 2
2. Query `kepengurusan` di periode aktif
3. Jika ditemukan → ambil `kode_role`, `level_akses`, `bidang_id`
4. Jika tidak ditemukan → role = `anggota_umum` (level 1)
5. Simpan ke Riverpod `currentUserProvider`

### 8.2 Guards & Conditional UI
- **User Public (level 0):** redirect ke pending screen via GoRouter redirect
- **Tombol Buat Kegiatan / Buat Rapat:** tampil jika `level >= 1`
- **Tombol Edit Kegiatan:** tampil jika `isAdmin || level >= 2`
- **Tombol Edit Rapat / Tambah Notulensi:** tampil jika `isAdmin || level >= 3`
- **List Rapat:** difilter via `isRapatVisible(rapat)` sebelum ditampilkan
- Menu admin di drawer hanya muncul untuk level ≥ 4

### 8.3 Mock Session (Development)
```dart
class AppSession {
  static bool isAdmin = true;
  static int level = 5;          // ketua_umum
  static String nama = 'Ahmad Rizky Pratama';
  static String bidang = '-';
}
```

### 8.4 Tabel `jabatan` (Seed Data)

| id | nama_jabatan | bidang_id | level_akses | kode_role |
|----|-------------|-----------|-------------|-----------|
| 1 | Ketua Umum | NULL | 5 | `ketua_umum` |
| 2 | Sekretaris Umum | NULL | 4 | `sekretaris_umum` |
| 3 | Bendahara Umum | NULL | 4 | `bendahara_umum` |
| 4–9 | Ketua Bidang (6 bidang) | 1–6 | 3 | `ketua_bidang` |
| 10–15 | Anggota Bidang (6 bidang) | 1–6 | 2 | `anggota_bidang` |
| 16 | Anggota Umum | NULL | 1 | `anggota_umum` |

---

## 9. Navigasi & UI per Role

### 9.1 Bottom Navigation Bar
- **User Public (level 0):** Tidak memiliki Bottom Nav. Hanya tampil halaman pending.
- **Level 1–5:** 4 tab utama + FAB Absensi: `Beranda | Kegiatan | [QR FAB] | Fitur | Menu`

### 9.2 Drawer Navigasi

| Item Drawer | Level Min |
|-------------|-----------|
| Beranda | 1 |
| Berita | 1 |
| Kegiatan | 1 |
| Absensi | 1 |
| Uang Khas | 1 |
| Anggota | 1 |
| Poin Keaktifan | 1 |
| Setelan | 1 |
| **Kelola Kegiatan** | 3 |
| **Kelola Berita** | 4 (Sekretaris/KU) |
| **Kelola Uang Khas** | 4 (Bendahara/KU) |
| **Panel Admin** | 4 |

### 9.3 Layar Kegiatan — Navigasi

```
/kegiatan             → ListKegiatanScreen (Tab Acara + Tab Rapat)
  AppBar trailing     → /kegiatan/riwayat
  FAB (Tab Acara)     → /kegiatan/buat
  FAB (Tab Rapat)     → /kegiatan/rapat/buat
  Tap card Acara      → /kegiatan/:id
  Tap card Rapat      → /kegiatan/rapat/:id
```

---

## 10. Ringkasan Cepat

```
Ketua Umum        → Semua fitur, semua rapat, kelola sistem (isAdmin)
Sekretaris Umum   → Konten + anggota + kegiatan semua bidang + semua rapat + verifikasi user
Bendahara Umum    → Uang khas semua anggota + semua rapat
Ketua Bidang      → Kegiatan + absensi + poin bidangnya + buat rapat kegiatan/bidang
Anggota Bidang    → View bidangnya + fitur anggota + edit kegiatan + rapat bidang
Anggota Umum      → Fitur dasar + buat kegiatan + buat rapat relevan + lihat rapat relevan
Demisioner        → Akses arsip berita & kegiatan, bebas iuran khas, read-only profil & anggota
User Public       → Profil saja, menunggu verifikasi pengurus
```
