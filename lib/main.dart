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
import 'features/profile/pages/onboarding_page.dart';
import 'features/profile/providers/profile_provider.dart';
import 'core/navigation/main_wrapper.dart';
import 'core/theme/app_theme.dart';

import 'shared/widgets/global_feedback.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint(details.exceptionAsString());
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: GlobalFeedback.errorMessage(
          'Ups! Ada yang salah dengan tampilan ini.\nTim kami akan segera memperbaikinya.',
          () {},
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
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingPage()),
    GoRoute(path: '/home', builder: (context, state) => const MainWrapper()),

    // Rute Placeholder
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
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
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