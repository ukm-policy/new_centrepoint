class Member {
  const Member({
    required this.id,
    required this.name,
    required this.role,
    required this.division,
    required this.tier,
    required this.nim,
    required this.email,
    required this.phone,
    required this.angkatan,
    required this.poin,
    required this.kegiatanCount,
    required this.kehadiranRate,
    required this.recentActivities,
  });

  final String id;
  final String name;
  final String role;
  final String division;
  final String tier;
  final String nim;
  final String email;
  final String phone;
  final String angkatan;
  final String poin;
  final String kegiatanCount;
  final String kehadiranRate;
  final List<(String, String, bool)> recentActivities;
}

const kMemberList = [
  Member(
    id: '1',
    name: 'Ahmad Ridhwan',
    role: 'Kepala Bidang Pemrograman',
    division: 'Pemrograman',
    tier: 'Gold',
    nim: '20210001',
    email: 'ahmad.ridhwan@email.com',
    phone: '+62 812 3456 7890',
    angkatan: '2021',
    poin: '1250',
    kegiatanCount: '42',
    kehadiranRate: '95%',
    recentActivities: [
      ('Workshop Flutter Lanjutan', '5 Jun 2026', true),
      ('Musyawarah Pengurus Q2', '10 Jun 2026', true),
      ('Rapat Koordinasi Bidang', '20 Mei 2026', false),
    ],
  ),
  Member(
    id: '2',
    name: 'Siti Nurhaliza',
    role: 'Staff Bidang Multimedia',
    division: 'Multimedia',
    tier: 'Silver',
    nim: '20210002',
    email: 'siti.nurhaliza@email.com',
    phone: '+62 812 9876 5432',
    angkatan: '2021',
    poin: '950',
    kegiatanCount: '35',
    kehadiranRate: '88%',
    recentActivities: [
      ('Workshop Desain Konten', '20 Mei 2026', true),
      ('Rapat Produksi Multimedia', '5 Jun 2026', false),
      ('Rapat Mingguan', '12 Jun 2026', true),
    ],
  ),
  Member(
    id: '3',
    name: 'Budi Santoso',
    role: 'Kepala Bidang Pengembangan',
    division: 'Pengembangan',
    tier: 'Gold',
    nim: '20210003',
    email: 'budi.santoso@email.com',
    phone: '+62 813 1111 2222',
    angkatan: '2021',
    poin: '1300',
    kegiatanCount: '48',
    kehadiranRate: '98%',
    recentActivities: [
      ('Pelatihan Leadership', '5 Jun 2026', true),
      ('Seminar Pengembangan Organisasi', '2 Jun 2026', true),
      ('Musyawarah Pengurus Q2', '10 Jun 2026', true),
    ],
  ),
  Member(
    id: '4',
    name: 'Dewi Purnama',
    role: 'Staff Bidang Jaringan',
    division: 'Jaringan',
    tier: 'Bronze',
    nim: '20220004',
    email: 'dewi.purnama@email.com',
    phone: '+62 815 3333 4444',
    angkatan: '2022',
    poin: '550',
    kegiatanCount: '18',
    kehadiranRate: '82%',
    recentActivities: [
      ('Workshop Networking', '20 Mei 2026', true),
      ('Rapat Mingguan', '12 Jun 2026', false),
    ],
  ),
  Member(
    id: '5',
    name: 'Faisal Hakim',
    role: 'Staff Bidang Humas',
    division: 'Humas',
    tier: 'Silver',
    nim: '20220005',
    email: 'faisal.hakim@email.com',
    phone: '+62 819 5555 6666',
    angkatan: '2022',
    poin: '800',
    kegiatanCount: '28',
    kehadiranRate: '90%',
    recentActivities: [
      ('Workshop Public Relations', '20 Mei 2026', true),
      ('Rapat Koordinasi Humas', '12 Jun 2026', true),
    ],
  ),
  Member(
    id: '6',
    name: 'Rini Wulandari',
    role: 'Kepala Bidang Kaderisasi',
    division: 'Kaderisasi',
    tier: 'Gold',
    nim: '20210006',
    email: 'rini.wulandari@email.com',
    phone: '+62 811 7777 8888',
    angkatan: '2021',
    poin: '1400',
    kegiatanCount: '50',
    kehadiranRate: '100%',
    recentActivities: [
      ('Pelantikan Anggota Baru', '5 Jun 2026', true),
      ('Musyawarah Pengurus Q2', '10 Jun 2026', true),
      ('Workshop Kaderisasi Internal', '20 Mei 2026', true),
    ],
  ),
];
