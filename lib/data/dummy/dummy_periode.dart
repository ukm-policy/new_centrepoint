import '../models/periode_model.dart';

final dummyPeriode = <PeriodeModel>[
  PeriodeModel(
    id: 'p-1',
    nama: 'Kepengurusan 2025/2026',
    tanggalMulai: DateTime(2025, 7, 1),
    tanggalSelesai: DateTime(2026, 6, 30),
    isActive: true,
  ),
  PeriodeModel(
    id: 'p-2',
    nama: 'Kepengurusan 2024/2025',
    tanggalMulai: DateTime(2024, 7, 1),
    tanggalSelesai: DateTime(2025, 6, 30),
    isActive: false,
  ),
  PeriodeModel(
    id: 'p-3',
    nama: 'Kepengurusan 2023/2024',
    tanggalMulai: DateTime(2023, 7, 1),
    tanggalSelesai: DateTime(2024, 6, 30),
    isActive: false,
  ),
];
