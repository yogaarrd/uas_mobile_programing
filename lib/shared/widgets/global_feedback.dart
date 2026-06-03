import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart'; // Sesuaikan path-nya

class GlobalFeedback {
  static Widget loadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.neonGreen),
    );
  }

  static Widget errorMessage(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}