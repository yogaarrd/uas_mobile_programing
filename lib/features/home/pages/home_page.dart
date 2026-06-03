import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/global_feedback.dart'; // Import ini wajib

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Memantau status dari AuthProvider
    final authProvider = context.watch<AuthProvider>();

    // 1. Error Handling State
    // Jika ada error saat memuat data, tampilkan widget error global
    if (authProvider.errorMessage != null) {
      return Scaffold(
        body: GlobalFeedback.errorMessage(authProvider.errorMessage!, () {
          // Logika untuk retry (bisa disesuaikan dengan fungsi fetch data kamu)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mencoba memuat ulang...')),
          );
        }),
      );
    }

    // 2. Loading State
    // Jika aplikasi sedang sibuk memuat data, tampilkan loading indikator global
    if (authProvider.isLoading) {
      return Scaffold(body: GlobalFeedback.loadingIndicator());
    }

    // 3. Main Content (Success State)
    final userEmail = authProvider.user?.email ?? 'Pengguna';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda GymApp', style: textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selamat Datang,\n$userEmail',
                textAlign: TextAlign.center,
                style: textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSizes.spaceMedium),
              Text(
                'Siap untuk memulai latihan hari ini?',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSizes.spaceXLarge),

              // Custom Button yang bersih
              CustomButton(
                text: 'GAS LATIHAN!',
                onPressed: () {
                  print('Mulai tracking latihan... 🔥');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
