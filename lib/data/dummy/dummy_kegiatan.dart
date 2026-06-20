import '../models/kegiatan_model.dart';

final dummyKegiatan = <KegiatanModel>[
  KegiatanModel(
    id: '1',
    judul: 'Seminar Kebijakan Publik 2023',
    deskripsi: 'Seminar ini membahas kebijakan publik terkini yang berdampak pada '
        'masyarakat luas. Narasumber akan memaparkan analisis mendalam beserta '
        'rekomendasi strategis untuk perbaikan kebijakan ke depan.\n\n'
        'Peserta diharapkan membawa kartu anggota dan hadir 15 menit sebelum acara dimulai.',
    tanggal: DateTime(2023, 10, 28),
    waktu: '09.00 – 13.00 WIB',
    lokasi: 'Aula Utama Kampus',
    status: 'Akan Datang',
    kuota: 60,
    pesertaTerdaftar: 45,
    ketuaPelaksana: PanitiaModel(memberId: '3', nama: 'Budi Santoso', nim: '20210003'),
    sekretarisPelaksana: PanitiaModel(memberId: '4', nama: 'Dewi Purnama', nim: '20220004'),
    bendaharaPelaksana: PanitiaModel(memberId: '5', nama: 'Faisal Hakim', nim: '20220005'),
    periodeId: 'p-1',
    sie: [
      SieModel(
        namaSie: 'Sie Acara',
        ketua: PanitiaModel(memberId: '7', nama: 'Ahmad Rizky Pratama', nim: '2021010001'),
        anggota: [
          PanitiaModel(memberId: '1', nama: 'Ahmad Ridhwan', nim: '20210001'),
          PanitiaModel(memberId: '2', nama: 'Siti Nurhaliza', nim: '20210002'),
        ],
      ),
      SieModel(
        namaSie: 'Sie Konsumsi',
        ketua: PanitiaModel(memberId: '2', nama: 'Siti Nurhaliza', nim: '20210002'),
        anggota: [
          PanitiaModel(memberId: '5', nama: 'Faisal Hakim', nim: '20220005'),
        ],
      ),
      SieModel(
        namaSie: 'Sie Perlengkapan',
        ketua: PanitiaModel(memberId: '1', nama: 'Ahmad Ridhwan', nim: '20210001'),
        anggota: [
          PanitiaModel(memberId: '4', nama: 'Dewi Purnama', nim: '20220004'),
        ],
      ),
    ],
  ),
  KegiatanModel(
    id: '2',
    judul: 'Workshop Penulisan Naskah Kebijakan',
    deskripsi: 'Workshop intensif tentang teknik penulisan naskah kebijakan yang efektif '
        'dan terstruktur. Peserta akan langsung praktek menyusun policy brief yang '
        'komprehensif dan mudah dipahami oleh pengambil keputusan.',
    tanggal: DateTime(2023, 11, 15),
    waktu: '13.00 – 17.00 WIB',
    lokasi: 'Ruang Rapat Lt. 3',
    status: 'Akan Datang',
    kuota: 25,
    pesertaTerdaftar: 20,
    ketuaPelaksana: PanitiaModel(memberId: '6', nama: 'Rini Wulandari', nim: '20210006'),
    sekretarisPelaksana: PanitiaModel(memberId: '1', nama: 'Ahmad Ridhwan', nim: '20210001'),
    bendaharaPelaksana: PanitiaModel(memberId: '2', nama: 'Siti Nurhaliza', nim: '20210002'),
    periodeId: 'p-1',
    sie: [
      SieModel(
        namaSie: 'Sie Materi',
        ketua: PanitiaModel(memberId: '3', nama: 'Budi Santoso', nim: '20210003'),
        anggota: [
          PanitiaModel(memberId: '4', nama: 'Dewi Purnama', nim: '20220004'),
          PanitiaModel(memberId: '5', nama: 'Faisal Hakim', nim: '20220005'),
        ],
      ),
      SieModel(
        namaSie: 'Sie Dokumentasi',
        ketua: PanitiaModel(memberId: '2', nama: 'Siti Nurhaliza', nim: '20210002'),
        anggota: [
          PanitiaModel(memberId: '7', nama: 'Ahmad Rizky Pratama', nim: '2021010001'),
        ],
      ),
    ],
  ),
  KegiatanModel(
    id: '3',
    judul: 'Musyawarah Anggota Q3',
    deskripsi: 'Musyawarah anggota kuartal ketiga untuk evaluasi program kerja dan '
        'perencanaan kegiatan semester genap. Agenda: laporan bidang, evaluasi '
        'anggaran, dan penetapan target Q4.',
    tanggal: DateTime(2023, 10, 10),
    waktu: '19.00 – 21.00 WIB',
    lokasi: 'Zoom Meeting',
    status: 'Selesai',
    kuota: 40,
    pesertaTerdaftar: 38,
    ketuaPelaksana: PanitiaModel(memberId: '7', nama: 'Ahmad Rizky Pratama', nim: '2021010001'),
    sekretarisPelaksana: PanitiaModel(memberId: '1', nama: 'Ahmad Ridhwan', nim: '20210001'),
    bendaharaPelaksana: PanitiaModel(memberId: '2', nama: 'Siti Nurhaliza', nim: '20210002'),
    periodeId: 'p-1',
    sie: [
      SieModel(
        namaSie: 'Sie Teknis',
        ketua: PanitiaModel(memberId: '3', nama: 'Budi Santoso', nim: '20210003'),
        anggota: [
          PanitiaModel(memberId: '4', nama: 'Dewi Purnama', nim: '20220004'),
        ],
      ),
    ],
  ),
  KegiatanModel(
    id: '4',
    judul: 'Pelatihan Advokasi Kebijakan',
    deskripsi: 'Pelatihan advokasi kebijakan untuk meningkatkan kapasitas anggota dalam '
        'melakukan lobi dan advokasi kepada pemangku kepentingan. Materi mencakup '
        'teknik komunikasi, penyusunan argumen, dan simulasi sidang.',
    tanggal: DateTime(2023, 10, 5),
    waktu: '08.00 – 16.00 WIB',
    lokasi: 'Gedung B Lantai 2',
    status: 'Selesai',
    kuota: 35,
    pesertaTerdaftar: 30,
    ketuaPelaksana: PanitiaModel(memberId: '3', nama: 'Budi Santoso', nim: '20210003'),
    sekretarisPelaksana: PanitiaModel(memberId: '4', nama: 'Dewi Purnama', nim: '20220004'),
    bendaharaPelaksana: PanitiaModel(memberId: '2', nama: 'Siti Nurhaliza', nim: '20210002'),
    periodeId: 'p-1',
    sie: [
      SieModel(
        namaSie: 'Sie Acara',
        ketua: PanitiaModel(memberId: '7', nama: 'Ahmad Rizky Pratama', nim: '2021010001'),
        anggota: [
          PanitiaModel(memberId: '1', nama: 'Ahmad Ridhwan', nim: '20210001'),
          PanitiaModel(memberId: '5', nama: 'Faisal Hakim', nim: '20220005'),
        ],
      ),
      SieModel(
        namaSie: 'Sie Konsumsi',
        ketua: PanitiaModel(memberId: '2', nama: 'Siti Nurhaliza', nim: '20210002'),
        anggota: [
          PanitiaModel(memberId: '4', nama: 'Dewi Purnama', nim: '20220004'),
        ],
      ),
    ],
  ),
];
