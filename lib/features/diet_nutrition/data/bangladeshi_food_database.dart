import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/bangladeshi_food_model.dart';

class BangladeshiFoodDatabase {
  static List<BangladeshiFoodModel> _cachedFoods = [];
  static bool _isLoaded = false;

  /// Modular category-wise JSON files in assets/data/foods/
  static const List<String> categoryAssetFiles = [
    'assets/data/foods/grains_carbs.json',
    'assets/data/foods/lentils_veggies.json',
    'assets/data/foods/fish_meat_eggs.json',
    'assets/data/foods/fruits_salads.json',
    'assets/data/foods/snacks_sweets.json',
    'assets/data/foods/beverages_drinks.json',
  ];

  /// Loads all category-wise JSON files asynchronously and caches in memory
  static Future<List<BangladeshiFoodModel>> loadAllFoods() async {
    if (_isLoaded && _cachedFoods.isNotEmpty) {
      return _cachedFoods;
    }

    final List<BangladeshiFoodModel> loaded = [];

    for (final filePath in categoryAssetFiles) {
      try {
        final jsonStr = await rootBundle.loadString(filePath);
        final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
        for (final item in decoded) {
          loaded.add(BangladeshiFoodModel.fromJson(item as Map<String, dynamic>));
        }
      } catch (e) {
        debugPrint('Error loading food JSON from $filePath: $e');
      }
    }

    _cachedFoods = loaded;
    _isLoaded = true;
    return _cachedFoods;
  }

  /// Synchronous getter for cached foods
  static List<BangladeshiFoodModel> get allFoods => _cachedFoods;
  static bool get isLoaded => _isLoaded;

  /// Filter & search helpers
  static List<BangladeshiFoodModel> searchFoods(List<BangladeshiFoodModel> source, String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return source;
    return source.where((food) {
      return food.nameBn.toLowerCase().contains(clean) ||
          food.nameEn.toLowerCase().contains(clean) ||
          food.category.labelBn.toLowerCase().contains(clean) ||
          food.category.labelEn.toLowerCase().contains(clean);
    }).toList();
  }

  static List<BangladeshiFoodModel> filterByCategory(
      List<BangladeshiFoodModel> source, FoodCategory? category) {
    if (category == null) return source;
    return source.where((f) => f.category == category).toList();
  }

  static List<BangladeshiFoodModel> getDiabeticSafeFoods(List<BangladeshiFoodModel> source) {
    return source.where((f) => f.diabeticRisk == DiabeticRisk.safe).toList();
  }
}
