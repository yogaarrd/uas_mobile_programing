import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
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
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    if (authProvider.user != null) {
      final userId = authProvider.user!.id;
      final profileProvider = context.read<ProfileProvider>();
      final hasProfile = await profileProvider.checkProfileExists(userId);

      if (!mounted) return;

      if (hasProfile) {
        context.go('/home');
      } else {
        // User login tapi belum punya profil → onboarding
        context.go('/onboarding');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
             'assets/image/MorepsLogo.png', // Sesuaikan path-nya
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 10),
            Text(
              'Moreps',
              style: textTheme.headlineLarge?.copyWith(
                color: AppTheme.neonGreen,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: AppTheme.neonGreen),
          ],
        ),
      ),
    );
  }
}
