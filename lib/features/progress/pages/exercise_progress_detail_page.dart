import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ExerciseProgressDetailPage extends StatelessWidget {
  final String exerciseId;
  final String exerciseName;

  const ExerciseProgressDetailPage({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: Text(exerciseName, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 80, color: AppTheme.neonGreen),
            SizedBox(height: 16),
            Text(
              'Grafik Progress',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Grafik dan detail rekor (PR) akan diimplementasikan\npada Sprint selanjutnya.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}