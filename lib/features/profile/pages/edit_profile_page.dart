import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;

  late FitnessGoal _selectedGoal;
  Uint8List? _pickedImageBytes;
  String? _pickedFileName;

  final List<Map<String, dynamic>> _goalOptions = [
    {
      'goal': FitnessGoal.strength,
      'icon': Icons.fitness_center,
      'label': 'Strength',
      'color': const Color(0xFFFF6B35),
    },
    {
      'goal': FitnessGoal.hypertrophy,
      'icon': Icons.accessibility_new,
      'label': 'Hypertrophy',
      'color': const Color(0xFF7B61FF),
    },
    {
      'goal': FitnessGoal.weightLoss,
      'icon': Icons.monitor_weight_outlined,
      'label': 'Weight Loss',
      'color': const Color(0xFF00D4AA),
    },
    {
      'goal': FitnessGoal.generalFitness,
      'icon': Icons.directions_run,
      'label': 'General Fitness',
      'color': AppTheme.neonGreen,
    },
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _weightController =
        TextEditingController(text: profile?.weightKg.toString() ?? '');
    _heightController =
        TextEditingController(text: profile?.heightCm.toString() ?? '');
    _selectedGoal = profile?.goal ?? FitnessGoal.generalFitness;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _pickedImageBytes = bytes;
      _pickedFileName = picked.name;
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProfileProvider>();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    // 1. Upload foto baru jika ada
    if (_pickedImageBytes != null && _pickedFileName != null) {
      final uploaded = await provider.uploadAndSaveAvatar(
        userId: userId,
        fileBytes: _pickedImageBytes!,
        fileName: _pickedFileName!,
      );
      if (!mounted) return;
      if (!uploaded) {
        _showSnackbar(provider.errorMessage ?? 'Gagal upload foto', isError: true);
        return;
      }
    }

    // 2. Simpan perubahan data profil
    final current = provider.profile!;
    final updated = current.copyWith(
      fullName: _nameController.text.trim(),
      weightKg: double.parse(_weightController.text.trim()),
      heightCm: double.parse(_heightController.text.trim()),
      goal: _selectedGoal,
    );

    final success = await provider.updateProfile(updated);
    if (!mounted) return;

    if (success) {
      _showSnackbar('Profil berhasil diperbarui ✓');
      context.pop();
    } else {
      _showSnackbar(provider.errorMessage ?? 'Gagal menyimpan', isError: true);
    }
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : AppTheme.neonGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final profile = provider.profile;
    final isLoading = provider.isLoading || provider.isUploadingAvatar;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: isLoading ? null : _handleSave,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: AppTheme.neonGreen,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(
                        color: AppTheme.neonGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Avatar ────────────────────────────────────────
              Center(child: _buildAvatarPicker(profile, provider.isUploadingAvatar)),
              const SizedBox(height: 36),

              // ─── Nama ──────────────────────────────────────────
              _buildLabel('Nama Lengkap'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: 'Nama lengkap',
                icon: Icons.person_outline,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Nama tidak boleh kosong';
                  if (v.trim().length < 2) return 'Nama minimal 2 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ─── Berat & Tinggi ────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Berat (kg)'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _weightController,
                          hint: '70',
                          icon: Icons.monitor_weight_outlined,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                            final n = double.tryParse(v);
                            if (n == null) return 'Angka tidak valid';
                            if (n < 20 || n > 300) return '20–300 kg';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tinggi (cm)'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _heightController,
                          hint: '170',
                          icon: Icons.height,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                            final n = double.tryParse(v);
                            if (n == null) return 'Angka tidak valid';
                            if (n < 100 || n > 250) return '100–250 cm';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ─── Goal ──────────────────────────────────────────
              _buildLabel('Goal Kebugaran'),
              const SizedBox(height: 12),
              _buildGoalSelector(),
              const SizedBox(height: 40),

              // ─── Tombol Simpan ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSave,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Avatar Picker ──────────────────────────────────────────
  Widget _buildAvatarPicker(UserProfile? profile, bool isUploading) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Lingkaran avatar
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E1E2A),
            border: Border.all(color: AppTheme.neonGreen.withAlpha(100), width: 2),
          ),
          child: ClipOval(
            child: isUploading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.neonGreen),
                  )
                : _pickedImageBytes != null
                    ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                    : (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty)
                        ? Image.network(
                            profile.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _defaultAvatar(),
                          )
                        : _defaultAvatar(),
          ),
        ),
        // Tombol kamera kecil
        GestureDetector(
          onTap: isUploading ? null : _pickImage,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.neonGreen,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.darkBackground, width: 2),
            ),
            child: const Icon(Icons.camera_alt, color: Colors.black, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: const Color(0xFF2A2A3A),
      child: const Icon(Icons.person, color: Colors.grey, size: 52),
    );
  }

  // ─── Goal Selector ──────────────────────────────────────────
  Widget _buildGoalSelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.8,
      ),
      itemCount: _goalOptions.length,
      itemBuilder: (context, index) {
        final opt = _goalOptions[index];
        final goal = opt['goal'] as FitnessGoal;
        final color = opt['color'] as Color;
        final isSelected = _selectedGoal == goal;

        return GestureDetector(
          onTap: () => setState(() => _selectedGoal = goal),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isSelected ? color.withAlpha(38) : const Color(0xFF1E1E2A),
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade800,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(opt['icon'] as IconData, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    opt['label'] as String,
                    style: TextStyle(
                      color: isSelected ? color : Colors.white70,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: color, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Helpers ────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
        filled: true,
        fillColor: const Color(0xFF1E1E2A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.neonGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        errorStyle: const TextStyle(fontSize: 11),
      ),
    );
  }
}
