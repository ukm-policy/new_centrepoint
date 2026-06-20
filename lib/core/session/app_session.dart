import '../../data/models/user_model.dart';

// Mock session backed by UserModel
class AppSession {
  AppSession._();

  static UserModel? _currentUser;

  static UserModel get currentUser {
    if (_currentUser == null) {
      _currentUser = UserModel(
        id: 'u-1',
        nama: 'Ahmad Rizky Pratama',
        email: 'ahmad.rizky@email.com',
        nim: '2021010001',
        noHp: '081234567890',
        prodi: 'Teknik Informatika',
        angkatan: '2021',
        role: 'ketua', // 'anggota' | 'staff' | 'ketua' | 'demisioner' | 'admin'
        bidang: '-',
        jabatan: 'Ketua Umum',
        avatarUrl: null,
        isVerified: true,
        createdAt: DateTime(2021, 8, 1),
      );
    }
    return _currentUser!;
  }

  static set currentUser(UserModel user) {
    _currentUser = user;
  }

  static bool get isAdmin => currentUser.role == 'admin' || currentUser.role == 'ketua';
  static String get nama => currentUser.nama;
  static String get nim => currentUser.nim;
  static String get jabatan => currentUser.jabatan ?? 'Anggota';
  static String get bidang => currentUser.bidang ?? '-';
  static int get level {
    return switch (currentUser.role) {
      'admin' => 5,
      'ketua' => 5,
      'staff' => 3,
      'anggota' => 1,
      'demisioner' => 1,
      _ => 0,
    };
  }
  static String get kodeRole => currentUser.role == 'ketua' ? 'ketua_umum' : currentUser.role;
}
