import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';
import '../models/health_habit_model.dart';
import '../provider/health_habit_provider.dart';

class HealthHabitScreen extends ConsumerStatefulWidget {
  const HealthHabitScreen({super.key});

  @override
  ConsumerState<HealthHabitScreen> createState() => _HealthHabitScreenState();
}

class _HealthHabitScreenState extends ConsumerState<HealthHabitScreen> {
  // Local water glasses state (1 to 8)
  int _waterGlasses = 5;

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final habitsAsync = ref.watch(activeHealthHabitsProvider);
    final completedAsync = ref.watch(todayCompletedHabitIdsProvider);
    final countsAsync = ref.watch(weeklyHabitCountsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isBn ? 'দৈনিক স্বাস্থ্য রুটিন' : 'Daily Health Habits',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            tooltip: isBn ? 'নতুন অভ্যাস যোগ করুন' : 'Add custom habit',
            onPressed: () => _showAddHabitSheet(context, ref, isBn),
            icon: const Icon(PhosphorIconsRegular.plusCircle, size: 24, color: AppColors.primaryColor),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitSheet(context, ref, isBn),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(PhosphorIconsRegular.plus, color: Colors.white),
        label: Text(
          isBn ? 'নতুন অভ্যাস' : 'Add Habit',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (habits) {
          final selectedDate = ref.watch(selectedHabitDateProvider);
          final completedAsync = ref.watch(completedHabitIdsForSelectedDateProvider);
          final completed = completedAsync.value ?? <int>{};
          final counts = countsAsync.value ?? <String, int>{};
          final progress = habits.isEmpty ? 0.0 : (completed.length / habits.length);
          final streak = _calculateStreak(counts);
          final isSelectedToday = habitDateString(selectedDate) == habitDateString(DateTime.now());

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              // 1. Hero Ring Progress Header
              _buildHeroHeader(isBn, completed.length, habits.length, progress, streak),
              const SizedBox(height: 16),

              // 2. 7-Day Consistency Dot Matrix
              _buildWeeklyDotMatrix(isBn, counts, habits.length, selectedDate),
              const SizedBox(height: 16),

              // Past date indicator banner
              if (!isSelectedToday)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsRegular.calendarCheck, size: 18, color: Color(0xFF2563EB)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isBn
                              ? 'তারিখ: ${selectedDate.day}/${selectedDate.month} এর রেকর্ড দেখা হচ্ছে'
                              : 'Viewing logs for ${selectedDate.day}/${selectedDate.month}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E40AF),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => ref.read(selectedHabitDateProvider.notifier).resetToToday(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF93C5FD)),
                          ),
                          child: Text(
                            isBn ? 'আজকে ফিরুন' : 'Today',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 3. Interactive Water Intake Tracker (8 Glasses)
              _buildWaterTrackerCard(isBn),
              const SizedBox(height: 20),

              // 4. Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSelectedToday
                        ? (isBn ? 'আজকের স্বাস্থ্য কর্মসূচি' : "Today's Wellness Tasks")
                        : (isBn ? 'ঐ দিনের স্বাস্থ্য কর্মসূচি' : "Day's Wellness Tasks"),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${completed.length}/${habits.length} ${isBn ? "সম্পন্ন" : "done"}',
                      style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 5. Habits List
              if (habits.isEmpty)
                _buildEmptyState(context, ref, isBn)
              else
                ...habits.map((habit) {
                  final isDone = completed.contains(habit.id);
                  return _buildHabitCard(context, ref, habit, isDone, isBn);
                }),

              const SizedBox(height: 24),
              // 6. Motivation Card
              _buildMotivationBanner(isBn, progress),
            ],
          );
        },
      ),
    );
  }

  // ─── 1. Hero Ring Progress Header ───
  Widget _buildHeroHeader(bool isBn, int completed, int total, double progress, int streak) {
    final percent = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F766E), // Deep Teal
            Color(0xFF0D9488),
            Color(0xFF14B8A6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),

          // Details & Streak
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBn ? 'আজকের অগ্রগতি' : "Today's Progress",
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    if (streak > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(PhosphorIconsFill.fire, color: Colors.white, size: 12),
                            const SizedBox(width: 3),
                            Text(
                              '$streak d',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$completed/$total ${isBn ? "কাজ সম্পন্ন" : "tasks completed"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  percent == 100
                      ? (isBn ? 'দারুণ! আজকের সব স্বাস্থ্য লক্ষ্য পূরণ হয়েছে 🎉' : 'Awesome! All wellness goals achieved today 🎉')
                      : (isBn ? 'সুস্থ থাকতে প্রতিদিনের রুটিন বজায় রাখুন' : 'Stay consistent to build a healthier life'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. 7-Day Consistency Dot Matrix ───
  Widget _buildWeeklyDotMatrix(bool isBn, Map<String, int> counts, int totalHabits, DateTime selectedDate) {
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? 'গত ৭ দিনের ধারাবাহিকতা ও তারিখ নির্বাচন' : '7-Day Consistency & Date Selector',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1E293B)),
              ),
              Text(
                isBn ? 'তারিখে ট্যাপ করুন' : 'Tap to view day',
                style: const TextStyle(fontSize: 11, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final date = today.subtract(Duration(days: 6 - index));
              final dateStr = habitDateString(date);
              final count = counts[dateStr] ?? 0;
              final isToday = index == 6;
              final isSelected = habitDateString(date) == habitDateString(selectedDate);
              final isDone = totalHabits > 0 && count >= totalHabits;
              final isPartial = totalHabits > 0 && count > 0 && count < totalHabits;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(selectedHabitDateProvider.notifier).selectDate(date);
                },
                child: Column(
                  children: [
                    Text(
                      _dayLabel(date.weekday, isBn),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.primaryColor : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFF10B981)
                            : (isPartial
                                ? const Color(0xFFF59E0B)
                                : (isSelected
                                    ? AppColors.primaryColor.withValues(alpha: 0.15)
                                    : Colors.grey.shade100)),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: AppColors.primaryColor, width: 2.2)
                            : (isToday ? Border.all(color: const Color(0xFF94A3B8), width: 1.2) : null),
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : (isPartial
                                ? Text(
                                    '$count',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppColors.primaryColor : Colors.grey.shade500,
                                    ),
                                  )),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── 3. Interactive Water Intake Tracker ───
  Widget _buildWaterTrackerCard(bool isBn) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE0F2FE), // Light sky blue
            const Color(0xFFF0F9FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(PhosphorIconsRegular.drop, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'পানি পানের ট্র্যাকার (Water Tracker)' : 'Daily Water Hydration',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0369A1)),
                      ),
                      Text(
                        isBn ? 'দৈনিক লক্ষ্য: ৮ গ্লাস (২ লিটার)' : 'Daily target: 8 glasses (2.0 L)',
                        style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_waterGlasses / 8',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 8 Interactive Glasses
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(8, (i) {
              final isFilled = i < _waterGlasses;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_waterGlasses == i + 1) {
                      _waterGlasses = i; // untap
                    } else {
                      _waterGlasses = i + 1;
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isFilled ? const Color(0xFF0284C7) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isFilled ? const Color(0xFF0369A1) : const Color(0xFFBAE6FD),
                      width: 1.5,
                    ),
                    boxShadow: isFilled
                        ? [BoxShadow(color: const Color(0xFF0284C7).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isFilled ? PhosphorIconsFill.drop : PhosphorIconsRegular.drop,
                        size: 16,
                        color: isFilled ? Colors.white : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isFilled ? Colors.white : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── 4. Habit Tile ───
  Widget _buildHabitCard(BuildContext context, WidgetRef ref, HealthHabitModel habit, bool completed, bool isBn) {
    final color = _parseColor(habit.color);

    return Dismissible(
      key: ValueKey(habit.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context, ref, habit, isBn),
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
            color: completed ? const Color(0xFF86EFAC) : Colors.grey.shade200,
            width: completed ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
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
              if (habit.id != null) {
                ref.read(healthHabitNotifierProvider.notifier).toggle(habit.id!, completed);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Checkmark Circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: completed ? const Color(0xFF10B981) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: completed ? const Color(0xFF10B981) : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: completed
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 14),

                  // Habit Icon Avatar
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_habitIcon(habit.icon), color: color, size: 20),
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
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            decoration: completed ? TextDecoration.lineThrough : null,
                            color: completed ? Colors.grey.shade500 : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              _localizedCategory(habit.category, isBn),
                              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                            ),
                            if (habit.reminderTime != null && habit.reminderTime!.isNotEmpty) ...[
                              Text('  •  ', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                              Icon(PhosphorIconsRegular.clock, size: 12, color: Colors.grey.shade500),
                              const SizedBox(width: 3),
                              Text(
                                habit.reminderTime!,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ],
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

  // ─── 5. Motivation Banner ───
  Widget _buildMotivationBanner(bool isBn, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsRegular.lightbulb, size: 24, color: Color(0xFF0F766E)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isBn
                  ? 'গবেষণায় দেখা গেছে, একটানা ২১ দিন একটি অভ্যাস বজায় রাখলে তা চিরস্থায়ী জীবনযাপনে রূপ নেয়।'
                  : 'Research shows practicing a healthy routine consistently for 21 days turns it into a permanent lifestyle.',
              style: TextStyle(fontSize: 11.5, color: Colors.blueGrey.shade800, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, bool isBn) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(PhosphorIconsRegular.sparkle, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            isBn ? 'কোনো অভ্যাস যুক্ত করা নেই' : 'No habits yet',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          ElevatedButton.icon(
            onPressed: () => _showAddHabitSheet(context, ref, isBn),
            icon: const Icon(Icons.add, size: 16),
            label: Text(isBn ? 'প্রথম অভ্যাস তৈরি করুন' : 'Add your first habit'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, WidgetRef ref, HealthHabitModel habit, bool isBn) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(isBn ? 'অভ্যাসটি মুছবেন?' : 'Delete habit?'),
        content: Text('${habit.title} ${isBn ? "মুছে ফেলতে চান?" : "will be removed."}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isBn ? 'বাতিল' : 'Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isBn ? 'মুছুন' : 'Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (result == true && habit.id != null) {
      await ref.read(healthHabitNotifierProvider.notifier).delete(habit.id!);
    }
    return result == true;
  }

  int _calculateStreak(Map<String, int> counts) {
    var streak = 0;
    final today = DateTime.now();
    for (var index = 0; index < 7; index++) {
      if ((counts[habitDateString(today.subtract(Duration(days: index)))] ?? 0) > 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  String _dayLabel(int weekday, bool isBn) {
    if (isBn) {
      return ['সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি', 'রবি'][weekday - 1];
    }
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
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

Future<void> _showAddHabitSheet(BuildContext context, WidgetRef ref, bool isBn) async {
  final result = await showModalBottomSheet<HealthHabitModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddHabitSheet(isBn: isBn),
  );
  if (result != null) await ref.read(healthHabitNotifierProvider.notifier).add(result);
}

class _AddHabitSheet extends StatefulWidget {
  final bool isBn;

  const _AddHabitSheet({required this.isBn});

  @override
  State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final _titleController = TextEditingController();
  String _category = 'Wellness';
  String? _reminderTime;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBn = widget.isBn;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isBn ? 'নতুন স্বাস্থ্য অভ্যাস যোগ করুন' : 'Add Custom Health Habit',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: isBn ? 'অভ্যাসের নাম' : 'Habit name',
                hintText: isBn ? 'যেমন: ২০ মিনিট মেডিটেশন' : 'e.g. 20 min meditation',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                labelText: isBn ? 'বিভাগ (Category)' : 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              items: ['Wellness', 'Nutrition', 'Exercise', 'Sleep', 'Medicine', 'Vitals']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => _category = value ?? _category),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _pickReminderTime,
              icon: const Icon(PhosphorIconsRegular.alarm),
              label: Text(_reminderTime == null ? (isBn ? 'অনুস্মারক সময় সেট করুন' : 'Add reminder time') : _reminderTime!),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  isBn ? 'অভ্যাসটি সংরক্ষণ করুন' : 'Save Habit',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
    if (picked != null && mounted) setState(() => _reminderTime = picked.format(context));
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    Navigator.pop(
      context,
      HealthHabitModel(
        title: title,
        category: _category,
        reminderTime: _reminderTime,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
  }
}
