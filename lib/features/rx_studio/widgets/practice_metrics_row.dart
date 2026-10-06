import 'package:flutter/material.dart';
import '../../../app/app_colors.dart';

class PracticeMetricsRow extends StatelessWidget {
  final int todayCount;
  final int totalPatients;
  final int totalCount;
  final bool isBn;

  const PracticeMetricsRow({
    super.key,
    required this.todayCount,
    required this.totalPatients,
    required this.totalCount,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildMetricTile(
          label: isBn ? 'আজকের প্রেসক্রিপশন' : "Today's Rx",
          value: todayCount.toString(),
          icon: Icons.today_rounded,
          color: AppColors.actionBlue,
        ),
        const SizedBox(width: 12),
        _buildMetricTile(
          label: isBn ? 'সর্বমোট রোগী' : 'Total Patients',
          value: totalPatients.toString(),
          icon: Icons.people_outline_rounded,
          color: AppColors.successColor,
        ),
        const SizedBox(width: 12),
        _buildMetricTile(
          label: isBn ? 'মোট প্রেসক্রিপশন' : 'Total Rx',
          value: totalCount.toString(),
          icon: Icons.description_outlined,
          color: AppColors.actionPurple,
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
