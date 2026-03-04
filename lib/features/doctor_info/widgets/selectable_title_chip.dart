import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/app/app_text_style.dart';

final selectedTitleProvider = StateProvider<String?>((ref) => null);
final selectedGenderProvider = StateProvider<String?>((ref) => null);

class SelectableTitleChip extends ConsumerWidget {
  const SelectableTitleChip({
    super.key,
    required this.title,
    required this.provider,
  });

  final String title;
  final StateProvider<String?> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(provider) == title;

    return GestureDetector(
      onTap: () {
        ref.read(provider.notifier).state = title;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: selected ? Colors.blue : Colors.white,
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey,
            width: 2,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}