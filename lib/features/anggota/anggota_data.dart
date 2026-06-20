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
    role: 'Senior Policy Analyst',
    division: 'Riset',
    tier: 'Gold',
    nim: '20210001',
    email: 'ahmad.ridhwan@email.com',
    phone: '+62 812 3456 7890',
    angkatan: '2021',
    poin: '1250',
    kegiatanCount: '42',
    kehadiranRate: '95%',
    recentActivities: [
      ('Pelatihan Advokasi', '5 Okt 2023', true),
      ('Musyawarah Q3', '10 Okt 2023', true),
      ('Workshop Penulisan', '20 Agu 2023', false),
    ],
  ),
  Member(
    id: '2',
    name: 'Siti Nurhaliza',
    role: 'Policy Writer',
    division: 'Publikasi',
    tier: 'Silver',
    nim: '20210002',
    email: 'siti.nurhaliza@email.com',
    phone: '+62 812 9876 5432',
    angkatan: '2021',
    poin: '950',
    kegiatanCount: '35',
    kehadiranRate: '88%',
    recentActivities: [
      ('Workshop Penulisan', '20 Agu 2023', true),
      ('Pelatihan Advokasi', '5 Okt 2023', false),
      ('Rapat Mingguan', '12 Okt 2023', true),
    ],
  ),
  Member(
    id: '3',
    name: 'Budi Santoso',
    role: 'Advocacy Lead',
    division: 'Advokasi',
    tier: 'Gold',
    nim: '20210003',
    email: 'budi.santoso@email.com',
    phone: '+62 813 1111 2222',
    angkatan: '2021',
    poin: '1300',
    kegiatanCount: '48',
    kehadiranRate: '98%',
    recentActivities: [
      ('Pelatihan Advokasi', '5 Okt 2023', true),
      ('Aksi Sosial', '2 Okt 2023', true),
      ('Musyawarah Q3', '10 Okt 2023', true),
    ],
  ),
  Member(
    id: '4',
    name: 'Dewi Purnama',
    role: 'Research Associate',
    division: 'Riset',
    tier: 'Bronze',
    nim: '20220004',
    email: 'dewi.purnama@email.com',
    phone: '+62 815 3333 4444',
    angkatan: '2022',
    poin: '550',
    kegiatanCount: '18',
    kehadiranRate: '82%',
    recentActivities: [
      ('Workshop Penulisan', '20 Agu 2023', true),
      ('Rapat Mingguan', '12 Okt 2023', false),
    ],
  ),
  Member(
    id: '5',
    name: 'Faisal Hakim',
    role: 'Communications',
    division: 'Publikasi',
    tier: 'Silver',
    nim: '20220005',
    email: 'faisal.hakim@email.com',
    phone: '+62 819 5555 6666',
    angkatan: '2022',
    poin: '800',
    kegiatanCount: '28',
    kehadiranRate: '90%',
    recentActivities: [
      ('Workshop Penulisan', '20 Agu 2023', true),
      ('Rapat Mingguan', '12 Okt 2023', true),
    ],
  ),
  Member(
    id: '6',
    name: 'Rini Wulandari',
    role: 'Project Manager',
    division: 'Kegiatan',
    tier: 'Gold',
    nim: '20210006',
    email: 'rini.wulandari@email.com',
    phone: '+62 811 7777 8888',
    angkatan: '2021',
    poin: '1400',
    kegiatanCount: '50',
    kehadiranRate: '100%',
    recentActivities: [
      ('Pelatihan Advokasi', '5 Okt 2023', true),
      ('Musyawarah Q3', '10 Okt 2023', true),
      ('Workshop Penulisan', '20 Agu 2023', true),
    ],
  ),
];
