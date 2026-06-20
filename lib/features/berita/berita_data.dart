class BeritaItem {
  const BeritaItem({
    required this.id,
    required this.date,
    required this.title,
    required this.category,
    required this.content,
  });
  final String id, date, title, category, content;
}

const kBeritaList = [
  BeritaItem(
    id: '1',
    date: '24 Okt 2023',
    title: 'Rapat Tinjauan Kebijakan Tahunan Dijadwalkan',
    category: 'Berita',
    content: 'Pengurus harian UKM POLICY mengundang seluruh anggota riset dan publikasi untuk menghadiri Rapat Tinjauan Kebijakan Tahunan. Rapat ini akan membahas efisiensi program advokasi eksternal serta pemutakhiran standar kajian berkas kebijakan publik daerah. Seluruh anggota diharapkan hadir tepat waktu membawa draf kajian masing-masing.',
  ),
  BeritaItem(
    id: '2',
    date: '20 Okt 2023',
    title: 'Alokasi Anggaran untuk Tahun Fiskal Berikutnya',
    category: 'Pengumuman',
    content: 'Berdasarkan koordinasi bersama Bendahara Umum dan Ketua Umum, telah diputuskan alokasi anggaran belanja organisasi untuk tahun fiskal berikutnya. Fokus pengeluaran akan dialihkan untuk mendanai workshop penulisan jurnal, penyusunan infografis kebijakan, dan peningkatan insentif poin keaktifan anggota aktif.',
  ),
  BeritaItem(
    id: '3',
    date: '15 Okt 2023',
    title: 'Update Peraturan Keanggotaan 2023',
    category: 'Berita',
    content: 'Telah terbit surat keputusan mengenai tata tertib dan peraturan keaktifan anggota UKM POLICY tahun 2023. Peraturan baru ini menegaskan batas minimum akumulasi poin keaktifan per semester dan sanksi penangguhan hak akses jika anggota tidak menghadiri rapat pleno tanpa keterangan tertulis.',
  ),
  BeritaItem(
    id: '4',
    date: '10 Okt 2023',
    title: 'Hasil Musyawarah Anggota Periode Q3',
    category: 'Pengumuman',
    content: 'Musyawarah Anggota periode Q3 yang diselenggarakan awal bulan ini telah menghasilkan beberapa keputusan penting, termasuk amandemen AD/ART terkait struktur organisasi bidang riset dan pembentukan tim ad-hoc untuk open recruitment gelombang kedua.',
  ),
  BeritaItem(
    id: '5',
    date: '5 Okt 2023',
    title: 'Pembentukan Divisi Riset & Kebijakan Baru',
    category: 'Berita',
    content: 'POLICY resmi membentuk sub-divisi baru di bawah koordinasi Bidang Riset, yaitu Divisi Analisis Dampak Kebijakan Digital. Pembentukan divisi ini ditujukan untuk mengkaji regulasi pemerintah terkait keamanan siber, e-commerce, dan perlindungan data pribadi konsumen.',
  ),
];
