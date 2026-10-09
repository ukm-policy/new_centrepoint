import 'package:supabase_flutter/supabase_flutter.dart';

/// Embed `kepengurusan` untuk select `profiles`, dengan status periode
/// supaya jabatan periode aktif bisa diutamakan.
const kepengurusanEmbed =
    'kepengurusan(jabatan(nama, level_akses, kode_role, bidang(nama)), periode(is_aktif))';

/// Versi tanpa relasi periode, dipakai jika relasi itu tidak tersedia.
const kepengurusanEmbedBasic =
    'kepengurusan(jabatan(nama, level_akses, kode_role, bidang(nama)))';

/// Select `profiles` beserta jabatan; otomatis mundur ke embed tanpa periode
/// bila relasi `kepengurusan → periode` tidak dikenali PostgREST.
Future<List<Map<String, dynamic>>> selectProfilesWithJabatan(
  SupabaseClient db, {
  String columns = '*',
}) async {
  try {
    return await db.from('profiles').select('$columns, $kepengurusanEmbed');
  } on PostgrestException {
    return await db
        .from('profiles')
        .select('$columns, $kepengurusanEmbedBasic');
  }
}

/// Pilih jabatan yang berlaku dari daftar `kepengurusan` seorang anggota:
/// utamakan periode aktif, lalu level akses tertinggi.
Map<String, dynamic>? pickJabatan(List? kepList) {
  Map<String, dynamic>? best;
  var bestActive = false;
  var bestLevel = -1;
  for (final kep in (kepList ?? const []).whereType<Map<String, dynamic>>()) {
    final jab = kep['jabatan'] as Map<String, dynamic>?;
    if (jab == null) continue;
    final active =
        (kep['periode'] as Map<String, dynamic>?)?['is_aktif'] as bool? ??
        false;
    final level = (jab['level_akses'] as num?)?.toInt() ?? 0;
    final better =
        (active && !bestActive) || (active == bestActive && level > bestLevel);
    if (best == null || better) {
      best = jab;
      bestActive = active;
      bestLevel = level;
    }
  }
  return best;
}
