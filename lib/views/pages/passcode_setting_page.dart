import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:kino_ne/theme/app_colors.dart';
import 'package:kino_ne/view_models/passcode/passcode_view_model.dart';

class PasscodeSettingsPage extends HookConsumerWidget {
  const PasscodeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(passcodeViewModelProvider);
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.6),
      appBar: AppBar(
        title: const Text('パスコードロック', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('セキュリティ'),
          _buildSettingTile(
            title: 'パスコードを使用',
            subtitle: 'アプリ起動時にロックを表示します',
            trailing: Switch(
              value: isEnabled,
              activeThumbColor: AppColors.primaryGreen,
              onChanged: (value) => _handlePasscodeToggle(context, ref, value),
            ),
          ),
          if (isEnabled) ...[
            const SizedBox(height: 16),
            _buildSettingTile(
              title: 'パスコードを変更',
              subtitle: '現在のパスコードを新しいものに変えます',
              onTap: () => _handleChangePasscode(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  void _handlePasscodeToggle(BuildContext context, WidgetRef ref, bool value) {
    final storage = ref.read(localStorageServiceProvider);

    if (value) {
      screenLockCreate(
        context: context,
        title: const Text('パスコードを登録'),
        confirmTitle: const Text('確認のためもう一度'),
        onConfirmed: (code) async {
          await storage.setPasscode(code);
          ref.read(passcodeViewModelProvider.notifier).updateStatus();
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      );
    } else {
      screenLock(
        context: context,
        correctString: storage.getPasscode() ?? '',
        title: const Text('パスコードを解除'),
        onUnlocked: () async {
          await storage.disablePasscode();
          ref.read(passcodeViewModelProvider.notifier).updateStatus();
          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      );
    }
  }

  void _handleChangePasscode(BuildContext context, WidgetRef ref) {
    final storage = ref.read(localStorageServiceProvider);
    screenLock(
      context: context,
      correctString: storage.getPasscode() ?? '',
      title: const Text('現在のパスコードを入力'),
      onUnlocked: () async {
        // 1. まず現在の「認証画面」を閉じる
        Navigator.pop(context);

        // 2. 少しだけ待機（画面が完全に閉じるのを待つとより安定します）
        await Future.delayed(const Duration(milliseconds: 200));

        // 3. 認証成功した後に、新しいパスコード作成画面を表示
        if (context.mounted) {
          screenLockCreate(
            context: context,
            title: const Text('新しいパスコード'),
            confirmTitle: const Text('確認のためもう一度入力'), // 2回目の入力時のテキスト
            onConfirmed: (code) async {
              await storage.setPasscode(code);
              // 4. 作成画面を閉じる（screenLockCreateは内部でpopするので1回でOKな場合が多い）
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          );
        }
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing:
            trailing ?? const Icon(Icons.chevron_right, color: Colors.white24),
        onTap: onTap,
      ),
    );
  }
}
