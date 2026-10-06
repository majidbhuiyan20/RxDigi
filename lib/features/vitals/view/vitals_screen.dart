import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/app_colors.dart';
import '../models/vital_log_model.dart';
import '../provider/vitals_provider.dart';
import 'add_vital_sheet.dart';

class VitalsScreen extends ConsumerStatefulWidget {
  const VitalsScreen({super.key});

  @override
  ConsumerState<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends ConsumerState<VitalsScreen> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final vitalsAsync = ref.watch(vitalsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Health Vitals Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 26),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const AddVitalSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                _buildFilterChip('ALL', 'All'),
                _buildFilterChip('BP', 'Blood Pressure'),
                _buildFilterChip('SUGAR', 'Sugar'),
                _buildFilterChip('WEIGHT', 'Weight'),
              ],
            ),
          ),
          Expanded(
            child: vitalsAsync.when(
              data: (list) {
                final filtered = _selectedFilter == 'ALL'
                    ? list
                    : list.where((v) => v.type == _selectedFilter).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.monitor_heart_outlined, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No vitals recorded yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => AddVitalSheet(
                                initialType: _selectedFilter == 'ALL' ? 'BP' : _selectedFilter,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Log First Vital'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _buildVitalCard(item);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddVitalSheet(),
          );
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVitalCard(VitalLogModel item) {
    Color cardColor;
    IconData icon;
    String valueText = '';
    String? subtext;

    if (item.type == 'BP') {
      cardColor = const Color(0xFFE53935);
      icon = Icons.favorite_rounded;
      valueText = '${item.value1.toInt()}/${item.value2?.toInt() ?? 0} ${item.unit}';
      subtext = item.getBpStatus();
    } else if (item.type == 'SUGAR') {
      cardColor = const Color(0xFF1E88E5);
      icon = Icons.water_drop_rounded;
      valueText = '${item.value1.toStringAsFixed(1)} ${item.unit}';
      subtext = item.category ?? 'Random';
    } else {
      cardColor = const Color(0xFF00897B);
      icon = Icons.monitor_weight_rounded;
      valueText = '${item.value1.toStringAsFixed(1)} ${item.unit}';
      final bmi = item.getBmi();
      if (bmi != null) {
        subtext = 'BMI: ${bmi.toStringAsFixed(1)}';
      }
    }

    final dateStr = DateFormat('d MMM yyyy, h:mm a').format(item.recordedAt);

    return Dismissible(
      key: Key('vital_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        if (item.id != null) {
          ref.read(vitalsListProvider.notifier).deleteVital(item.id!);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: cardColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valueText,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (subtext != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: cardColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            subtext,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: cardColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        dateStr,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  if (item.notes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.notes!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
