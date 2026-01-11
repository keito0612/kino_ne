import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'; // HookConsumer用
import 'package:flutter_hooks/flutter_hooks.dart'; // useHooks用
import 'package:kino_ne/view_models/tree/tree_view_model.dart';

class AddTreeDialog extends HookConsumerWidget {
  const AddTreeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks による状態管理
    final nameController = useTextEditingController();
    final isLoading = useState(false);

    Future<void> submit() async {
      isLoading.value = true;
      try {
        await ref
            .read(treeViewModelProvider.notifier)
            .addTree(name: nameController.text);
        if (context.mounted) Navigator.pop(context);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      } finally {
        isLoading.value = false;
      }
    }

    return AlertDialog(
      title: const Text('新しい木を植える'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            autovalidateMode: AutovalidateMode.always,
            // TextField から TextFormField に変更
            controller: nameController,
            decoration: const InputDecoration(
              labelText: '木の名前',
              hintText: '例: 桜',
            ),
            autofocus: true,

            // --- バリデーションロジック ---
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '木の名前を入力してください';
              }
              if (value.length < 2) {
                return '2文字以上で入力してください';
              }
              return null; // 問題なければ null を返す
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading.value ? null : () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: isLoading.value ? null : submit,
          child: isLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('植える'),
        ),
      ],
    );
  }
}
