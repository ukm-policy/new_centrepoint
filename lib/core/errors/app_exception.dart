import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Error yang pesannya sudah siap ditampilkan ke pengguna.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Ubah error teknis (Postgrest, Auth, jaringan, dll.) menjadi pesan yang
/// bisa dipahami pengguna.
String friendlyError(Object error) {
  if (error is AppException) return error.message;
  if (error is AuthException) return error.message;
  if (error is SocketException || error is TimeoutException) {
    return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
  }
  if (error is StorageException) {
    return 'Gagal mengunggah file: ${error.message}';
  }
  if (error is PostgrestException) {
    final msg = error.message.toLowerCase();
    if (error.code == '42501' || msg.contains('row-level security') || msg.contains('permission denied')) {
      return 'Anda tidak memiliki izin untuk melakukan aksi ini.';
    }
    if (error.code == '23505') return 'Data yang sama sudah ada.';
    if (error.code == '23503') return 'Data masih terhubung dengan data lain.';
    if (error.code == 'PGRST116') return 'Data tidak ditemukan.';
    return error.message;
  }
  final text = error.toString();
  if (text.contains('SocketException') || text.contains('Failed host lookup') || text.contains('ClientException')) {
    return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
  }
  return text.replaceFirst('Exception: ', '');
}
