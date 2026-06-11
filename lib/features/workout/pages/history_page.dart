import 'package:flutter/material.dart';

class   HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(title: Text('Progress Latihan', style: textTheme.titleLarge)),
      body: Center(
        child: Text('Belum ada data history', style: textTheme.bodyLarge),
      ),
    );
  }
}