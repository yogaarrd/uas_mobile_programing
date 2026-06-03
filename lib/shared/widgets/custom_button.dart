import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    super.key, 
    required this.text, 
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55, // Sedikit lebih tinggi agar proporsional
      child: ElevatedButton(
        // HAPUS style: ElevatedButton.styleFrom(...) di sini
        // Biarkan tombol otomatis mengambil settingan dari AppTheme!
        onPressed: isLoading ? null : onPressed,
        child: isLoading 
            ? const SizedBox(
                height: 20, width: 20, 
                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  // Color tidak perlu diset, sudah diatur oleh foregroundColor di AppTheme
                ),
              ),
      ),
    );
  }
}