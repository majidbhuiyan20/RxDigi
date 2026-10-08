import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';
import '../../../core/utils/app_feedback.dart';
import '../../../core/widgets/perfect_day_celebration.dart';
import '../models/health_habit_model.dart';
import '../provider/health_habit_provider.dart';
import '../provider/water_intake_provider.dart';
import '../view/health_habit_screen.dart';

class HealthHabitHomeCard extends ConsumerWidget {
  const HealthHabitHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final habitsAsync = ref.watch(activeHealthHabitsProvider);
    final completedAsync = ref.watch(todayCompletedHabitIdsProvider);
    final countsAsync = ref.watch(weeklyHabitCountsProvider);

    return habitsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (habits) {
        if (habits.isEmpty) return const SizedBox.shrink();

        final completed = completedAsync.value ?? <int>{};
        final counts = countsAsync.value ?? <String, int>{};
        final progress = completed.length / habits.length;
        final percent = (progress * 100).toInt();
        final streak = _calculateStreak(counts);
        final todayKey = habitDateString(DateTime.now());
        final waterGlasses = ref.watch(waterIntakeForDateProvider(todayKey));

        // Display up to 3 most relevant habits on home
        final displayHabits = habits.take(3).toList();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header with Streak Badge & View All
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          PhosphorIconsRegular.sparkle,
                          color: Color(0xFF059669),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'দৈনিক স্বাস্থ্য রুটিন' : 'Daily Health Habits',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            isBn
                                ? '${habits.length}টির মধ্যে ${completed.length}টি সম্পন্ন ($percent%)'
                                : '${completed.length} of ${habits.length} done ($percent%)',
                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Streak Badge
                  if (streak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(PhosphorIconsFill.fire, color: Colors.white, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            '$streak ${isBn ? "দিনের স্ট্রিক" : "d streak"}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // 2. Slim Curved Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percent == 100 ? const Color(0xFF10B981) : AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 2.5. Water Hydration Quick Action Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0284C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(PhosphorIconsFill.drop, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isBn ? 'দৈনিক পানি পান' : 'Water Hydration',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0369A1),
                                ),
                              ),
                              Text(
                                '$waterGlasses/৮ ${isBn ? "গ্লাস" : "glasses"}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (waterGlasses / 8.0).clamp(0.0, 1.0),
                              minHeight: 5,
                              backgroundColor: const Color(0xFFE0F2FE),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Quick Increment Button
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        AppFeedback.playSuccess();
                        ref.read(waterIntakeNotifierProvider.notifier).increment(todayKey);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(PhosphorIconsBold.plus, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. Interactive Habit Rows (1-Tap Completion Right on Home!)
              ...displayHabits.map((habit) {
                final isDone = completed.contains(habit.id);
                final color = _parseColor(habit.color);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDone ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDone ? const Color(0xFF86EFAC) : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        if (habit.id != null) {
                          AppFeedback.playSuccess();
                          ref.read(healthHabitNotifierProvider.notifier).toggle(habit.id!, isDone);
                          if (!isDone && completed.length + 1 >= habits.length) {
                            PerfectDayCelebration.show(
                              context,
                              title: isBn ? 'অভিনন্দন! শতভাগ অভ্যাস সম্পন্ন' : 'Outstanding! 100% Habits Done',
                              message: isBn
                                  ? 'আজকের সকল স্বাস্থ্যকর রুটিন চমৎকারভাবে পূর্ণ হয়েছে।'
                                  : 'You achieved all your wellness habits for today!',
                            );
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            // Interactive Checkbox Circle
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isDone ? const Color(0xFF10B981) : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDone ? const Color(0xFF10B981) : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: isDone
                                  ? const Icon(PhosphorIconsBold.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            // Icon Avatar
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _habitIcon(habit.icon),
                                color: color,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Title
                            Expanded(
                              child: Text(
                                _localizedTitle(habit.title, isBn),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                  color: isDone ? Colors.grey.shade500 : const Color(0xFF1E293B),
                                ),
                              ),
                            ),

                            // Category Tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _localizedCategory(habit.category, isBn),
                                style: TextStyle(fontSize: 9.5, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // 4. Footer Link to Full Routine Screen
              const SizedBox(height: 6),
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HealthHabitScreen()),
                  ),
                  icon: const Icon(PhosphorIconsRegular.arrowRight, size: 15, color: AppColors.primaryColor),
                  label: Text(
                    isBn ? 'সম্পূর্ণ রুটিন ও সাপ্তাহিক ট্র্যাকার দেখুন' : 'View Full Routine & Weekly Analytics',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _calculateStreak(Map<String, int> counts) {
    var streak = 0;
    final today = DateTime.now();
    for (var index = 0; index < 7; index++) {
      final key = habitDateString(today.subtract(Duration(days: index)));
      if ((counts[key] ?? 0) > 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  String _localizedTitle(String title, bool isBn) {
    if (!isBn) return title;
    final l = title.toLowerCase();
    if (l.contains('water')) return 'পর্যাপ্ত পানি পান (৮ গ্লাস)';
    if (l.contains('walk')) return '৩০ মিনিট হাঁটা বা ব্যায়াম';
    if (l.contains('sleep')) return '৭-৮ ঘণ্টা পরিমিত ঘুম';
    if (l.contains('bp') || l.contains('sugar')) return 'রক্তচাপ বা ডায়াবেটিস মাপা';
    if (l.contains('meal')) return 'পুষ্টিকর সুষম খাবার গ্রহণ';
    if (l.contains('medicine')) return 'সময়মত ওষুধ গ্রহণ';
    if (l.contains('smoking')) return 'ধূমপান ও অতিরিক্ত চিনি বর্জন';
    return title;
  }

  String _localizedCategory(String category, bool isBn) {
    if (!isBn) return category;
    switch (category.toLowerCase()) {
      case 'nutrition':
        return 'পুষ্টি';
      case 'exercise':
        return 'ব্যায়াম';
      case 'sleep':
        return 'ঘুম';
      case 'vitals':
        return 'ভাইটালস';
      case 'medicine':
        return 'ওষুধ';
      case 'wellness':
        return 'স্বাস্থ্য';
      default:
        return category;
    }
  }

  IconData _habitIcon(String icon) {
    switch (icon) {
      case 'water_drop':
      case 'water':
        return PhosphorIconsRegular.drop;
      case 'directions_walk':
      case 'walk':
        return PhosphorIconsRegular.footprints;
      case 'bedtime':
      case 'sleep':
        return PhosphorIconsRegular.moonStars;
      case 'monitor_heart':
      case 'vitals':
        return PhosphorIconsRegular.heartbeat;
      case 'restaurant':
      case 'food':
        return PhosphorIconsRegular.forkKnife;
      case 'medication':
      case 'medicine':
        return PhosphorIconsRegular.pill;
      default:
        return PhosphorIconsRegular.checkCircle;
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primaryColor;
    }
  }
}
