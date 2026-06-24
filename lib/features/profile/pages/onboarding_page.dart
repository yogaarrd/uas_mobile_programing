import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  DateTime? _selectedDate;
  FitnessGoal _selectedGoal = FitnessGoal.generalFitness;
  int _currentStep = 0;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _goalOptions = [
    {
      'goal': FitnessGoal.strength,
      'icon': Icons.fitness_center,
      'title': 'Strength',
      'subtitle': 'Angkat lebih berat, jadi lebih kuat',
      'color': const Color(0xFFFF6B35),
    },
    {
      'goal': FitnessGoal.hypertrophy,
      'icon': Icons.accessibility_new,
      'title': 'Hypertrophy',
      'subtitle': 'Besarkan otot & tingkatkan massa',
      'color': const Color(0xFF7B61FF),
    },
    {
      'goal': FitnessGoal.weightLoss,
      'icon': Icons.monitor_weight_outlined,
      'title': 'Weight Loss',
      'subtitle': 'Bakar lemak & capai berat ideal',
      'color': const Color(0xFF00D4AA),
    },
    {
      'goal': FitnessGoal.generalFitness,
      'icon': Icons.directions_run,
      'title': 'General Fitness',
      'subtitle': 'Hidup sehat & aktif setiap hari',
      'color': AppTheme.neonGreen,
    },
  ];

  @override
  void initState() {
    super.initState();

    // Pre-fill nama dari metadata Supabase (diisi saat register)
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final displayName =
          user.userMetadata?['display_name'] as String? ??
          user.userMetadata?['full_name'] as String? ??
          '';
      if (displayName.isNotEmpty) {
        _nameController.text = displayName;
      }
    }

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _animateToNextStep() {
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 10, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.neonGreen,
              surface: Color(0xFF1E1E26),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showSnackbar('Pilih tanggal lahir terlebih dahulu', isError: true);
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      _showSnackbar('Sesi tidak valid, silakan login ulang', isError: true);
      return;
    }

    final profile = UserProfile(
      id: userId,
      fullName: _nameController.text.trim(),
      birthDate: _selectedDate!,
      weightKg: double.parse(_weightController.text.trim()),
      heightCm: double.parse(_heightController.text.trim()),
      goal: _selectedGoal,
    );

    final provider = context.read<ProfileProvider>();
    final success = await provider.saveProfile(profile);

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      _showSnackbar(
        provider.errorMessage ?? 'Gagal menyimpan profil',
        isError: true,
      );
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppTheme.neonGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: _currentStep == 0
                          ? _buildStepOne()
                          : _buildStepTwo(provider),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: AppTheme.neonGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Moreps',
                style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _currentStep == 0 ? 'Kenalkan dirimu 👋' : 'Goal kebugaran kamu 🎯',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentStep == 0
                ? 'Isi data dirimu agar latihan lebih personal'
                : 'Pilih tujuan utama latihanmu sekarang',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ─── STEP INDICATOR ─────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(2, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 1 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isActive ? AppTheme.neonGreen : Colors.grey.shade800,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── STEP 1: Data Diri ───────────────────────────────────────
  Widget _buildStepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Nama Lengkap
        _buildLabel('Nama Lengkap'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _nameController,
          hint: 'Contoh: Budi Santoso',
          icon: Icons.person_outline,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Nama tidak boleh kosong';
            if (v.trim().length < 2) return 'Nama minimal 2 karakter';
            return null;
          },
        ),

        const SizedBox(height: 24),

        // Tanggal Lahir
        _buildLabel('Tanggal Lahir'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _selectedDate != null
                    ? AppTheme.neonGreen.withAlpha(128)
                    : Colors.grey.shade800,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: _selectedDate != null ? AppTheme.neonGreen : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? _formatDate(_selectedDate!)
                      : 'Pilih tanggal lahir',
                  style: TextStyle(
                    color: _selectedDate != null ? Colors.white : Colors.grey,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 20),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Berat & Tinggi Badan (2 kolom)
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Berat Badan (kg)'),
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
                      final num = double.tryParse(v);
                      if (num == null) return 'Angka tidak valid';
                      if (num < 20 || num > 300) return '20–300 kg';
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
                  _buildLabel('Tinggi Badan (cm)'),
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
                      final num = double.tryParse(v);
                      if (num == null) return 'Angka tidak valid';
                      if (num < 100 || num > 250) return '100–250 cm';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        // Tombol Lanjut
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (_selectedDate == null) {
                  _showSnackbar('Pilih tanggal lahir terlebih dahulu', isError: true);
                  return;
                }
                setState(() => _currentStep = 1);
                _animateToNextStep();
              }
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lanjut', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── STEP 2: Pilih Goal ────────────────────────────────────
  Widget _buildStepTwo(ProfileProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Grid pilihan goal
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: _goalOptions.length,
          itemBuilder: (context, index) {
            final option = _goalOptions[index];
            final goal = option['goal'] as FitnessGoal;
            final isSelected = _selectedGoal == goal;
            final color = option['color'] as Color;

            return GestureDetector(
              onTap: () => setState(() => _selectedGoal = goal),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected ? color.withAlpha(38) : const Color(0xFF1E1E2A),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade800,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withAlpha(64),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withAlpha(38),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(option['icon'] as IconData, color: color, size: 22),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            child: const Icon(Icons.check, color: Colors.black, size: 14),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option['title'] as String,
                          style: TextStyle(
                            color: isSelected ? color : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option['subtitle'] as String,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 36),

        // Tombol Kembali + Selesai
        Row(
          children: [
            SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _currentStep = 0);
                  _animateToNextStep();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 20, color: Colors.grey),
                    SizedBox(width: 6),
                    Text('Kembali', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _handleSubmit,
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
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
                              'Mulai Latihan!',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── HELPER WIDGETS ─────────────────────────────────────────
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
    bool isPassword = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
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
