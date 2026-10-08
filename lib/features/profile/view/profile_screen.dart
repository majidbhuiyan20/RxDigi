import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/app_colors.dart';
import '../../../core/utils/app_feedback.dart';
import '../../../core/data/providers/doctor_provider.dart';
import '../provider/health_profile_provider.dart';
import '../models/user_health_profile_model.dart';
import '../widgets/digital_health_card_widget.dart';
import '../widgets/edit_health_card_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final profile = ref.watch(healthProfileProvider);
    final doctorAsync = ref.watch(latestDoctorProvider);

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
                color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                PhosphorIconsFill.identificationCard,
                size: 18,
                color: Color(0xFF0F766E),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isBn ? 'মেডিকেল প্রোফাইল ও হেলথ কার্ড' : 'Health Profile & Medical ID',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          IconButton(
            tooltip: isBn ? 'কার্ড এডিট করুন' : 'Edit Card',
            icon: const Icon(PhosphorIconsBold.pencilSimple, color: Color(0xFF0F766E)),
            onPressed: () => EditHealthCardSheet.show(context, profile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. Ultra-Premium Digital Health Card ───
            DigitalHealthCardWidget(
              profile: profile,
              onEdit: () => EditHealthCardSheet.show(context, profile),
              onShare: () => _shareHealthCard(profile, isBn),
            ),
            const SizedBox(height: 14),

            // Card Action Buttons (Make / Edit & Share)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => EditHealthCardSheet.show(context, profile),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(PhosphorIconsBold.pencilSimple, size: 16),
                    label: Text(
                      isBn ? 'কার্ড তৈরি / এডিট করুন' : 'Make / Edit Card',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareHealthCard(profile, isBn),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F766E),
                      side: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(PhosphorIconsBold.shareNetwork, size: 16),
                    label: Text(
                      isBn ? 'কার্ড শেয়ার করুন' : 'Share Card',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ─── 2. Emergency ICE Notice Card ───
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(PhosphorIconsFill.phoneCall, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'জরুরি যোগাযোগ (ICE Contact)' : 'Emergency ICE Contact',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${profile.emergencyContact} (${profile.emergencyRelation})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7F1D1D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── 3. Clinical & Medical Summary Section ───
            Text(
              isBn ? 'চিকিৎসাগত তথ্যাবলি (Medical Summary)' : 'Medical Summary',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildProfileRow(
                    PhosphorIconsFill.drop,
                    const Color(0xFFDC2626),
                    isBn ? 'রক্তের গ্রুপ' : 'Blood Group',
                    '${profile.bloodGroup} Positive',
                    badgeColor: const Color(0xFFFEE2E2),
                    badgeTextColor: const Color(0xFFDC2626),
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildProfileRow(
                    PhosphorIconsFill.user,
                    AppColors.primaryColor,
                    isBn ? 'বয়স ও লিঙ্গ' : 'Age & Gender',
                    '${profile.age} বছর (${profile.gender})',
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildProfileRow(
                    PhosphorIconsFill.warningCircle,
                    const Color(0xFFF59E0B),
                    isBn ? 'অ্যালার্জি' : 'Allergies',
                    profile.allergies.join(', '),
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildProfileRow(
                    PhosphorIconsFill.heartbeat,
                    const Color(0xFF8B5CF6),
                    isBn ? 'দীর্ঘস্থায়ী রোগ' : 'Conditions',
                    profile.chronicConditions.join(', '),
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildProfileRow(
                    PhosphorIconsFill.heart,
                    const Color(0xFF10B981),
                    isBn ? 'অঙ্গদানকারী স্ট্যাটাস' : 'Organ Donor',
                    profile.isOrganDonor ? 'নিবন্ধিত (Yes)' : 'না (No)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── 4. Doctor Credentials (if applicable) ───
            doctorAsync.maybeWhen(
              data: (doctor) => doctor != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'ডাক্তার প্রোফাইল (Doctor Credentials)' : 'Physician Information',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              _buildProfileRow(
                                PhosphorIconsFill.firstAid,
                                const Color(0xFF0F766E),
                                isBn ? 'চিকিৎসক' : 'Doctor Name',
                                doctor.fullName,
                              ),
                              if (doctor.specialization != null) ...[
                                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                                _buildProfileRow(
                                  PhosphorIconsFill.brain,
                                  const Color(0xFF0284C7),
                                  isBn ? 'বিশেষজ্ঞ' : 'Specialization',
                                  doctor.specialization!,
                                ),
                              ],
                              if (doctor.bmdcRegNo != null) ...[
                                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                                _buildProfileRow(
                                  PhosphorIconsFill.sealCheck,
                                  const Color(0xFF059669),
                                  'BMDC Reg No',
                                  doctor.bmdcRegNo!,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),

            // ─── 5. App & Safety Info ───
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(PhosphorIconsFill.lockKey, size: 20, color: Color(0xFF64748B)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'আপনার ডিজিটাল হেলথ কার্ড সম্পূর্ণ অফলাইনে আপনার ডিভাইসে নিরাপদে সংরক্ষিত।'
                          : 'Your Digital Health ID Card is securely stored on-device locally.',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(
    IconData icon,
    Color iconColor,
    String label,
    String value, {
    Color? badgeColor,
    Color? badgeTextColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ),
        if (badgeColor != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: badgeTextColor ?? Colors.black,
              ),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
      ],
    );
  }

  void _shareHealthCard(UserHealthProfileModel profile, bool isBn) {
    AppFeedback.playLight();
    final buffer = StringBuffer();
    buffer.writeln('🪪 RxDigi EMERGENCY MEDICAL ID CARD');
    buffer.writeln('═══════════════════════════════');
    buffer.writeln('নাম: ${profile.name}');
    buffer.writeln('কার্ড আইডি: ${profile.cardId}');
    buffer.writeln('রক্তের গ্রুপ: ${profile.bloodGroup} Positive');
    buffer.writeln('বয়স ও লিঙ্গ: ${profile.age} বছর (${profile.gender})');
    buffer.writeln('জরুরি যোগাযোগ (ICE): ${profile.emergencyContact} (${profile.emergencyRelation})');
    if (profile.allergies.isNotEmpty) {
      buffer.writeln('অ্যালার্জি: ${profile.allergies.join(", ")}');
    }
    if (profile.chronicConditions.isNotEmpty) {
      buffer.writeln('রোগ: ${profile.chronicConditions.join(", ")}');
    }
    buffer.writeln('═══════════════════════════════');
    buffer.writeln('📱 RxDigi হেলথ অ্যাপ থেকে প্রস্তুতকৃত।');

    Share.share(buffer.toString());
  }
}
