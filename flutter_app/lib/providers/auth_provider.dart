import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  dynamic _user;
  bool _isLoading = false;

  AuthProvider(this._authService) {
    // Listen to auth state changes and update the provider
    _authService.authStateChanges.listen((User? user) {
      if (_user == null) { // Only update if we haven't manually set a demo user
        _user = user;
        notifyListeners();
      }
    });
  }

  dynamic get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithApple() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithApple();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (email == 'demo@example.com') {
        _user = {'displayName': 'Demo User', 'email': 'demo@example.com'};
        return;
      }
      await _authService.signInWithEmail(email, password);
      _user = _authService.currentUser;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail(String email, String password, {String? name}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signUpWithEmail(email, password, name: name);
      // Manually trigger a state update to ensure the UI switches immediately
      _user = _authService.currentUser;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signOut();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
