import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kino_ne/view_models/icloud/icloud_view_model.dart';
import 'package:kino_ne/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ICloudBackupPage extends HookConsumerWidget {
  const ICloudBackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(icloudViewModelProvider);
    final lastBackupTime = useState<String>('確認中...');
    final isAutoEnabled = useState<bool>(false);
    final isICloudAvailable = useState<bool>(true);
    // データ取得関数
    Future<void> refreshData() async {
      lastBackupTime.value = await ref
          .read(icloudViewModelProvider.notifier)
          .getLastBackupTime();
      isAutoEnabled.value = await ref
          .read(icloudViewModelProvider.notifier)
          .isAutoBackupEnabled();
    }

    useEffect(() {
      refreshData();
      ref.read(icloudViewModelProvider.notifier).checkConnection().then((val) {
        isICloudAvailable.value = val;
      });
      return null;
    }, []);

    // 完了・エラー監視
    ref.listen<AsyncValue<void>>(icloudViewModelProvider, (previous, next) {
      next.when(
        data: (_) {
          if (previous is AsyncLoading) {
            refreshData();
            _showCompleteDialog(context);
          }
        },
        error: (err, _) => _showErrorDialog(context, err.toString()),
        loading: () {},
      );
    });

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text(
          'iCloud同期',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildInfoCard(lastBackupTime.value),
              const SizedBox(height: 24),
              _buildSettingsCard(
                '自動バックアップ',
                '起動時に最新データを保存します',
                Switch(
                  value: isAutoEnabled.value,
                  activeThumbColor: AppColors.primaryGreen,
                  onChanged: (val) async {
                    isAutoEnabled.value = val;
                    await ref
                        .read(icloudViewModelProvider.notifier)
                        .toggleAutoBackup(val);
                  },
                ),
              ),
              const SizedBox(height: 32),
              _buildActionButton(
                Icons.backup_outlined,
                '今すぐバックアップ',
                () => ref.read(icloudViewModelProvider.notifier).backup(),
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                Icons.restore_outlined,
                'データを復元する',
                () => _confirmRestore(context, ref),
                isDestructive: true,
              ),
            ],
          ),
          if (backupState.isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String time) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_done_rounded,
            color: Colors.blueAccent,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            '最終同期: $time',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(String title, String sub, Widget trailing) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        subtitle: Text(
          sub,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive
            ? Colors.redAccent.withOpacity(0.8)
            : Colors.white10,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('完了'),
        content: const Text('同期が成功しました。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String err) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エラー'),
        content: Text(err),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmRestore(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('復元の確認'),
        content: const Text('現在のデータが上書きされます。よろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(icloudViewModelProvider.notifier).restore();
            },
            child: const Text('復元', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildICloudNotice(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.brown.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, color: Colors.orangeAccent, size: 32),
          const SizedBox(height: 12),
          const Text(
            'iCloudが眠っているようです',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ノートをクラウドで守るために、iPhoneの設定でiCloudにサインインし、「iCloud Drive」をオンにしてください。',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // iOSの設定画面（iCloud設定など）へ直接誘導を試みる
              final url = Uri.parse('App-Prefs:root=CASTLE');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.brown[900],
            ),
            child: const Text('設定を開く'),
          ),
        ],
      ),
    );
  }

  Future<void> openICloudSettings() async {
    final Uri url = Uri.parse('App-Prefs:root=CASTLE');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        final Uri generalSettings = Uri.parse('package:ios_settings'); // 代替案
        await launchUrl(generalSettings);
      }
    } catch (e) {
      debugPrint('設定画面を開けませんでした: $e');
    }
  }
}
