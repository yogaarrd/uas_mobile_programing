import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/body_measurement.dart';
import '../providers/body_measurement_provider.dart';

class BodyWeightPage extends ConsumerStatefulWidget {
  const BodyWeightPage({super.key});

  @override
  ConsumerState<BodyWeightPage> createState() => _BodyWeightPageState();
}

class _BodyWeightPageState extends ConsumerState<BodyWeightPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final measAsync = ref.watch(bodyMeasurementProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Berat Badan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.neonGreen),
            tooltip: 'Catat Berat Badan',
            onPressed: () => _showInputSheet(context),
          ),
        ],
      ),
      body: measAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 12),
                Text('Gagal memuat data:\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        data: (measurements) {
          if (measurements.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildContent(measurements);
        },
      ),
      floatingActionButton: measAsync.hasValue && measAsync.value!.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.neonGreen,
              foregroundColor: AppTheme.darkBackground,
              onPressed: () => _showInputSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Catat Berat',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  // ─────────────────────────── BUILD CONTENT ───────────────────────────────

  Widget _buildContent(List<BodyMeasurement> measurements) {
    final latest = measurements.last;
    final oldest = measurements.first;
    final change = latest.weightKg - oldest.weightKg;
    final minW = measurements.map((m) => m.weightKg).reduce(min);
    final maxW = measurements.map((m) => m.weightKg).reduce(max);

    return CustomScrollView(
      slivers: [
        // ─── Summary Cards ──────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Berat Terkini – card besar
                _buildLatestWeightCard(latest, change),
                const SizedBox(height: 12),

                // Row statistik kecil
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniStatCard(
                        label: 'Terendah',
                        value: '${minW.toStringAsFixed(1)} kg',
                        icon: Icons.arrow_downward_rounded,
                        color: const Color(0xFF00D4AA),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMiniStatCard(
                        label: 'Tertinggi',
                        value: '${maxW.toStringAsFixed(1)} kg',
                        icon: Icons.arrow_upward_rounded,
                        color: const Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMiniStatCard(
                        label: 'Catatan',
                        value: '${measurements.length}x',
                        icon: Icons.event_note_rounded,
                        color: const Color(0xFF7B61FF),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ─── Tab selector untuk periode ─────────────────────────
                const Text('Grafik Perkembangan',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildPeriodTabBar(),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),

        // ─── Chart ─────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 220,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChart(measurements, 30),
                  _buildChart(measurements, 90),
                  _buildChart(measurements, null),
                ],
              ),
            ),
          ),
        ),


        // ─── History List ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
            child: const Text('Riwayat Catatan',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final m = measurements.reversed.toList()[i];
                return _buildHistoryTile(m, measurements);
              },
              childCount: measurements.length,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────── WIDGET HELPERS ──────────────────────────────

  Widget _buildLatestWeightCard(BodyMeasurement latest, double change) {
    final isDown = change <= 0;
    final changeColor = isDown ? const Color(0xFF00D4AA) : const Color(0xFFFF6B35);
    final changeIcon = isDown ? Icons.trending_down : Icons.trending_up;
    final changeStr = isDown
        ? '${change.toStringAsFixed(1)} kg'
        : '+${change.toStringAsFixed(1)} kg';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonGreen.withOpacity(0.15),
            AppTheme.surfaceColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonGreen.withOpacity(0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.monitor_weight_outlined,
                    color: AppTheme.neonGreen, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Berat Terkini',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                latest.weightKg.toStringAsFixed(1),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8, left: 4),
                child: Text('kg',
                    style: TextStyle(color: Colors.grey, fontSize: 20)),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: changeColor.withOpacity(0.4), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(changeIcon, color: changeColor, size: 14),
                    const SizedBox(width: 4),
                    Text(changeStr,
                        style: TextStyle(
                            color: changeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('EEEE, dd MMMM yyyy', 'id').format(latest.measuredAt),
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPeriodTabBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.neonGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppTheme.darkBackground,
        unselectedLabelColor: Colors.grey,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [
          Tab(text: '1 Bulan'),
          Tab(text: '3 Bulan'),
          Tab(text: 'Semua'),
        ],
      ),
    );
  }

  Widget _buildChart(List<BodyMeasurement> all, int? days) {
    final cutoff = days != null
        ? DateTime.now().subtract(Duration(days: days))
        : null;

    final filtered = cutoff != null
        ? all.where((m) => m.measuredAt.isAfter(cutoff)).toList()
        : all;

    if (filtered.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: const Center(
          child: Text('Belum ada data untuk periode ini',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < filtered.length; i++) {
      spots.add(FlSpot(i.toDouble(), filtered[i].weightKg));
    }

    final maxW = filtered.map((m) => m.weightKg).reduce(max);
    final minW = filtered.map((m) => m.weightKg).reduce(min);
    double yPad = (maxW - minW) * 0.25;
    if (yPad < 1) yPad = 2;

    return Container(
      padding: const EdgeInsets.only(right: 20, left: 6, top: 16, bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: Colors.grey.shade900, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (val, meta) => Text(
                  val.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: max(1, (filtered.length / 4).floor()).toDouble(),
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= filtered.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('dd/MM').format(filtered[idx].measuredAt),
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: max(1, filtered.length - 1).toDouble(),
          minY: max(0, minW - yPad),
          maxY: maxW + yPad,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppTheme.surfaceColor,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((ts) {
                  final idx = ts.spotIndex;
                  final m = filtered[idx];
                  return LineTooltipItem(
                    '${m.weightKg.toStringAsFixed(1)} kg\n',
                    const TextStyle(
                        color: AppTheme.neonGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                    children: [
                      TextSpan(
                        text: DateFormat('dd MMM yyyy').format(m.measuredAt),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppTheme.neonGreen,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.darkBackground,
                  strokeWidth: 2.5,
                  strokeColor: AppTheme.neonGreen,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.neonGreen.withValues(alpha: 0.18),
                    AppTheme.neonGreen.withValues(alpha: 0.01),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHistoryTile(
      BodyMeasurement m, List<BodyMeasurement> all) {
    final idx = all.indexOf(m);
    double? delta;
    if (idx > 0) {
      delta = m.weightKg - all[idx - 1].weightKg;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppTheme.neonGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.monitor_weight_outlined,
              color: AppTheme.neonGreen, size: 22),
        ),
        title: Text(
          '${m.weightKg.toStringAsFixed(1)} kg',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          DateFormat('EEEE, dd MMMM yyyy', 'id').format(m.measuredAt),
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (delta != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (delta <= 0
                          ? const Color(0xFF00D4AA)
                          : const Color(0xFFFF6B35))
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  delta <= 0
                      ? '${delta.toStringAsFixed(1)}'
                      : '+${delta.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: delta <= 0
                        ? const Color(0xFF00D4AA)
                        : const Color(0xFFFF6B35),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
              onPressed: () => _confirmDelete(m),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── EMPTY STATE ─────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.monitor_weight_outlined,
                  size: 44, color: AppTheme.neonGreen),
            ),
            const SizedBox(height: 24),
            const Text('Belum Ada Catatan',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              'Mulai catat berat badan harian atau mingguanmu\nuntuk melihat grafik perkembangan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showInputSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Catat Pertama Kali',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen,
                foregroundColor: AppTheme.darkBackground,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── BOTTOM SHEET INPUT ──────────────────────────

  void _showInputSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WeightInputSheet(
        onSave: (date, weight, note) async {
          final notifier = ref.read(bodyMeasurementProvider.notifier);
          await notifier.upsert(date: date, weightKg: weight, note: note);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  // ─────────────────────────── DELETE CONFIRM ──────────────────────────────

  void _confirmDelete(BodyMeasurement m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Catatan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Hapus catatan berat badan ${m.weightKg.toStringAsFixed(1)} kg pada '
          '${DateFormat('dd MMM yyyy').format(m.measuredAt)}?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(bodyMeasurementProvider.notifier)
                  .delete(m.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── WEIGHT INPUT SHEET ──────────────────────────────

class _WeightInputSheet extends StatefulWidget {
  final Future<void> Function(DateTime date, double weight, String? note)
      onSave;

  const _WeightInputSheet({required this.onSave});

  @override
  State<_WeightInputSheet> createState() => _WeightInputSheetState();
}

class _WeightInputSheetState extends State<_WeightInputSheet> {
  final _weightCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.neonGreen,
            surface: AppTheme.surfaceColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final weight = double.parse(_weightCtrl.text.replaceAll(',', '.'));
      await widget.onSave(_selectedDate, weight, _noteCtrl.text.trim());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text('Catat Berat Badan',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Masukkan berat badan dan tanggal pencatatan.',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),

            // Date picker
            const Text('Tanggal',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.darkBackground,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: Colors.grey.shade700, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppTheme.neonGreen, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy', 'id')
                          .format(_selectedDate),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.edit_calendar_outlined,
                        color: Colors.grey, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Weight input
            const Text('Berat Badan (kg)',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _weightCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '0.0',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 20),
                suffixText: 'kg',
                suffixStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                filled: true,
                fillColor: AppTheme.darkBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppTheme.neonGreen, width: 1.5),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Masukkan berat badan';
                }
                final parsed =
                    double.tryParse(val.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0 || parsed > 700) {
                  return 'Masukkan angka yang valid (1-700 kg)';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Note input
            const Text('Catatan (opsional)',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteCtrl,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Mis: setelah makan, pagi hari, ...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                filled: true,
                fillColor: AppTheme.darkBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppTheme.neonGreen, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen,
                  foregroundColor: AppTheme.darkBackground,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor:
                      AppTheme.neonGreen.withOpacity(0.4),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: AppTheme.darkBackground, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Simpan Catatan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
