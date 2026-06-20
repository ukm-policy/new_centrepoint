class PanitiaItem {
  const PanitiaItem({required this.nama, required this.nim});
  final String nama;
  final String nim;
}

class SieItem {
  const SieItem({required this.namaSie, this.ketua, this.anggota = const []});
  final String namaSie;
  final PanitiaItem? ketua;
  final List<PanitiaItem> anggota;
}

class KegiatanItem {
  const KegiatanItem({
    required this.id,
    required this.title,
    required this.tanggal,
    required this.waktu,
    required this.lokasi,
    required this.status,
    required this.kuota,
    required this.pesertaTerdaftar,
    required this.deskripsi,
    this.ketuaPelaksana,
    this.sekretarisPelaksana,
    this.bendaharaPelaksana,
    this.sie = const [],
  });

  final String id;
  final String title;
  final String tanggal;
  final String waktu;
  final String lokasi;
  final String status; // 'Upcoming' | 'Berlangsung' | 'Selesai'
  final int kuota;
  final int pesertaTerdaftar;
  final String deskripsi;
  final PanitiaItem? ketuaPelaksana;
  final PanitiaItem? sekretarisPelaksana;
  final PanitiaItem? bendaharaPelaksana;
  final List<SieItem> sie;
}

// ── Mock Data ─────────────────────────────────────────────────────────────────

