import 'package:flutter/material.dart';
import '../../core/session/app_session.dart';
import '../../core/theme/app_colors.dart';
import 'kegiatan_models.dart';

// ── Tipe ──────────────────────────────────────────────────────────────────────

enum RapatTipe {
  rapatUmumAcara,           // Semua panitia event
  rapatStakeholderAcara,    // Ketua/Sekretaris/Bendahara Pelaksana saja
  rapatSie,                 // Ketua + Anggota Sie tertentu
  rapatStakeholderOrg,      // Ketum/Sekum/Bendam (± Ketua Bidang)
  rapatInternalBidang,      // Pengurus satu bidang
}

extension RapatTipeX on RapatTipe {
  String get label => switch (this) {
    RapatTipe.rapatUmumAcara        => 'Rapat Umum Acara',
    RapatTipe.rapatStakeholderAcara => 'Rapat Stakeholder Acara',
    RapatTipe.rapatSie              => 'Rapat Internal Sie',
    RapatTipe.rapatStakeholderOrg   => 'Rapat Stakeholder Org',
    RapatTipe.rapatInternalBidang   => 'Rapat Internal Bidang',
  };

  String get labelShort => switch (this) {
    RapatTipe.rapatUmumAcara        => 'Umum Acara',
    RapatTipe.rapatStakeholderAcara => 'Stakeholder Acara',
    RapatTipe.rapatSie              => 'Internal Sie',
    RapatTipe.rapatStakeholderOrg   => 'Stakeholder Org',
    RapatTipe.rapatInternalBidang   => 'Internal Bidang',
  };

  String get description => switch (this) {
    RapatTipe.rapatUmumAcara        => 'Seluruh panitia acara/event (inti + semua Sie)',
    RapatTipe.rapatStakeholderAcara => 'Ketua, Sekretaris & Bendahara Pelaksana',
    RapatTipe.rapatSie              => 'Ketua dan Anggota Sie tertentu',
    RapatTipe.rapatStakeholderOrg   => 'Ketum, Sekum, Bendam (± Ketua Bidang)',
    RapatTipe.rapatInternalBidang   => 'Seluruh pengurus satu bidang organisasi',
  };

  Color get badgeColor => switch (this) {
    RapatTipe.rapatUmumAcara        => AppColors.primaryContainer,
    RapatTipe.rapatStakeholderAcara => AppColors.secondary,
    RapatTipe.rapatSie              => AppColors.secondaryContainer,
    RapatTipe.rapatStakeholderOrg   => AppColors.blackCharcoal,
    RapatTipe.rapatInternalBidang   => AppColors.surfaceContainerHigh,
  };

  Color get badgeTextColor => switch (this) {
    RapatTipe.rapatUmumAcara        => AppColors.onPrimaryContainer,
    RapatTipe.rapatStakeholderAcara => AppColors.onSecondary,
    RapatTipe.rapatSie              => AppColors.onSecondaryContainer,
    RapatTipe.rapatStakeholderOrg   => Colors.white,
    RapatTipe.rapatInternalBidang   => AppColors.onSurface,
  };

  IconData get icon => switch (this) {
    RapatTipe.rapatUmumAcara        => Icons.groups_outlined,
    RapatTipe.rapatStakeholderAcara => Icons.supervisor_account_outlined,
    RapatTipe.rapatSie              => Icons.people_outline,
    RapatTipe.rapatStakeholderOrg   => Icons.account_balance_outlined,
    RapatTipe.rapatInternalBidang   => Icons.workspaces_outlined,
  };

  bool get isAcaraRelated =>
      this == RapatTipe.rapatUmumAcara ||
      this == RapatTipe.rapatStakeholderAcara ||
      this == RapatTipe.rapatSie;
}

// ── Status ────────────────────────────────────────────────────────────────────

enum RapatStatus { terjadwal, berlangsung, selesai, dibatalkan }

extension RapatStatusX on RapatStatus {
  String get label => switch (this) {
    RapatStatus.terjadwal   => 'Terjadwal',
    RapatStatus.berlangsung => 'Berlangsung',
    RapatStatus.selesai     => 'Selesai',
    RapatStatus.dibatalkan  => 'Dibatalkan',
  };

