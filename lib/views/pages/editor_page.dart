import 'package:flutter/material.dart' hide Page;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kino_ne/models/page.dart';
import 'package:kino_ne/view_models/page/page_view_model.dart';

class EditorPage extends HookConsumerWidget {
  final int treeId;
  final Page? page; // 既存ノートの編集ならPageが入る、新規ならnull

  const EditorPage({super.key, required this.treeId, this.page});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks: コントローラーの初期化
    final titleController = useTextEditingController(text: page?.title ?? '');
    final contentController = useTextEditingController(
      text: page?.content ?? '',
    );

    // Hooks: 現在の文字数を監視して差分（成長量）を表示
    final currentContent = useValueListenable(contentController);
    final initialLength = page?.content.length ?? 0;
    final delta = (currentContent.text.length - initialLength)
        .clamp(0, double.infinity)
        .toInt();

    Future<void> saveNote(BuildContext context) async {
      try {
        final currentContentText = contentController.text;
        final initialLength = page?.content.length ?? 0;
        final delta = (currentContentText.length - initialLength)
            .clamp(0, double.infinity)
            .toInt();

        final pageToSave =
            page ??
            Page(
              treeId: treeId,
              title: titleController.text,
              content: currentContentText,
              createdAt: DateTime.now(),
              updatedAt: null,
            );

        await ref
            .read(pageViewModelProvider(treeId).notifier)
            .saveAndGrowPage(
              page: pageToSave,
              newTitle: titleController.text,
              newContent: currentContentText,
            );

        if (!context.mounted) return;

        // 2. 成功時：成長ダイアログを表示
        await showDialog(
          context: context,
          barrierDismissible: false, // ユーザーがボタンを押すまで閉じない
          builder: (context) => AlertDialog(
            title: const Text('保存完了'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.amber, size: 48),
                const SizedBox(height: 16),
                Text(delta > 0 ? '木が $delta 文字分、成長しました！' : 'ノートを保存しました。'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ダイアログを閉じる
                },
                child: const Text('閉じる'),
              ),
            ],
          ),
        );
      } catch (e) {
        // 3. エラー時：ユーザーに通知
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.error_outline, color: Colors.red),
                ),
                Text('$e', style: TextStyle(color: Colors.red)),
              ],
            ),
            backgroundColor: Colors.white,
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(page == null ? '新しいノート' : '編集'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              saveNote(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 成長インジケーター（執筆中にモチベーションを上げる）
          if (delta > 0)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.green.shade50,
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                '＋$delta 文字 成長中！',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'タイトル',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'ここに言葉を綴ると、木が育ちます...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