const kKegiatanList = [
  KegiatanItem(
    id: '1',
    title: 'Seminar Kebijakan Publik 2023',
    tanggal: '28 Oktober 2023',
    waktu: '09.00 – 13.00 WIB',
    lokasi: 'Aula Utama Kampus',
    status: 'Upcoming',
    kuota: 60,
    pesertaTerdaftar: 45,
    deskripsi:
        'Seminar ini membahas kebijakan publik terkini yang berdampak pada '
        'masyarakat luas. Narasumber akan memaparkan analisis mendalam beserta '
        'rekomendasi strategis untuk perbaikan kebijakan ke depan.\n\n'
        'Peserta diharapkan membawa kartu anggota dan hadir 15 menit sebelum acara dimulai.',
    ketuaPelaksana: PanitiaItem(nama: 'Budi Santoso', nim: '2020010023'),
    sekretarisPelaksana: PanitiaItem(nama: 'Sari Dewi', nim: '2020010045'),
    bendaharaPelaksana: PanitiaItem(nama: 'Ahmad Fauzi', nim: '2021010012'),
    sie: [
      SieItem(
        namaSie: 'Sie Acara',
        ketua: PanitiaItem(nama: 'Rizky Pratama', nim: '2021010033'),
        anggota: [
          PanitiaItem(nama: 'Lina Kusuma', nim: '2022010015'),
          PanitiaItem(nama: 'Denny Wahyu', nim: '2022010027'),
        ],
      ),
      SieItem(
        namaSie: 'Sie Konsumsi',
        ketua: PanitiaItem(nama: 'Maya Putri', nim: '2021010044'),
        anggota: [
          PanitiaItem(nama: 'Fikri Alamsyah', nim: '2022010039'),
        ],
      ),
      SieItem(
        namaSie: 'Sie Perlengkapan',
        ketua: PanitiaItem(nama: 'Hendra Saputra', nim: '2021010055'),
        anggota: [
          PanitiaItem(nama: 'Yuni Astuti', nim: '2022010051'),
          PanitiaItem(nama: 'Bagas Wicaksono', nim: '2022010063'),
          PanitiaItem(nama: 'Nadia Rahma', nim: '2023010007'),
        ],
      ),
    ],
  ),
  KegiatanItem(
    id: '2',
    title: 'Workshop Penulisan Naskah Kebijakan',
    tanggal: '15 November 2023',
    waktu: '13.00 – 17.00 WIB',
    lokasi: 'Ruang Rapat Lt. 3',
    status: 'Upcoming',
    kuota: 25,
    pesertaTerdaftar: 20,
    deskripsi:
        'Workshop intensif tentang teknik penulisan naskah kebijakan yang efektif '
        'dan terstruktur. Peserta akan langsung praktek menyusun policy brief yang '
        'komprehensif dan mudah dipahami oleh pengambil keputusan.',
    ketuaPelaksana: PanitiaItem(nama: 'Dina Marlina', nim: '2020010067'),
    sekretarisPelaksana: PanitiaItem(nama: 'Arif Budiman', nim: '2021010089'),
    bendaharaPelaksana: PanitiaItem(nama: 'Susi Hartati', nim: '2021010101'),
    sie: [
      SieItem(
        namaSie: 'Sie Materi',
        ketua: PanitiaItem(nama: 'Rendi Kurniawan', nim: '2022010111'),
        anggota: [
          PanitiaItem(nama: 'Fitriani', nim: '2022010123'),
          PanitiaItem(nama: 'Guntur Wibowo', nim: '2022010135'),
        ],
      ),
      SieItem(
        namaSie: 'Sie Dokumentasi',
        ketua: PanitiaItem(nama: 'Hani Rahmawati', nim: '2022010147'),
        anggota: [
          PanitiaItem(nama: 'Imam Santoso', nim: '2023010009'),
        ],
      ),
    ],
  ),
  KegiatanItem(
    id: '3',
    title: 'Musyawarah Anggota Q3',
    tanggal: '10 Oktober 2023',
    waktu: '19.00 – 21.00 WIB',
    lokasi: 'Zoom Meeting',
    status: 'Selesai',
    kuota: 40,
    pesertaTerdaftar: 38,
    deskripsi:
        'Musyawarah anggota kuartal ketiga untuk evaluasi program kerja dan '
        'perencanaan kegiatan semester genap. Agenda: laporan bidang, evaluasi '
        'anggaran, dan penetapan target Q4.',
    ketuaPelaksana: PanitiaItem(nama: 'Ahmad Rizky Pratama', nim: '2021010001'),
    sekretarisPelaksana: PanitiaItem(nama: 'Ratna Sari', nim: '2021010013'),
    bendaharaPelaksana: PanitiaItem(nama: 'Yoga Pratama', nim: '2021010025'),
    sie: [
      SieItem(
        namaSie: 'Sie Teknis',
        ketua: PanitiaItem(nama: 'Dodi Saputra', nim: '2022010159'),
        anggota: [
          PanitiaItem(nama: 'Rina Melati', nim: '2022010171'),
        ],
      ),
    ],
  ),
  KegiatanItem(
    id: '4',
    title: 'Pelatihan Advokasi Kebijakan',
    tanggal: '5 Oktober 2023',
    waktu: '08.00 – 16.00 WIB',
    lokasi: 'Gedung B Lantai 2',
    status: 'Selesai',
    kuota: 35,
    pesertaTerdaftar: 30,
    deskripsi:
        'Pelatihan advokasi kebijakan untuk meningkatkan kapasitas anggota dalam '
        'melakukan lobi dan advokasi kepada pemangku kepentingan. Materi mencakup '
        'teknik komunikasi, penyusunan argumen, dan simulasi sidang.',
    ketuaPelaksana: PanitiaItem(nama: 'Farhan Maulana', nim: '2020010089'),
    sekretarisPelaksana: PanitiaItem(nama: 'Nurul Aini', nim: '2020010101'),
    bendaharaPelaksana: PanitiaItem(nama: 'Wahyu Saputra', nim: '2021010113'),
    sie: [
      SieItem(
        namaSie: 'Sie Acara',
        ketua: PanitiaItem(nama: 'Citra Amelia', nim: '2021010125'),
        anggota: [
          PanitiaItem(nama: 'Reza Firmansyah', nim: '2022010183'),
          PanitiaItem(nama: 'Putri Handayani', nim: '2022010195'),
          PanitiaItem(nama: 'Aldi Nugraha', nim: '2022010207'),
        ],
      ),
      SieItem(
        namaSie: 'Sie Konsumsi',
        ketua: PanitiaItem(nama: 'Mila Anggraeni', nim: '2022010219'),
        anggota: [
          PanitiaItem(nama: 'Toni Susanto', nim: '2023010021'),
          PanitiaItem(nama: 'Vina Oktaviani', nim: '2023010033'),
        ],
      ),
      SieItem(
        namaSie: 'Sie Publikasi',
        ketua: PanitiaItem(nama: 'Ikhsan Fauzi', nim: '2022010231'),
        anggota: [
          PanitiaItem(nama: 'Laila Syahputri', nim: '2023010045'),
        ],
      ),
    ],
  ),
];
