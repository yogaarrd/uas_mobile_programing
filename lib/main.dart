import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/register_page.dart';
import 'features/auth/pages/splash_page.dart';
import 'features/home/pages/home_page.dart'; 
import 'core/navigation/main_wrapper.dart'; 
import 'core/theme/app_theme.dart'; 

// === IMPORT INI DITAMBAHKAN UNTUK INF-03 ===
import 'shared/widgets/global_feedback.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

 
  // Menangkap error UI secara global agar terhindar dari Red Screen of Death
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // Print error asli di terminal untuk keperluan debug developer
    debugPrint(details.exceptionAsString()); 
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppTheme.darkBackground, // Menggunakan warna dari tema
        body: GlobalFeedback.errorMessage(
          'Ups! Ada yang salah dengan tampilan ini.\nTim kami akan segera memperbaikinya.',
          () {
            // Bisa dikosongkan, atau biarkan user klik tapi tidak melakukan apa-apa 
            // karena ini error fatal pada UI, bukan pada koneksi data.
          },
        ),
      ),
    );
  };

  runApp(const ProviderScope(child: MyApp()));
}

// Konfigurasi Rute Aplikasi
final GoRouter _router = GoRouter(
  initialLocation: '/', 
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
    GoRoute(path: '/home', builder: (context, state) => const MainWrapper()),

    // Rute Placeholder (Agar tombol + dan Start tidak crash saat di-klik)
    GoRoute(
      path: '/create-workout', 
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Create Workout')),
        body: const Center(child: Text('Under Construction: Workout Builder')),
      ),
    ),
    GoRoute(
      path: '/active-session/:id', 
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Active Session')),
        body: Center(child: Text('Under Construction: Session ID ${state.pathParameters['id']}')),
      ),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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