import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kino_ne/core/database/database_helper.dart';
import 'package:kino_ne/theme/app_colors.dart';
import 'package:kino_ne/view_models/tree/tree_view_model.dart';
import 'package:kino_ne/views/pages/icloud_backup_page.dart';
import 'package:kino_ne/views/pages/passcode_setting_page.dart';
import 'package:kino_ne/views/widgets/dynamic_forest_background.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum SettingContent {
  passCode,
  iCloud,
  privacyPolicy,
  inquiry,
  allDelete;

  String get title => switch (this) {
    passCode => 'パスコード',
    iCloud => 'iCloud',
    privacyPolicy => 'プライバシーポリシー・利用規約',
    inquiry => 'お問い合わせ',
    allDelete => 'すべてのデータを削除',
  };

  IconData get icon => switch (this) {
    passCode => Icons.lock,
    iCloud => Icons.cloud_queue,
    privacyPolicy => Icons.privacy_tip_sharp,
    inquiry => Icons.phone,
    allDelete => Icons.delete,
  };
  Color get textColor => switch (this) {
    allDelete => Colors.red,
    _ => Colors.white,
  };

  Uri? get url => switch (this) {
    privacyPolicy => Uri.parse(
      'https://keito0612.github.io/kino_ne_privacy_policy/',
    ),
    inquiry => Uri.parse(
      'https://docs.google.com/forms/d/e/1FAIpQLSetUQVMO3yH3FdoDgpoC5SdottkMSL7rBADZH4p3HIrU-tYTQ/viewform?usp=publish-editor',
    ),
    _ => null,
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSettingsTile(SettingContent.passCode, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PasscodeSettingsPage(),
                  ),
                );
              }),
              _buildSettingsTile(SettingContent.iCloud, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ICloudBackupPage()),
                );
              }),
              _buildSettingsTile(SettingContent.privacyPolicy, () {
                _launchUrl(SettingContent.privacyPolicy.url!);
              }),
              _buildSettingsTile(SettingContent.inquiry, () {
                _launchUrl(SettingContent.inquiry.url!);
              }),
              _buildSettingsTile(SettingContent.allDelete, () {
                _handleFullReset(context, ref);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(SettingContent content, void Function() onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.7),
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

  Future<void> _handleFullReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('全てのデータを削除', style: TextStyle(color: Colors.red)),
        content: const Text(
          'これまでの成長記録や木々のデータが全て消去されます。この操作は取り消せません。本当によろしいですか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除する', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper.instance.deleteFullDatabase();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('全てのデータを削除しました')));
      }
    }
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
