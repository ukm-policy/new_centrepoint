# Planning Model Data — Centrepoint

> Tujuan: Mengganti semua data hardcoded di setiap screen menjadi data yang bersumber dari Model Data terstruktur. Tahap awal menggunakan dummy data sesuai struktur model, siap di-replace dengan API/database di tahap berikutnya.

---

## Prinsip Desain

- Setiap model disimpan di `lib/data/models/` sebagai file dart tersendiri
- Dummy data disimpan di `lib/data/dummy/` (bukan di dalam screen file)
- Provider/state management akan membaca dari dummy data di tahap ini
- Semua field nullable diberi nilai default yang masuk akal pada dummy
- ID menggunakan `String` (siap untuk UUID dari backend)

---

## Struktur Direktori Target

```
lib/
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── member_model.dart
│   │   ├── berita_model.dart
│   │   ├── kegiatan_model.dart
│   │   ├── rapat_model.dart
│   │   ├── absensi_model.dart
│   │   ├── poin_model.dart
│   │   ├── uang_khas_model.dart
│   │   ├── inbox_model.dart
│   │   ├── or_model.dart
│   │   └── periode_model.dart
│   └── dummy/
│       ├── dummy_users.dart
│       ├── dummy_members.dart
│       ├── dummy_berita.dart
│       ├── dummy_kegiatan.dart
│       ├── dummy_rapat.dart
│       ├── dummy_absensi.dart
│       ├── dummy_poin.dart
│       ├── dummy_uang_khas.dart
│       ├── dummy_inbox.dart
│       ├── dummy_or.dart
│       └── dummy_periode.dart
```

---

## Model 1: `UserModel` (user_model.dart)

Dipakai di: `AppSession`, `LoginScreen`, `EditProfileScreen`, `CompleteProfileScreen`, semua screen yang menampilkan nama/role user.

```dart
class UserModel {
  final String id;
  final String nama;
  final String email;
  final String nim;
  final String noHp;
  final String prodi;
  final String angkatan;       // contoh: '2023'
  final String role;           // 'anggota' | 'staff' | 'ketua' | 'demisioner' | 'admin'
  final String? bidang;        // 'Pemrograman' | 'Jaringan' | 'Multimedia' | 'Pengembangan' | 'Kaderisasi' | 'Humas' | null
  final String? jabatan;       // null jika tidak ada jabatan khusus
  final String? avatarUrl;
  final bool isVerified;
  final DateTime createdAt;
}
```

**Dummy:** 1 user sesi aktif + beberapa user untuk kelola akun admin.

---

## Model 2: `MemberModel` (member_model.dart)

Dipakai di: `ListMembersScreen`, `DetailMemberScreen`, `KelolaPoinScreen`, `AssignJabatanScreen`, `VerifikasiAnggotaScreen`.

Catatan: Refactor dari `Member` yang sudah ada di `anggota_data.dart` ke model terpusat.

```dart
class MemberModel {
  final String id;
  final String nama;
  final String nim;
  final String email;
  final String noHp;
  final String prodi;
  final String angkatan;
  final String role;           // sama dengan UserModel.role
  final String? bidang;        // 'Pemrograman' | 'Jaringan' | 'Multimedia' | 'Pengembangan' | 'Kaderisasi' | 'Humas' | null
  final String? jabatan;
  final String tier;           // 'Gold' | 'Silver' | 'Bronze' | 'Member'
  final int totalPoin;
  final int kegiatanCount;
  final double kehadiranRate;  // 0.0 - 1.0
  final bool isActive;
  final String? avatarUrl;
}
```

**Dummy:** 10 anggota dengan variasi bidang, tier, dan role.

---

## Model 3: `BeritaModel` (berita_model.dart)

Dipakai di: `BerandaScreen` (banner + latest news), `ListBeritaScreen`, `DetailBeritaScreen`, `KelolaBeritaScreen`.

Catatan: Refactor dari `BeritaItem` di `berita_data.dart`.

```dart
class BeritaModel {
  final String id;
  final String judul;
  final String kategori;       // 'Berita' | 'Pengumuman'
  final String konten;
  final String? thumbnailUrl;
  final String penulisId;      // ref ke UserModel.id
  final String penulisNama;    // denormalized untuk display
  final DateTime tanggalPublish;
  final bool isDraft;
}
```

**Dummy:** 6 item (4 Berita + 2 Pengumuman), 2 di antaranya draft.

---

## Model 4: `KegiatanModel` (kegiatan_model.dart)

Dipakai di: `ListKegiatanScreen`, `DetailKegiatanScreen`, `CreateKegiatanScreen`, `KelolaKegiatanScreen`, `BerandaScreen` (quick access count).

Catatan: Refactor dari `KegiatanItem` + `PanitiaItem` + `SieItem` di `kegiatan_models.dart`.

