enum FoodCategory {
  grains,
  lentilsVeg,
  fishMeat,
  fruits,
  snacksSweets,
  beverages,
}

extension FoodCategoryExtension on FoodCategory {
  String get labelBn {
    switch (this) {
      case FoodCategory.grains:
        return 'ভাত ও শস্য';
      case FoodCategory.lentilsVeg:
        return 'ডাল ও তরকারি';
      case FoodCategory.fishMeat:
        return 'মাছ, মাংস ও ডিম';
      case FoodCategory.fruits:
        return 'ফলমূল ও সালাদ';
      case FoodCategory.snacksSweets:
        return 'মিষ্টি ও স্ন্যাক্স';
      case FoodCategory.beverages:
        return 'পানীয়';
    }
  }

  String get labelEn {
    switch (this) {
      case FoodCategory.grains:
        return 'Grains & Rice';
      case FoodCategory.lentilsVeg:
        return 'Lentils & Veggies';
      case FoodCategory.fishMeat:
        return 'Fish, Meat & Egg';
      case FoodCategory.fruits:
        return 'Fruits & Salads';
      case FoodCategory.snacksSweets:
        return 'Sweets & Snacks';
      case FoodCategory.beverages:
        return 'Beverages';
    }
  }

  String get iconEmoji {
    switch (this) {
      case FoodCategory.grains:
        return '🌾';
      case FoodCategory.lentilsVeg:
        return '🥗';
      case FoodCategory.fishMeat:
        return '🐟';
      case FoodCategory.fruits:
        return '🍎';
      case FoodCategory.snacksSweets:
        return '🍰';
      case FoodCategory.beverages:
        return '☕';
    }
  }
}

enum DiabeticRisk {
  safe, // Low GI (<= 55)
  moderate, // Medium GI (56 - 69)
  highRisk, // High GI (>= 70)
}

extension DiabeticRiskExtension on DiabeticRisk {
  String get labelBn {
    switch (this) {
      case DiabeticRisk.safe:
        return 'ডায়াবেটিসে নিরাপদ';
      case DiabeticRisk.moderate:
        return 'পরিমিত পরিমাণে খান';
      case DiabeticRisk.highRisk:
        return 'সুগার বৃদ্ধির ঝুঁকি (সতর্ক)';
    }
  }

  String get labelEn {
    switch (this) {
      case DiabeticRisk.safe:
        return 'Diabetic Safe (Low GI)';
      case DiabeticRisk.moderate:
        return 'Moderate (Portion Control)';
      case DiabeticRisk.highRisk:
        return 'High Risk (Spikes Glucose)';
    }
  }
}

class BangladeshiFoodModel {
  final String id;
  final String nameBn;
  final String nameEn;
  final FoodCategory category;
  final String servingSizeBn;
  final String servingSizeEn;
  final int calories; // kcal
  final double carbs; // grams
  final double protein; // grams
  final double fat; // grams
  final double fiber; // grams
  final int glycemicIndex; // 0 - 100
  final DiabeticRisk diabeticRisk;
  final String diabeticAdviceBn;
  final String diabeticAdviceEn;
  final String emoji;

  const BangladeshiFoodModel({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.category,
    required this.servingSizeBn,
    required this.servingSizeEn,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.fiber,
    required this.glycemicIndex,
    required this.diabeticRisk,
    required this.diabeticAdviceBn,
    required this.diabeticAdviceEn,
    required this.emoji,
  });

  factory BangladeshiFoodModel.fromJson(Map<String, dynamic> json) {
    FoodCategory parseCategory(String? cat) {
      switch (cat) {
        case 'grains':
          return FoodCategory.grains;
        case 'lentilsVeg':
          return FoodCategory.lentilsVeg;
        case 'fishMeat':
          return FoodCategory.fishMeat;
        case 'fruits':
          return FoodCategory.fruits;
        case 'snacksSweets':
          return FoodCategory.snacksSweets;
        case 'beverages':
          return FoodCategory.beverages;
        default:
          return FoodCategory.grains;
      }
    }

    DiabeticRisk parseDiabeticRisk(String? risk) {
      switch (risk) {
        case 'safe':
          return DiabeticRisk.safe;
        case 'moderate':
          return DiabeticRisk.moderate;
        case 'highRisk':
          return DiabeticRisk.highRisk;
        default:
          return DiabeticRisk.moderate;
      }
    }

    return BangladeshiFoodModel(
      id: json['id'] as String? ?? '',
      nameBn: json['nameBn'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      category: parseCategory(json['category'] as String?),
      servingSizeBn: json['servingSizeBn'] as String? ?? '',
      servingSizeEn: json['servingSizeEn'] as String? ?? '',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      glycemicIndex: (json['glycemicIndex'] as num?)?.toInt() ?? 0,
      diabeticRisk: parseDiabeticRisk(json['diabeticRisk'] as String?),
      diabeticAdviceBn: json['diabeticAdviceBn'] as String? ?? '',
      diabeticAdviceEn: json['diabeticAdviceEn'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🍽️',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameBn': nameBn,
      'nameEn': nameEn,
      'category': category.name,
      'servingSizeBn': servingSizeBn,
      'servingSizeEn': servingSizeEn,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'fiber': fiber,
      'glycemicIndex': glycemicIndex,
      'diabeticRisk': diabeticRisk.name,
      'diabeticAdviceBn': diabeticAdviceBn,
      'diabeticAdviceEn': diabeticAdviceEn,
      'emoji': emoji,
    };
  }
}

