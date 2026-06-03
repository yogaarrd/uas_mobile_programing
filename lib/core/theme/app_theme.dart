import 'package:flutter/material.dart';

class AppTheme {
  // Kita jadikan variabel agar mudah dipanggil
  static const Color neonGreen = Color(0xFFD5FF5F);
  static const Color darkBackground = Color(0xFF14141C);
  
  // Warna untuk elemen yang mengambang di atas background (seperti bottom nav)
  static const Color surfaceColor = Color(0xFF1E1E26); 

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: neonGreen, 
      
      // Standar Tipografi
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.grey),
      ),

      // Standar AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0, 
        centerTitle: true,
      ),
      
      // Standar Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: neonGreen,
        unselectedItemColor: Colors.grey,
      ),

      // ================= INI TAMBAHAN BARU =================
      // Standar Tombol Aplikasi (Elevated Button)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonGreen, // Warna tombol neon
          foregroundColor: darkBackground, // Warna teks hitam pekat agar kontras terbaca
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // Dibuat lebih membulat mengikuti desainmu
          ),
        ),
      ),
    );
  }
}