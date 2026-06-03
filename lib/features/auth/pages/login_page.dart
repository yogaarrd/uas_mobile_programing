import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../../../shared/widgets/custom_input_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/global_feedback.dart';

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  void _handleGoogleLogin() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.loginWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // 1. Error Handling State
    if (authProvider.errorMessage != null) {
      return Scaffold(
        body: GlobalFeedback.errorMessage(
          authProvider.errorMessage!,
          () => _handleLogin(), 
        ),
      );
    }

    // 2. Loading State (Full Screen)
    if (authProvider.isLoading) {
      return Scaffold(body: GlobalFeedback.loadingIndicator());
    }

    // 3. Main Login UI
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
              
              // Custom Button dengan state loading yang terintegrasi
              CustomButton(
                text: 'Masuk',
                onPressed: _handleLogin,
                isLoading: authProvider.isLoading,
              ),
              
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
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('Belum punya akun? Daftar sekarang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}