import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bottom_nav_provider.dart';
import '../../features/home/pages/home_page.dart'; // Import halaman buatan temanmu

class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pantau tab mana yang sedang aktif
    final currentIndex = ref.watch(bottomNavIndexProvider);

    // Daftar halaman untuk setiap tab
    final List<Widget> pages = const [
      HomePage(), // Index 0: Fitur Home temanmu
      Center(child: Text("History")), // Index 1: Placeholder History
      Center(child: Text("Progress")), // Index 2: Placeholder Progress
      Center(child: Text("Profile")), // Index 3: Placeholder Profile
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blueAccent,
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
