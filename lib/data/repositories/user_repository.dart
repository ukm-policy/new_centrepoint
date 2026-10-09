import 'package:flutter/foundation.dart';
import 'repository_load_state.dart';
import '../models/user_model.dart';
import '../dummy/dummy_users.dart';

abstract class UserRepository extends ChangeNotifier with RepositoryLoadState {
  List<UserModel> get users;
  Future<void> addUser(UserModel user);
  Future<void> updateUser(UserModel user);
  Future<void> verifyUser(String id);
}

class DummyUserRepository extends UserRepository {
  final List<UserModel> _users = List.from(dummyUsers);

  @override
  List<UserModel> get users => List.unmodifiable(_users);

  @override
  Future<void> addUser(UserModel user) async {
    _users.add(user);
    notifyListeners();
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) {
      _users[idx] = user;
      notifyListeners();
    }
  }

  @override
  Future<void> verifyUser(String id) async {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      _users[idx] = _users[idx].copyWith(isVerified: true, role: 'anggota');
      notifyListeners();
    }
  }
}

class ApiUserRepository extends UserRepository {
  List<UserModel> _users = [];

  ApiUserRepository() {
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _users = List.from(dummyUsers);
    notifyListeners();
  }

  @override
  List<UserModel> get users => List.unmodifiable(_users);

  @override
  Future<void> addUser(UserModel user) async {
    // POST /api/users
    _users.add(user);
    notifyListeners();
  }

  @override
  Future<void> updateUser(UserModel user) async {
    // PUT /api/users/${user.id}
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) {
      _users[idx] = user;
      notifyListeners();
    }
  }

  @override
  Future<void> verifyUser(String id) async {
    // POST /api/users/$id/verify
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      _users[idx] = _users[idx].copyWith(isVerified: true, role: 'anggota');
      notifyListeners();
    }
  }
}
