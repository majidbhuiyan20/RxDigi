import 'dart:convert';

class UserHealthProfileModel {
  final String name;
  final String bloodGroup;
  final int age;
  final String gender;
  final String phone;
  final String emergencyContact;
  final String emergencyRelation;
  final String cardId;
  final List<String> allergies;
  final List<String> chronicConditions;
  final double? heightCm;
  final double? weightKg;
  final bool isOrganDonor;

  UserHealthProfileModel({
    required this.name,
    required this.bloodGroup,
    required this.age,
    required this.gender,
    required this.phone,
    required this.emergencyContact,
    this.emergencyRelation = 'Family',
    required this.cardId,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.heightCm,
    this.weightKg,
    this.isOrganDonor = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bloodGroup': bloodGroup,
      'age': age,
      'gender': gender,
      'phone': phone,
      'emergencyContact': emergencyContact,
      'emergencyRelation': emergencyRelation,
      'cardId': cardId,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'isOrganDonor': isOrganDonor,
    };
  }

  factory UserHealthProfileModel.fromMap(Map<String, dynamic> map) {
    return UserHealthProfileModel(
      name: map['name'] as String? ?? 'স্বাস্থ্য সাথী (Patient)',
      bloodGroup: map['bloodGroup'] as String? ?? 'B+',
      age: map['age'] as int? ?? 26,
      gender: map['gender'] as String? ?? 'পুরুষ',
      phone: map['phone'] as String? ?? '+880 1700-000000',
      emergencyContact: map['emergencyContact'] as String? ?? '+880 1800-000000',
      emergencyRelation: map['emergencyRelation'] as String? ?? 'পরিবার (Family)',
      cardId: map['cardId'] as String? ?? 'RXD-8942-BD',
      allergies: List<String>.from(map['allergies'] ?? ['Penicillin']),
      chronicConditions: List<String>.from(map['chronicConditions'] ?? ['None']),
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 170.0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 65.0,
      isOrganDonor: map['isOrganDonor'] as bool? ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserHealthProfileModel.fromJson(String source) =>
      UserHealthProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);

  UserHealthProfileModel copyWith({
    String? name,
    String? bloodGroup,
    int? age,
    String? gender,
    String? phone,
    String? emergencyContact,
    String? emergencyRelation,
    String? cardId,
    List<String>? allergies,
    List<String>? chronicConditions,
    double? heightCm,
    double? weightKg,
    bool? isOrganDonor,
  }) {
    return UserHealthProfileModel(
      name: name ?? this.name,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyRelation: emergencyRelation ?? this.emergencyRelation,
      cardId: cardId ?? this.cardId,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      isOrganDonor: isOrganDonor ?? this.isOrganDonor,
    );
  }
}

