import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

// ViewModel: holds UI state for auth screens (login/signup/reset password).
// Views watch this via context.watch<AuthViewModel>() and never touch
// FirebaseAuth or AuthRepository directly.
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    _authRepository.authStateChanges.listen(_onAuthStateChanged);
  }

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  User? _currentUser;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isLoading => _status == AuthStatus.loading;

  void _onAuthStateChanged(User? user) {
    _currentUser = user;
    _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _setLoading();
    final result = await _authRepository.signIn(email.trim(), password);
    _handleResult(result);
  }

  Future<void> signUp(String email, String password) async {
    _setLoading();
    final result = await _authRepository.signUp(email.trim(), password);
    _handleResult(result);
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  Future<bool> resetPassword(String email) async {
    _setLoading();
    final result = await _authRepository.resetPassword(email.trim());
    if (!result.success) {
      _status = AuthStatus.error;
      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    }
    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return true;
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _handleResult(AuthResult result) {
    if (!result.success) {
      _status = AuthStatus.error;
      _errorMessage = result.errorMessage;
      notifyListeners();
    }
    // success case is handled by the authStateChanges listener
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}