import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/health_habit_model.dart';

class HabitItemCard extends StatelessWidget {
  final HealthHabitModel habit;
  final bool completed;
  final bool isBn;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const HabitItemCard({
    super.key,
    required this.habit,
    required this.completed,
    required this.isBn,
    required this.onToggle,
    required this.onDelete,
  });

  Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFF0F766E);
    }
  }

  IconData _habitIcon(String icon) {
    switch (icon) {
      case 'water_drop':
        return PhosphorIconsFill.drop;
      case 'directions_walk':
        return PhosphorIconsFill.personSimpleWalk;
      case 'bedtime':
        return PhosphorIconsFill.moonStars;
      case 'monitor_heart':
        return PhosphorIconsFill.heartbeat;
      case 'restaurant':
        return PhosphorIconsFill.forkKnife;
      case 'medication':
        return PhosphorIconsFill.pill;
      case 'health_and_safety':
        return PhosphorIconsFill.shieldCheck;
      default:
        return PhosphorIconsFill.checkCircle;
    }
  }

  String _localizedTitle(String title, bool isBn) {
    if (!isBn) return title;
    switch (title) {
      case 'Drink 8 glasses of water':
        return '৮ গ্লাস পানি পান করুন';
      case 'Walk for 30 minutes':
        return '৩০ মিনিট হাঁটুন';
      case 'Sleep 7-8 hours':
        return '৭-৮ ঘণ্টা ঘুম';
      case 'Check BP or sugar':
        return 'ব্লাড প্রেশার বা সুগার মাপুন';
      case 'Eat a healthy meal':
        return 'স্বাস্থ্যকর খাবার গ্রহণ';
      case 'Take medicines on time':
        return 'সময়মতো ওষুধ সেবন';
      case 'Avoid smoking today':
        return 'ধূমপানমুক্ত থাকুন';
      default:
        return title;
    }
  }

  String _localizedCategory(String category, bool isBn) {
    if (!isBn) return category;
    switch (category) {
      case 'Nutrition':
        return 'পুষ্টি ও খাদ্য';
      case 'Exercise':
        return 'ব্যায়াম';
      case 'Sleep':
        return 'ঘুম';
      case 'Vitals':
        return 'ভাইটালস';
      case 'Medicine':
        return 'ওষুধ';
      case 'Wellness':
        return 'সুস্থতা';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(habit.color);

    return Dismissible(
      key: ValueKey(habit.id ?? habit.title),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              isBn ? 'অভ্যাসটি মুছে ফেলতে চান?' : 'Delete Habit?',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            content: Text(
              isBn
                  ? 'এই অভ্যাসটি মুছে ফেললে এর পূর্বের রেকর্ডও মুছে যাবে।'
                  : 'Deleting this habit will also remove its logged completions.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(isBn ? 'বাতিল' : 'Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(isBn ? 'মুছুন' : 'Delete', style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        return confirm ?? false;
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(PhosphorIconsRegular.trash, color: Colors.red),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: completed ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: completed ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
            width: completed ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              HapticFeedback.selectionClick();
              onToggle();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  // Smooth Checkmark Circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: completed ? const Color(0xFF10B981) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: completed ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                        width: completed ? 1.8 : 1.8,
                      ),
                    ),
                    child: completed
                        ? const Icon(PhosphorIconsBold.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 13),

                  // Habit Icon Avatar
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_habitIcon(habit.icon), color: color, size: 18),
                  ),
                  const SizedBox(width: 12),

                  // Title & Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _localizedTitle(habit.title, isBn),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: completed ? const Color(0xFF0F766E) : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _localizedCategory(habit.category, isBn),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                            if (habit.reminderTime != null && habit.reminderTime!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Row(
                                children: [
                                  const Icon(PhosphorIconsRegular.clock, size: 11, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 3),
                                  Text(
                                    habit.reminderTime!,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Completed Badge
                  if (completed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(PhosphorIconsFill.checkCircle, size: 12, color: Color(0xFF059669)),
                          const SizedBox(width: 3),
                          Text(
                            isBn ? 'সম্পন্ন' : 'Done',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

