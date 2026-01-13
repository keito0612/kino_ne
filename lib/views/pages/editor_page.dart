import 'package:flutter/material.dart' hide Page;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kino_ne/models/page.dart';
import 'package:kino_ne/view_models/page/page_view_model.dart';
import 'package:kino_ne/theme/app_colors.dart';

class EditorPage extends HookConsumerWidget {
  final int treeId;
  final Page? page;

  const EditorPage({super.key, required this.treeId, this.page});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController(text: page?.title ?? '');
    final contentController = useTextEditingController(
      text: page?.content ?? '',
    );

    final currentContent = useValueListenable(contentController);
    final initialLength = page?.content.length ?? 0;
    final delta = (currentContent.text.length - initialLength)
        .clamp(0, double.infinity)
        .toInt();

    final whiteTextStyle = TextStyle(color: Colors.white);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(page == null ? '新しいページ' : '編集', style: whiteTextStyle),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () => _saveNote(
              context,
              ref,
              titleController.text,
              contentController.text,
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/page_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 成長インジケーター（透過させた白で浮かせる）
              if (delta > 0)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  color: Colors.white.withOpacity(0.15),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    '＋$delta 文字 成長中！',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),

              // タイトル入力
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10,
                ),
                child: TextField(
                  controller: titleController,
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'タイトル',
                    border: InputBorder.none,
                    hintStyle: whiteTextStyle.copyWith(
                      fontSize: 22,
                      color: Colors.white60,
                    ),
                  ),
                  style: whiteTextStyle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Divider(
                height: 1,
                color: Colors.white24,
                indent: 20,
                endIndent: 20,
              ),

              // 本文入力
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    controller: contentController,
                    maxLines: null,
                    expands: true,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: '内容',
                      border: InputBorder.none,
                      hintStyle: whiteTextStyle.copyWith(
                        fontSize: 16,
                        color: Colors.white60,
                      ),
                    ),
                    style: whiteTextStyle.copyWith(fontSize: 18, height: 1.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveNote(
    BuildContext context,
    WidgetRef ref,
    String title,
    String content,
  ) async {
    try {
      final initialLength = page?.content.length ?? 0;
      final delta = (content.length - initialLength)
          .clamp(0, double.infinity)
          .toInt();

      final pageToSave =
          page ??
          Page(
            treeId: treeId,
            title: title,
            content: content,
            createdAt: DateTime.now(),
            updatedAt: null,
          );

      await ref
          .read(pageViewModelProvider(treeId).notifier)
          .saveAndGrowPage(
            page: pageToSave,
            newTitle: title,
            newContent: content,
          );

      if (!context.mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          title: const Text('保存完了'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(delta > 0 ? '木が $delta 文字分、成長しました！' : 'ノートを保存しました。'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('閉じる'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.redAccent),
      );
    }
  }
}
