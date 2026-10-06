import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_colors.dart';
import '../provider/health_habit_provider.dart';
import '../view/health_habit_screen.dart';

class HealthHabitHomeCard extends ConsumerWidget {
  const HealthHabitHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final habitsAsync = ref.watch(activeHealthHabitsProvider);
    final completedAsync = ref.watch(todayCompletedHabitIdsProvider);
    final medicineAsync = ref.watch(medicineAdherenceSummaryProvider);

    return habitsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (habits) {
        final completed = completedAsync.value ?? <int>{};
        final progress = habits.isEmpty ? 0.0 : completed.length / habits.length;
        final medicine = medicineAsync.value ?? {'taken': 0, 'total': 0};
        final medicineTotal = medicine['total'] ?? 0;
        final medicineTaken = medicine['taken'] ?? 0;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.checklist_rounded, color: AppColors.primaryColor, size: 20)),
              const SizedBox(width: 10),
              Expanded(child: Text(isBn ? 'দৈনিক স্বাস্থ্য রুটিন' : 'Daily Health Routine', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthHabitScreen())), child: Text(isBn ? 'দেখুন' : 'View')),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.grey.shade100, valueColor: const AlwaysStoppedAnimation(AppColors.primaryColor)))),
              const SizedBox(width: 10),
              Text('${completed.length}/${habits.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.medication_outlined, size: 17, color: Color(0xFFE65100)),
              const SizedBox(width: 6),
              Text(isBn ? 'ওষুধ: $medicineTaken/$medicineTotal' : 'Medicine: $medicineTaken/$medicineTotal', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              const Spacer(),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthHabitScreen())), child: Text(isBn ? 'Routine খুলুন' : 'Open routine')),
            ]),
          ]),
        );
      },
    );
  }
}
