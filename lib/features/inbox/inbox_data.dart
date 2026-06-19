// Shared models and mock data for Inbox feature

class InboxNotifItem {
  const InboxNotifItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    this.route,
  });
  final String id, type, title, body, time;
  final bool isRead;
  // Deep-link target; null = no navigation (just mark read)
  final String? route;
}

class InboxPengumumanItem {
  const InboxPengumumanItem({
    required this.id,
    required this.category,
    required this.title,
    required this.excerpt,
    required this.date,
    required this.content,
    required this.isNew,
    this.actionLabel,
    this.actionRoute,
  });
  final String id, category, title, excerpt, date;
  final List<String> content; // paragraphs
  final bool isNew;
  final String? actionLabel;
  final String? actionRoute;
}

// ── Mock Data ─────────────────────────────────────────────────────────────────

const kInboxNotif = [
  InboxNotifItem(
    id: '1',
    type: 'poin',
    title: 'Poin Bertambah',
    body: 'Kamu mendapatkan +50 poin karena hadir di Rapat Tinjauan Kebijakan.',
    time: '5 mnt lalu',
    isRead: false,
    route: '/poin',
  ),
  InboxNotifItem(
    id: '2',
    type: 'kegiatan',
    title: 'Kegiatan Baru Ditambahkan',
    body: 'Workshop Policy Writing telah dijadwalkan pada 28 Oktober 2025.',
    time: '2 jam lalu',
    isRead: false,
    route: '/kegiatan',
  ),
  InboxNotifItem(
    id: '3',
    type: 'absensi',
    title: 'Konfirmasi Absensi',
    body: 'Absensi kamu untuk Rapat Rutin telah tercatat — Tepat Waktu.',
    time: '1 hari lalu',
    isRead: true,
    route: '/absensi',
  ),
  InboxNotifItem(
    id: '4',
    type: 'uang_khas',
    title: 'Tagihan Uang Khas',
    body: 'Tagihan uang khas bulan Oktober 2025 telah diterbitkan. Silakan segera bayar.',
    time: '2 hari lalu',
    isRead: false,
    route: '/uang-khas',
  ),
  InboxNotifItem(
    id: '5',
    type: 'poin',
    title: 'Level Naik!',
    body: 'Selamat! Kamu telah mencapai level Gold. Pertahankan keaktifanmu.',
    time: '3 hari lalu',
    isRead: true,
    route: '/poin',
  ),
  InboxNotifItem(
    id: '6',
    type: 'sistem',
    title: 'Update Aplikasi Tersedia',
    body: 'Versi 1.1.0 kini tersedia dengan fitur-fitur baru dan perbaikan performa.',
    time: '5 hari lalu',
    isRead: true,
  ),
  InboxNotifItem(
    id: '7',
    type: 'kegiatan',
    title: 'Pengingat Kegiatan',
    body: 'Rapat Advokasi Bulanan akan berlangsung besok pukul 09.00 WIB.',
    time: '5 hari lalu',
    isRead: true,
    route: '/kegiatan',
  ),
];

