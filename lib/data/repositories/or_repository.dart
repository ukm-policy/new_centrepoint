import 'package:flutter/foundation.dart';
import 'repository_load_state.dart';
import '../models/or_model.dart';
import '../dummy/dummy_or.dart';

abstract class ORRepository extends ChangeNotifier with RepositoryLoadState {
  ORPeriodeModel get orPeriode;
  List<ORApplicantModel> get applicants;
  Future<void> updatePeriode(ORPeriodeModel p);
  Future<void> addApplicant(ORApplicantModel app);
  Future<void> reviewApplicant(String id, ApplicantStatus status, {String? catatan});
}

class DummyORRepository extends ORRepository {
  ORPeriodeModel _periode = dummyOrPeriode;
  final List<ORApplicantModel> _applicants = List.from(dummyApplicants);

  @override
  ORPeriodeModel get orPeriode => _periode;
  
  @override
  List<ORApplicantModel> get applicants => List.unmodifiable(_applicants);

  @override
  Future<void> updatePeriode(ORPeriodeModel p) async {
    _periode = p;
    notifyListeners();
  }

  @override
  Future<void> addApplicant(ORApplicantModel app) async {
    _applicants.add(app);
    notifyListeners();
  }

  @override
  Future<void> reviewApplicant(String id, ApplicantStatus status, {String? catatan}) async {
    final idx = _applicants.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _applicants[idx] = _applicants[idx].copyWith(
        status: status,
        catatan: catatan,
      );
      notifyListeners();
    }
  }
}

class ApiORRepository extends ORRepository {
  ORPeriodeModel _periode = dummyOrPeriode;
  List<ORApplicantModel> _applicants = [];

  ApiORRepository() {
    _loadORData();
  }

  Future<void> _loadORData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _periode = dummyOrPeriode;
    _applicants = List.from(dummyApplicants);
    notifyListeners();
  }

  @override
  ORPeriodeModel get orPeriode => _periode;
  
  @override
  List<ORApplicantModel> get applicants => List.unmodifiable(_applicants);

  @override
  Future<void> updatePeriode(ORPeriodeModel p) async {
    // POST /api/or/periode
    _periode = p;
    notifyListeners();
  }

  @override
  Future<void> addApplicant(ORApplicantModel app) async {
    // POST /api/or/apply
    _applicants.add(app);
    notifyListeners();
  }

  @override
  Future<void> reviewApplicant(String id, ApplicantStatus status, {String? catatan}) async {
    // POST /api/or/applicants/$id/review
    final idx = _applicants.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _applicants[idx] = _applicants[idx].copyWith(
        status: status,
        catatan: catatan,
      );
      notifyListeners();
    }
  }
}

