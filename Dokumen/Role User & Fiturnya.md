# Role, User & Fiturnya — POLICY CENTREPOINT

**Versi:** 3.0  
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

---

## 2. Sistem Periode Kepengurusan

Kepengurusan berjalan per **periode akademik** (contoh: 2024/2025, 2025/2026). Setiap periode:
- Dilakukan pemilihan/penunjukan pemegang jabatan baru
- Data jabatan periode lama tetap tersimpan (riwayat)
- Hanya satu periode yang berstatus **aktif** (`is_aktif = true`)
- Hak akses fitur ditentukan oleh jabatan di **periode aktif**

### Skema Database Periode

```sql
bidang      → id, nama_bidang, deskripsi
jabatan     → id, nama_jabatan, bidang_id (nullable), level_akses (1-5), kode_role
periode     → id, nama_periode, tahun_mulai, tahun_selesai, is_aktif
kepengurusan → id, user_id, jabatan_id, periode_id, tanggal_mulai, tanggal_selesai
```

---

## 3. Hierarki Akses (Level)

Sistem menggunakan **6 level akses** yang ditentukan dari jabatan di periode aktif. User yang tidak terdaftar di kepengurusan periode aktif otomatis berstatus Anggota Umum (level 1).

| Level | Kode Role | Jabatan | Catatan |
|-------|-----------|---------|---------|
| **5** | `ketua_umum` | Ketua Umum | Akses penuh semua fitur |
| **4** | `sekretaris_umum` | Sekretaris Umum | Administrasi, anggota, berita, kegiatan |
| **4** | `bendahara_umum` | Bendahara Umum | Keuangan & uang khas |
| **3** | `ketua_bidang` | Ketua Bidang (semua bidang) | Kelola bidang masing-masing |
| **2** | `anggota_bidang` | Anggota Bidang (semua bidang) | Fitur anggota + info bidang |
| **1** | `anggota_umum` | Anggota Umum | Fitur dasar saja |

> **Catatan:** Level 4 (Sekretaris & Bendahara) memiliki domain akses berbeda, bukan hierarki vertikal.

---

## 4. Matriks Fitur per Role

### 4.1 Akses Baca / View

| Fitur | Anggota Umum | Anggota Bidang | Ketua Bidang | Bendahara | Sekretaris | Ketua Umum |
|-------|:---:|:---:|:---:|:---:|:---:|:---:|
| Beranda | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Berita (baca) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Kegiatan (baca) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Daftar Anggota | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Profil Anggota Lain | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Uang Khas (milik sendiri) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Poin & Level (milik sendiri) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Leaderboard Poin | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Inbox & Pengumuman | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Absensi (riwayat milik sendiri) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Riwayat Anggota Bidang | ❌ | ✅ (bidangnya) | ✅ (bidangnya) | ❌ | ✅ | ✅ |

### 4.2 Aksi / Manage

| Fitur | Anggota Umum | Anggota Bidang | Ketua Bidang | Bendahara | Sekretaris | Ketua Umum |
|-------|:---:|:---:|:---:|:---:|:---:|:---:|
| Absensi (scan QR) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Absensi Sekret (foto) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Edit Profil Sendiri | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Generate QR Absensi** | ❌ | ❌ | ✅ (bidangnya) | ❌ | ✅ | ✅ |
| **Kelola Kegiatan** | ❌ | ❌ | ✅ (bidangnya) | ❌ | ✅ | ✅ |
| **Kelola Berita / Pengumuman** | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Kelola Uang Khas** | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ |
| **Verifikasi Pembayaran** | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ |
| **Lihat Uang Khas Semua** | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ |
| **Kelola Poin Anggota** | ❌ | ❌ | ✅ (bidangnya) | ❌ | ✅ | ✅ |
| **Kelola Data Anggota** | ❌ | ❌ | ✅ (bidangnya) | ❌ | ✅ | ✅ |
| **Kirim Pengumuman** | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Panel Admin Penuh** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Kelola Periode Kepengurusan** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Manajemen Role & Jabatan** | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |

---

## 5. Deskripsi Detail Fitur per Role

### 5.1 Anggota Umum (Level 1)
Anggota aktif UKM POLICY yang tidak sedang memegang jabatan di periode berjalan.

**Bisa:**
- Melihat beranda, berita, kegiatan, daftar anggota
- Scan QR absensi untuk kegiatan yang diikuti
- Absensi sekretariat (foto)
- Memantau status uang khas & riwayat bayar milik sendiri
- Melihat poin & level keanggotaan milik sendiri
- Melihat leaderboard poin
- Menerima & membaca inbox / pengumuman
- Edit profil pribadi

**Tidak Bisa:**
- Generate QR, kelola kegiatan, kelola anggota
- Melihat uang khas orang lain
- Manage poin
- Kirim pengumuman

---

### 5.2 Anggota Bidang (Level 2)
Anggota yang menjabat sebagai anggota dalam salah satu bidang di periode aktif.

**Tambahan dari Anggota Umum:**
- Melihat riwayat absensi & poin anggota lain di bidangnya
- Akses info internal bidang (progres kegiatan bidang)

---

### 5.3 Ketua Bidang (Level 3)
Menjabat sebagai Ketua Bidang salah satu dari 6 bidang (Pemrograman, Jaringan, Multimedia, Humas, Pengembangan, Kaderisasi).

**Tambahan dari Anggota Bidang:**
- Generate QR absensi untuk kegiatan yang diselenggarakan bidangnya
- Membuat & mengelola kegiatan untuk bidangnya
- Melihat & mengelola data absensi anggota di bidangnya
- Memberikan atau mengurangi poin anggota di bidangnya
- Approve absensi manual untuk anggota bidangnya

