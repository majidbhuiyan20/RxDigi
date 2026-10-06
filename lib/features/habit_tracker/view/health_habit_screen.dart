import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_colors.dart';
import '../models/health_habit_model.dart';
import '../provider/health_habit_provider.dart';

class HealthHabitScreen extends ConsumerWidget {
  const HealthHabitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final habitsAsync = ref.watch(activeHealthHabitsProvider);
    final completedAsync = ref.watch(todayCompletedHabitIdsProvider);
    final countsAsync = ref.watch(weeklyHabitCountsProvider);
    final medicineAsync = ref.watch(medicineAdherenceSummaryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(isBn ? 'দৈনিক স্বাস্থ্য রুটিন' : 'Daily Health Routine', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: isBn ? 'নতুন অভ্যাস যোগ করুন' : 'Add custom habit',
            onPressed: () => _showAddHabitSheet(context, ref, isBn),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitSheet(context, ref, isBn),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(isBn ? 'অভ্যাস যোগ করুন' : 'Add Habit', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (habits) {
          final completed = completedAsync.value ?? <int>{};
          final counts = countsAsync.value ?? <String, int>{};
          final medicine = medicineAsync.value ?? {'taken': 0, 'total': 0};
          final habitProgress = habits.isEmpty ? 0.0 : completed.length / habits.length;
          final streak = _calculateStreak(counts);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              _buildProgressHeader(context, isBn, completed.length, habits.length, habitProgress, streak),
              const SizedBox(height: 16),
              _buildMedicineSummary(isBn, medicine),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isBn ? 'আজকের অভ্যাস' : "Today's habits", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  Text('${completed.length}/${habits.length}', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              if (habits.isEmpty)
                _buildEmptyState(context, ref, isBn)
              else
                ...habits.map((habit) => _buildHabitTile(context, ref, habit, completed.contains(habit.id), isBn)),
              const SizedBox(height: 20),
              _buildWeeklyChart(isBn, habits.length, counts),
              const SizedBox(height: 20),
              _buildMissedHistory(isBn, habits.length, counts),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, bool isBn, int completed, int total, double progress, int streak) {
    final percent = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: AppColors.primaryColor.withOpacity(0.2), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            height: 82,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(value: progress, strokeWidth: 8, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.white)),
                Text('$percent%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isBn ? 'আজকের অগ্রগতি' : "Today's progress", style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text('$completed/$total ${isBn ? 'সম্পন্ন' : 'completed'}', style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.local_fire_department_rounded, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text('$streak ${isBn ? 'দিনের streak' : 'day streak'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineSummary(bool isBn, Map<String, int> medicine) {
    final total = medicine['total'] ?? 0;
    final taken = medicine['taken'] ?? 0;
    final percent = total == 0 ? 0 : (taken / total * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        const Icon(Icons.medication_rounded, color: Color(0xFFE65100)),
        const SizedBox(width: 10),
        Expanded(child: Text(isBn ? 'আজকের ওষুধ গ্রহণ' : "Today's medicine adherence", style: const TextStyle(fontWeight: FontWeight.w600))),
        Text('$taken/$total  $percent%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
      ]),
    );
  }

  Widget _buildHabitTile(BuildContext context, WidgetRef ref, HealthHabitModel habit, bool completed, bool isBn) {
    final color = _parseColor(habit.color);
    return Dismissible(
      key: ValueKey(habit.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context, ref, habit, isBn),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: completed ? color.withOpacity(0.5) : Colors.grey.shade200)),
        child: ListTile(
          onTap: () => ref.read(healthHabitNotifierProvider.notifier).toggle(habit.id!, completed),
          leading: CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(_habitIcon(habit.icon), color: color, size: 21)),
          title: Text(habit.title, style: TextStyle(fontWeight: FontWeight.w600, decoration: completed ? TextDecoration.lineThrough : null)),
          subtitle: Text('${habit.category}${habit.reminderTime == null ? '' : '  •  ${habit.reminderTime}'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          trailing: Checkbox(value: completed, activeColor: color, onChanged: (_) => ref.read(healthHabitNotifierProvider.notifier).toggle(habit.id!, completed)),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(bool isBn, int totalHabits, Map<String, int> counts) {
    final today = DateTime.now();
    return _sectionContainer(
      title: isBn ? 'সাপ্তাহিক অগ্রগতি' : 'Weekly progress',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final date = today.subtract(Duration(days: 6 - index));
          final count = counts[habitDateString(date)] ?? 0;
          final ratio = totalHabits == 0 ? 0.0 : (count / totalHabits).clamp(0.0, 1.0);
          return Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(height: 86, child: Align(alignment: Alignment.bottomCenter, child: Container(width: 20, height: 12 + (ratio * 62).toDouble(), decoration: BoxDecoration(color: ratio == 1 ? AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.35), borderRadius: BorderRadius.circular(8))))),
            const SizedBox(height: 6),
            Text(_dayLabel(date.weekday, isBn), style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          ]);
        }),
      ),
    );
  }

  Widget _buildMissedHistory(bool isBn, int totalHabits, Map<String, int> counts) {
    final missedDays = counts.entries.where((entry) => totalHabits > 0 && entry.value < totalHabits).length;
    return _sectionContainer(
      title: isBn ? 'মিসড হিস্টোরি' : 'Missed history',
      child: Row(children: [
        Icon(missedDays == 0 ? Icons.verified_rounded : Icons.history_toggle_off_rounded, color: missedDays == 0 ? Colors.green : Colors.orange),
        const SizedBox(width: 10),
        Expanded(child: Text(missedDays == 0 ? (isBn ? 'গত ৭ দিনে কোনো habit মিস হয়নি।' : 'No habits missed in the last 7 days.') : '$missedDays ${isBn ? 'দিনে কিছু habit বাকি ছিল।' : 'days had incomplete habits.'}', style: TextStyle(color: Colors.grey.shade700))),
      ]),
    );
  }

  Widget _sectionContainer({required String title, required Widget child}) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 14), child]));
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, bool isBn) => _sectionContainer(title: isBn ? 'কোনো habit নেই' : 'No habits yet', child: Center(child: TextButton.icon(onPressed: () => _showAddHabitSheet(context, ref, isBn), icon: const Icon(Icons.add), label: Text(isBn ? 'প্রথম habit যোগ করুন' : 'Add your first habit'))));

  Future<bool> _confirmDelete(BuildContext context, WidgetRef ref, HealthHabitModel habit, bool isBn) async {
    final result = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: Text(isBn ? 'Habit মুছবেন?' : 'Delete habit?'), content: Text(habit.title), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isBn ? 'না' : 'Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(isBn ? 'মুছুন' : 'Delete'))]));
    if (result == true) await ref.read(healthHabitNotifierProvider.notifier).delete(habit.id!);
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

  String _dayLabel(int weekday, bool isBn) => isBn ? ['সোম', 'মঙ্গল', 'বুধ', 'বৃহস্পতি', 'শুক্র', 'শনি', 'রবি'][weekday - 1] : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];

  IconData _habitIcon(String icon) => {'water_drop': Icons.water_drop_rounded, 'directions_walk': Icons.directions_walk_rounded, 'bedtime': Icons.bedtime_rounded, 'monitor_heart': Icons.monitor_heart_rounded, 'restaurant': Icons.restaurant_rounded}.containsKey(icon) ? {'water_drop': Icons.water_drop_rounded, 'directions_walk': Icons.directions_walk_rounded, 'bedtime': Icons.bedtime_rounded, 'monitor_heart': Icons.monitor_heart_rounded, 'restaurant': Icons.restaurant_rounded}[icon]! : Icons.check_circle_rounded;

  Color _parseColor(String hex) { try { return Color(int.parse(hex.replaceFirst('#', '0xFF'))); } catch (_) { return AppColors.primaryColor; } }
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
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)))),
          const SizedBox(height: 18),
          Text(isBn ? 'Custom habit যোগ করুন' : 'Add custom habit', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _titleController, autofocus: true, decoration: InputDecoration(labelText: isBn ? 'Habit-এর নাম' : 'Habit name', hintText: isBn ? 'যেমন: ৮ গ্লাস পানি' : 'e.g. Drink 8 glasses of water', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(initialValue: _category, decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), items: ['Wellness', 'Nutrition', 'Exercise', 'Sleep', 'Medicine', 'Vitals'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(), onChanged: (value) => setState(() => _category = value ?? _category)),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: _pickReminderTime, icon: const Icon(Icons.notifications_none_rounded), label: Text(_reminderTime == null ? (isBn ? 'Reminder time যোগ করুন' : 'Add reminder time') : _reminderTime!)),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: Text(isBn ? 'সংরক্ষণ করুন' : 'Save habit'))),
        ]),
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
    Navigator.pop(context, HealthHabitModel(title: title, category: _category, reminderTime: _reminderTime, createdAt: DateTime.now().toIso8601String()));
  }
}