```dart
class PanitiaModel {
  final String memberId;       // ref ke MemberModel.id
  final String nama;           // denormalized
  final String nim;            // denormalized
}

class SieModel {
  final String namaSie;
  final PanitiaModel ketua;
  final List<PanitiaModel> anggota;
}

class KegiatanModel {
  final String id;
  final String judul;
  final String deskripsi;
  final DateTime tanggal;
  final String waktu;          // contoh: '09.00 – 12.00 WIB'
  final String lokasi;
  final String status;         // 'Akan Datang' | 'Berlangsung' | 'Selesai' | 'Dibatalkan'
  final int kuota;
  final int pesertaTerdaftar;
  final PanitiaModel ketuaPelaksana;
  final PanitiaModel sekretarisPelaksana;
  final PanitiaModel bendaharaPelaksana;
  final List<SieModel> sie;
  final String periodeId;      // ref ke PeriodeModel.id
}
```

**Dummy:** 5 kegiatan (variasi status dan jumlah sie).

---

## Model 5: `RapatModel` (rapat_model.dart)

Dipakai di: `ListKegiatanScreen` (tab Rapat), `DetailRapatScreen`, `CreateRapatScreen`.

Catatan: Refactor dari `RapatItem` + `AgendaItem` di `rapat_models.dart`.

```dart
enum RapatTipe {
  rapatUmumAcara,
  rapatStakeholderAcara,
  rapatSie,
  rapatStakeholderOrg,
  rapatInternalBidang,
}

enum RapatStatus { terjadwal, berlangsung, selesai, dibatalkan }

class AgendaModel {
  final String judul;
  final String keterangan;
}

class RapatModel {
  final String id;
  final String judul;
  final RapatTipe tipe;
  final RapatStatus status;
  final DateTime tanggal;
  final String waktu;
  final String lokasi;
  final List<AgendaModel> agenda;
  final List<String> pesertaIds;    // ref ke MemberModel.id
  final String? notulensi;
  final String? kegiatanId;         // null jika rapat org (bukan acara)
  final String? namaSie;            // diisi jika tipe rapatSie
  final String? namaBidang;         // diisi jika tipe rapatInternalBidang
  final bool denganKetuaBidang;
}
```

**Dummy:** 8 rapat dengan berbagai tipe dan status.

---

## Model 6: `AbsensiModel` (absensi_model.dart)

Dipakai di: `AbsensiScreen`, `RiwayatSekretScreen`.

```dart
enum StatusAbsensi { hadir, izin, absen, belumAbsen }

class AbsensiModel {
  final String id;
  final String memberId;          // ref ke MemberModel.id
  final String memberNama;        // denormalized
  final String kegiatanId;        // ref ke KegiatanModel.id atau RapatModel.id
  final String kegiatanJudul;     // denormalized
  final String tipeKegiatan;      // 'kegiatan' | 'rapat'
  final StatusAbsensi status;
  final DateTime? waktuScan;      // null jika belum absen
  final String? keterangan;       // diisi jika izin
}

class QrSessionModel {
  final String id;
  final String kegiatanId;
  final String kegiatanJudul;
  final DateTime tanggal;
  final DateTime expiredAt;
  final bool isActive;
}
```

**Dummy:** 15 record absensi dari berbagai kegiatan + 2 QR session.

---

## Model 7: `PoinModel` (poin_model.dart)

Dipakai di: `PoinScreen` (riwayat + leaderboard), `KelolaPoinScreen`, `DetailMemberScreen`.

```dart
enum TipePoin { hadir, absen, panitia, bonus, penalti }

class PoinEntryModel {
  final String id;
  final String memberId;       // ref ke MemberModel.id
  final String memberNama;     // denormalized
  final String label;          // deskripsi aktivitas
  final TipePoin tipe;
  final int poin;              // bisa negatif untuk penalti/absen
  final DateTime tanggal;
  final String? kegiatanId;   // opsional, jika terkait kegiatan
}

class LeaderboardEntryModel {
  final int rank;
  final String memberId;
  final String memberNama;
  final String? divisi;
  final int totalPoin;
  final String tier;           // 'Gold' | 'Silver' | 'Bronze' | 'Member'
}
```

**Dummy:** 15 poin entry untuk beberapa member + leaderboard 10 besar.

---

## Model 8: `UangKhasModel` (uang_khas_model.dart)

Dipakai di: `UangKhasScreen`, `UangKhasAdminScreen`, `VerifikasiKhasScreen`, `RekapKeuanganScreen`.

```dart
enum StatusBayar { lunas, belumBayar, pending }

class UangKhasBulanModel {
  final String id;
  final String memberId;
  final String bulan;          // 'Januari 2026', dst
  final int tahun;
  final int nominal;           // dalam Rupiah
  final StatusBayar status;
  final DateTime? tanggalBayar;
  final String? buktiUrl;      // URL bukti transfer
  final bool isVerified;
}

class TransaksiKhasModel {
  final String id;
  final String label;
  final DateTime tanggal;
  final int jumlah;
  final bool isPemasukan;      // true = pemasukan, false = pengeluaran
  final bool isPending;
  final String? keterangan;
}
```

