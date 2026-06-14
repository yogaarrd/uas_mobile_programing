import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Cek apakah profil sudah ada untuk user yang sedang login
  Future<bool> hasProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select('id')
        .eq('id', userId)
        .maybeSingle();
    return response != null;
  }

  /// Ambil profil user berdasarkan userId
  Future<UserProfile?> getProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  /// Simpan profil baru (INSERT) saat onboarding
  Future<void> saveProfile(UserProfile profile) async {
    await _supabase.from('profiles').insert(profile.toJson());
  }

  /// Update profil yang sudah ada
  Future<void> updateProfile(UserProfile profile) async {
    await _supabase
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id);
  }
}
