import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../dummy/dummy_users.dart';

abstract class UserRepository extends ChangeNotifier {
  List<UserModel> get users;
  void addUser(UserModel user);
  void updateUser(UserModel user);
  void verifyUser(String id);
}

class DummyUserRepository extends UserRepository {
  final List<UserModel> _users = List.from(dummyUsers);

  @override
  List<UserModel> get users => List.unmodifiable(_users);

  @override
  void addUser(UserModel user) {
    _users.add(user);
    notifyListeners();
  }

  @override
  void updateUser(UserModel user) {
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) {
      _users[idx] = user;
      notifyListeners();
    }
  }

  @override
  void verifyUser(String id) {
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
  void addUser(UserModel user) {
    // POST /api/users
    _users.add(user);
    notifyListeners();
  }

  @override
  void updateUser(UserModel user) {
    // PUT /api/users/${user.id}
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) {
      _users[idx] = user;
      notifyListeners();
    }
  }

  @override
  void verifyUser(String id) {
    // POST /api/users/$id/verify
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx != -1) {
      _users[idx] = _users[idx].copyWith(isVerified: true, role: 'anggota');
      notifyListeners();
    }
  }
}
