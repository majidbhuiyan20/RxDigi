import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../models/user_health_profile_model.dart';
import '../provider/health_profile_provider.dart';

class EditHealthCardSheet extends ConsumerStatefulWidget {
  final UserHealthProfileModel currentProfile;

  const EditHealthCardSheet({super.key, required this.currentProfile});

  static Future<void> show(BuildContext context, UserHealthProfileModel profile) {
    AppFeedback.playLight();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditHealthCardSheet(currentProfile: profile),
    );
  }

  @override
  ConsumerState<EditHealthCardSheet> createState() => _EditHealthCardSheetState();
}

class _EditHealthCardSheetState extends ConsumerState<EditHealthCardSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _icePhoneController;
  late final TextEditingController _iceRelationController;
  late final TextEditingController _ageController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _conditionsController;

  late String _selectedBloodGroup;
  late String _selectedGender;
  late bool _isOrganDonor;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> _genders = ['পুরুষ (Male)', 'মহিলা (Female)', 'অন্যান্য (Other)'];

  @override
  void initState() {
    super.initState();
    final p = widget.currentProfile;
    _nameController = TextEditingController(text: p.name);
    _phoneController = TextEditingController(text: p.phone);
    _icePhoneController = TextEditingController(text: p.emergencyContact);
    _iceRelationController = TextEditingController(text: p.emergencyRelation);
    _ageController = TextEditingController(text: p.age.toString());
    _allergiesController = TextEditingController(text: p.allergies.join(', '));
    _conditionsController = TextEditingController(text: p.chronicConditions.join(', '));

    _selectedBloodGroup = p.bloodGroup;
    _selectedGender = p.gender;
    _isOrganDonor = p.isOrganDonor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _icePhoneController.dispose();
    _iceRelationController.dispose();
    _ageController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  void _handleSave() {
    AppFeedback.playSuccess();
    final age = int.tryParse(_ageController.text.trim()) ?? widget.currentProfile.age;

    final allergies = _allergiesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final conditions = _conditionsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final updated = widget.currentProfile.copyWith(
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : widget.currentProfile.name,
      phone: _phoneController.text.trim(),
      emergencyContact: _icePhoneController.text.trim(),
      emergencyRelation: _iceRelationController.text.trim(),
      age: age,
      bloodGroup: _selectedBloodGroup,
      gender: _selectedGender,
      allergies: allergies.isNotEmpty ? allergies : ['None'],
      chronicConditions: conditions.isNotEmpty ? conditions : ['None'],
      isOrganDonor: _isOrganDonor,
    );

    ref.read(healthProfileProvider.notifier).updateProfile(updated);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 ডিজিটাল হেলথ কার্ড সফলভাবে আপডেট হয়েছে!'),
        backgroundColor: Color(0xFF0F766E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          PhosphorIconsFill.identificationCard,
                          color: Color(0xFF0F766E),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ডিজিটাল হেলথ কার্ড এডিটর',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'জরুরি পরিস্থিতিতে চিকিৎসকের জন্য প্রয়োজনীয় তথ্য',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(PhosphorIconsBold.x, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Full Name
              _buildLabel('আপনার পুরো নাম (Full Name)'),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration('নাম লিখুন (যেমন: মোঃ আবরার জাহিন)'),
              ),
              const SizedBox(height: 14),

              // Blood Group Selector
              _buildLabel('রক্তের গ্রুপ (Blood Group)'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _bloodGroups.map((bg) {
                  final isSelected = _selectedBloodGroup == bg;
                  return ChoiceChip(
                    label: Text(
                      bg,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFDC2626),
                    backgroundColor: const Color(0xFFF1F5F9),
                    onSelected: (val) {
                      AppFeedback.playSelection();
                      if (val) setState(() => _selectedBloodGroup = bg);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Age & Gender
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('বয়স (Age)'),
                        TextField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('বয়স (বছর)'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('লিঙ্গ (Gender)'),
                        DropdownButtonFormField<String>(
                          initialValue: _genders.contains(_selectedGender) ? _selectedGender : _genders.first,
                          decoration: _inputDecoration('লিঙ্গ'),
                          items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 12.5)))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedGender = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Emergency Contact Phone & Relation
              _buildLabel('জরুরি যোগাযোগ ফোন (ICE Contact)'),
              TextField(
                controller: _icePhoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('যেমন: +880 1819-xxxxxx'),
              ),
              const SizedBox(height: 14),

              _buildLabel('সম্পর্ক (Relation)'),
              TextField(
                controller: _iceRelationController,
                decoration: _inputDecoration('যেমন: বাবা, মা, স্ত্রী, ভাই'),
              ),
              const SizedBox(height: 14),

              // Allergies & Conditions
              _buildLabel('অ্যালার্জি (Allergies - কমা দিয়ে লিখুন)'),
              TextField(
                controller: _allergiesController,
                decoration: _inputDecoration('যেমন: Penicillin, Dust, Prawn'),
              ),
              const SizedBox(height: 14),

              _buildLabel('দীর্ঘস্থায়ী রোগ (Chronic Conditions - কমা দিয়ে)'),
              TextField(
                controller: _conditionsController,
                decoration: _inputDecoration('যেমন: ডায়াবেটিস, উচ্চ রক্তচাপ'),
              ),
              const SizedBox(height: 16),

              // Organ Donor Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(PhosphorIconsFill.heart, color: Color(0xFFEF4444), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'অঙ্গদানকারী (Organ Donor)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isOrganDonor,
                      activeThumbColor: const Color(0xFF0F766E),
                      onChanged: (val) {
                        AppFeedback.playSelection();
                        setState(() => _isOrganDonor = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(PhosphorIconsBold.checkCircle, size: 20),
                  label: const Text(
                    'কার্ড সেভ ও আপডেট করুন',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 12.5, color: Colors.grey.shade400),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
      ),
    );
  }
}
