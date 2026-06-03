import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Profile', style: textTheme.titleLarge)),
      body: Center(
        child: Text('Belum ada data profile', style: textTheme.bodyLarge),
      ),
    );
  }
}
