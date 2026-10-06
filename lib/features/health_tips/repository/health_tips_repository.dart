import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/health_tip_model.dart';

class HealthTipsRepository {
  static const String _tipsPath = 'assets/data/health_tips.json';
  List<HealthTipModel>? _cachedTips;

  Future<List<HealthTipModel>> getAllTips() async {
    if (_cachedTips != null && _cachedTips!.isNotEmpty) {
      return _cachedTips!;
    }

    try {
      final jsonString = await rootBundle.loadString(_tipsPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedTips = jsonList.map((e) => HealthTipModel.fromJson(e)).toList();
      return _cachedTips!;
    } catch (e) {
      print('Error loading health tips JSON: $e');
      return [];
    }
  }

  Future<List<HealthTipModel>> searchTips(String query, bool isBn) async {
    final all = await getAllTips();
    if (query.trim().isEmpty) return all;

    final lower = query.toLowerCase();
    return all.where((tip) {
      final title = tip.getTitle(isBn).toLowerCase();
      final summary = tip.getSummary(isBn).toLowerCase();
      final category = tip.getCategory(isBn).toLowerCase();
      return title.contains(lower) || summary.contains(lower) || category.contains(lower);
    }).toList();
  }
}

