import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../provider/pregnancy_provider.dart';
import '../provider/women_health_provider.dart';
import '../services/pregnancy_notification_service.dart';
import '../utils/women_health_formatters.dart';

class PregnancySetupSheet extends ConsumerStatefulWidget {
  const PregnancySetupSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PregnancySetupSheet(),
    );
  }

  @override
  ConsumerState<PregnancySetupSheet> createState() =>
      _PregnancySetupSheetState();
}

class _PregnancySetupSheetState extends ConsumerState<PregnancySetupSheet> {
  bool _useLmp = true;
  late DateTime _selectedDate;
  late TextEditingController _nicknameController;
  late bool _notificationsEnabled;
  late TimeOfDay _notificationTime;

  @override
  void initState() {
    super.initState();
    final current = ref.read(pregnancyProvider);
    _selectedDate = current.lastPeriodDate;
    _nicknameController = TextEditingController(text: current.babyNickname);
    _notificationsEnabled = current.isNotificationEnabled;
    _notificationTime = current.notificationTime;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final firstDate = _useLmp
        ? now.subtract(const Duration(days: 300))
        : now.subtract(const Duration(days: 30));
    final lastDate = _useLmp
        ? now
        : now.add(const Duration(days: 300));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE11D48),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickNotificationTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );
    if (picked != null) {
      setState(() => _notificationTime = picked);
    }
  }

  Future<void> _save(bool isBn) async {
    AppFeedback.playSuccess();
    final nickname = _nicknameController.text.trim().isEmpty
        ? (isBn ? 'সোনামণি' : 'Baby')
        : _nicknameController.text.trim();

    if (_useLmp) {
      await ref.read(pregnancyProvider.notifier).setupFromLmp(
            _selectedDate,
            nickname: nickname,
            notifications: _notificationsEnabled,
          );
    } else {
      await ref.read(pregnancyProvider.notifier).setupFromEdd(
            _selectedDate,
            nickname: nickname,
            notifications: _notificationsEnabled,
          );
    }

    await ref.read(pregnancyProvider.notifier).updateNotificationTime(
          _notificationTime.hour,
          _notificationTime.minute,
        );

    // Schedule notification
    final updatedModel = ref.read(pregnancyProvider);
    await PregnancyNotificationService.scheduleDailyNotification(
      model: updatedModel,
      isBn: isBn,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isBn
              ? '🤰 গর্ভাবস্থা প্রোফাইল সফলভাবে আপডেট করা হয়েছে'
              : '🤰 Pregnancy profile updated successfully'),
          backgroundColor: const Color(0xFFE11D48),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showExitPregnancyDialog(BuildContext context, bool isBn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isBn ? 'গর্ভাবস্থা মোড বন্ধ করবেন?' : 'Exit Pregnancy Mode?',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          isBn
              ? 'আপনি কি পুনরায় সাধারণ সাইকেল ট্র্যাকিং মোডে ফিরে যেতে চান? আপনার পূর্ববর্তী সাইকেল রেকর্ড সংরক্ষিত থাকবে।'
              : 'Switch back to regular cycle tracking mode? Your cycle history is safely preserved.',
          style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isBn ? 'না' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // close sheet
              ref.read(cycleGoalModeProvider.notifier).setMode(CycleGoalMode.trackCycle);
              PregnancyNotificationService.cancelDailyNotification();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
            child: Text(isBn ? 'হ্যাঁ, সাধারণ মোড' : 'Yes, Switch Back', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final dateStr = WomenHealthFormatters.formatFullDate(_selectedDate, isBn: isBn);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      PhosphorIconsFill.baby,
                      color: Color(0xFFE11D48),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isBn ? 'গর্ভাবস্থা ও ডিউ ডেট সেটিংস' : 'Pregnancy & Due Date Settings',
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(PhosphorIconsRegular.x, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // Calculation Type Switcher
                Text(
                  isBn ? 'গণনার পদ্ধতি নির্বাচন করুন:' : 'Calculation Method:',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Text(isBn ? 'শেষ পিরিয়ড (LMP)' : 'Last Period (LMP)'),
                        selected: _useLmp,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _useLmp = true;
                              _selectedDate = DateTime.now().subtract(const Duration(days: 112));
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: Text(isBn ? 'আল্ট্রাসাউন্ড ডিউ ডেট' : 'Ultrasound EDD'),
                        selected: !_useLmp,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _useLmp = false;
                              _selectedDate = DateTime.now().add(const Duration(days: 168));
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Date Picker Field
                Text(
                  _useLmp
                      ? (isBn ? 'শেষ পিরিয়ড শুরুর তারিখ (LMP):' : 'Last Menstrual Period (LMP):')
                      : (isBn ? 'আল্ট্রাসাউন্ড অনুযায়ী সম্ভাব্য প্রসবের তারিখ (EDD):' : 'Estimated Due Date (EDD):'),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(PhosphorIconsRegular.calendar, size: 20, color: Color(0xFFE11D48)),
                        const SizedBox(width: 10),
                        Text(
                          dateStr,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const Spacer(),
                        Text(
                          isBn ? 'তারিখ পরিবর্তন' : 'Change',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE11D48)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Baby Nickname
                Text(
                  isBn ? 'সোনামণির আদুরে নাম (ঐচ্ছিক):' : 'Baby Nickname (Optional):',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    hintText: isBn ? 'যেমন: সোনামণি, লিটল অ্যাঞ্জেল' : 'e.g., Little Angel, Baby',
                    prefixIcon: const Icon(PhosphorIconsRegular.heart, size: 18, color: Color(0xFFE11D48)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),

                const SizedBox(height: 20),

                // Daily Maternal Notification Toggle
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(PhosphorIconsFill.bellRinging, size: 20, color: Color(0xFFBE123C)),
                              const SizedBox(width: 10),
                              Text(
                                isBn ? 'দৈনিক মাতৃত্ব যত্ন নোটিফিকেশন' : 'Daily Maternal Notification',
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF9F1239)),
                              ),
                            ],
                          ),
                          Switch.adaptive(
                            value: _notificationsEnabled,
                            activeTrackColor: const Color(0xFFBE123C),
                            onChanged: (val) => setState(() => _notificationsEnabled = val),
                          ),
                        ],
                      ),
                      if (_notificationsEnabled) ...[
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isBn ? 'নোটিফিকেশন পৌঁছানোর সময়:' : 'Notification Time:',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF881337), fontWeight: FontWeight.w600),
                            ),
                            InkWell(
                              onTap: _pickNotificationTime,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFFECDD3)),
                                ),
                                child: Text(
                                  _notificationTime.format(context),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9F1239)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Option to exit pregnancy mode
                Center(
                  child: TextButton.icon(
                    onPressed: () => _showExitPregnancyDialog(context, isBn),
                    icon: const Icon(PhosphorIconsRegular.arrowsClockwise, size: 16, color: Color(0xFF64748B)),
                    label: Text(
                      isBn ? 'সাধারণ সাইকেল ট্র্যাকিং মোডে ফিরে যান' : 'Switch back to Regular Cycle Mode',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _save(isBn),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                isBn ? 'সংরক্ষণ করুন' : 'Save Changes',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
