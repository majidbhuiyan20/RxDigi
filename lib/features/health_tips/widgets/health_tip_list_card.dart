import 'package:flutter/material.dart';
import '../../../app/app_colors.dart';
import '../models/health_tip_model.dart';
import '../view/health_tip_detail_screen.dart';

class HealthTipListCard extends StatelessWidget {
  final HealthTipModel tip;
  final bool isBn;

  const HealthTipListCard({
    super.key,
    required this.tip,
    required this.isBn,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'favorite':
        return Icons.favorite_rounded;
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'medical_services':
        return Icons.medical_services_rounded;
      case 'bug_report':
        return Icons.coronavirus_rounded;
      case 'bedtime':
        return Icons.bedtime_rounded;
      default:
        return Icons.health_and_safety_rounded;
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipColor = _parseColor(tip.color);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HealthTipDetailScreen(tip: tip),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tipColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_getIconData(tip.icon), color: tipColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: tipColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tip.getCategory(isBn),
                      style: TextStyle(
                        color: tipColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tip.getTitle(isBn),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tip.getSummary(isBn),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
