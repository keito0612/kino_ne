import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kino_ne/theme/app_colors.dart';
import 'package:kino_ne/views/pages/setting_page.dart';
import 'home_page.dart';

class MainPage extends HookWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);
    final pages = [
      HomePage(key: ValueKey('home_${selectedIndex.value}')),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[selectedIndex.value],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          indicatorColor: AppColors.primaryGreen.withOpacity(0.1),
        ),
        child: NavigationBar(
          surfaceTintColor: Colors.white,
          backgroundColor: AppColors.primaryGreen,
          selectedIndex: selectedIndex.value,
          onDestinationSelected: (index) => selectedIndex.value = index,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.park_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.park, color: Colors.lightGreen),
              label: 'ホーム',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.settings, color: Colors.lightGreen),
              label: '設定',
            ),
          ],
        ),
      ),
    );
  }
}
