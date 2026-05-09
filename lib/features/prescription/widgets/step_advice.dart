import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/features/prescription/provider/prescription_provider.dart';

class StepAdvice extends ConsumerWidget {
  const StepAdvice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prescriptionProvider);
    final notifier = ref.read(prescriptionProvider.notifier);

    final List<String> commonAdvice = [
      'Drink plenty of water',
      'Take complete rest',
      'Avoid cold food/drinks',
      'Walk for 30 minutes daily',
      'Stop smoking'
    ];

    final List<String> commonTests = [
      'CBC', 'CRP', 'Blood Sugar (F/PP)', 'Urine R/M/E', 'X-ray Chest P/A View', 'ECG'
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Advice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.topHeaderColor)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: commonAdvice.map((advice) => ActionChip(
              label: Text(advice),
              onPressed: () {
                final current = state.advice ?? '';
                notifier.updateAdvice(current.isEmpty ? advice : '$current. $advice');
              },
            )).toList(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: state.advice,
            maxLines: 4,
            onChanged: notifier.updateAdvice,
            decoration: InputDecoration(
              hintText: 'Enter clinical advice...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          
          const SizedBox(height: 24),
          Text('Lab Tests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.topHeaderColor)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: commonTests.map((test) => FilterChip(
              label: Text(test),
              selected: state.labTests.contains(test),
              onSelected: (selected) {
                if (selected) {
                  notifier.addLabTest(test);
                } else {
                  // remove logic if needed
                }
              },
            )).toList(),
          ),

          const SizedBox(height: 24),
          Text('Follow-up / Next Visit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.topHeaderColor)),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: state.nextVisit,
            onChanged: notifier.updateNextVisit,
            decoration: InputDecoration(
              hintText: 'e.g. After 7 days or 15/05/2026',
              prefixIcon: const Icon(Icons.calendar_today),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
