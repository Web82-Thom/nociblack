import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/admin_profile.dart';
import '../../domain/errors/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';

/// État global de la session administrative.
enum AuthenticationStatus { checking, unauthenticated, authenticated }

/// Orchestre la session entre le repository et l'interface Flutter.
///
/// Le contrôleur ne connaît aucun widget et reste la source unique de vérité
/// pour l'écran affiché par [AuthGate].
final class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;
  StreamSubscription<bool>? _sessionSubscription;

  AuthenticationStatus _status = AuthenticationStatus.checking;
  AdminProfile? _profile;
  String? _errorMessage;
  bool _isSubmitting = false;
  bool _isRestoring = false;
  bool _isInitialized = false;

  AuthenticationStatus get status => _status;
  AdminProfile? get profile => _profile;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _sessionSubscription = _repository.sessionChanges.listen(
      _handleSessionChange,
    );
    await _restoreSession();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.signIn(email: email, password: password);
      _status = AuthenticationStatus.authenticated;
      return true;
    } on AuthFailure catch (failure) {
      _profile = null;
      _status = AuthenticationStatus.unauthenticated;
      _errorMessage = failure.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _errorMessage = null;

    try {
      await _repository.signOut();
    } on AuthFailure catch (failure) {
      _errorMessage = failure.message;
    } finally {
      _profile = null;
      _status = AuthenticationStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> _restoreSession() async {
    if (_isRestoring || _isSubmitting) return;
    _isRestoring = true;

    try {
      _profile = await _repository.getCurrentProfile();
      _status = _profile == null
          ? AuthenticationStatus.unauthenticated
          : AuthenticationStatus.authenticated;
    } on AuthFailure catch (failure) {
      _profile = null;
      _status = AuthenticationStatus.unauthenticated;
      _errorMessage = failure.message;
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }

  void _handleSessionChange(bool hasSession) {
    if (!hasSession) {
      _profile = null;
      _status = AuthenticationStatus.unauthenticated;
      notifyListeners();
      return;
    }

    if (_status != AuthenticationStatus.authenticated) {
      unawaited(_restoreSession());
    }
  }

  @override
  void dispose() {
    unawaited(_sessionSubscription?.cancel());
    super.dispose();
  }
}