  Color get color => switch (this) {
    RapatStatus.terjadwal   => AppColors.secondaryContainer,
    RapatStatus.berlangsung => AppColors.primaryContainer,
    RapatStatus.selesai     => AppColors.surfaceContainerHigh,
    RapatStatus.dibatalkan  => AppColors.errorContainer,
  };

  Color get textColor => switch (this) {
    RapatStatus.terjadwal   => AppColors.onSecondaryContainer,
    RapatStatus.berlangsung => AppColors.onPrimaryContainer,
    RapatStatus.selesai     => AppColors.tertiary,
    RapatStatus.dibatalkan  => AppColors.onErrorContainer,
  };
}

// ── Models ────────────────────────────────────────────────────────────────────

class AgendaItem {
  const AgendaItem({required this.judul, this.keterangan});
  final String judul;
  final String? keterangan;
}

class RapatItem {
  const RapatItem({
    required this.id,
    required this.judul,
    required this.tipe,
    required this.status,
    required this.tanggal,
    required this.waktu,
    required this.lokasi,
    this.agenda = const [],
    this.peserta = const [],
    this.notulensi,
    this.kegiatanId,
    this.namaSie,
    this.namaBidang,
    this.denganKetuaBidang = false,
  });

  final String id;
  final String judul;
  final RapatTipe tipe;
  final RapatStatus status;
  final String tanggal;
  final String waktu;
  final String lokasi;
  final List<AgendaItem> agenda;
  final List<String> peserta;
  final String? notulensi;

  // Konteks acara
  final String? kegiatanId;
  final String? namaSie;

  // Konteks org
  final String? namaBidang;
  final bool denganKetuaBidang;
}

// ── Visibility Filter ─────────────────────────────────────────────────────────

bool isRapatVisible(RapatItem rapat) {
  if (AppSession.isAdmin) return true;

  switch (rapat.tipe) {
    case RapatTipe.rapatUmumAcara:
    case RapatTipe.rapatStakeholderAcara:
      if (rapat.kegiatanId == null) return false;
      final kegiatan = kKegiatanList.firstWhere(
        (k) => k.id == rapat.kegiatanId,
        orElse: () => kKegiatanList.first,
      );
      final isPanitiaInti =
          kegiatan.ketuaPelaksana?.nama == AppSession.nama ||
          kegiatan.sekretarisPelaksana?.nama == AppSession.nama ||
          kegiatan.bendaharaPelaksana?.nama == AppSession.nama;
      if (rapat.tipe == RapatTipe.rapatStakeholderAcara) return isPanitiaInti;
      return isPanitiaInti ||
          kegiatan.sie.any((s) =>
              s.ketua?.nama == AppSession.nama ||
              s.anggota.any((a) => a.nama == AppSession.nama));

    case RapatTipe.rapatSie:
      if (rapat.kegiatanId == null || rapat.namaSie == null) return false;
      final kegiatan = kKegiatanList.firstWhere(
        (k) => k.id == rapat.kegiatanId,
        orElse: () => kKegiatanList.first,
      );
      return kegiatan.sie
          .where((s) => s.namaSie == rapat.namaSie)
          .any((s) =>
              s.ketua?.nama == AppSession.nama ||
              s.anggota.any((a) => a.nama == AppSession.nama));

    case RapatTipe.rapatStakeholderOrg:
      if (AppSession.level >= 4) return true;
      return AppSession.level == 3 && rapat.denganKetuaBidang;

    case RapatTipe.rapatInternalBidang:
      return AppSession.bidang == rapat.namaBidang && AppSession.level >= 2;
  }
}

// ── Mock Data ─────────────────────────────────────────────────────────────────

