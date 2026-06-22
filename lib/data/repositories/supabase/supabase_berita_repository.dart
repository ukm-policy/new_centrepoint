import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/berita_model.dart';
import '../berita_repository.dart';

class SupabaseBeritaRepository extends BeritaRepository {
  final _db = Supabase.instance.client;
  List<BeritaModel> _berita = [];

  SupabaseBeritaRepository() {
    _loadBerita();
    _db
        .channel('public:berita')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'berita',
          callback: (payload) {
            _loadBerita();
          },
        )
        .subscribe();
  }

  Future<void> _loadBerita() async {
    try {
      final data = await _db.from('berita').select().order('tanggal_publish', ascending: false);
      _berita = data.map<BeritaModel>((json) {
        return BeritaModel(
          id: json['id'] as String,
          judul: json['judul'] as String? ?? '',
          kategori: json['kategori'] as String? ?? 'Berita',
          konten: json['konten'] as String? ?? '',
          thumbnailUrl: json['thumbnail_url'] as String?,
          penulisId: json['penulis_id'] as String? ?? '',
          penulisNama: json['penulis_nama'] as String? ?? '',
          tanggalPublish: DateTime.tryParse(json['tanggal_publish'] ?? '') ?? DateTime.now(),
          isDraft: json['is_draft'] as bool? ?? false,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading berita: $e');
    }
  }

  @override
  List<BeritaModel> get berita => List.unmodifiable(_berita);

  @override
  List<BeritaModel> get publishedBerita =>
      _berita.where((b) => !b.isDraft).toList();

  @override
  Future<void> addBerita(BeritaModel item) async {
    try {
      await _db.from('berita').insert({
        'judul': item.judul,
        'kategori': item.kategori,
        'konten': item.konten,
        'thumbnail_url': item.thumbnailUrl,
        'penulis_id': item.penulisId.isNotEmpty ? item.penulisId : null,
        'penulis_nama': item.penulisNama,
        'is_draft': item.isDraft,
        'tanggal_publish': item.tanggalPublish.toIso8601String(),
      });
      await _loadBerita();
    } catch (e) {
      debugPrint('Error adding berita: $e');
    }
  }

  @override
  Future<void> updateBerita(BeritaModel item) async {
    try {
      await _db.from('berita').update({
        'judul': item.judul,
        'kategori': item.kategori,
        'konten': item.konten,
        'thumbnail_url': item.thumbnailUrl,
        'is_draft': item.isDraft,
        'tanggal_publish': item.tanggalPublish.toIso8601String(),
      }).eq('id', item.id);
      await _loadBerita();
    } catch (e) {
      debugPrint('Error updating berita: $e');
    }
  }

  @override
  Future<void> deleteBerita(String id) async {
    try {
      await _db.from('berita').delete().eq('id', id);
      await _loadBerita();
    } catch (e) {
      debugPrint('Error deleting berita: $e');
    }
  }

  @override
  Future<void> publishBerita(String id) async {
    try {
      await _db.from('berita').update({
        'is_draft': false,
        'tanggal_publish': DateTime.now().toIso8601String(),
      }).eq('id', id);
      await _loadBerita();
    } catch (e) {
      debugPrint('Error publishing berita: $e');
    }
  }
}
