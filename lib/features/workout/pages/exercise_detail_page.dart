import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/exercise_models.dart'; 

class ExerciseDetailPage extends StatelessWidget {
  final ExerciseModel exercise;

  const ExerciseDetailPage({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    // Memecah string instruksi menjadi list berdasarkan baris baru
    final List<String> instructionSteps = exercise.instructions
        .split('.')
        .where((step) => step.trim().isNotEmpty) // Buang baris yang kosong
        .map((step) => '${step.trim()}.')
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: const Text('Detail Latihan'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Otot / Latihan
            Container(
              width: double.infinity,
              height: 250,
              color: AppTheme.surfaceColor,
              child: exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty
                  ? Image.network(
                      exercise.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                    )
                  : const Icon(Icons.fitness_center, size: 80, color: Colors.grey),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Nama Latihan
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Info Otot & Equipment (Pake Chip/Badge)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.accessibility_new, 'Primary: ${exercise.muscleGroup}', AppTheme.neonGreen),
                      if (exercise.secondaryMuscles.isNotEmpty)
                        _buildInfoChip(Icons.people_outline, 'Secondary: ${exercise.secondaryMuscles.join(", ")}', Colors.orangeAccent),
                      _buildInfoChip(Icons.fitness_center, exercise.equipment, Colors.lightBlueAccent),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),

                  // 4. Instruksi (Numbered List)
                  const Text(
                    'Instruksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(instructionSteps.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppTheme.neonGreen.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: AppTheme.neonGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              instructionSteps[index].trim(),
                              style: const TextStyle(color: Colors.white70, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // // 5. Tombol Add to Workout (Hanya UI sesuai AC)
      // bottomNavigationBar: SafeArea(
      //   child: Padding(
      //     padding: const EdgeInsets.all(16.0),
      //     child: ElevatedButton(
      //       style: ElevatedButton.styleFrom(
      //         backgroundColor: AppTheme.neonGreen,
      //         foregroundColor: Colors.black,
      //         minimumSize: const Size(double.infinity, 54),
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(12),
      //         ),
      //       ),
      //       onPressed: () {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           const SnackBar(content: Text('Fitur Add to Workout segera hadir!')),
      //         );
      //       },
      //       child: const Text(
      //         'Add to Workout',
      //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  // Widget bantuan untuk bikin label/chip info
  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}