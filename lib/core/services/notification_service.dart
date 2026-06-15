import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart'; // Wajib untuk debugPrint dan kIsWeb

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (kIsWeb) return;

    // Ganti '@mipmap/ic_launcher' menjadi nama ikon default bawaan sistem Android berikut:
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('app_icon');
    
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notificationsPlugin.initialize(settings: initSettings);
    
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  static Future<void> showRestFinishedNotification() async {
    // =========================================================
    // 1. TEST CONSOLE: Ini akan SELALU MUNCUL di terminal/console
    // =========================================================
    debugPrint("🔔 [LOG] FUNGSI NOTIFIKASI & GETAR BERHASIL DIEKSEKUSI!");
    debugPrint("⏰ Waktu Istirahat Habis. Memulai Set Selanjutnya...");

    // 2. CEK PLATFORM: Cegah crash jika di-run di Chrome/Web
    if (kIsWeb) {
      debugPrint("💻 (Berjalan di Chrome: Simulasi Notifikasi Selesai)");
      return; 
    }

    // --- KODE DI BAWAH INI HANYA DIEKSEKUSI DI HP ANDROID/IOS ---
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'rest_timer_channel',
      'Rest Timer',
      channelDescription: 'Notifikasi saat waktu istirahat selesai',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: 'app_icon',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentSound: true, presentAlert: true),
    );

    await _notificationsPlugin.show(
      id: 0,
      title: 'Waktu Istirahat Habis!',
      body: 'Saatnya kembali mengangkat beban. Semangat! 💪',
      notificationDetails: platformDetails,
    );

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 500, 200, 500]);
    }
  }
}