import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bottom_nav_provider.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/progress/pages/progress_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../core/theme/app_theme.dart'; // Import AppTheme kita
import '../../features/history/pages/workout_history_page.dart'; // Import halaman history yang sudah kamu buat

class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final List<Widget> pages = const [
      HomePage(),
      WorkoutHistoryPage(),
      ProgressPage(),
      ProfilePage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        // Gunakan warna dari AppTheme kita!
        backgroundColor: AppTheme.surfaceColor,
        selectedItemColor: AppTheme.neonGreen,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).changeIndex(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
