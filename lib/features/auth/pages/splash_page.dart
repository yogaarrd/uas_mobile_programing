import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
// Import tema kita
import '../../../core/theme/app_theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Delay 2 detik untuk kesan profesional
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // Cek session
    if (authProvider.user != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil gaya teks dari tema global
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground, // Background hitam neon
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon dengan warna Neon Hijau
            const Icon(
              Icons.fitness_center,
              size: 100,
              color: AppTheme.neonGreen,
            ),
            const SizedBox(height: 24),
            Text(
              'GymApp',
              style: textTheme.headlineLarge?.copyWith(
                color: AppTheme.neonGreen, // Teks judul warna neon
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator warna neon agar senada
            const CircularProgressIndicator(color: AppTheme.neonGreen),
          ],
        ),
      ),
    );
  }
}
