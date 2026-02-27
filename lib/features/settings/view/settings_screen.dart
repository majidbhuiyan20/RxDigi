import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/local_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final l10n   = AppLocalizations.of(context)!;
    final isBn   = locale.languageCode == 'bn';

    return  Scaffold(
      appBar: AppBar(
          title:       Row(
            children: [
              Text(l10n.settings),
            ],
          ),


      ),
      body: Padding(
        padding:  EdgeInsets.all(16.0),
        child: Column(

          children: [

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [

                  const Icon(
                    Icons.language,
                    size: 26,
                  ),

                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.language,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // 🔁 Language Toggle Container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // English
                        _buildToggleButton(
                          label: l10n.english,
                          isSelected: !isBn,
                          onTap: () => ref
                              .read(localeProvider.notifier)
                              .setLocale(const Locale('en')),
                        ),

                        const SizedBox(width: 4),

                        // Bengali
                        _buildToggleButton(
                          label: l10n.bengali,
                          isSelected: isBn,
                          onTap: () => ref
                              .read(localeProvider.notifier)
                              .setLocale(const Locale('bn')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, size: 26),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Add navigation or action
        },
      ),
    );
  }
}

Widget _buildToggleButton({
  required String       label,
  required bool         isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding:  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color:        isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color:      Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset:     const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color:      isSelected ? Colors.black : Colors.grey[600],
        ),
      ),
    ),
  );
}
