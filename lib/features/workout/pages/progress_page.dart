import 'package:flutter/material.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(title: Text('Progress Latihan', style: textTheme.titleLarge)),
      body: Center(
        child: Text('Belum ada data progress', style: textTheme.bodyLarge),
      ),
    );
  }
}