import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// Repository: sits between ViewModels and AuthService. Translates raw
// Firebase exceptions into friendly messages, never lets FirebaseAuthException
// leak up to the UI layer.
class AuthResult {
  final bool success;
  final String? errorMessage;
  final User? user;

  AuthResult.success(this.user)
      : success = true,
        errorMessage = null;

  AuthResult.failure(this.errorMessage)
      : success = false,
        user = null;
}

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  User? get currentUser => _authService.currentUser;

  bool get isLoggedIn => _authService.currentUser != null;

  Future<AuthResult> signUp(String email, String password) async {
    try {
      final user = await _authService.signUpWithEmail(email, password);
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapError(e));
    }
  }

  Future<AuthResult> signIn(String email, String password) async {
    try {
      final user = await _authService.signInWithEmail(email, password);
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapError(e));
    }
  }

  Future<void> signOut() => _authService.signOut();

  Future<AuthResult> resetPassword(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapError(e));
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}