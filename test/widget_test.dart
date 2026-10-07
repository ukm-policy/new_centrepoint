import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:centrepoint/core/config/kas_config.dart';
import 'package:centrepoint/core/errors/app_exception.dart';
import 'package:centrepoint/data/models/jabatan_model.dart';
import 'package:centrepoint/data/repositories/supabase/kepengurusan_utils.dart';
import 'package:centrepoint/shared/utils/initials.dart';

// Aplikasi penuh butuh Supabase/Firebase/.env, jadi yang diuji di sini adalah
// logika murni yang tidak bergantung pada backend.

void main() {
  group('initialsOf', () {
    test('mengambil dua huruf pertama', () {
      expect(initialsOf('budi santoso'), 'BS');
      expect(initialsOf('Ahmad Ridhwan Saputra'), 'AR');
    });

    test('aman untuk spasi ganda, spasi di ujung, dan nama kosong', () {
      expect(initialsOf('  Rini   Wulandari '), 'RW');
      expect(initialsOf('Maya'), 'M');
      expect(initialsOf(''), '?');
      expect(initialsOf('   ', fallback: 'M'), 'M');
    });
  });

  group('friendlyError', () {
    test('AppException memakai pesannya apa adanya', () {
      expect(friendlyError(const AppException('Kuota penuh.')), 'Kuota penuh.');
    });

    test('pelanggaran RLS menjadi pesan izin', () {
      const e = PostgrestException(message: 'new row violates row-level security policy', code: '42501');
      expect(friendlyError(e), 'Anda tidak memiliki izin untuk melakukan aksi ini.');
    });

    test('duplikat & tidak ditemukan', () {
      expect(friendlyError(const PostgrestException(message: 'dup', code: '23505')), 'Data yang sama sudah ada.');
      expect(friendlyError(const PostgrestException(message: 'x', code: 'PGRST116')), 'Data tidak ditemukan.');
    });

    test('error jaringan dikenali dari teksnya', () {
      expect(friendlyError(Exception('SocketException: Failed host lookup')), contains('koneksi internet'));
    });
  });

  group('pickJabatan', () {
    Map<String, dynamic> kep(String nama, int level, {bool? aktif}) => {
          'jabatan': {'nama': nama, 'level_akses': level},
          if (aktif != null) 'periode': {'is_aktif': aktif},
        };

    test('null / kosong → null', () {
      expect(pickJabatan(null), isNull);
      expect(pickJabatan(const []), isNull);
    });

    test('mengutamakan periode aktif walau levelnya lebih rendah', () {
      final best = pickJabatan([
        kep('Ketua Umum (lama)', 5, aktif: false),
        kep('Staff Bidang', 2, aktif: true),
      ]);
      expect(best?['nama'], 'Staff Bidang');
    });

    test('tanpa info periode → level tertinggi', () {
      final best = pickJabatan([kep('Staff', 2), kep('Kepala Bidang', 3)]);
      expect(best?['nama'], 'Kepala Bidang');
    });
  });

  group('JabatanModel.label', () {
    test('menambahkan bidang bila belum disebut di nama', () {
      final j = JabatanModel.fromJson({
        'id': 1,
        'nama': 'Kepala Bidang',
        'level_akses': 3,
        'kode_role': 'ketua_bidang_pemrograman',
        'bidang': {'nama': 'Pemrograman'},
      });
      expect(j.label, 'Kepala Bidang — Pemrograman');
    });

    test('tidak menggandakan bidang yang sudah ada di nama', () {
      final j = JabatanModel.fromJson({
        'id': 2,
        'nama': 'Staff Bidang Humas',
        'bidang': {'nama': 'Humas'},
      });
      expect(j.label, 'Staff Bidang Humas');
      expect(j.levelAkses, 1);
    });
  });

  group('KasConfig', () {
    test('tahun berjalan mengikuti jam sistem', () {
      expect(KasConfig.tahunBerjalan, DateTime.now().year);
    });

    test('label nominal memakai pemisah ribuan', () {
      expect(KasConfig.nominalLabel, 'Rp 20.000');
    });
  });
}