const kInboxPengumuman = [
  InboxPengumumanItem(
    id: '1',
    category: 'PENTING',
    title: 'Panduan Baru Tata Tertib Organisasi 2025',
    excerpt:
        'Pengurus telah merilis panduan tata tertib yang diperbarui untuk tahun 2025. Seluruh anggota wajib membaca dan mematuhi aturan yang berlaku.',
    date: '20 Okt 2025',
    isNew: true,
    content: [
      'Pengurus UKM Policy dengan bangga mengumumkan diterbitkannya Panduan Tata Tertib Organisasi 2025. Panduan ini merupakan pembaruan komprehensif dari versi sebelumnya dan mencerminkan nilai-nilai serta standar baru yang telah disepakati bersama dalam Musyawarah Besar Anggota.',
      'Perubahan utama mencakup revisi sistem poin keaktifan, kewajiban kehadiran minimum 70% dari total kegiatan per semester, serta mekanisme sanksi yang lebih transparan dan terukur. Setiap anggota diwajibkan membaca dan menandatangani lembar persetujuan digital melalui aplikasi ini paling lambat 30 Oktober 2025.',
      'Panduan ini juga memperkenalkan sistem mentoring antar anggota dan jalur pengembangan karir di dalam organisasi. Anggota baru akan mendapatkan pendampingan selama 3 bulan pertama dari anggota senior yang ditunjuk oleh pengurus.',
      'Bagi anggota yang belum memahami isi panduan sepenuhnya, pengurus akan menyelenggarakan sesi sosialisasi pada 25 Oktober 2025. Kehadiran dalam sesi ini bersifat wajib dan akan dihitung sebagai kegiatan organisasi.',
    ],
  ),
  InboxPengumumanItem(
    id: '2',
    category: 'KEGIATAN',
    title: 'Jadwal Rapat Tinjauan Kebijakan Q4 2025',
    excerpt:
        'Rapat tinjauan kebijakan kuartal keempat akan dilaksanakan secara hybrid. Konfirmasi kehadiran paling lambat 25 Oktober 2025.',
    date: '18 Okt 2025',
    isNew: true,
    content: [
      'Rapat Tinjauan Kebijakan Kuartal Keempat (Q4) 2025 akan dilaksanakan pada Jumat, 1 November 2025, pukul 09.00 – 13.00 WIB. Rapat ini akan diselenggarakan secara hybrid: secara langsung di Ruang Rapat Utama Gedung Pusat Mahasiswa Lantai 3, sekaligus dapat diikuti secara daring melalui tautan yang akan dikirimkan 24 jam sebelum acara.',
      'Agenda utama rapat mencakup: (1) Evaluasi pencapaian program kerja Q3 2025, (2) Pembahasan rancangan program kerja Q4 2025, (3) Pemaparan laporan keuangan semester ganjil, dan (4) Diskusi mengenai rencana kegiatan akhir tahun termasuk Policy Fair 2025.',
      'Seluruh anggota diwajibkan hadir, baik daring maupun luring. Konfirmasi kehadiran dan pilihan metode keikutsertaan (luring/daring) harus dilakukan paling lambat Kamis, 25 Oktober 2025 melalui menu Kegiatan di aplikasi ini.',
      'Bagi anggota yang berhalangan hadir karena alasan akademis, harap melaporkan kepada koordinator divisi masing-masing beserta bukti pendukung. Ketidakhadiran tanpa izin yang valid akan mempengaruhi poin keaktifan semester.',
    ],
    actionLabel: 'Lihat Detail Kegiatan',
    actionRoute: '/kegiatan',
  ),
  InboxPengumumanItem(
    id: '3',
    category: 'KEUANGAN',
    title: 'Batas Pembayaran Uang Khas Q4',
    excerpt:
        'Pembayaran uang khas periode Oktober–Desember 2025 jatuh tempo pada 31 Oktober 2025. Keterlambatan dikenakan denda 10%.',
    date: '15 Okt 2025',
    isNew: false,
    content: [
      'Bendahara UKM Policy menginformasikan bahwa tagihan uang khas untuk periode Oktober–Desember 2025 telah diterbitkan. Besaran iuran adalah Rp 30.000 per bulan atau Rp 90.000 untuk pembayaran langkap satu kuartal.',
      'Batas waktu pembayaran adalah 31 Oktober 2025. Pembayaran dapat dilakukan melalui transfer ke rekening organisasi atau secara tunai kepada bendahara pada jam kerja sekretariat (Senin–Jumat, 10.00–15.00 WIB).',
      'Anggota yang terlambat membayar setelah tanggal jatuh tempo akan dikenakan denda administratif sebesar 10% dari total tagihan per minggu keterlambatan. Anggota yang belum melunasi tagihan setelah 3 minggu akan mendapatkan status "Non-Aktif" sementara yang dapat mempengaruhi keikutsertaan dalam kegiatan.',
      'Jika ada kendala keuangan, anggota dapat mengajukan permohonan keringanan atau cicilan kepada bendahara dengan mengisi formulir pengajuan yang tersedia di sekretariat. Pengurus berkomitmen untuk mencari solusi terbaik bagi setiap anggota.',
    ],
    actionLabel: 'Cek Uang Khas',
    actionRoute: '/uang-khas',
  ),
  InboxPengumumanItem(
    id: '4',
    category: 'REKRUTMEN',
    title: 'Pembukaan Rekrutmen Anggota Baru 2025',
    excerpt:
        'UKM Policy membuka rekrutmen anggota baru untuk periode 2025/2026. Daftarkan dirimu sebelum 10 November 2025.',
    date: '10 Okt 2025',
    isNew: false,
    content: [
      'UKM Policy dengan bangga mengumumkan pembukaan rekrutmen anggota baru untuk periode 2025/2026. Kami mencari individu-individu bertalenta yang memiliki minat dan semangat di bidang kebijakan publik, advokasi, penelitian, dan komunikasi.',
      'Pendaftaran dibuka mulai 10 Oktober hingga 10 November 2025. Calon anggota dapat mendaftar melalui tautan yang tersedia di media sosial resmi UKM Policy atau langsung mengunjungi sekretariat UKM Policy di Gedung Pusat Mahasiswa Ruang 205.',
      'Proses seleksi terdiri dari tiga tahap: (1) Seleksi administrasi berkas, (2) Wawancara motivasi dan minat, serta (3) Masa Orientasi Anggota Baru selama dua minggu. Seluruh tahap wajib diikuti oleh calon anggota yang lolos.',
      'UKM Policy membuka tiga divisi utama: Divisi Riset & Kebijakan, Divisi Advokasi & Hubungan Eksternal, dan Divisi Publikasi & Komunikasi. Setiap pendaftar dapat menyatakan preferensi divisi, namun penempatan akhir ditentukan oleh tim seleksi berdasarkan kompetensi dan kebutuhan organisasi.',
    ],
  ),
  InboxPengumumanItem(
    id: '5',
    category: 'PRESTASI',
    title: 'UKM Policy Raih Juara 1 Kompetisi Kebijakan Nasional',
    excerpt:
        'Tim delegasi UKM Policy berhasil meraih juara pertama dalam Kompetisi Policy Brief Nasional 2025. Selamat!',
    date: '5 Okt 2025',
    isNew: false,
    content: [
      'UKM Policy dengan penuh kebanggaan mengumumkan bahwa tim delegasi kita berhasil meraih Juara Pertama dalam Kompetisi Policy Brief Nasional 2025 yang diselenggarakan oleh Asosiasi Mahasiswa Ilmu Politik Indonesia (AMPI) di Universitas Gadjah Mada, Yogyakarta, pada 1–3 Oktober 2025.',
      'Tim yang beranggotakan Ahmad Ridhwan (ketua), Siti Nurhaliza, dan Budi Santoso berhasil menyisihkan 47 tim dari 32 universitas se-Indonesia. Policy brief mereka yang berjudul "Reformasi Kebijakan Subsidi Energi Berbasis Data: Solusi Fiskal dan Keadilan Sosial" mendapatkan pujian dari panel juri sebagai yang paling komprehensif dan solutif.',
      'Kepala Divisi Riset menyampaikan bahwa pencapaian ini merupakan hasil dari persiapan intensif selama tiga bulan, termasuk serangkaian workshop internal, sesi mentoring dengan akademisi, dan simulasi presentasi. "Kami sangat bangga dengan dedikasi tim. Ini bukan hanya kemenangan individu, tetapi kemenangan seluruh organisasi," tuturnya.',
      'Sebagai penghargaan atas prestasi ini, ketiga anggota tim akan mendapatkan poin keaktifan bonus sebesar 200 poin masing-masing, dan nama mereka akan diabadikan dalam Papan Prestasi UKM Policy. Selamat kepada tim dan seluruh anggota yang telah memberikan dukungan!',
    ],
  ),
];
