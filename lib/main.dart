import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Tetap pastikan Riverpod terimport

import 'features/auth/providers/auth_provider.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/register_page.dart';
import 'features/auth/pages/splash_page.dart';
import 'features/home/pages/home_page.dart'; // 2. KOREKSI: Jalur import HomePage disesuaikan dengan folder baru
import 'core/navigation/main_wrapper.dart'; // 3. Pastikan MainWrapper terimport untuk rute navigasi

import 'core/theme/app_theme.dart'; // 6. KOREKSI: Pastikan AppTheme terimport untuk digunakan di MaterialApp

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 4. KOREKSI: MyApp wajib dibungkus ProviderScope agar state management Riverpod aktif secara global
  runApp(const ProviderScope(child: MyApp()));
}

// Konfigurasi Rute Aplikasi
final GoRouter _router = GoRouter(
  initialLocation: '/', 
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
    
    // 5. KOREKSI: Ubah tujuan rute /home dari HomePage menuju ke MainWrapper
    // Ini krusial agar saat aplikasi masuk ke halaman utama, Bottom Navigation Bar langsung ikut tampil
    GoRoute(path: '/home', builder: (context, state) => const MainWrapper()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider bawaan temanmu tetap dipertahankan utuh agar fitur autentikasi tidak rusak
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp.router(
        title: 'GymApp',
        theme: AppTheme.darkTheme, 
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}