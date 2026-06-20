// Mock session — di produksi ini akan dari auth provider (Riverpod/Provider)
class AppSession {
  AppSession._();

  // Toggle untuk testing: ganti ke false untuk simulasi user biasa
  static const bool isAdmin = true;

  static const String nama = 'Ahmad Rizky Pratama';
  static const String nim = '2021010001';
  static const String jabatan = 'Ketua Umum';
  static const String bidang = '-';
  static const int level = 5; // 0=user_public, 1=anggota_umum, ..., 5=ketua_umum
  static const String kodeRole = 'ketua_umum';
}
