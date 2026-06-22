import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/poin_model.dart';
import '../poin_repository.dart';

class SupabasePoinRepository extends PoinRepository {
  final _db = Supabase.instance.client;
  List<PoinEntryModel> _poinEntries = [];
  List<LeaderboardEntryModel> _leaderboard = [];

  SupabasePoinRepository() {
    _loadPoin();
    _db
        .channel('public:poin_entry')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'poin_entry',
          callback: (payload) {
            _loadPoin();
          },
        )
        .subscribe();
  }

  Future<void> _loadPoin() async {
    try {
      // 1. Load Poin entries
      final entriesData = await _db.from('poin_entry').select().order('tanggal', ascending: false);
      _poinEntries = entriesData.map<PoinEntryModel>((json) {
        final id = json['id'] as String;
        final memberId = json['member_id'] as String? ?? '';
        final memberNama = json['member_nama'] as String? ?? 'Anggota';
        final label = json['label'] as String? ?? '';
        final tipeStr = json['tipe'] as String? ?? 'bonus';
        final poin = json['poin'] as int? ?? 0;
        final tanggal = DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now();
        final kegiatanId = json['kegiatan_id'] as String?;

        final tipe = TipePoin.values.firstWhere(
          (e) => e.toString().split('.').last == tipeStr,
          orElse: () => TipePoin.bonus,
        );

        return PoinEntryModel(
          id: id,
          memberId: memberId,
          memberNama: memberNama,
          label: label,
          tipe: tipe,
          poin: poin,
          tanggal: tanggal,
          kegiatanId: kegiatanId,
        );
      }).toList();

      // 2. Load members, their divisions and calculate leaderboard
      final membersData = await _db.from('profiles').select(
        'id, nama, kepengurusan(jabatan(bidang(nama)))'
      );

      final Map<String, int> pointsSum = {};
      for (final entry in _poinEntries) {
        pointsSum[entry.memberId] = (pointsSum[entry.memberId] ?? 0) + entry.poin;
      }

      final List<LeaderboardEntryModel> board = [];
      for (final m in membersData) {
        final id = m['id'] as String;
        final nama = m['nama'] as String? ?? 'Anggota';
        final totalPoin = pointsSum[id] ?? 0;

        String? divisi;
        final kepList = m['kepengurusan'] as List?;
        if (kepList != null && kepList.isNotEmpty) {
          final firstKep = kepList.first as Map<String, dynamic>?;
          final jab = firstKep?['jabatan'] as Map<String, dynamic>?;
          final bid = jab?['bidang'] as Map<String, dynamic>?;
          if (bid != null) {
            divisi = bid['nama'] as String?;
          }
        }

        String tier = 'Member';
        if (totalPoin >= 1200) {
          tier = 'Gold';
        } else if (totalPoin >= 800) {
          tier = 'Silver';
        } else if (totalPoin >= 400) {
          tier = 'Bronze';
        }

        board.add(LeaderboardEntryModel(
          rank: 0, // Calculated after sorting
          memberId: id,
          memberNama: nama,
          divisi: divisi,
          totalPoin: totalPoin,
          tier: tier,
        ));
      }

      // Sort leaderboard
      board.sort((a, b) => b.totalPoin.compareTo(a.totalPoin));
      for (int i = 0; i < board.length; i++) {
        board[i] = board[i].copyWith(rank: i + 1);
      }
      _leaderboard = board;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading points: $e');
    }
  }

  @override
  List<PoinEntryModel> get poinEntries => List.unmodifiable(_poinEntries);
  
  @override
  List<LeaderboardEntryModel> get leaderboard => List.unmodifiable(_leaderboard);

  @override
  Future<void> addPoinEntry(PoinEntryModel entry) async {
    try {
      final user = _db.auth.currentUser;
      await _db.from('poin_entry').insert({
        'member_id': entry.memberId,
        'member_nama': entry.memberNama,
        'label': entry.label,
        'tipe': entry.tipe.toString().split('.').last,
        'poin': entry.poin,
        'tanggal': entry.tanggal.toIso8601String().substring(0, 10),
        'kegiatan_id': entry.kegiatanId,
        'created_by': user?.id,
      });
      await _loadPoin();
    } catch (e) {
      debugPrint('Error adding points: $e');
    }
  }
}
