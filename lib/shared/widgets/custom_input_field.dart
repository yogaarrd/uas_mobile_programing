import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final String? Function(String?)? validator;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil semua pengaturan tema yang sedang aktif
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      style: theme.textTheme.bodyLarge, // Teks input ikuti tema
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium, // Teks label ikuti tema
        prefixIcon: Icon(icon, color: Colors.grey),
        
        // 1. Border saat posisi diam (tidak diklik)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        
        // 2. Border saat diklik (fokus) -> Garis otomatis menyala sesuai primaryColor!
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        
        // 3. Border saat error/salah input
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        
        filled: true,
        fillColor: const Color(0xFF1E1E1E), // Kotak input sedikit lebih terang dari background hitam
      ),
    );
  }
}