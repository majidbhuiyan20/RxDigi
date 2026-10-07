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

class DosePreset {
  final String label;
  final bool morning;
  final bool noon;
  final bool evening;
  final bool night;

  const DosePreset({
    required this.label,
    required this.morning,
    required this.noon,
    required this.evening,
    required this.night,
  });
}

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
  bool _evening = false;
  bool _night = true;

  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _noonTime = const TimeOfDay(hour: 13, minute: 30);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _nightTime = const TimeOfDay(hour: 21, minute: 0);

  int _durationDays = 0; // 0 = Ongoing

  final List<String> _forms = ['Tablet', 'Capsule', 'Syrup', 'Drop', 'Injection', 'Cream', 'Ointment', 'Suspension'];
  final List<String> _instructionOptions = [
    'After Meal',
    'Before Meal',
    'With Meal',
    'Empty Stomach',
  ];

  // Quick dose patterns (including Bangladeshi 4-part prescribing standards)
  final List<DosePreset> _presets = const [
    DosePreset(label: '1 + 0 + 1', morning: true, noon: false, evening: false, night: true),
    DosePreset(label: '1 + 1 + 1', morning: true, noon: true, evening: false, night: true),
    DosePreset(label: '1 + 0 + 0', morning: true, noon: false, evening: false, night: false),
    DosePreset(label: '0 + 0 + 1', morning: false, noon: false, evening: false, night: true),
    DosePreset(label: '1 + 1 + 1 + 1', morning: true, noon: true, evening: true, night: true),
    DosePreset(label: '0 + 1 + 0', morning: false, noon: true, evening: false, night: false),
    DosePreset(label: '1 + 0 + 1 + 0', morning: true, noon: false, evening: true, night: false),
    DosePreset(label: '0 + 0 + 1 + 1', morning: false, noon: false, evening: true, night: true),
  ];

  List<MedicineModel> _suggestions = [];
  bool _isSearching = false;
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
    if (q.isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 200), () async {
      final results = await ref.read(medicineRepositoryProvider).searchMedicines(q);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _isSearching = false;
      });
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
      _isSearching = false;
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
            : slot == 'evening'
                ? _eveningTime
                : _nightTime;

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      setState(() {
        if (slot == 'morning') _morningTime = picked;
        if (slot == 'noon') _noonTime = picked;
        if (slot == 'evening') _eveningTime = picked;
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

    if (!_morning && !_noon && !_evening && !_night) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one schedule time (Morning, Noon, Evening, or Night)')),
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
      evening: _evening,
      night: _night,
      morningTime: _formatTimeOfDay(_morningTime),
      noonTime: _formatTimeOfDay(_noonTime),
      eveningTime: _formatTimeOfDay(_eveningTime),
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
                  child: Icon(PhosphorIconsRegular.alarm, color: AppColors.primaryColor, size: 24),
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
                        isBn ? 'ঔষধের নাম খুঁজুন এবং গ্রহণের সময়সূচী নির্বাচন করুন' : 'Search 21,000+ medicines & schedule doses',
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
            const SizedBox(height: 18),

            // Medicine Name Field (with instant 21k search)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBn ? 'ঔষধের নাম (Medicine Name)' : 'Medicine Name',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                if (_isSearching)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              onChanged: _onNameChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: isBn ? 'ঔষধের নাম লিখুন (যেমন: Napa, Seclo, Maxpro)' : 'Type medicine name (e.g. Napa, Seclo)',
                prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass, color: AppColors.primaryColor),
                suffixIcon: _nameController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _nameController.clear();
                          setState(() {
                            _suggestions = [];
                            _isSearching = false;
                          });
                        },
                      ),
              ),
            ),

            // Suggestions List Dropdown
            if (_suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 230),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, i) {
                      final m = _suggestions[i];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                        title: Row(
                          children: [
                            Text(
                              m.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            if (m.dosageForm != null && m.dosageForm!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  m.dosageForm!,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
                                ),
                              ),
                            ],
                            if (m.strength != null && m.strength!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  m.strength!,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade700),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          [m.genericName, m.manufacturer]
                              .where((e) => e != null && e.trim().isNotEmpty)
                              .join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                        ),
                        trailing: Icon(PhosphorIconsRegular.plusCircle, color: AppColors.primaryColor, size: 22),
                        onTap: () => _selectMedicine(m),
                      );
                    },
                  ),
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
                        value: _forms.contains(_dosageForm) ? _dosageForm : _forms.first,
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
                        isBn ? 'মাত্রা (Strength)' : 'Strength',
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

            // Dose Pattern Selection (e.g. 1+0+1, 1+1+1, 1+1+1+1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBn ? 'গ্রহণের সময়সূচী (Dose Pattern)' : 'Dose Pattern (Schedule)',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  '${_morning ? '1' : '0'}+${_noon ? '1' : '0'}+${_evening ? '1' : '0'}+${_night ? '1' : '0'}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Preset Chips Row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((p) {
                final selected = _morning == p.morning &&
                    _noon == p.noon &&
                    _evening == p.evening &&
                    _night == p.night;
                return ChoiceChip(
                  label: Text(p.label),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: AppColors.primaryColor,
                  backgroundColor: Colors.grey.shade50,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: selected ? Colors.white : Colors.black87,
                  ),
                  side: BorderSide(color: selected ? AppColors.primaryColor : Colors.grey.shade300),
                  onSelected: (_) => setState(() {
                    _morning = p.morning;
                    _noon = p.noon;
                    _evening = p.evening;
                    _night = p.night;
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // 4 Slot Toggles: Morning, Noon, Evening, Night
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
                  title: isBn ? 'সন্ধ্যা' : 'Evening',
                  style: SlotStyle.evening,
                  isSelected: _evening,
                  timeText: _formatTimeOfDay(_eveningTime),
                  onToggle: () => setState(() => _evening = !_evening),
                  onPickTime: () => _pickTime('evening'),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor.withOpacity(0.08) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(style.icon, size: 24, color: isSelected ? style.color : Colors.grey.shade400),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isSelected ? AppColors.primaryColor : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: isSelected ? onPickTime : onToggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    timeText,
                    style: TextStyle(
                      fontSize: 9.5,
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