**Dummy:** Status 12 bulan untuk user sesi + 8 transaksi kas.

---

## Model 9: `InboxModel` (inbox_model.dart)

Dipakai di: `InboxScreen`, `DetailPengumumanScreen`.

Catatan: Refactor dari `InboxNotifItem` + `InboxPengumumanItem` di `inbox_data.dart`.

```dart
enum TipeNotif { poin, kegiatan, absensi, uangKhas, sistem, pengumuman }

class NotifModel {
  final String id;
  final TipeNotif tipe;
  final String judul;
  final String isi;
  final DateTime waktu;
  final bool isRead;
  final String? route;         // deep link route dalam app
}

class PengumumanModel {
  final String id;
  final String kategori;       // 'PENTING' | 'KEGIATAN' | 'KEUANGAN' | 'REKRUTMEN' | 'PRESTASI'
  final String judul;
  final String ringkasan;      // satu paragraf singkat
  final List<String> konten;   // list paragraf
  final DateTime tanggal;
  final bool isNew;
  final String? actionLabel;
  final String? actionRoute;
}
```

**Dummy:** 8 notif + 6 pengumuman dengan berbagai kategori.

---

## Model 10: `ORModel` (or_model.dart)

Dipakai di: `OrScreen`, `OrFormScreen`, `OrStatusScreen`, `OrAdminScreen`, `OrDetailScreen`, `OrKelolaScreen`.

Catatan: Refactor dari `ORPeriode` + `ORApplicant` di `or_data.dart`.

```dart
enum ORStatus { belumBuka, buka, ditutup }
enum ApplicantStatus { pending, diterima, ditolak }

class ORPeriodeModel {
  final String id;
  final String nama;           // contoh: 'OR 2026/2027'
  final DateTime tanggalBuka;
  final DateTime tanggalTutup;
  final int kuota;
  final String deskripsi;
  final List<String> bidangTersedia;  // subset dari: ['Pemrograman', 'Jaringan', 'Multimedia', 'Pengembangan', 'Kaderisasi', 'Humas']
  final bool isManuallyOpen;

  // computed
  ORStatus get status { ... }
  int get sisaHari { ... }
  int get sisaKuota { ... }    // perlu join dengan applicants
}

class ORApplicantModel {
  final String id;
  final String periodeId;      // ref ke ORPeriodeModel.id
  final String nama;
  final String nim;
  final String prodi;
  final String angkatan;
  final String noHp;
  final String bidangMinat;
  final String motivasi;
  final String pengalamanOrg;
  final ApplicantStatus status;
  final DateTime tanggalDaftar;
  final String? catatan;       // catatan reviewer
}
```

**Dummy:** 1 periode aktif + 8 pelamar dengan status bervariasi.

---

## Model 11: `PeriodeModel` (periode_model.dart)

Dipakai di: `KelolaPeriodeScreen`, semua model yang memerlukan konteks periode kepengurusan.

```dart
class PeriodeModel {
  final String id;
  final String nama;           // contoh: 'Kepengurusan 2025/2026'
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final bool isActive;         // hanya 1 yang aktif dalam satu waktu
}
```

**Dummy:** 3 periode (1 aktif, 2 arsip).

---

## Roadmap Migrasi

### Fase 1 — Buat Model & Dummy Data
- [x] Buat semua file model di `lib/data/models/`
- [x] Pindahkan & standarisasi dummy data dari file lama ke `lib/data/dummy/`
- [x] Hapus file data lama (`anggota_data.dart`, `berita_data.dart`, `inbox_data.dart`, `kegiatan_models.dart`, `rapat_models.dart`, `or_data.dart`)
- [x] Update semua import di screen yang terpengaruh

### Fase 2 — Koneksi ke Screen via Provider
- [x] Tambahkan dependency `provider` atau `riverpod` ke `pubspec.yaml`
- [x] Buat Repository interface untuk setiap domain
- [x] Buat DummyRepository yang mengembalikan data dari `lib/data/dummy/`
- [x] Inject repository ke screen via Provider

### Fase 3 — Siap Backend (Future)
- [x] Buat ApiRepository yang implementasi interface yang sama
- [x] Tambahkan `fromJson` / `toJson` ke setiap model
- [x] Swap DummyRepository → ApiRepository tanpa mengubah screen

---

## Catatan Khusus

- **`AppSession`** — Setelah model selesai, `AppSession` harus menyimpan `UserModel` lengkap, bukan field terpisah (role, nama, dll)
- **Visibility filter Rapat** — Logic filter berdasarkan role/bidang tetap ada di screen, bukan di model
- **Inline dummy di poin_screen.dart & uang_khas_screen.dart** — Dua file ini masih punya class private (`_PoinEntry`, `_Transaksi`); keduanya harus diganti dengan model terpusat di Fase 1
- **Denormalized fields** — Field seperti `memberNama`, `kegiatanJudul` di model absensi/poin sengaja disimpan untuk menghindari join yang mahal saat masih dummy; hapus saat sudah pakai database relasional
