import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/bottom_nav_provider.dart'; // Import provider navigasi
import '../../workout/providers/workout_provider.dart';
import '../../workout/models/workout_template.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../features/workout/pages/exercise_library_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null && mounted) {
        final profileProv = context.read<ProfileProvider>();
        if (profileProv.profile == null && !profileProv.isLoading) {
          profileProv.loadProfile(userId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);

          return Scaffold(
            backgroundColor: AppTheme.darkBackground,
            floatingActionButton: AnimatedBuilder(
              animation: tabController,
              builder: (context, child) {
                return tabController.index == 0
                    ? FloatingActionButton(
                        backgroundColor: AppTheme.neonGreen,
                        onPressed: () => context.push('/create-workout'),
                        child: const Icon(Icons.add, color: Colors.black),
                      )
                    : const SizedBox.shrink();
              },
            ),

            appBar: AppBar(
              backgroundColor: AppTheme.darkBackground,
              elevation: 0,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/image/MorepsLogo.png', // Logo kecil untuk AppBar
                    height: 60, // Sesuaikan tinggi agar pas di AppBar
                  ),
                  // Jarak antara logo dan teks
                  const Text(
                    'Moreps',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
              bottom: const TabBar(
                indicatorColor: AppTheme.neonGreen,
                labelColor: AppTheme.neonGreen,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'My Workouts'),
                  Tab(text: 'Library'),
                ],
              ),
            ),

            body: const TabBarView(
              children: [MyWorkoutsView(), ExerciseLibraryTab()],
            ),
          );
        },
      ),
    );
  }
}

class MyWorkoutsView extends ConsumerWidget {
  const MyWorkoutsView({super.key});

  // Fungsi kecerdasan waktu untuk sapaan
  String _getDynamicGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  // Fungsi untuk mendapatkan tanggal saat ini dengan format Bahasa Indonesia
  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(workoutTemplatesProvider);
    final profileProv = context.watch<ProfileProvider>();
    final profile = profileProv.profile;

    String userName = 'Fighter';
    if (profile != null) {
      userName = profile.fullName.split(' ')[0];
    } else {
      final email = Supabase.instance.client.auth.currentUser?.email;
      if (email != null) userName = email.split('@')[0];
    }

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(workoutTemplatesProvider.future),
      color: AppTheme.neonGreen,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: _buildPremiumGreetingCard(
                ref,
                userName,
              ), // Berikan parameter ref di sini
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Template Latihan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          templatesAsync.when(
            data: (templates) {
              if (templates.isEmpty) {
                return SliverToBoxAdapter(child: _buildEmptyState(context));
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _WorkoutTemplateCard(template: templates[index]),
                    );
                  }, childCount: templates.length),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.neonGreen),
                ),
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: Text(
                    'Terjadi kesalahan:\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  // DESAIN CARD SAPAAN PREMIUM (TANGGAL, DARK BADGE & TOMBOL AKSI)
  Widget _buildPremiumGreetingCard(WidgetRef ref, String userName) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppTheme.neonGreen, Color(0xFF9EBA00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonGreen.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TANGGAL HARI INI (Di atas sapaan)
          Text(
            _getFormattedDate(),
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.black87.withOpacity(
                0.6,
              ), // Warna agak redup agar tidak mengalahkan sapaan
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),

          // 2. SAPAAN (Semibold)
          Text(
            _getDynamicGreeting(),
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),

          // 3. NAMA (Extra Bold / Black) - Dipertebal dengan w900 & spasinya dirapatkan
          Text(
            'Hello, $userName!',
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.black,
              fontSize: 32,
              fontWeight: FontWeight
                  .w900, // <-- EXTRA BOLD (Pastikan poppins terdaftar di pubspec.yaml)
              letterSpacing: -1.0,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 24),

          // 4. MOTIVASI, ICON & TOMBOL (Dark Glassmorphism)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(
                0.65,
              ), // Background kaca gelap (Dark Glass)
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black.withOpacity(
                  0.8,
                ), // Pinggiran border lebih pekat
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                // Bulat Ikon berwarna Neon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color:
                        AppTheme.neonGreen, // Warna background ikon neon green
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.black, // Warna ikon api hitam
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),

                // Teks motivasi berwarna Neon
                const Expanded(
                  child: Text(
                    'Siap pecahkan rekor?',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppTheme.neonGreen, // Warna teks neon green
                      fontSize: 12,
                      fontWeight: FontWeight.w700, // Bold
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                // --- TOMBOL BARU: CEK REKOR ---
                GestureDetector(
                  onTap: () {
                    // Pindah ke Tab Progress (Index ke-2 di Bottom Nav)
                    ref.read(bottomNavIndexProvider.notifier).changeIndex(2);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Cek Rekor',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.black,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
                // ------------------------------
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada template latihan',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/create-workout'),
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                'Buat Template Pertama',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutTemplateCard extends ConsumerWidget {
  final WorkoutTemplate template;
  const _WorkoutTemplateCard({required this.template});

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Workout?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah kamu yakin ingin menghapus template "${template.name}"?\nData yang dihapus tidak dapat dikembalikan.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(color: AppTheme.neonGreen),
          ),
        );

        final repo = ref.read(workoutRepositoryProvider);
        await repo.deleteWorkoutTemplate(template.id);

        if (!context.mounted) return;
        Navigator.pop(context);

        ref.invalidate(workoutTemplatesProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Workout berhasil dihapus',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppTheme.neonGreen,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        if (context.mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimatedTime = template.exerciseCount * 10;
    return Card(
      color: AppTheme.surfaceColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade800, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    template.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Colors.grey),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(right: 12),
                      onPressed: () =>
                          context.push('/create-workout?id=${template.id}'),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () => _handleDelete(context, ref),
                    ),
                  ],
                ),
              ],
            ),
            if (template.description != null &&
                template.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                template.description!,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: _buildBadge(
                    Icons.format_list_bulleted,
                    '${template.exerciseCount} Latihan',
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: _buildBadge(
                    Icons.timer_outlined,
                    '~ $estimatedTime mnt',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: template.muscleGroups
                  .map((m) => _buildMuscleChip(m))
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/active-session/${template.id}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Workout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 16, color: Colors.grey),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(color: Colors.grey, fontSize: 13)),
    ],
  );

  Widget _buildMuscleChip(String muscle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.neonGreen.withOpacity(0.15),
        border: Border.all(color: AppTheme.neonGreen.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        muscle.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.neonGreen,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
