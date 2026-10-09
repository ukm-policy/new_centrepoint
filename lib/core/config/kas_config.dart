/// Pengaturan iuran uang kas.
class KasConfig {
  KasConfig._();

  /// Nominal iuran per bulan (Rupiah).
  static const int nominalBulanan = 20000;

  /// Tahun iuran yang sedang berjalan.
  static int get tahunBerjalan => DateTime.now().year;

  static String get nominalLabel => 'Rp ${_ribuan(nominalBulanan)}';

  static String _ribuan(int v) => v.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}
