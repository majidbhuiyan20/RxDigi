import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_routes.dart';
import '../../../core/data/database/database_helper.dart';
import '../../../core/data/providers/prescription_provider.dart';
import '../../../core/data/providers/patient_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/local_provider.dart';
import '../../vitals/provider/vitals_provider.dart';

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
            Icon(Icons.health_and_safety, color: Color(0xFFE65100)),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            child: const Text('I Understand', style: TextStyle(color: Colors.white)),
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
            Icon(Icons.privacy_tip_outlined, color: Color(0xFF00897B)),
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
            child: const Text('Close'),
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
                ref.invalidate(vitalsListProvider);
                ref.invalidate(prescriptionListProvider);
                ref.invalidate(patientListProvider);

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
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(l10n.settings, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌐 Language Switcher
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.language, size: 24, color: Color(0xFF004D40)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.language,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(4),
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
            const SizedBox(height: 16),

            // 👨‍⚕️ Prescriber / Doctor Profile
            _buildSettingsTile(
              icon: Icons.badge_outlined,
              title: isBn ? 'প্রেসক্রাইবার / ডক্টর প্রোফাইল' : 'Doctor / Prescriber Profile',
              subtitle: isBn ? 'ডিগ্রি, চেম্বার ও প্যাডের তথ্য সম্পাদনা' : 'Edit degrees, chamber & pad info',
              color: AppColors.primaryColor,
              onTap: () => Navigator.pushNamed(context, AppRoutes.introOnboarding),
            ),
            const SizedBox(height: 12),

            // 📜 Medical Disclaimer
            _buildSettingsTile(
              icon: Icons.health_and_safety_outlined,
              title: isBn ? 'মেডিকেল ডিসক্লেইমার' : 'Medical Disclaimer',
              subtitle: isBn ? 'স্বাস্থ্য তথ্য ও অ্যাপের ব্যবহারের শর্তাবলী' : 'Health advice & clinical terms',
              color: const Color(0xFFE65100),
              onTap: () => _showMedicalDisclaimer(context),
            ),
            const SizedBox(height: 12),

            // 🔒 Data Privacy & Security
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: isBn ? 'ডাটা প্রাইভেসি ও নিরাপত্তা' : 'Privacy & Data Security',
              subtitle: isBn ? '১০০% অফলাইন ও ডিভাইসে সংরক্ষিত' : '100% offline & stored on-device',
              color: const Color(0xFF00897B),
              onTap: () => _showPrivacySecurity(context),
            ),
            const SizedBox(height: 12),

            // 🗑️ Clear / Reset Data (Google Play Compliance)
            _buildSettingsTile(
              icon: Icons.delete_outline_rounded,
              title: isBn ? 'সকল ডাটা মুছুন (রিসেট)' : 'Clear App Data & Reset',
              subtitle: isBn ? 'ডিভাইসের সকল স্বাস্থ্য ও প্রেসক্রিপশন রেকর্ড ডিলিট' : 'Delete all local logs & records',
              color: Colors.red.shade700,
              onTap: () => _confirmResetData(context),
            ),
            const SizedBox(height: 32),

            // App Version Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'RxDigi - Smart Health & Rx',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Colors.grey),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
