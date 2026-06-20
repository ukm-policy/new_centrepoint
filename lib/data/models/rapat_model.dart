import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

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

class AgendaModel {
  final String judul;
  final String? keterangan;

  const AgendaModel({
    required this.judul,
    this.keterangan,
  });

  factory AgendaModel.fromJson(Map<String, dynamic> json) {
    return AgendaModel(
      judul: json['judul'] as String,
      keterangan: json['keterangan'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'keterangan': keterangan,
    };
  }
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
  final List<String> pesertaIds;    // ref ke MemberModel.id atau nama (menyesuaikan compatibility)
  final String? notulensi;
  final String? kegiatanId;         // null jika rapat org (bukan acara)
  final String? namaSie;            // diisi jika tipe rapatSie
  final String? namaBidang;         // diisi jika tipe rapatInternalBidang
  final bool denganKetuaBidang;

  const RapatModel({
    required this.id,
    required this.judul,
    required this.tipe,
    required this.status,
    required this.tanggal,
    required this.waktu,
    required this.lokasi,
    this.agenda = const [],
    this.pesertaIds = const [],
    this.notulensi,
    this.kegiatanId,
    this.namaSie,
    this.namaBidang,
    this.denganKetuaBidang = false,
  });

  RapatModel copyWith({
    String? id,
    String? judul,
    RapatTipe? tipe,
    RapatStatus? status,
    DateTime? tanggal,
    String? waktu,
    String? lokasi,
    List<AgendaModel>? agenda,
    List<String>? pesertaIds,
    String? notulensi,
    String? kegiatanId,
    String? namaSie,
    String? namaBidang,
    bool? denganKetuaBidang,
  }) {
    return RapatModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      tipe: tipe ?? this.tipe,
      status: status ?? this.status,
      tanggal: tanggal ?? this.tanggal,
      waktu: waktu ?? this.waktu,
      lokasi: lokasi ?? this.lokasi,
      agenda: agenda ?? this.agenda,
      pesertaIds: pesertaIds ?? this.pesertaIds,
      notulensi: notulensi ?? this.notulensi,
      kegiatanId: kegiatanId ?? this.kegiatanId,
      namaSie: namaSie ?? this.namaSie,
      namaBidang: namaBidang ?? this.namaBidang,
      denganKetuaBidang: denganKetuaBidang ?? this.denganKetuaBidang,
    );
  }

  factory RapatModel.fromJson(Map<String, dynamic> json) {
    return RapatModel(
      id: json['id'] as String,
      judul: json['judul'] as String,
      tipe: RapatTipe.values.firstWhere((e) => e.toString() == json['tipe']),
      status: RapatStatus.values.firstWhere((e) => e.toString() == json['status']),
      tanggal: DateTime.parse(json['tanggal'] as String),
      waktu: json['waktu'] as String,
      lokasi: json['lokasi'] as String,
      agenda: (json['agenda'] as List<dynamic>?)?.map((e) => AgendaModel.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      pesertaIds: List<String>.from(json['pesertaIds'] as List<dynamic>? ?? const []),
      notulensi: json['notulensi'] as String?,
      kegiatanId: json['kegiatanId'] as String?,
      namaSie: json['namaSie'] as String?,
      namaBidang: json['namaBidang'] as String?,
      denganKetuaBidang: json['denganKetuaBidang'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'tipe': tipe.toString(),
      'status': status.toString(),
      'tanggal': tanggal.toIso8601String(),
      'waktu': waktu,
      'lokasi': lokasi,
      'agenda': agenda.map((e) => e.toJson()).toList(),
      'pesertaIds': pesertaIds,
      'notulensi': notulensi,
      'kegiatanId': kegiatanId,
      'namaSie': namaSie,
      'namaBidang': namaBidang,
      'denganKetuaBidang': denganKetuaBidang,
    };
  }
}
