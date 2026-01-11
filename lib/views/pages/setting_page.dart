import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kino_ne/theme/app_colors.dart';
import 'package:kino_ne/view_models/tree/tree_view_model.dart';
import 'package:kino_ne/views/pages/icloud_backup_page.dart';
import 'package:kino_ne/views/pages/passcode_setting_page.dart';
import 'package:kino_ne/views/widgets/dynamic_forest_background.dart';
import 'package:flutter/material.dart';

enum SettingContent {
  passCode,
  iCloud,
  privacyPolicy,
  allDelete;

  String get title => switch (this) {
    passCode => 'パスコード',
    iCloud => 'iCloud',
    privacyPolicy => 'プライバシーポリシー・利用規約',
    allDelete => 'すべてのデータを削除',
  };

  IconData get icon => switch (this) {
    passCode => Icons.lock,
    iCloud => Icons.cloud_queue,
    privacyPolicy => Icons.privacy_tip_sharp,
    allDelete => Icons.delete,
  };
  Color get textColor => switch (this) {
    allDelete => Colors.red,
    _ => Colors.white,
  };
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treeCount = ref.watch(treeViewModelProvider).value?.length ?? 0;
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '設定',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: DynamicForestBackground(
        treeCount: treeCount,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSettingsTile(SettingContent.passCode, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PasscodeSettingsPage()),
              );
            }),
            _buildSettingsTile(SettingContent.iCloud, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ICloudBackupPage()),
              );
            }),
            _buildSettingsTile(SettingContent.privacyPolicy, () => {}),
            _buildSettingsTile(SettingContent.allDelete, () => {}),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(SettingContent content, void Function() onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(content.icon, color: Colors.white),
        title: Text(content.title, style: TextStyle(color: content.textColor)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}
