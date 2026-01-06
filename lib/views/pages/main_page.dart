import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kino_ne/theme/app_colors.dart';
import 'package:kino_ne/views/pages/setting_page.dart';
import 'home_page.dart';

class MainPage extends HookWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 現在のタブインデックスを管理
    final selectedIndex = useState(0);

    // 表示するページのリスト
    final pages = [const HomePage(), const SettingsPage()];

    return Scaffold(
      body: pages[selectedIndex.value],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: AppColors.primaryGreen.withOpacity(0.2),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.bgColor,
          selectedIndex: selectedIndex.value,
          onDestinationSelected: (index) => selectedIndex.value = index,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.park_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.park, color: AppColors.primaryGreen),
              label: 'ホーム',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.settings, color: AppColors.primaryGreen),
              label: '設定',
            ),
          ],
        ),
      ),
    );
  }
}
