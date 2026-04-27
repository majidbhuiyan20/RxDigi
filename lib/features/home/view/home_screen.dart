import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/l10n/app_localizations.dart';
import 'package:rxdigi/features/patient_management/view/patient_list_screen.dart';
import 'package:rxdigi/features/prescription_management/view/prescription_list_screen.dart';
import 'package:rxdigi/features/prescription_management/view/medicine_search_screen.dart';
import 'package:rxdigi/core/data/models/medicine_model.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/features/dashboard/view/dashboard_screen.dart';

import '../../../l10n/local_provider.dart';
import '../../settings/view/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final screens = [
      const DashboardScreen(),
      const PatientsTab(),
      const PrescriptionTab(),
      const MedicineTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(l10n.home),
          ],
        ),
        backgroundColor: const Color(0xFF0D3592),
        elevation: 0,
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
            icon: const Icon(Icons.settings, size: 28),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0D3592),
        unselectedItemColor: Colors.grey[500],
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Prescriptions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medicines',
          ),
        ],
      ),
    );
  }
}

// Patients Tab
class PatientsTab extends StatelessWidget {
  const PatientsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const PatientListScreen();
  }
}

// Prescription Tab
class PrescriptionTab extends StatelessWidget {
  const PrescriptionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrescriptionListScreen();
  }
}

// Medicine Tab
class MedicineTab extends ConsumerWidget {
  const MedicineTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: MedicineSearchScreen(
        selectedMedicines: const <MedicineModel>[],
      ),
    );
  }
}

