// Models & mock data untuk Open Recruitment

// ── Enums ─────────────────────────────────────────────────────────────────────

enum ORStatus { belumBuka, buka, ditutup }

enum ApplicantStatus { pending, diterima, ditolak }

// ── Models ────────────────────────────────────────────────────────────────────

class ORPeriode {
  const ORPeriode({
    required this.id,
    required this.nama,
    required this.tanggalBuka,
    required this.tanggalTutup,
    required this.kuota,
    required this.deskripsi,
    required this.isManuallyOpen,
  });
  final String id;
  final String nama;
  final DateTime tanggalBuka;
  final DateTime tanggalTutup;
  final int kuota;
  final String deskripsi;
  final bool isManuallyOpen; // admin bisa paksa tutup sebelum deadline

  ORStatus get status {
    if (!isManuallyOpen) return ORStatus.ditutup;
    final now = DateTime.now();
    if (now.isBefore(tanggalBuka)) return ORStatus.belumBuka;
    if (now.isAfter(tanggalTutup)) return ORStatus.ditutup;
    return ORStatus.buka;
  }

  int get sisaHari {
    final now = DateTime.now();
    return tanggalTutup.difference(now).inDays;
  }
}

class ORApplicant {
  const ORApplicant({
    required this.id,
    required this.nama,
    required this.nim,
    required this.prodi,
    required this.angkatan,
    required this.noHp,
    required this.bidangMinat,
    required this.motivasi,
    required this.pengalamanOrg,
    required this.status,
    required this.tanggalDaftar,
    this.catatan,
  });
  final String id;
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
  final String? catatan; // catatan admin saat approve/reject
}

// ── Mock Data ─────────────────────────────────────────────────────────────────

final kOrPeriode = ORPeriode(
  id: 'or-2026',
  nama: 'Open Recruitment 2026/2027',
  tanggalBuka: DateTime(2026, 6, 15),
  tanggalTutup: DateTime(2026, 7, 15),
  kuota: 30,
  isManuallyOpen: true,
  deskripsi:
      'UKM POLICY membuka kesempatan bagi mahasiswa aktif untuk bergabung sebagai '
      'anggota dalam kepengurusan periode 2026/2027. Bergabunglah dan kembangkan '
      'kemampuan di bidang teknologi informasi dan kebijakan digital bersama kami.',
);

final kBidangList = [
  'Pemrograman',
  'Jaringan',
  'Multimedia',
  'Humas',
  'Pengembangan',
  'Kaderisasi',
];

final kApplicants = <ORApplicant>[
  ORApplicant(
    id: 'app-1',
    nama: 'Rizky Aditya Pratama',
    nim: '2023010001',
    prodi: 'Teknik Informatika',
    angkatan: '2023',
    noHp: '08123456789',
    bidangMinat: 'Pemrograman',
    motivasi: 'Saya ingin mengembangkan skill pemrograman dan berkontribusi pada UKM POLICY.',
    pengalamanOrg: 'Ketua OSIS SMA, Anggota Robotika',
    status: ApplicantStatus.pending,
    tanggalDaftar: DateTime(2026, 6, 16),
  ),
  ORApplicant(
    id: 'app-2',
    nama: 'Siti Nurhaliza',
    nim: '2023010042',
    prodi: 'Sistem Informasi',
    angkatan: '2023',
    noHp: '08567891234',
    bidangMinat: 'Multimedia',
    motivasi: 'Saya tertarik desain dan ingin berkontribusi di bidang multimedia UKM POLICY.',
    pengalamanOrg: 'Anggota UKM Fotografi',
    status: ApplicantStatus.diterima,
    tanggalDaftar: DateTime(2026, 6, 16),
    catatan: 'Portfolio desain sangat baik, skill yang dibutuhkan.',
  ),
  ORApplicant(
    id: 'app-3',
    nama: 'Muhammad Fadhil',
    nim: '2024010015',
    prodi: 'Teknik Informatika',
    angkatan: '2024',
    noHp: '08112233445',
    bidangMinat: 'Jaringan',
    motivasi: 'Tertarik dengan jaringan komputer dan keamanan siber.',
    pengalamanOrg: '-',
    status: ApplicantStatus.pending,
    tanggalDaftar: DateTime(2026, 6, 17),
  ),
  ORApplicant(
    id: 'app-4',
    nama: 'Andi Wijayanti',
    nim: '2023010088',
    prodi: 'Ilmu Komunikasi',
    angkatan: '2023',
    noHp: '08998877665',
    bidangMinat: 'Humas',
    motivasi: 'Ingin mengembangkan kemampuan public relations dan media sosial.',
    pengalamanOrg: 'Staff Humas BEM Fakultas',
    status: ApplicantStatus.diterima,
    tanggalDaftar: DateTime(2026, 6, 18),
    catatan: 'Pengalaman relevan, cocok untuk bidang Humas.',
  ),
  ORApplicant(
    id: 'app-5',
    nama: 'Bagas Prayoga',
    nim: '2024010032',
    prodi: 'Manajemen Informatika',
    angkatan: '2024',
    noHp: '08234567890',
    bidangMinat: 'Pemrograman',
    motivasi: 'Suka coding sejak SMA dan ingin belajar lebih dalam di lingkungan yang supportif.',
    pengalamanOrg: '-',
    status: ApplicantStatus.ditolak,
    tanggalDaftar: DateTime(2026, 6, 19),
    catatan: 'Kuota Pemrograman sudah terpenuhi, disarankan coba periode berikutnya.',
  ),
];
