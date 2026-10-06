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

class TipLanguageNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  set state(bool value) => super.state = value;
  void toggle() => state = !state;
}

final tipLanguageIsBnProvider = NotifierProvider<TipLanguageNotifier, bool>(() {
  return TipLanguageNotifier();
});

class SelectedTipCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  set state(String? value) => super.state = value;
}

final selectedTipCategoryProvider = NotifierProvider<SelectedTipCategoryNotifier, String?>(() {
  return SelectedTipCategoryNotifier();
});
