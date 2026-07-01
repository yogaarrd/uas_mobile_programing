import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../../../shared/widgets/custom_input_field.dart';
import '../../../shared/widgets/custom_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      if (event == AuthChangeEvent.signedIn && session != null) {
        if (mounted) {
          context.go('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ FIX: Null-safe form validation, error via SnackBar
  Future<void> _handleRegister() async {
    context.read<AuthProvider>().clearError();

    if (_formKey.currentState?.validate() != true) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );

    if (!mounted) return;

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
    // Navigasi ke /onboarding ditangani oleh _authSubscription di initState
  }

  Future<void> _handleGoogleLogin() async {
    context.read<AuthProvider>().clearError();
    await context.read<AuthProvider>().loginWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Form SELALU terlihat. Tidak ada lagi penggantian Scaffold saat error.
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Akun Baru')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomInputField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  icon: Icons.person,
                  validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  validator: (v) =>
                      v!.isEmpty || !v.contains('@') ? 'Masukkan email yang valid' : null,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                  validator: (v) => v!.length < 6 ? 'Password minimal 6 karakter' : null,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Daftar',
                  onPressed: _handleRegister,
                  isLoading: authProvider.isLoading,
                ),
                const SizedBox(height: 16),
                const Text('ATAU', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                OutlinedButton.icon(
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
                  onPressed: authProvider.isLoading ? null : () => context.go('/login'),
                  child: const Text('Sudah punya akun? Login disini'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}