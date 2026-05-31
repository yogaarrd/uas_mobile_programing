import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Mendapatkan user yang sedang login
  User? get currentUser => _supabase.auth.currentUser;

  // Fitur Register
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': name}, // Menyimpan nama ke metadata user
    );
  }

  // Fitur Login
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Fitur Login dengan Google OAuth
  Future<bool> signInWithGoogle() async {
    return await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.gymapp://login-callback/', // Deep link callback
    );
  }

  // Fitur Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}