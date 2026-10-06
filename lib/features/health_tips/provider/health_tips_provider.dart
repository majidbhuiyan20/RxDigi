import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_tip_model.dart';
import '../repository/health_tips_repository.dart';

final healthTipsRepositoryProvider = Provider<HealthTipsRepository>((ref) {
  return HealthTipsRepository();
});

final healthTipsListProvider = FutureProvider<List<HealthTipModel>>((ref) async {
  final repo = ref.watch(healthTipsRepositoryProvider);
  return repo.getAllTips();
});

final tipLanguageIsBnProvider = StateProvider<bool>((ref) => true);

final selectedTipCategoryProvider = StateProvider<String?>((ref) => null);
