import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_tip_model.dart';

class HealthTipsRepository {
  static const List<String> _tipFiles = [
    'assets/data/tips/stomach_digestion.json',
    'assets/data/tips/brain_sleep_mental.json',
    'assets/data/tips/eyes_vision.json',
    'assets/data/tips/hair_scalp.json',
    'assets/data/tips/skin_face.json',
    'assets/data/tips/heart_blood_pressure.json',
    'assets/data/tips/bones_joints_back.json',
    'assets/data/tips/emergency_first_aid.json',
    'assets/data/tips/lifestyle_diabetes.json',
    'assets/data/tips/ent_oral.json',
    'assets/data/tips/kidney_hydration.json',
    'assets/data/tips/hands_feet_nails.json',
    'assets/data/tips/women_maternal.json',
    'assets/data/tips/fitness_posture.json',
  ];

  static const String _bookmarksKey = 'rxdigi_bookmarked_tip_ids';

  List<HealthTipModel>? _cachedTips;

  Future<HealthTipModel?> getTipById(String tipId) async {
    final tips = await getAllTips();
    try {
      return tips.firstWhere((t) => t.id == tipId);
    } catch (_) {
      return null;
    }
  }

  Future<List<HealthTipModel>> getAllTips() async {
    if (_cachedTips != null && _cachedTips!.isNotEmpty) {
      return _cachedTips!;
    }

    final List<HealthTipModel> combined = [];

    for (final filePath in _tipFiles) {
      try {
        final jsonString = await rootBundle.loadString(filePath);
        final List<dynamic> jsonList = json.decode(jsonString);
        final items = jsonList.map((e) => HealthTipModel.fromJson(e)).toList();
        combined.addAll(items);
      } catch (e) {
        // Fallback for single file error without crashing the rest
        // ignore: avoid_print
        print('Error loading health tips from $filePath: $e');
      }
    }

    _cachedTips = combined;
    return _cachedTips!;
  }

  Future<List<HealthTipModel>> getTrendingTips() async {
    final all = await getAllTips();
    return all.where((tip) => tip.isTrending).toList();
  }

  Future<List<String>> getBookmarkedTipIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_bookmarksKey) ?? [];
  }

  Future<bool> toggleBookmark(String tipId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_bookmarksKey) ?? [];
    bool isBookmarked;
    if (list.contains(tipId)) {
      list.remove(tipId);
      isBookmarked = false;
    } else {
      list.add(tipId);
      isBookmarked = true;
    }
    await prefs.setStringList(_bookmarksKey, list);
    return isBookmarked;
  }

  Future<List<HealthTipModel>> searchTips(String query, bool isBn) async {
    final all = await getAllTips();
    if (query.trim().isEmpty) return all;

    final lower = query.toLowerCase();
    return all.where((tip) {
      final title = tip.getTitle(isBn).toLowerCase();
      final summary = tip.getSummary(isBn).toLowerCase();
      final category = tip.getCategory(isBn).toLowerCase();
      final hack = tip.getQuickHack(isBn).toLowerCase();
      final myth = tip.getMythBuster(isBn).toLowerCase();
      return title.contains(lower) ||
          summary.contains(lower) ||
          category.contains(lower) ||
          hack.contains(lower) ||
          myth.contains(lower);
    }).toList();
  }
}
