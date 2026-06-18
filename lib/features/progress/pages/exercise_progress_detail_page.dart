import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/progress_models.dart';
import '../providers/progress_provider.dart';

class ExerciseProgressDetailPage extends ConsumerWidget {
  final String exerciseId;
  final String exerciseName;

  const ExerciseProgressDetailPage({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(exerciseProgressProvider(exerciseId));

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: Text(exerciseName, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: progressAsync.when(
        data: (points) {
          if (points.isEmpty) {
            return _buildEmptyState();
          }

          // Filter data minimal 3 bulan terakhir sesuai AC
          final standardCutoff = DateTime.now().subtract(const Duration(days: 90));
          // Jika data history totalnya banyak, kita potong 90 hari, 
          // tapi jika datanya sedikit, tampilkan semua agar grafik tidak kosong.
          final displayPoints = points.any((p) => p.date.isBefore(standardCutoff))
              ? points.where((p) => p.date.isAfter(standardCutoff)).toList()
              : points;

          // Tabel riwayat di bawah diurutkan dari yang TERBARU ke TERLAMA (kebalikan dari grafik)
          final tableHistory = List<ExerciseProgressPoint>.from(points).reversed.toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Grafik Kekuatan (Max Weight)',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  points.any((p) => p.date.isBefore(standardCutoff)) ? 'Menampilkan data 3 bulan terakhir' : 'Menampilkan semua histori latihan',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // ==========================================
                // KONTEN UTAMA: BOX GRAFIK FL_CHART
                // ==========================================
                Container(
                  height: 240,
                  padding: const EdgeInsets.only(right: 24, left: 8, top: 12, bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: LineChart(
                    _getChartData(displayPoints),
                  ),
                ),
                const SizedBox(height: 36),

                // ==========================================
                // KONTEN KEDUA: TABEL HISTORIS LENGKAP
                // ==========================================
                const Text(
                  'Catatan Historis Lengkap',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2.5), // Tanggal
                      1: FlexColumnWidth(2.0), // Max Weight
                      2: FlexColumnWidth(1.5), // Sets
                      3: FlexColumnWidth(1.5), // Reps
                    },
                    children: [
                      // Header Tabel
                      TableRow(
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
                        children: const [
                          _TableCell(text: 'Tanggal', isHeader: true, align: TextAlign.left),
                          _TableCell(text: 'Max (KG)', isHeader: true),
                          _TableCell(text: 'Sets', isHeader: true),
                          _TableCell(text: 'Reps', isHeader: true),
                        ],
                      ),
                      // Baris Data Looping
                      ...tableHistory.map((p) {
                        final dateStr = DateFormat('dd MMM yyyy').format(p.date);
                        final dayName = DateFormat('EEEE').format(p.date);
                        final weightFormatted = p.maxWeight.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
                        
                        return TableRow(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.shade900)),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dateStr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text(dayName, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                            ),
                            _TableCell(text: '$weightFormatted kg', color: AppTheme.neonGreen),
                            _TableCell(text: '${p.totalSets}'),
                            _TableCell(text: '${p.totalReps}'),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }

  // LOGIKA CONFIGURASI FL_CHART GRAFIK GARIS NEON
  LineChartData _getChartData(List<ExerciseProgressPoint> displayPoints) {
    // Buat koordinat spot (X, Y)
    // X = indeks urutan latihan (0, 1, 2...) agar spasi titik seimbang
    // Y = berat maksimal kg
    List<FlSpot> spots = [];
    for (int i = 0; i < displayPoints.length; i++) {
      spots.add(FlSpot(i.toDouble(), displayPoints[i].maxWeight));
    }

    // Hitung batas Y agar garis tidak mentok ke atas/bawah frame grafik (Padding Visual)
    double maxWeight = displayPoints.map((p) => p.maxWeight).reduce(max);
    double minWeight = displayPoints.map((p) => p.maxWeight).reduce(min);
    double yPadding = (maxWeight - minWeight) * 0.2;
    if (yPadding == 0) yPadding = 10; // Fallback jika beratnya sama semua

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade900, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        show: true,
        // Dihapus const agar kompatibel dengan fl_chart v1.2.0
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        // Sumbu Y (Berat KG)
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}k',
                style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        // Sumbu X (Tanggal Sesi)
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            // Mengatur interval kemunculan teks tanggal agar tidak berhimpitan jika datanya banyak
            interval: max(1, (displayPoints.length / 4).floor()).toDouble(),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < displayPoints.length) {
                final date = displayPoints[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    DateFormat('dd/MM').format(date),
                    style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: max(1, displayPoints.length - 1).toDouble(),
      minY: max(0, minWeight - yPadding),
      maxY: maxWeight + yPadding,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true, // Membuat garis melengkung smooth premium
          color: AppTheme.neonGreen,
          barWidth: 3,
          isStrokeCapRound: true,
          // IMPLEMENTASI BARU UNTUK DOT DATA DI FL_CHART 1.2.0
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4.0,
                color: Colors.black,
                strokeWidth: 2.0,
                strokeColor: AppTheme.neonGreen,
              );
            },
          ),
          // Efek warna gradasi di bawah garis chart
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.neonGreen.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 72, color: Colors.grey.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text('Belum ada riwayat angkatan\nuntuk latihan "$exerciseName".', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }
}

// === HELPER WIDGET CELL TABEL ===
class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final TextAlign align;
  final Color color;

  const _TableCell({
    required this.text,
    this.isHeader = false,
    this.align = TextAlign.center,
    this.color = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          color: isHeader ? Colors.grey : color,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
          fontSize: isHeader ? 12 : 14,
        ),
      ),
    );
  }
}