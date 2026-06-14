import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _bucket = 'avatars';

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

  /// Upload foto profil ke Supabase Storage, kembalikan URL publik
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final ext = fileName.split('.').last.toLowerCase();
    final path = '$userId/avatar.$ext';

    // Upload (upsert agar bisa replace foto lama)
    await _supabase.storage.from(_bucket).uploadBinary(
          path,
          fileBytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: 'image/$ext',
          ),
        );

    // Ambil public URL
    final publicUrl = _supabase.storage.from(_bucket).getPublicUrl(path);
    // Tambahkan timestamp agar tidak ter-cache browser
    return '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
  }
}
