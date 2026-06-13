import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
// 1. Class AuthProvider tetap di luar
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? get user => _authService.currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<bool> register(String email, String password, String name) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.signUp(email: email, password: password, name: name);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan yang tidak diketahui';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.signIn(email: email, password: password);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan yang tidak diketahui';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      final success = await _authService.signInWithGoogle();
      _setLoading(false);
      return success;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan OAuth';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    notifyListeners();
  }
}

// // 2. Provider Riverpod ditaruh DI LUAR class
// final authProvider = ChangeNotifierProvider <AuthProvider>((ref) {
//   return AuthProvider();
// });