const kRapatList = [
  // ── Seminar Kebijakan Publik (kegiatan '1') ───────────────────────────────
  RapatItem(
    id: 'r1',
    judul: 'Rapat Perdana Seminar Kebijakan Publik',
    tipe: RapatTipe.rapatUmumAcara,
    status: RapatStatus.selesai,
    tanggal: '10 Oktober 2023',
    waktu: '19.00 – 21.00 WIB',
    lokasi: 'Zoom Meeting',
    kegiatanId: '1',
    peserta: [
      'Budi Santoso', 'Sari Dewi', 'Ahmad Fauzi',
      'Rizky Pratama', 'Lina Kusuma', 'Denny Wahyu',
      'Maya Putri', 'Fikri Alamsyah', 'Hendra Saputra',
    ],
    agenda: [
      AgendaItem(judul: 'Pembukaan & perkenalan panitia'),
      AgendaItem(judul: 'Pembagian tugas per-Sie',
          keterangan: 'Diskusi dan penetapan PIC tiap seksi'),
      AgendaItem(judul: 'Penyusunan timeline H-14 s.d. hari-H'),
      AgendaItem(judul: 'Lain-lain'),
    ],
    notulensi:
        'Rapat dihadiri 9 dari 11 panitia. Disepakati: Ketua Sie Acara bertanggung jawab atas rundown. '
        'Sie Konsumsi koordinasi katering paling lambat H-7. '
        'Sie Perlengkapan cek ketersediaan proyektor dan sound system H-10.',
  ),
  RapatItem(
    id: 'r2',
    judul: 'Koordinasi Panitia Inti Seminar',
    tipe: RapatTipe.rapatStakeholderAcara,
    status: RapatStatus.terjadwal,
    tanggal: '18 Oktober 2023',
    waktu: '16.00 – 17.30 WIB',
    lokasi: 'Ruang Sekretariat UKM',
    kegiatanId: '1',
    peserta: ['Budi Santoso', 'Sari Dewi', 'Ahmad Fauzi'],
    agenda: [
      AgendaItem(judul: 'Evaluasi progres persiapan'),
      AgendaItem(judul: 'Finalisasi anggaran',
          keterangan: 'Review RAB dan alokasi dana per seksi'),
      AgendaItem(judul: 'Koordinasi teknis narasumber'),
    ],
  ),
  RapatItem(
    id: 'r3',
    judul: 'Rapat Internal Sie Acara – Seminar',
    tipe: RapatTipe.rapatSie,
    status: RapatStatus.terjadwal,
    tanggal: '20 Oktober 2023',
    waktu: '13.00 – 14.00 WIB',
    lokasi: 'Koridor Gedung A',
    kegiatanId: '1',
    namaSie: 'Sie Acara',
    peserta: ['Rizky Pratama', 'Lina Kusuma', 'Denny Wahyu'],
    agenda: [
      AgendaItem(judul: 'Finalisasi rundown acara'),
      AgendaItem(judul: 'Gladi bersih MC', keterangan: 'Latihan MC dan pemandu sesi'),
      AgendaItem(judul: 'Koordinasi dengan narasumber'),
    ],
  ),
  RapatItem(
    id: 'r4',
    judul: 'Rapat Internal Sie Konsumsi – Seminar',
    tipe: RapatTipe.rapatSie,
    status: RapatStatus.selesai,
    tanggal: '15 Oktober 2023',
    waktu: '12.00 – 12.30 WIB',
    lokasi: 'Kantin Gedung B',
    kegiatanId: '1',
    namaSie: 'Sie Konsumsi',
    peserta: ['Maya Putri', 'Fikri Alamsyah'],
    agenda: [
      AgendaItem(judul: 'Penentuan vendor katering'),
      AgendaItem(judul: 'Estimasi jumlah porsi & snack'),
    ],
    notulensi:
        'Disepakati vendor Katering Barokah, paket standing party. '
        'Estimasi 65 porsi (peserta + panitia). DP dibayar H-5.',
  ),

  // ── Workshop Penulisan Naskah (kegiatan '2') ──────────────────────────────
  RapatItem(
    id: 'r5',
    judul: 'Rapat Persiapan Workshop Penulisan',
    tipe: RapatTipe.rapatUmumAcara,
    status: RapatStatus.terjadwal,
    tanggal: '5 November 2023',
    waktu: '19.30 – 21.00 WIB',
    lokasi: 'Zoom Meeting',
    kegiatanId: '2',
    peserta: [
      'Dina Marlina', 'Arif Budiman', 'Susi Hartati',
      'Rendi Kurniawan', 'Fitriani', 'Guntur Wibowo',
      'Hani Rahmawati', 'Imam Santoso',
    ],
    agenda: [
      AgendaItem(judul: 'Pembagian tugas panitia workshop'),
      AgendaItem(judul: 'Presentasi draft modul (Sie Materi)'),
      AgendaItem(judul: 'Timeline H-10 kegiatan'),
    ],
  ),
  RapatItem(
    id: 'r6',
    judul: 'Rapat Internal Sie Materi – Workshop',
    tipe: RapatTipe.rapatSie,
    status: RapatStatus.berlangsung,
    tanggal: '2 November 2023',
    waktu: '15.00 – 16.30 WIB',
    lokasi: 'Perpustakaan Kampus',
    kegiatanId: '2',
    namaSie: 'Sie Materi',
    peserta: ['Rendi Kurniawan', 'Fitriani', 'Guntur Wibowo'],
    agenda: [
      AgendaItem(judul: 'Review draft modul policy brief'),
      AgendaItem(judul: 'Pembagian materi per sesi'),
    ],
  ),

  // ── Rapat Kepengurusan Organisasi ─────────────────────────────────────────
  RapatItem(
    id: 'r7',
    judul: 'Evaluasi Program Kerja Q3',
    tipe: RapatTipe.rapatStakeholderOrg,
    status: RapatStatus.selesai,
    tanggal: '1 Oktober 2023',
    waktu: '14.00 – 16.00 WIB',
    lokasi: 'Ruang Rapat Lt. 3',
    denganKetuaBidang: false,
    peserta: ['Ahmad Rizky Pratama', 'Ratna Sari', 'Yoga Pratama'],
    agenda: [
      AgendaItem(judul: 'Laporan realisasi program kerja Q3'),
      AgendaItem(judul: 'Evaluasi serapan anggaran'),
      AgendaItem(judul: 'Perencanaan Q4 & semester genap'),
    ],
    notulensi:
        'Proker Q3 terlaksana 85%, anggaran terserap 78%. '
        'Disepakati penambahan 2 kegiatan Q4: Pelatihan Advokasi dan Seminar Kebijakan Publik.',
  ),
  RapatItem(
    id: 'r8',
    judul: 'Konsolidasi Akhir Tahun + Ketua Bidang',
    tipe: RapatTipe.rapatStakeholderOrg,
    status: RapatStatus.terjadwal,
    tanggal: '25 November 2023',
    waktu: '09.00 – 12.00 WIB',
    lokasi: 'Aula UKM Lantai 2',
    denganKetuaBidang: true,
    peserta: [
      'Ahmad Rizky Pratama', 'Ratna Sari', 'Yoga Pratama',
      'Kepala Bidang Humas', 'Kepala Bidang Litbang',
      'Kepala Bidang Kaderisasi', 'Kepala Bidang Advokasi',
    ],
    agenda: [
      AgendaItem(judul: 'Laporan capaian tiap bidang 2023'),
      AgendaItem(judul: 'Evaluasi & lessons learned'),
      AgendaItem(judul: 'Kick-off perencanaan 2024'),
      AgendaItem(judul: 'Pergantian kepengurusan (informasi awal)'),
    ],
  ),
  RapatItem(
    id: 'r9',
    judul: 'Rapat Internal Bidang Humas',
    tipe: RapatTipe.rapatInternalBidang,
    status: RapatStatus.selesai,
    tanggal: '8 Oktober 2023',
    waktu: '13.00 – 14.30 WIB',
    lokasi: 'Sekretariat Bidang Humas',
    namaBidang: 'Humas',
    peserta: ['Kepala Bidang Humas', 'Anggota Humas A', 'Anggota Humas B', 'Anggota Humas C'],
    agenda: [
      AgendaItem(judul: 'Evaluasi konten media sosial Q3'),
      AgendaItem(judul: 'Strategi promosi Seminar Kebijakan Publik'),
      AgendaItem(judul: 'Pembagian PIC konten November'),
    ],
    notulensi:
        'Target reach Instagram 2000+/post untuk Seminar. '
        'Jadwal posting: H-14, H-7, H-3, H-1, hari-H.',
  ),
  RapatItem(
    id: 'r10',
    judul: 'Rapat Internal Bidang Litbang',
    tipe: RapatTipe.rapatInternalBidang,
    status: RapatStatus.terjadwal,
    tanggal: '12 November 2023',
    waktu: '16.00 – 17.30 WIB',
    lokasi: 'Perpustakaan Kampus',
    namaBidang: 'Litbang',
    peserta: ['Kepala Bidang Litbang', 'Anggota Litbang A', 'Anggota Litbang B'],
    agenda: [
      AgendaItem(judul: 'Progress riset kebijakan tahunan'),
      AgendaItem(judul: 'Rencana publikasi paper bidang'),
    ],
  ),
];
