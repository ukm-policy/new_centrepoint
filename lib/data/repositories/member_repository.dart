import 'package:flutter/foundation.dart';
import 'repository_load_state.dart';
import '../../core/errors/app_exception.dart';
import '../models/jabatan_model.dart';
import '../models/member_model.dart';
import '../dummy/dummy_members.dart';

abstract class MemberRepository extends ChangeNotifier with RepositoryLoadState {
  List<MemberModel> get members;
  Future<void> addMember(MemberModel member);
  Future<void> updateMember(MemberModel member);
  Future<void> updatePoin(String id, int poinChange);
  Future<void> verifyMember(String id);
  Future<void> updateStatusAndLevel(String id, {required String status, required int level, bool? isAdmin});

  /// Semua jabatan yang tersedia (tabel `jabatan`).
  Future<List<JabatanModel>> fetchJabatan() async => const [];

  /// Jabatan tiap anggota pada [periodeId]: userId → jabatanId.
  Future<Map<String, int>> fetchKepengurusan(String periodeId) async => const {};

  /// Set jabatan [userId] pada [periodeId]; null = hapus jabatan.
  Future<void> setJabatan(String userId, String periodeId, int? jabatanId) async =>
      throw const AppException('Pengaturan jabatan belum didukung.');
}

class DummyMemberRepository extends MemberRepository {
  final List<MemberModel> _members = List.from(dummyMembers);

  @override
  List<MemberModel> get members => List.unmodifiable(_members);

  @override
  Future<void> addMember(MemberModel member) async {
    _members.add(member);
    notifyListeners();
  }

  @override
  Future<void> updateMember(MemberModel member) async {
    final idx = _members.indexWhere((m) => m.id == member.id);
    if (idx != -1) {
      _members[idx] = member;
      notifyListeners();
    }
  }

  @override
  Future<void> updatePoin(String id, int poinChange) async {
    final idx = _members.indexWhere((m) => m.id == id);
    if (idx != -1) {
      final currentPoin = _members[idx].totalPoin + poinChange;
      String newTier = 'Member';
      if (currentPoin >= 1200) {
        newTier = 'Gold';
      } else if (currentPoin >= 800) {
        newTier = 'Silver';
      } else if (currentPoin >= 400) {
        newTier = 'Bronze';
      }
      _members[idx] = _members[idx].copyWith(
        totalPoin: currentPoin,
        tier: newTier,
      );
      notifyListeners();
    }
  }

  @override
  Future<void> verifyMember(String id) async {
    final idx = _members.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _members[idx] = _members[idx].copyWith(isActive: true, status: 'Aktif');
      notifyListeners();
    }
  }

  @override
  Future<void> updateStatusAndLevel(String id, {required String status, required int level, bool? isAdmin}) async {
    final idx = _members.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _members[idx] = _members[idx].copyWith(
        status: status,
        level: level,
        isAdmin: isAdmin ?? _members[idx].isAdmin,
      );
      notifyListeners();
    }
  }
}

class ApiMemberRepository extends MemberRepository {
  List<MemberModel> _members = [];

  ApiMemberRepository() {
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _members = List.from(dummyMembers);
    notifyListeners();
  }

  @override
  List<MemberModel> get members => List.unmodifiable(_members);

  @override
  Future<void> addMember(MemberModel member) async {
    // POST /api/members
    _members.add(member);
    notifyListeners();
  }

  @override
  Future<void> updateMember(MemberModel member) async {
    // PUT /api/members/${member.id}
    final idx = _members.indexWhere((m) => m.id == member.id);
    if (idx != -1) {
      _members[idx] = member;
      notifyListeners();
    }
  }

  @override
  Future<void> updatePoin(String id, int poinChange) async {
    // POST /api/members/$id/poin
    final idx = _members.indexWhere((m) => m.id == id);
    if (idx != -1) {
      final currentPoin = _members[idx].totalPoin + poinChange;
      _members[idx] = _members[idx].copyWith(totalPoin: currentPoin);
      notifyListeners();
    }
  }

  @override
  Future<void> verifyMember(String id) async {
    // POST /api/members/$id/verify
    final idx = _members.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _members[idx] = _members[idx].copyWith(isActive: true, status: 'Aktif');
      notifyListeners();
    }
  }

  @override
  Future<void> updateStatusAndLevel(String id, {required String status, required int level, bool? isAdmin}) async {
    // POST /api/members/$id/status
    final idx = _members.indexWhere((m) => m.id == id);
    if (idx != -1) {
      _members[idx] = _members[idx].copyWith(
        status: status,
        level: level,
        isAdmin: isAdmin ?? _members[idx].isAdmin,
      );
      notifyListeners();
    }
  }
}
