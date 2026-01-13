// main.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kino_ne/view_models/passcode/passcode_view_model.dart';
import 'package:kino_ne/views/pages/main_page.dart';

class AppLauncher extends HookConsumerWidget {
  const AppLauncher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. ストレージからパスコード設定を取得
    final storage = ref.watch(localStorageServiceProvider);
    final passcode = storage.getPasscode();
    final isLocked = useState(passcode != null && passcode.isNotEmpty);

    useEffect(() {
      if (isLocked.value) {
        Future.microtask(() {
          screenLock(
            context: context,
            correctString: passcode!,
            title: const Text('おかえりなさい'),
            canCancel: false,
            onUnlocked: () {
              isLocked.value = false;
              Navigator.pop(context);
            },
          );
        });
      }
      return null;
    }, const []);

    return const MainPage();
  }
}
