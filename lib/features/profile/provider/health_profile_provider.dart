import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_health_profile_model.dart';

const String _kProfileKey = 'rxdigi_user_health_profile_v1';

class HealthProfileNotifier extends Notifier<UserHealthProfileModel> {
  @override
  UserHealthProfileModel build() {
    _loadFromPrefs();
    return UserHealthProfileModel(
      name: 'স্বাস্থ্য সাথী (Patient)',
      bloodGroup: 'B+',
      age: 26,
      gender: 'পুরুষ (Male)',
      phone: '+880 1711-000000',
      emergencyContact: '+880 1819-000000',
      emergencyRelation: 'অভিভাবক (Guardian)',
      cardId: 'RXD • 8821 • 4910',
      allergies: ['Penicillin', 'Dust'],
      chronicConditions: ['None / কোনোটি নয়'],
      heightCm: 172.0,
      weightKg: 68.0,
      isOrganDonor: true,
    );
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kProfileKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        state = UserHealthProfileModel.fromJson(jsonStr);
      } catch (_) {}
    }
  }

  Future<void> updateProfile(UserHealthProfileModel newProfile) async {
    state = newProfile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfileKey, newProfile.toJson());
  }
}

final healthProfileProvider = NotifierProvider<HealthProfileNotifier, UserHealthProfileModel>(
  HealthProfileNotifier.new,
);

