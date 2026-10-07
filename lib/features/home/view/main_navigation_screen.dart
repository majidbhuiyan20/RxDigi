import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:prescripto/app/app_colors.dart';
import 'package:prescripto/features/home/view/home_screen.dart';
import 'package:prescripto/features/medicine_reminder/view/medicine_reminder_screen.dart';
import 'package:prescripto/features/health_tips/view/health_tips_screen.dart';
import 'package:prescripto/features/rx_studio/view/rx_studio_screen.dart';
import 'package:prescripto/features/settings/view/settings_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MedicineReminderScreen(),
    const HealthTipsScreen(),
    const RxStudioScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 900;
    final isBn = Localizations.localeOf(context).languageCode == 'bn';

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: const Color(0xFF004D40),
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedIconTheme: IconThemeData(color: Colors.white.withOpacity(0.55)),
              selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              unselectedLabelTextStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(PhosphorIconsRegular.house),
                  selectedIcon: const Icon(PhosphorIconsFill.house),
                  label: Text(isBn ? 'হোম' : 'Home'),
                ),
                NavigationRailDestination(
                  icon: const Icon(PhosphorIconsRegular.alarm),
                  selectedIcon: const Icon(PhosphorIconsFill.alarm),
                  label: Text(isBn ? 'রিমাইন্ডার' : 'Reminder'),
                ),
                NavigationRailDestination(
                  icon: const Icon(PhosphorIconsRegular.lightbulb),
                  selectedIcon: const Icon(PhosphorIconsFill.lightbulb),
                  label: Text(isBn ? 'টিপস' : 'Health Tips'),
                ),
                NavigationRailDestination(
                  icon: const Icon(PhosphorIconsRegular.fileText),
                  selectedIcon: const Icon(PhosphorIconsFill.fileText),
                  label: Text(isBn ? 'প্রেসক্রিপশন' : 'Rx Studio'),
                ),
                NavigationRailDestination(
                  icon: const Icon(PhosphorIconsRegular.gear),
                  selectedIcon: const Icon(PhosphorIconsFill.gear),
                  label: Text(isBn ? 'সেটিংস' : 'Settings'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 68,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 22),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, PhosphorIconsRegular.house, PhosphorIconsFill.house, isBn ? 'হোম' : 'Home'),
            _buildNavItem(1, PhosphorIconsRegular.alarm, PhosphorIconsFill.alarm, isBn ? 'রিমাইন্ডার' : 'Routine'),
            _buildNavItem(2, PhosphorIconsRegular.lightbulb, PhosphorIconsFill.lightbulb, isBn ? 'টিপস' : 'Tips'),
            _buildNavItem(3, PhosphorIconsRegular.fileText, PhosphorIconsFill.fileText, isBn ? 'প্রেসক্রিপশন' : 'Rx Studio'),
            _buildNavItem(4, PhosphorIconsRegular.gear, PhosphorIconsFill.gear, isBn ? 'সেটিংস' : 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppColors.primaryColor : Colors.grey.shade400,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
