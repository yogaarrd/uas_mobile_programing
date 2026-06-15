import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedDateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() {
    return null; // Nilai awal: null (tidak ada filter)
  }

  // Fungsi untuk mengubah tanggal
  void setDate(DateTime? date) {
    state = date;
  }
}

final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime?>(() {
  return SelectedDateNotifier();
});