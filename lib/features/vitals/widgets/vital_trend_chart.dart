import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/vital_log_model.dart';
import '../../../app/app_colors.dart';

class VitalTrendChart extends StatefulWidget {
  final List<VitalLogModel> logs;
  final String vitalType; // 'BP', 'SUGAR', 'WEIGHT', 'ALL'

  const VitalTrendChart({
    super.key,
    required this.logs,
    required this.vitalType,
  });

  @override
  State<VitalTrendChart> createState() => _VitalTrendChartState();
}

class _VitalTrendChartState extends State<VitalTrendChart> {
  int? _selectedPointIndex;

  @override
  Widget build(BuildContext context) {
    final type = widget.vitalType == 'ALL' ? 'BP' : widget.vitalType;

    // Filter and sort chronologically (oldest to newest)
    final sortedLogs = widget.logs
        .where((l) => l.type == type)
        .toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    if (sortedLogs.isEmpty) {
      return const SizedBox.shrink();
    }

    final latest = sortedLogs.last;
    final primaryColor = type == 'BP'
        ? AppColors.primaryColor
        : (type == 'SUGAR' ? const Color(0xFFEA580C) : const Color(0xFF8B5CF6));

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Metric Title, Latest Value Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      type == 'BP'
                          ? PhosphorIconsFill.heartbeat
                          : (type == 'SUGAR' ? PhosphorIconsFill.drop : PhosphorIconsFill.scales),
                      size: 16,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type == 'BP'
                            ? 'রক্তচাপ বিশ্লেষণ (BP Trend)'
                            : (type == 'SUGAR'
                                ? 'ব্লাড সুগার পরিবর্তন (Sugar Trend)'
                                : 'ওজন পর্যবেক্ষণ (Weight Trend)'),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '${sortedLogs.length} টি রেকর্ড বিশ্লেষিত',
                        style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  type == 'BP'
                      ? '${latest.value1.toInt()}/${latest.value2?.toInt() ?? 0} ${latest.unit}'
                      : '${latest.value1} ${latest.unit}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Line Chart Canvas
          if (sortedLogs.length >= 2) ...[
            SizedBox(
              height: 140,
              width: double.infinity,
              child: GestureDetector(
                onTapUp: (details) {
                  final width = context.size?.width ?? 300;
                  final step = width / (sortedLogs.length - 1);
                  final index = (details.localPosition.dx / step).round().clamp(0, sortedLogs.length - 1);
                  setState(() => _selectedPointIndex = index);
                },
                child: CustomPaint(
                  painter: _LineChartPainter(
                    logs: sortedLogs,
                    type: type,
                    primaryColor: primaryColor,
                    selectedIndex: _selectedPointIndex,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Date X-axis labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM').format(sortedLogs.first.recordedAt),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
                if (sortedLogs.length > 2)
                  Text(
                    DateFormat('dd MMM').format(sortedLogs[sortedLogs.length ~/ 2].recordedAt),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                Text(
                  DateFormat('dd MMM').format(sortedLogs.last.recordedAt),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(PhosphorIconsRegular.chartLineUp, size: 28, color: Colors.grey.shade400),
                  const SizedBox(height: 6),
                  Text(
                    'পরবর্তী ট্রেন্ড লাইন দেখতে অন্তত ২টি পরিমাপ রেকর্ড করুন',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          // Legend / Target indicators
          if (type == 'BP')
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDotLegend(AppColors.primaryColor, 'Systolic (উপরের)'),
                    const SizedBox(width: 16),
                    _buildDotLegend(const Color(0xFF0D9488), 'Diastolic (নিচের)'),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildZoneBadge(const Color(0xFF10B981), '<120/80', 'স্বাভাবিক'),
                      _buildZoneBadge(const Color(0xFFF59E0B), '120-139', 'উচ্চ ঝুঁকি'),
                      _buildZoneBadge(const Color(0xFFEF4444), '140+', 'উচ্চ রক্তচাপ'),
                    ],
                  ),
                ),
              ],
            )
          else if (type == 'SUGAR')
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDotLegend(const Color(0xFFEA580C), 'ব্লাড গ্লুকোজ লেভেল'),
                    const SizedBox(width: 14),
                    Text(
                      'লক্ষ্যমাত্রা: ৪.০ - ৭.০ mmol/L',
                      style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildZoneBadge(const Color(0xFF10B981), '4.0-7.0', 'স্বাভাবিক'),
                      _buildZoneBadge(const Color(0xFFF59E0B), '7.1-10.0', 'বর্ডারলাইন'),
                      _buildZoneBadge(const Color(0xFFEF4444), '>10.0', 'উচ্চ মাত্রা'),
                    ],
                  ),
                ),
              ],
            )
          else if (type == 'WEIGHT')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDotLegend(const Color(0xFF8B5CF6), 'শরীরের ওজন (কেজি)'),
                if (sortedLogs.length >= 2) ...[
                  const SizedBox(width: 12),
                  Builder(builder: (context) {
                    final diff = sortedLogs.last.value1 - sortedLogs.first.value1;
                    final isDown = diff <= 0;
                    return Text(
                      '${isDown ? "📉" : "📈"} ${diff.abs().toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDown ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      ),
                    );
                  }),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDotLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
      ],
    );
  }

  Widget _buildZoneBadge(Color color, String range, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$range $label',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<VitalLogModel> logs;
  final String type;
  final Color primaryColor;
  final int? selectedIndex;

  _LineChartPainter({
    required this.logs,
    required this.type,
    required this.primaryColor,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (logs.length < 2) return;

    final n = logs.length;
    final stepX = size.width / (n - 1);

    // Calculate min and max
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final l in logs) {
      minY = min(minY, l.value1);
      maxY = max(maxY, l.value1);
      if (type == 'BP' && l.value2 != null) {
        minY = min(minY, l.value2!);
        maxY = max(maxY, l.value2!);
      }
    }

    // Add padding to range & ensure standard clinical reference lines fit nicely
    if (type == 'BP') {
      minY = min(minY, 65.0);
      maxY = max(maxY, 155.0);
    } else if (type == 'SUGAR') {
      minY = min(minY, 3.5);
      maxY = max(maxY, 12.5);
    } else {
      final pad = (maxY - minY).clamp(10.0, 50.0) * 0.25;
      minY -= pad;
      maxY += pad;
    }
    final rangeY = maxY - minY > 0 ? (maxY - minY) : 1.0;

    // --- AHA / WHO Clinical Background Range Bands ---
    if (type == 'BP') {
      final y140 = (size.height - ((140.0 - minY) / rangeY * size.height)).clamp(0.0, size.height);
      final y120 = (size.height - ((120.0 - minY) / rangeY * size.height)).clamp(0.0, size.height);

      // Red Zone: Hypertension (>= 140)
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, y140),
        Paint()..color = const Color(0xFFEF4444).withValues(alpha: 0.07),
      );

      // Amber Zone: Elevated (120 - 140)
      canvas.drawRect(
        Rect.fromLTWH(0, y140, size.width, y120 - y140),
        Paint()..color = const Color(0xFFF59E0B).withValues(alpha: 0.07),
      );

      // Green Zone: Normal (< 120)
      canvas.drawRect(
        Rect.fromLTWH(0, y120, size.width, size.height - y120),
        Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.07),
      );

      // Guideline 140 mmHg
      final guidePaint = Paint()
        ..color = const Color(0xFFEF4444).withValues(alpha: 0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, y140), Offset(size.width, y140), guidePaint);

      // Guideline 120 mmHg
      final guidePaint120 = Paint()
        ..color = const Color(0xFF10B981).withValues(alpha: 0.35)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, y120), Offset(size.width, y120), guidePaint120);
    } else if (type == 'SUGAR') {
      final y10 = (size.height - ((10.0 - minY) / rangeY * size.height)).clamp(0.0, size.height);
      final y7 = (size.height - ((7.0 - minY) / rangeY * size.height)).clamp(0.0, size.height);

      // Red Zone: High (> 10.0)
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, y10),
        Paint()..color = const Color(0xFFEF4444).withValues(alpha: 0.07),
      );

      // Amber Zone: Elevated (7.0 - 10.0)
      canvas.drawRect(
        Rect.fromLTWH(0, y10, size.width, y7 - y10),
        Paint()..color = const Color(0xFFF59E0B).withValues(alpha: 0.07),
      );

      // Green Zone: Normal (< 7.0)
      canvas.drawRect(
        Rect.fromLTWH(0, y7, size.width, size.height - y7),
        Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.07),
      );
    }

    // Background horizontal grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9).withValues(alpha: 0.6)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = size.height * (i / 3.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw lines
    if (type == 'BP') {
      _drawLine(
        canvas: canvas,
        size: size,
        stepX: stepX,
        minY: minY,
        rangeY: rangeY,
        values: logs.map((l) => l.value1).toList(),
        lineColor: AppColors.primaryColor,
        isSecondary: false,
      );
      _drawLine(
        canvas: canvas,
        size: size,
        stepX: stepX,
        minY: minY,
        rangeY: rangeY,
        values: logs.map((l) => l.value2 ?? 70.0).toList(),
        lineColor: const Color(0xFF0D9488),
        isSecondary: true,
      );
    } else {
      _drawLine(
        canvas: canvas,
        size: size,
        stepX: stepX,
        minY: minY,
        rangeY: rangeY,
        values: logs.map((l) => l.value1).toList(),
        lineColor: primaryColor,
        isSecondary: false,
      );
    }
  }

  void _drawLine({
    required Canvas canvas,
    required Size size,
    required double stepX,
    required double minY,
    required double rangeY,
    required List<double> values,
    required Color lineColor,
    required bool isSecondary,
  }) {
    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final normalizedY = (values[i] - minY) / rangeY;
      final y = size.height - (normalizedY * size.height);
      points.add(Offset(x, y));
    }

    // Line Path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    // Area Gradient (only for primary line)
    if (!isSecondary) {
      final fillPath = Path.from(path)
        ..lineTo(points.last.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();

      final gradientPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.25),
            lineColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, gradientPaint);
    }

    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // Draw Dots
    final dotPaint = Paint()..color = Colors.white;
    final dotBorderPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final isSelected = selectedIndex == i;
      final radius = isSelected ? 5.5 : 3.5;

      canvas.drawCircle(p, radius, dotPaint);
      canvas.drawCircle(p, radius, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.logs != logs ||
        oldDelegate.type != type ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

