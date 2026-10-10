import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:prescripto/app/app_colors.dart';
import 'package:prescripto/core/data/providers/prescription_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionsAsync = ref.watch(prescriptionListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Practice Reports',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0F172A)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: prescriptionsAsync.when(
        data: (prescriptions) {
          final totalRx = prescriptions.length;
          final today = DateTime.now();
          final thisMonthRx = prescriptions.where((p) => p.date.year == today.year && p.date.month == today.month).length;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCard(
                  context,
                  title: 'Total Prescriptions',
                  value: totalRx.toString(),
                  icon: PhosphorIconsRegular.fileText,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 14),
                _buildStatCard(
                  context,
                  title: 'Prescriptions This Month',
                  value: thisMonthRx.toString(),
                  icon: PhosphorIconsRegular.calendar,
                  color: const Color(0xFF0D9488),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Insights',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(PhosphorIconsRegular.chartLineUp, size: 40, color: Color(0xFF94A3B8)),
                        SizedBox(height: 12),
                        Text(
                          'Detailed prescription analytics and visual trends',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
