import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kino_ne/view_models/growth_log/growth_log_view_model.dart';
import 'package:kino_ne/view_models/icloud/icloud_view_model.dart';
import 'package:kino_ne/theme/app_colors.dart';
import 'package:kino_ne/view_models/tree/tree_view_model.dart';

class ICloudBackupPage extends HookConsumerWidget {
  const ICloudBackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(icloudViewModelProvider);
    final lastBackupTime = useState<String>('確認中...');
    final isICloudAvailable = useState<bool?>(null);

    final lifecycleState = useAppLifecycleState();

    Future<void> refreshAllStatus() async {
      lastBackupTime.value = await ref
          .read(icloudViewModelProvider.notifier)
          .getLastBackupTime();
      final available = await ref
          .read(icloudViewModelProvider.notifier)
          .checkConnection();
      isICloudAvailable.value = available;
    }

    useEffect(() {
      refreshAllStatus();
      return null;
    }, [lifecycleState]);

    ref.listen<AsyncValue<void>>(icloudViewModelProvider, (previous, next) {
      next.when(
        data: (_) {
          if (previous is AsyncLoading) {
            refreshAllStatus();
            _showCompleteDialog(context);
          }
        },
        error: (err, _) => _showErrorDialog(context, err.toString()),
        loading: () {},
      );
    });

    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text(
          'iCloud同期',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: isICloudAvailable.value == false
                ? _buildICloudNotice(context)
                : Column(
                    children: [
                      _buildInfoCard(lastBackupTime.value),
                      const SizedBox(height: 24),
                      const SizedBox(height: 32),
                      _buildActionButton(
                        Icons.backup_outlined,
                        '今すぐバックアップ',
                        () =>
                            ref.read(icloudViewModelProvider.notifier).backup(),
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
          ),

          // ローディング表示
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

  Widget _buildICloudNotice(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.brown.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            const Text(
              'iCloudが未設定です',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'データを保存するには、iPhoneの設定でiCloudにサインインし、「iCloud Drive」をオンにする必要があります。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => openICloudSettings(),
              icon: const Icon(Icons.settings),
              label: const Text('iPhoneの設定を開く'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String time) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_done_rounded, color: Colors.green, size: 48),
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

  Future<void> openICloudSettings() async {
    const channel = MethodChannel("openSetting");
    try {
      await channel.invokeMethod('openSetting');
    } catch (e) {
      debugPrint('設定画面を開けませんでした: $e');
    }
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
              ref.read(icloudViewModelProvider.notifier).restore();
              Navigator.pop(context);
            },
            child: const Text('復元', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
