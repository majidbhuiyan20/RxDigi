import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';
import '../../../app/slot_style.dart';
import '../../../core/data/models/medicine_model.dart';
import '../../../core/data/providers/medicine_provider.dart';
import '../models/medicine_reminder_model.dart';
import '../provider/medicine_reminder_provider.dart';

class AddReminderSheet extends ConsumerStatefulWidget {
  const AddReminderSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddReminderSheet(),
    );
  }

  @override
  ConsumerState<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends ConsumerState<AddReminderSheet> {
  final _nameController = TextEditingController();
  final _strengthController = TextEditingController();

  String _dosageForm = 'Tablet';
  String _instructions = 'After Meal';

  bool _morning = true;
  bool _noon = false;
  bool _night = true;

  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _noonTime = const TimeOfDay(hour: 13, minute: 30);
  TimeOfDay _nightTime = const TimeOfDay(hour: 21, minute: 0);

  int _durationDays = 0; // 0 = Ongoing

  final List<String> _forms = ['Tablet', 'Capsule', 'Syrup', 'Drop', 'Injection', 'Cream'];
  final List<String> _instructionOptions = [
    'After Meal',
    'Before Meal',
    'With Meal',
    'Empty Stomach',
  ];

  // Quick dose patterns: morning + noon + night
  final List<List<int>> _dosePatterns = const [
    [1, 0, 0],
    [0, 0, 1],
    [1, 0, 1],
    [1, 1, 1],
    [0, 1, 0],
    [0, 1, 1],
  ];

  List<MedicineModel> _suggestions = [];
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _strengthController.dispose();
    super.dispose();
  }

  void _onNameChanged(String value) {
    _debounce?.cancel();
    final q = value.trim();
    if (q.length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final results = await ref.read(medicineRepositoryProvider).searchMedicines(q);
      if (!mounted) return;
      setState(() => _suggestions = results);
    });
  }

  void _selectMedicine(MedicineModel m) {
    FocusScope.of(context).unfocus();
    final form = (m.dosageForm ?? '').toLowerCase();
    String matched = _dosageForm;
    for (final f in _forms) {
      if (form.contains(f.toLowerCase())) {
        matched = f;
        break;
      }
    }
    setState(() {
      _nameController.text = m.name;
      _strengthController.text = m.strength ?? '';
      _dosageForm = matched;
      _suggestions = [];
    });
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> _pickTime(String slot) async {
    TimeOfDay initial = slot == 'morning'
        ? _morningTime
        : slot == 'noon'
            ? _noonTime
            : _nightTime;

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      setState(() {
        if (slot == 'morning') _morningTime = picked;
        if (slot == 'noon') _noonTime = picked;
        if (slot == 'night') _nightTime = picked;
      });
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter medicine name')),
      );
      return;
    }

    if (!_morning && !_noon && !_night) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one schedule time (Morning, Noon, or Night)')),
      );
      return;
    }

    final reminder = MedicineReminderModel(
      medicineName: name,
      dosageForm: _dosageForm,
      dosageStrength: _strengthController.text.trim(),
      instructions: _instructions,
      morning: _morning,
      noon: _noon,
      night: _night,
      morningTime: _formatTimeOfDay(_morningTime),
      noonTime: _formatTimeOfDay(_noonTime),
      nightTime: _formatTimeOfDay(_nightTime),
      startDate: getTodayDateString(),
      durationDays: _durationDays,
      createdAt: DateTime.now().toIso8601String(),
    );

    ref.read(medicineReminderNotifierProvider.notifier).addReminder(reminder);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder added for $name'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.alarm_add_rounded, color: AppColors.primaryColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'নতুন মেডিসিন রিমাইন্ডার' : 'Add Medicine Reminder',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isBn ? 'সঠিক সময়ে ঔষধ খাওয়ার নোটিফিকেশন সেট করুন' : 'Track schedule & daily adherence',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Medicine Name Field
            Text(
              isBn ? 'ঔষধের নাম' : 'Medicine Name',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              onChanged: _onNameChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: isBn ? 'ঔষধের নাম লিখুন (যেমন: Napa)' : 'Type medicine name (e.g. Napa)',
                prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass, color: AppColors.primaryColor),
                suffixIcon: _nameController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _nameController.clear();
                          setState(() => _suggestions = []);
                        },
                      ),
              ),
            ),
            if (_suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 6),
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (context, i) {
                    final m = _suggestions[i];
                    final sub = [m.strength, m.dosageForm, m.genericName]
                        .where((e) => e != null && e.trim().isNotEmpty)
                        .join(' • ');
                    return ListTile(
                      dense: true,
                      title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: sub.isEmpty
                          ? null
                          : Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5)),
                      trailing: Icon(PhosphorIconsRegular.plusCircle, color: AppColors.primaryColor, size: 20),
                      onTap: () => _selectMedicine(m),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Form & Strength Row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'প্রকার (Form)' : 'Dosage Form',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _dosageForm,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                        items: _forms.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _dosageForm = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'মাত্রা' : 'Strength',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _strengthController,
                        decoration: InputDecoration(
                          hintText: isBn ? 'যেমন: 500mg' : 'e.g. 500mg',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Schedule / Times of Day
            Text(
              isBn ? 'গ্রহণের সময়সূচী (Schedule)' : 'Times of Day',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dosePatterns.map((p) {
                final selected = _morning == (p[0] == 1) && _noon == (p[1] == 1) && _night == (p[2] == 1);
                return ChoiceChip(
                  label: Text(p.join(' + ')),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: AppColors.primaryColor,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: selected ? Colors.white : Colors.black87,
                  ),
                  side: BorderSide(color: selected ? AppColors.primaryColor : Colors.grey.shade300),
                  onSelected: (_) => setState(() {
                    _morning = p[0] == 1;
                    _noon = p[1] == 1;
                    _night = p[2] == 1;
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildScheduleSlot(
                  title: isBn ? 'সকাল' : 'Morning',
                  style: SlotStyle.morning,
                  isSelected: _morning,
                  timeText: _formatTimeOfDay(_morningTime),
                  onToggle: () => setState(() => _morning = !_morning),
                  onPickTime: () => _pickTime('morning'),
                ),
                const SizedBox(width: 8),
                _buildScheduleSlot(
                  title: isBn ? 'দুপুর' : 'Noon',
                  style: SlotStyle.noon,
                  isSelected: _noon,
                  timeText: _formatTimeOfDay(_noonTime),
                  onToggle: () => setState(() => _noon = !_noon),
                  onPickTime: () => _pickTime('noon'),
                ),
                const SizedBox(width: 8),
                _buildScheduleSlot(
                  title: isBn ? 'রাত' : 'Night',
                  style: SlotStyle.night,
                  isSelected: _night,
                  timeText: _formatTimeOfDay(_nightTime),
                  onToggle: () => setState(() => _night = !_night),
                  onPickTime: () => _pickTime('night'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Meal Instructions
            Text(
              isBn ? 'খাওয়ার নিয়ম (Meal Instruction)' : 'Meal Instructions',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _instructionOptions.map((opt) {
                final isSelected = _instructions == opt;
                return ChoiceChip(
                  label: Text(
                    isBn
                        ? (opt == 'After Meal'
                            ? 'খাওয়ার পর'
                            : opt == 'Before Meal'
                                ? 'খাওয়ার আগে'
                                : opt == 'With Meal'
                                    ? 'খাওয়ার সাথে'
                                    : 'খালি পেটে')
                        : opt,
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primaryColor.withOpacity(0.18),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primaryColor : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _instructions = opt);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Duration
            Text(
              isBn ? 'সময়কাল (Duration)' : 'Treatment Duration',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDurationChip(0, isBn ? 'চলমান (Ongoing)' : 'Ongoing'),
                _buildDurationChip(3, isBn ? '৩ দিন' : '3 Days'),
                _buildDurationChip(5, isBn ? '৫ দিন' : '5 Days'),
                _buildDurationChip(7, isBn ? '৭ দিন' : '7 Days'),
                _buildDurationChip(14, isBn ? '১৪ দিন' : '14 Days'),
                _buildDurationChip(30, isBn ? '৩০ দিন' : '30 Days'),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded, color: Colors.white),
                label: Text(
                  isBn ? 'রিমাইন্ডার সংরক্ষণ করুন' : 'Save Medicine Reminder',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSlot({
    required String title,
    required SlotStyle style,
    required bool isSelected,
    required String timeText,
    required VoidCallback onToggle,
    required VoidCallback onPickTime,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor.withOpacity(0.08) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(style.icon, size: 26, color: isSelected ? style.color : Colors.grey.shade400),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? AppColors.primaryColor : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: isSelected ? onPickTime : onToggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    timeText,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primaryColor : Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationChip(int days, String label) {
    final isSelected = _durationDays == days;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryColor.withOpacity(0.18),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (val) {
        if (val) setState(() => _durationDays = days);
      },
    );
  }
}
