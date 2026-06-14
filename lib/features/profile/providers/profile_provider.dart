import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Cek apakah user sudah punya profil
  Future<bool> checkProfileExists(String userId) async {
    try {
      return await _service.hasProfile(userId);
    } catch (_) {
      return false;
    }
  }

  /// Load profil dari Supabase
  Future<void> loadProfile(String userId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _profile = await _service.getProfile(userId);
    } catch (e) {
      _errorMessage = 'Gagal memuat profil: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Simpan profil baru (onboarding)
  Future<bool> saveProfile(UserProfile profile) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _service.saveProfile(profile);
      _profile = profile;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyimpan profil: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }
}
