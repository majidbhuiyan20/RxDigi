import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/habit_analytics_model.dart';

class HabitStatsOverview extends StatelessWidget {
  final HabitAnalyticsReport report;
  final bool isBn;

  const HabitStatsOverview({
    super.key,
    required this.report,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: PhosphorIconsFill.fire,
                iconColor: const Color(0xFFEA580C),
                bgColor: const Color(0xFFFFF7ED),
                borderColor: const Color(0xFFFFEDD5),
                title: isBn ? 'বর্তমান স্ট্রিক' : 'Current Streak',
                value: isBn ? '${report.currentStreak} দিন' : '${report.currentStreak} Days',
                subtitle: isBn ? 'নিয়মিত অভ্যাস' : 'Consistency',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                icon: PhosphorIconsFill.target,
                iconColor: const Color(0xFF059669),
                bgColor: const Color(0xFFECFDF5),
                borderColor: const Color(0xFFD1FAE5),
                title: isBn ? 'সাপ্তাহিক গড়' : 'Weekly Average',
                value: '${report.averagePercentage}%',
                subtitle: isBn ? 'লক্ষ্য অর্জন' : 'Goal Completion',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: PhosphorIconsFill.trophy,
                iconColor: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFF5F3FF),
                borderColor: const Color(0xFFEDE9FE),
                title: isBn ? 'নিখুঁত দিন' : 'Perfect Days',
                value: isBn ? '${report.perfectDaysCount} দিন' : '${report.perfectDaysCount} Days',
                subtitle: isBn ? '১০০% সফল' : '100% Target Met',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                icon: PhosphorIconsFill.checkCircle,
                iconColor: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
                borderColor: const Color(0xFFDBEAFE),
                title: isBn ? 'আজকের অগ্রগতি' : 'Today\'s Progress',
                value: '${report.todayCompleted}/${report.todayTotal}',
                subtitle: isBn ? 'টাস্ক সম্পন্ন' : 'Tasks Done',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

