import 'package:flutter/foundation.dart';
import '../models/poin_model.dart';
import '../dummy/dummy_poin.dart';

abstract class PoinRepository extends ChangeNotifier {
  List<PoinEntryModel> get poinEntries;
  List<LeaderboardEntryModel> get leaderboard;
  void addPoinEntry(PoinEntryModel entry);
}

class DummyPoinRepository extends PoinRepository {
  final List<PoinEntryModel> _poinEntries = List.from(dummyPoinEntries);
  final List<LeaderboardEntryModel> _leaderboard = List.from(dummyLeaderboard);

  @override
  List<PoinEntryModel> get poinEntries => List.unmodifiable(_poinEntries);
  
  @override
  List<LeaderboardEntryModel> get leaderboard => List.unmodifiable(_leaderboard);

  @override
  void addPoinEntry(PoinEntryModel entry) {
    _poinEntries.insert(0, entry);
    _recalculateLeaderboard(entry.memberId, entry.memberNama, entry.poin);
    notifyListeners();
  }

  void _recalculateLeaderboard(String memberId, String memberNama, int poinDiff) {
    final idx = _leaderboard.indexWhere((l) => l.memberId == memberId);
    if (idx != -1) {
      final updatedPoin = _leaderboard[idx].totalPoin + poinDiff;
      String newTier = 'Member';
      if (updatedPoin >= 1200) {
        newTier = 'Gold';
      } else if (updatedPoin >= 800) {
        newTier = 'Silver';
      } else if (updatedPoin >= 400) {
        newTier = 'Bronze';
      }
      _leaderboard[idx] = _leaderboard[idx].copyWith(
        totalPoin: updatedPoin,
        tier: newTier,
      );
    } else {
      _leaderboard.add(LeaderboardEntryModel(
        rank: _leaderboard.length + 1,
        memberId: memberId,
        memberNama: memberNama,
        totalPoin: poinDiff,
        tier: poinDiff >= 1200 ? 'Gold' : (poinDiff >= 800 ? 'Silver' : (poinDiff >= 400 ? 'Bronze' : 'Member')),
      ));
    }

    _leaderboard.sort((a, b) => b.totalPoin.compareTo(a.totalPoin));

    for (int i = 0; i < _leaderboard.length; i++) {
      _leaderboard[i] = _leaderboard[i].copyWith(rank: i + 1);
    }
  }
}

class ApiPoinRepository extends PoinRepository {
  List<PoinEntryModel> _poinEntries = [];
  List<LeaderboardEntryModel> _leaderboard = [];

  ApiPoinRepository() {
    _loadPoin();
  }

  Future<void> _loadPoin() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _poinEntries = List.from(dummyPoinEntries);
    _leaderboard = List.from(dummyLeaderboard);
    notifyListeners();
  }

  @override
  List<PoinEntryModel> get poinEntries => List.unmodifiable(_poinEntries);
  
  @override
  List<LeaderboardEntryModel> get leaderboard => List.unmodifiable(_leaderboard);

  @override
  void addPoinEntry(PoinEntryModel entry) {
    // POST /api/poin
    _poinEntries.insert(0, entry);
    _recalculateLeaderboard(entry.memberId, entry.memberNama, entry.poin);
    notifyListeners();
  }

  void _recalculateLeaderboard(String memberId, String memberNama, int poinDiff) {
    final idx = _leaderboard.indexWhere((l) => l.memberId == memberId);
    if (idx != -1) {
      final updatedPoin = _leaderboard[idx].totalPoin + poinDiff;
      String newTier = 'Member';
      if (updatedPoin >= 1200) {
        newTier = 'Gold';
      } else if (updatedPoin >= 800) {
        newTier = 'Silver';
      } else if (updatedPoin >= 400) {
        newTier = 'Bronze';
      }
      _leaderboard[idx] = _leaderboard[idx].copyWith(
        totalPoin: updatedPoin,
        tier: newTier,
      );
    } else {
      _leaderboard.add(LeaderboardEntryModel(
        rank: _leaderboard.length + 1,
        memberId: memberId,
        memberNama: memberNama,
        totalPoin: poinDiff,
        tier: poinDiff >= 1200 ? 'Gold' : (poinDiff >= 800 ? 'Silver' : (poinDiff >= 400 ? 'Bronze' : 'Member')),
      ));
    }

    _leaderboard.sort((a, b) => b.totalPoin.compareTo(a.totalPoin));

    for (int i = 0; i < _leaderboard.length; i++) {
      _leaderboard[i] = _leaderboard[i].copyWith(rank: i + 1);
    }
  }
}

