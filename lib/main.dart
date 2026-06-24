import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uas_mobile_programing/features/workout/pages/active_session_page.dart';
import 'package:uas_mobile_programing/features/workout/pages/create_workout_page.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/register_page.dart';
import 'features/auth/pages/splash_page.dart';
import 'features/profile/pages/onboarding_page.dart';
import 'features/profile/pages/edit_profile_page.dart';
import 'features/profile/providers/profile_provider.dart';
import 'core/navigation/main_wrapper.dart';
import 'core/theme/app_theme.dart';

import 'shared/widgets/global_feedback.dart';

import 'core/services/notification_service.dart';

// summary after workout
import 'features/workout/pages/session_summary_page.dart';
import 'features/workout/models/session_summary_args.dart';

// Progress
import 'features/progress/pages/exercise_progress_detail_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null); // Inisialisasi locale Indonesia
  await NotificationService.init();
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
    GoRoute(path: '/edit-profile', builder: (context, state) => const EditProfilePage()),
    GoRoute(
      path: '/summary',
      builder: (context, state) {
        // Ambil extra arguments yang dikirim
        final args = state.extra as SessionSummaryArgs;
        return SessionSummaryPage(args: args);
      },
    ),
    GoRoute(
      path: '/progress/exercise/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final name = state.extra as String? ?? 'Detail Latihan';
        return ExerciseProgressDetailPage(exerciseId: id, exerciseName: name);
      },
    ),

    // Rute Placeholder
    GoRoute(
      path: '/create-workout',
      builder: (context, state) {
        // Menerima parameter ID jika mode edit
        final id = state.uri.queryParameters['id'];
        return CreateWorkoutPage(templateId: id);
      },
    ),
    GoRoute(
      path: '/active-session/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return ActiveSessionPage(templateId: id); // Panggil halaman asli
      },
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
        title: 'Moreps',
        theme: AppTheme.darkTheme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}