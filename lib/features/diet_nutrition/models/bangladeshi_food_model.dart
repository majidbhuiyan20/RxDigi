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
}

