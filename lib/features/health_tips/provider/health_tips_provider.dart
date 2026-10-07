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

final trendingTipsProvider = FutureProvider<List<HealthTipModel>>((ref) async {
  final repo = ref.watch(healthTipsRepositoryProvider);
  return repo.getTrendingTips();
});

final dailyFeaturedTipProvider = FutureProvider<HealthTipModel?>((ref) async {
  final allTips = await ref.watch(healthTipsListProvider.future);
  if (allTips.isEmpty) return null;
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
  final index = dayOfYear % allTips.length;
  return allTips[index];
});

class TipLanguageNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void setBn(bool value) => state = value;
}

final tipLanguageIsBnProvider = NotifierProvider<TipLanguageNotifier, bool>(() {
  return TipLanguageNotifier();
});

class SelectedTipCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? category) => state = category;
}

final selectedTipCategoryProvider = NotifierProvider<SelectedTipCategoryNotifier, String?>(() {
  return SelectedTipCategoryNotifier();
});

class SelectedBodyPartNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? bodyPart) => state = bodyPart;
}

final selectedBodyPartProvider = NotifierProvider<SelectedBodyPartNotifier, String?>(() {
  return SelectedBodyPartNotifier();
});

class BookmarkedTipIdsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final repo = ref.read(healthTipsRepositoryProvider);
    return repo.getBookmarkedTipIds();
  }

  Future<void> toggle(String tipId) async {
    final repo = ref.read(healthTipsRepositoryProvider);
    await repo.toggleBookmark(tipId);
    state = AsyncData(await repo.getBookmarkedTipIds());
  }
}

final bookmarkedTipIdsProvider = AsyncNotifierProvider<BookmarkedTipIdsNotifier, List<String>>(() {
  return BookmarkedTipIdsNotifier();
});
