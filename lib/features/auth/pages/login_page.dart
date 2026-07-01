import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../shared/widgets/custom_input_field.dart';
import '../../../shared/widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final StreamSubscription<AuthState> _authSubscription;

  // ✅ Flag untuk mencegah navigasi ganda jika event auth terpicu berkali-kali
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null && !_isNavigating) {
        _isNavigating = true;
        if (!mounted) return;

        final profileProvider = context.read<ProfileProvider>();
        final hasProfile = await profileProvider.checkProfileExists(session.user.id);

        if (!mounted) return;

        if (hasProfile) {
          context.go('/home');
        } else {
          context.go('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ FIX: Pakai ?. untuk null-safe form validation, error ditampilkan via SnackBar
  Future<void> _handleLogin() async {
    // Bersihkan error lama sebelum mencoba lagi
    context.read<AuthProvider>().clearError();

    // Null-safe validation: kalau form tidak ada di tree, langsung return
    if (_formKey.currentState?.validate() != true) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    // Tampilkan error sebagai SnackBar agar form TETAP terlihat
    if (!success && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    context.read<AuthProvider>().clearError();
    await context.read<AuthProvider>().loginWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Hanya watch isLoading untuk disable tombol saat proses berlangsung
    // TIDAK ada lagi if (errorMessage != null) return Scaffold(...) yang menghilangkan form!
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Masuk Aplikasi')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomInputField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                validator: (v) => v!.isEmpty ? 'Masukkan email Anda' : null,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                isPassword: true,
                validator: (v) => v!.isEmpty ? 'Masukkan password Anda' : null,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Masuk',
                onPressed: _handleLogin,
                isLoading: authProvider.isLoading,
              ),
              const SizedBox(height: 16),
              const Text('ATAU', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                // Disable semua tombol saat loading berlangsung
                onPressed: authProvider.isLoading ? null : _handleGoogleLogin,
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text('Continue with Google'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: authProvider.isLoading ? null : () => context.go('/register'),
                child: const Text('Belum punya akun? Daftar sekarang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}