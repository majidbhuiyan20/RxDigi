import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/l10n/app_localizations.dart';

import '../../../l10n/local_provider.dart';
import '../../settings/view/settings_screen.dart';
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    return  Scaffold(
      appBar: AppBar(
        title:       Row(
          children: [
            Text(l10n.home),
          ],
        ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
              icon:  Icon(Icons.settings, size: 28),
            ),
            const SizedBox(width: 16),
          ]

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            //  hello in current language
            Text(
              l10n.home,
              style: const TextStyle(
                fontSize:   32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),


          ],
        ),
      ),
    );
  }
}

