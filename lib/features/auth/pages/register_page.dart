import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../../../shared/widgets/custom_input_field.dart';
// 1. TAMBAHKAN IMPORT CUSTOM BUTTON DI SINI
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
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      if (event == AuthChangeEvent.signedIn && session != null) {
        if (mounted) {
          context.go('/home');
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

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrasi Berhasil! Silakan masuk.')),
          );
          context.go('/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.errorMessage ?? 'Registrasi Gagal')),
          );
        }
      }
    }
  }

  void _handleGoogleLogin() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithGoogle();
    
    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Google Login Gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  validator: (v) => v!.isEmpty || !v.contains('@') ? 'Masukkan email yang valid' : null,
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
                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          // 2. GANTI ELEVATED BUTTON DENGAN CUSTOM BUTTON
                          CustomButton(
                            text: 'Daftar',
                            onPressed: _handleRegister,
                          ),
                          // ===========================================
                          const SizedBox(height: 16),
                          const Text('ATAU', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _handleGoogleLogin,
                            icon: const Icon(Icons.g_mobiledata, size: 28),
                            label: const Text('Continue with Google'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
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