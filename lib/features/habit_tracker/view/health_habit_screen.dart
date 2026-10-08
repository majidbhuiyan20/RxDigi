import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';
import '../models/health_habit_model.dart';
import '../models/habit_analytics_model.dart';
import '../provider/health_habit_provider.dart';
import '../widgets/habit_bar_chart.dart';
import '../widgets/habit_category_chart.dart';
import '../widgets/habit_stats_overview.dart';
import '../widgets/habit_item_card.dart';
import '../widgets/habit_water_tracker.dart';
import '../provider/water_intake_provider.dart';

class HealthHabitScreen extends ConsumerStatefulWidget {
  const HealthHabitScreen({super.key});

  @override
  ConsumerState<HealthHabitScreen> createState() => _HealthHabitScreenState();
}

class _HealthHabitScreenState extends ConsumerState<HealthHabitScreen> {
  int _activeTab = 0; // 0: Daily Checklist, 1: Weekly Analytics

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final habitsAsync = ref.watch(activeHealthHabitsProvider);
    final selectedDate = ref.watch(selectedHabitDateProvider);
    final isToday = habitDateString(selectedDate) == habitDateString(DateTime.now());
    final analyticsAsync = ref.watch(habitAnalyticsReportProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isBn ? 'দৈনিক স্বাস্থ্য রুটিন' : 'Daily Health Habits',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: Color(0xFF0F172A),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showAddHabitSheet(context, ref, isBn),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(PhosphorIconsBold.plus, size: 14, color: AppColors.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      isBn ? 'নতুন অভ্যাস' : 'Add Habit',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Segmented Tab Switcher (Checklist vs Analytics)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Container(
                height: 42,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _activeTab = 0);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            color: _activeTab == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: _activeTab == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1.5),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIconsFill.checkSquare,
                                size: 15,
                                color: _activeTab == 0 ? AppColors.primaryColor : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isBn ? 'দৈনিক চেকলিস্ট' : 'Daily Checklist',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: _activeTab == 0 ? FontWeight.bold : FontWeight.w600,
                                  color: _activeTab == 0 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _activeTab = 1);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            color: _activeTab == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: _activeTab == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1.5),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIconsFill.chartBar,
                                size: 15,
                                color: _activeTab == 1 ? const Color(0xFF0D9488) : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isBn ? 'উইকলি অ্যানালিটিক্স' : 'Weekly Analytics',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: _activeTab == 1 ? FontWeight.bold : FontWeight.w600,
                                  color: _activeTab == 1 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Tab Content
            Expanded(
              child: _activeTab == 0
                  ? _buildChecklistTab(context, ref, habitsAsync, selectedDate, isToday, isBn)
                  : _buildAnalyticsTab(context, ref, analyticsAsync, selectedDate, isBn),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 0: Daily Checklist
  Widget _buildChecklistTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<HealthHabitModel>> habitsAsync,
    DateTime selectedDate,
    bool isToday,
    bool isBn,
  ) {
    final completedAsync = ref.watch(completedHabitIdsForSelectedDateProvider);
    final weeklyCountsAsync = ref.watch(weeklyHabitCountsProvider);

    return habitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (habits) {
        final completedIds = completedAsync.value ?? <int>{};
        final totalHabits = habits.length;
        final completedCount = habits.where((h) => completedIds.contains(h.id)).length;
        final progress = totalHabits > 0 ? (completedCount / totalHabits) : 0.0;
        final percent = (progress * 100).toInt();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
          physics: const BouncingScrollPhysics(),
          children: [
            // Status Completion Banner (Unclipped & Clean)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: progress >= 1.0
                      ? [const Color(0xFF065F46), const Color(0xFF059669)]
                      : [const Color(0xFF0F766E), const Color(0xFF0D9488)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Circular Progress Indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 5,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn
                              ? '$totalHabits টির মধ্যে $completedCount টি টাস্ক সম্পন্ন'
                              : '$completedCount of $totalHabits tasks completed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          progress >= 1.0
                              ? (isBn ? 'দারুণ! আজকের সকল লক্ষ্য পূরণ হয়েছে 🎉' : 'Awesome! All targets reached 🎉')
                              : (isBn ? 'প্রতিটি ছোট অভ্যাস আপনার সুস্থতার ভিত্তি' : 'Keep building healthy daily routines'),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Date Ribbon Selector
            weeklyCountsAsync.when(
              data: (counts) => _buildDateRibbon(ref, selectedDate, totalHabits, counts, isBn),
              loading: () => const SizedBox(height: 60),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),

            // Past date indicator banner
            if (!isToday) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(PhosphorIconsFill.clockCounterClockwise, size: 14, color: Color(0xFFD97706)),
                        const SizedBox(width: 6),
                        Text(
                          isBn
                              ? '${selectedDate.day}/${selectedDate.month} তারিখের হিস্ট্রি দেখছেন'
                              : 'Viewing log for ${selectedDate.day}/${selectedDate.month}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(selectedHabitDateProvider.notifier).resetToToday();
                      },
                      child: Text(
                        isBn ? 'আজকে ফিরুন' : 'Back to Today',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F766E),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Water Hydration Widget
            HabitWaterTracker(
              glasses: ref.watch(waterIntakeForDateProvider(habitDateString(selectedDate))),
              onChanged: (val) {
                ref.read(waterIntakeNotifierProvider.notifier).setGlasses(habitDateString(selectedDate), val);
              },
              isBn: isBn,
            ),
            const SizedBox(height: 16),

            // Habits Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBn ? 'সুস্থতার দৈনিক অভ্যাসসমূহ' : 'Daily Wellness Habits',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$completedCount/$totalHabits ${isBn ? "সম্পন্ন" : "done"}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Habits List with HabitItemCard (No ugly strikethrough!)
            ...habits.map((habit) {
              final isCompleted = completedIds.contains(habit.id);
              return HabitItemCard(
                habit: habit,
                completed: isCompleted,
                isBn: isBn,
                onToggle: () {
                  if (habit.id != null) {
                    ref.read(healthHabitNotifierProvider.notifier).toggle(habit.id!, isCompleted);
                  }
                },
                onDelete: () {
                  if (habit.id != null) {
                    ref.read(healthHabitNotifierProvider.notifier).delete(habit.id!);
                  }
                },
              );
            }),
          ],
        );
      },
    );
  }

  // TAB 1: Weekly Analytics
  Widget _buildAnalyticsTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<HabitAnalyticsReport> analyticsAsync,
    DateTime selectedDate,
    bool isBn,
  ) {
    return analyticsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(child: Text('Error loading analytics: $e')),
      data: (report) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
          physics: const BouncingScrollPhysics(),
          children: [
            // KPI Summary Cards
            HabitStatsOverview(report: report, isBn: isBn),
            const SizedBox(height: 14),

            // fl_chart Bar Chart: Daily consistency trend
            HabitBarChart(
              dailyStats: report.dailyStats,
              selectedDate: selectedDate,
              onDateSelected: (date) {
                ref.read(selectedHabitDateProvider.notifier).selectDate(date);
                // Also optionally switch to checklist tab so user inspects that day
                setState(() => _activeTab = 0);
              },
              isBn: isBn,
            ),
            const SizedBox(height: 14),

            // fl_chart Pie Chart: Category wellness balance
            HabitCategoryChart(
              categoryStats: report.categoryStats,
              averageScore: report.averagePercentage,
              isBn: isBn,
            ),
            const SizedBox(height: 14),

            // Motivational Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(PhosphorIconsFill.lightbulb, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'স্বাস্থ্য পরামর্শ' : 'Health Habit Tip',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isBn
                              ? 'একটি নির্দিষ্ট সময়ে অভ্যাস পালন করলে তা দ্রুত স্থায়ী অভ্যাসে রূপ নেয়। অ্যালার্ম বা রিমাইন্ডার সেট করে রাখুন!'
                              : 'Performing habits at a consistent time each day anchors them faster. Use reminder alerts!',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF1E40AF),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Date Ribbon Picker
  Widget _buildDateRibbon(
    WidgetRef ref,
    DateTime selectedDate,
    int totalHabits,
    Map<String, int> counts,
    bool isBn,
  ) {
    final now = DateTime.now();
    final todayStr = habitDateString(now);
    final selectedStr = habitDateString(selectedDate);
    final bnDays = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি'];
    final enDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBn ? 'সাপ্তাহিক ক্যালেন্ডার' : 'Weekly Calendar',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
                Text(
                  isBn ? 'দিন নির্বাচন করে হিস্ট্রি দেখুন' : 'Tap day to view logs',
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final d = now.subtract(Duration(days: 6 - i));
              final dStr = habitDateString(d);
              final isToday = dStr == todayStr;
              final isSelected = dStr == selectedStr;
              final completed = counts[dStr] ?? 0;
              final isFull = totalHabits > 0 && completed >= totalHabits;
              final weekdayIdx = (d.weekday - 1) % 7;
              final dayLabel = isBn ? bnDays[weekdayIdx] : enDays[weekdayIdx];

              Color dotColor;
              if (isFull) {
                dotColor = const Color(0xFF10B981);
              } else if (completed > 0) {
                dotColor = const Color(0xFFF59E0B);
              } else {
                dotColor = const Color(0xFFCBD5E1);
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(selectedHabitDateProvider.notifier).selectDate(d);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0F766E)
                        : (isToday ? const Color(0xFFF0FDF4) : Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0F766E)
                          : (isToday ? const Color(0xFF86EFAC) : Colors.transparent),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isToday ? const Color(0xFF0F766E) : const Color(0xFF64748B)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : dotColor,
                          shape: BoxShape.circle,
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
              initialValue: _category,
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
