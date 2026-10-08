import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_routes.dart';
import '../../../core/data/database/database_helper.dart';
import '../../../core/data/providers/prescription_provider.dart';
import '../../../core/data/providers/patient_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/local_provider.dart';
import '../../vitals/provider/vitals_provider.dart';
import '../../medicine_reminder/provider/medicine_reminder_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showMedicalDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(PhosphorIconsFill.shieldWarning, color: Color(0xFFE65100), size: 24),
            SizedBox(width: 8),
            Text('Medical Disclaimer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'RxDigi provides health logging tools and wellness tips for educational and personal tracking purposes only.\n\n'
            '• The app does NOT diagnose, treat, or cure any medical disease.\n'
            '• Health recommendations are not a replacement for clinical consultation.\n'
            '• Always consult a licensed medical physician before starting, stopping, or modifying any medication or treatment.',
            style: TextStyle(fontSize: 13.5, height: 1.45, color: Color(0xFF37474F)),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('I Understand', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPrivacySecurity(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(PhosphorIconsFill.lockKey, color: Color(0xFF0F766E), size: 24),
            SizedBox(width: 8),
            Text('Data Privacy & Security', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            '100% Offline & Private by Design:\n\n'
            '• All your health vitals, patient records, and prescriptions are stored locally on your device in an isolated SQLite database.\n'
            '• We do NOT transmit, collect, or sell your health data to any cloud servers or third parties.\n'
            '• You have complete ownership and control over your medical data.',
            style: TextStyle(fontSize: 13.5, height: 1.45, color: Color(0xFF37474F)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmResetData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset All Local Data?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: const Text(
          'This will permanently delete all logged health vitals, prescriptions, and patient records from this device. This action cannot be undone.',
          style: TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final db = await DatabaseHelper().database;
                await db.delete('user_vitals');
                await db.delete('prescriptions');
                await db.delete('patients');
                await db.delete('medicine_reminders');
                await db.delete('medicine_adherence_logs');
                await db.delete('health_habits');
                await db.delete('habit_logs');
                ref.invalidate(vitalsListProvider);
                ref.invalidate(prescriptionListProvider);
                ref.invalidate(patientListProvider);
                ref.invalidate(activeRemindersProvider);
                ref.invalidate(allRemindersProvider);
                ref.invalidate(todayAdherenceMapProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data successfully cleared.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error clearing data: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Everything', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final isBn = locale.languageCode == 'bn';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                PhosphorIconsFill.gear,
                size: 18,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.settings,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌐 Language Switcher
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(PhosphorIconsRegular.translate, size: 20, color: AppColors.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.language,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildToggleButton(
                          label: l10n.english,
                          isSelected: !isBn,
                          onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
                        ),
                        const SizedBox(width: 4),
                        _buildToggleButton(
                          label: l10n.bengali,
                          isSelected: isBn,
                          onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('bn')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 👨‍⚕️ Prescriber / Doctor Profile
            _buildSettingsTile(
              icon: PhosphorIconsRegular.userCircle,
              title: isBn ? 'প্রেসক্রাইবার / ডক্টর প্রোফাইল' : 'Doctor / Prescriber Profile',
              subtitle: isBn ? 'ডিগ্রি, চেম্বার ও প্যাডের তথ্য সম্পাদনা' : 'Edit degrees, chamber & pad info',
              color: AppColors.primaryColor,
              onTap: () => Navigator.pushNamed(context, AppRoutes.introOnboarding),
            ),
            const SizedBox(height: 10),

            // 📜 Medical Disclaimer
            _buildSettingsTile(
              icon: PhosphorIconsRegular.shieldWarning,
              title: isBn ? 'মেডিকেল ডিসক্লেইমার' : 'Medical Disclaimer',
              subtitle: isBn ? 'স্বাস্থ্য তথ্য ও অ্যাপের ব্যবহারের শর্তাবলী' : 'Health advice & clinical terms',
              color: const Color(0xFFEA580C),
              onTap: () => _showMedicalDisclaimer(context),
            ),
            const SizedBox(height: 10),

            // 🔒 Data Privacy & Security
            _buildSettingsTile(
              icon: PhosphorIconsRegular.lockKey,
              title: isBn ? 'ডাটা প্রাইভেসি ও নিরাপত্তা' : 'Privacy & Data Security',
              subtitle: isBn ? '১০০% অফলাইন ও ডিভাইসে সংরক্ষিত' : '100% offline & stored on-device',
              color: const Color(0xFF0F766E),
              onTap: () => _showPrivacySecurity(context),
            ),
            const SizedBox(height: 10),

            // 🗑️ Clear / Reset Data (Google Play Compliance)
            _buildSettingsTile(
              icon: PhosphorIconsRegular.trashSimple,
              title: isBn ? 'সকল ডাটা মুছুন (রিসেট)' : 'Clear App Data & Reset',
              subtitle: isBn ? 'ডিভাইসের সকল স্বাস্থ্য ও প্রেসক্রিপশন রেকর্ড ডিলিট' : 'Delete all local logs & records',
              color: const Color(0xFFDC2626),
              onTap: () => _confirmResetData(context),
            ),
            const SizedBox(height: 32),

            // App Version Footer
            Center(
              child: Column(
                children: [
                  const Text(
                    'RxDigi • Smart Health & Rx',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Version 2.0.0 • Offline Medical & Wellness Hub',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF0F172A)),
        ),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16, color: Color(0xFF94A3B8)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
