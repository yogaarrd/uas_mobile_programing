import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
// 1. Import AppSizes untuk jarak konsisten
import '../../../core/theme/app_sizes.dart';
// 2. Import CustomButton buatanmu
import '../../../shared/widgets/custom_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userEmail = authProvider.user?.email ?? 'Pengguna';
    
    // 3. Ambil TextTheme dari app_theme.dart yang sedang aktif
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
          )
        ],
      ),
      body: Center(
        child: Padding(
          // Gunakan AppSizes untuk padding
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selamat Datang,\n$userEmail',
                textAlign: TextAlign.center,
                style: textTheme.headlineLarge, // Gunakan font besar dari tema
              ),
              const SizedBox(height: AppSizes.spaceMedium), // Gunakan jarak dari AppSizes
              Text(
                'Siap untuk memulai latihan hari ini?',
                style: textTheme.bodyLarge, // Gunakan font reguler dari tema
              ),
              const SizedBox(height: AppSizes.spaceXLarge), // Jarak yang lebih besar sebelum tombol
              
              // 4. Tombol yang sudah menggunakan Design System
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