> **Batasan:** Hanya bisa kelola data bidangnya sendiri, tidak bidang lain.

---

### 5.4 Bendahara Umum (Level 4 — Domain Keuangan)
Pengurus inti yang bertanggung jawab atas keuangan organisasi.

**Tambahan dari Ketua Bidang:**
- Melihat status uang khas **semua anggota** (bukan hanya sendiri)
- Memperbarui status pembayaran uang khas (lunas/belum)
- Verifikasi bukti pembayaran
- Melihat rekap keuangan per bulan / per tahun
- Export laporan keuangan

> **Batasan:** Tidak bisa kelola konten (berita, kegiatan), tidak bisa generate QR, tidak bisa kelola anggota.

---

### 5.5 Sekretaris Umum (Level 4 — Domain Administrasi)
Pengurus inti yang bertanggung jawab atas administrasi dan dokumentasi organisasi.

**Tambahan dari Ketua Bidang:**
- Membuat & mengelola kegiatan untuk semua bidang
- Membuat & mengelola berita / pengumuman
- Kirim notifikasi pengumuman ke semua anggota
- Melihat & mengelola data absensi semua anggota (lintas bidang)
- Kelola data profil anggota
- Memberikan atau mengurangi poin untuk semua anggota

> **Batasan:** Tidak bisa akses keuangan/uang khas semua anggota, tidak bisa kelola periode kepengurusan.

---

### 5.6 Ketua Umum (Level 5 — Full Access)
Pimpinan tertinggi organisasi. Memiliki akses penuh ke seluruh fitur.

**Tambahan dari Sekretaris & Bendahara:**
- Seluruh akses Sekretaris Umum dan Bendahara Umum
- Kelola periode kepengurusan (buka/tutup periode, assign jabatan)
- Assign atau ubah role/jabatan anggota
- Panel Admin penuh: manajemen semua data sistem
- Melihat log aktivitas / audit trail
- Konfigurasi threshold level poin

---

## 6. Implementasi di Aplikasi

### 6.1 Cara Menentukan Role Aktif
Saat user login, aplikasi:
1. Ambil `periode` dengan `is_aktif = true`
2. Query `kepengurusan` → cari `user_id` di periode aktif
3. Jika ditemukan → ambil `jabatan.kode_role` dan `jabatan.bidang_id`
4. Jika tidak ditemukan → role = `anggota_umum`
5. Simpan ke Riverpod `currentUserProvider` untuk digunakan di seluruh app

### 6.2 Guards & Conditional UI
- Tombol admin / manage hanya dirender jika `userRole.level >= 3`
- Fitur keuangan (`bendahara_umum`) dicek via `userRole.kode == 'bendahara_umum' || level == 5`
- Batasan bidang: `jabatan.bidang_id == target.bidang_id || level >= 4`
- Menu `Panel Admin` di drawer hanya muncul untuk level ≥ 4

### 6.3 Tabel `jabatan` (Seed Data)

| id | nama_jabatan | bidang_id | level_akses | kode_role |
|----|-------------|-----------|-------------|-----------|
| 1 | Ketua Umum | NULL | 5 | `ketua_umum` |
| 2 | Sekretaris Umum | NULL | 4 | `sekretaris_umum` |
| 3 | Bendahara Umum | NULL | 4 | `bendahara_umum` |
| 4 | Ketua Bidang Pemrograman | 1 | 3 | `ketua_bidang` |
| 5 | Ketua Bidang Jaringan | 2 | 3 | `ketua_bidang` |
| 6 | Ketua Bidang Multimedia | 3 | 3 | `ketua_bidang` |
| 7 | Ketua Bidang Humas | 4 | 3 | `ketua_bidang` |
| 8 | Ketua Bidang Pengembangan | 5 | 3 | `ketua_bidang` |
| 9 | Ketua Bidang Kaderisasi | 6 | 3 | `ketua_bidang` |
| 10 | Anggota Bidang Pemrograman | 1 | 2 | `anggota_bidang` |
| 11 | Anggota Bidang Jaringan | 2 | 2 | `anggota_bidang` |
| 12 | Anggota Bidang Multimedia | 3 | 2 | `anggota_bidang` |
| 13 | Anggota Bidang Humas | 4 | 2 | `anggota_bidang` |
| 14 | Anggota Bidang Pengembangan | 5 | 2 | `anggota_bidang` |
| 15 | Anggota Bidang Kaderisasi | 6 | 2 | `anggota_bidang` |
| 16 | Anggota Umum | NULL | 1 | `anggota_umum` |

---

## 7. Navigasi & UI per Role

### 7.1 Bottom Navigation Bar
Sama untuk semua role (5 tab):
`Beranda | Berita | Kegiatan | Menu | Absensi`

### 7.2 Drawer Navigasi
Semua role mendapat akses ke drawer. Item yang ditampilkan tergantung level:

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

### 7.3 AppBar Actions
- Level 1–2: Inbox icon + standard nav
- Level 3–5: Inbox icon + badge notif admin

---

## 8. Ringkasan Cepat

```
Ketua Umum        → Semua fitur, semua data, kelola sistem
Sekretaris Umum   → Konten + anggota + kegiatan semua bidang
Bendahara Umum    → Uang khas semua anggota
Ketua Bidang      → Kegiatan + absensi + poin bidangnya
Anggota Bidang    → View bidangnya + fitur anggota standar
Anggota Umum      → Fitur dasar: baca, scan, pantau sendiri
```
