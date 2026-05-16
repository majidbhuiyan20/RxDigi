import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:prescripto/app/app_colors.dart';
import 'package:prescripto/app/app_text_style.dart';

final selectedTitleProvider = StateProvider<String?>((ref) => null);
final selectedGenderProvider = StateProvider<String?>((ref) => null);
final selectedTitlesProvider = StateProvider<List<String>>((ref) => []);
final selectedExperienceProvider = StateProvider<String?>((ref) => null);
final selectedPositionProvider = StateProvider<String?>((ref) => null);
final selectedWeekDaysProvider = StateProvider<List<String>>((ref) => []);

class SelectableTitleChip extends StatelessWidget {
  const SelectableTitleChip({
    super.key,
    required this.title,
    this.isSelected = false,
    this.onTap,
    this.singleProvider,
    this.multiProvider,
  });

  final String title;
  final bool isSelected;
  final VoidCallback? onTap;
  final StateProvider<String?>? singleProvider;
  final StateProvider<List<String>>? multiProvider;

  @override
  Widget build(BuildContext context) {
    if (singleProvider != null || multiProvider != null) {
      return Consumer(
        builder: (context, ref, _) {
          bool selected = isSelected;

          // 🔹 Single select
          if (singleProvider != null) {
            selected = ref.watch(singleProvider!) == title;
          }

          // 🔹 Multi select
          if (multiProvider != null) {
            selected = ref.watch(multiProvider!).contains(title);
          }

          return _ChipWidget(
            title: title,
            selected: selected,
            onTap: () {
              if (onTap != null) {
                onTap!();
              } else {
                // 🔹 Single select
                if (singleProvider != null) {
                  ref.read(singleProvider!.notifier).state = title;
                }

                // 🔹 Multi select
                if (multiProvider != null) {
                  final current = ref.read(multiProvider!.notifier).state;

                  if (current.contains(title)) {
                    ref.read(multiProvider!.notifier).state =
                        current.where((e) => e != title).toList();
                  } else {
                    ref.read(multiProvider!.notifier).state = [...current, title];
                  }
                }
              }
            },
          );
        },
      );
    }

    return _ChipWidget(
      title: title,
      selected: isSelected,
      onTap: onTap,
    );
  }
}

class _ChipWidget extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback? onTap;

  const _ChipWidget({
    required this.title,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
