import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kino_ne/models/page.dart' as model;
import 'package:kino_ne/models/tree.dart';
import 'package:kino_ne/theme/app_colors.dart';
import 'package:kino_ne/services/pdf_export_service.dart';
import 'editor_page.dart';

class PreviewPage extends HookConsumerWidget {
  final List<model.Page> allPages;
  final int initialIndex;
  final Tree tree;

  const PreviewPage({
    super.key,
    required this.allPages,
    this.initialIndex = 0,
    required this.tree,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController(initialPage: initialIndex);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: _buildPreviewBadge(),
        leading: IconButton(
          // 背景が暗い場合を想定し、アイコンを白に
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (allPages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.ios_share, color: Colors.white),
              onPressed: () =>
                  PdfExportService.exportFullNotebook(tree.name, allPages),
            ),
          const SizedBox(width: 8),
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
        child: allPages.isEmpty
            ? _buildEmptyPreview(context)
            : PageView.builder(
                controller: pageController,
                itemCount: allPages.length,
                itemBuilder: (context, index) {
                  return _buildSinglePage(
                    context,
                    allPages[index],
                    index + 1,
                    allPages.length,
                  );
                },
              ),
      ),
    );
  }

  // Previewバッジも白ベースに変更
  Widget _buildPreviewBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // 透過させた白
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_outlined, size: 14, color: Colors.white),
          SizedBox(width: 6),
          Text(
            'Preview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinglePage(
    BuildContext context,
    model.Page page,
    int current,
    int total,
  ) {
    // 文字に影をつけて可読性を上げるためのスタイル
    final textStyleBase = TextStyle(
      color: Colors.white,
      shadows: [
        Shadow(
          offset: const Offset(1, 1),
          blurRadius: 3.0,
          color: Colors.black.withOpacity(0.5),
        ),
      ],
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ページ $current / $total',
                  style: textStyleBase.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                  onPressed: () => _navigateToEditor(context, page, tree.id!),
                ),
              ],
            ),
            Text(
              page.title,
              style: textStyleBase.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 32, color: Colors.white30),
            Stack(
              children: [
                _buildLines(),
                Text(
                  page.content,
                  style: textStyleBase.copyWith(fontSize: 18, height: 2.22),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPreview(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'ページがありません',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'このノートにはまだ内容がありません。\n新しいページを追加しましょう。',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => _navigateToEditor(context, null, tree.id!),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              '新しいページを追加',
              style: TextStyle(color: Colors.white),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  // 罫線も白に変更
  Widget _buildLines() {
    return Column(
      children: List.generate(
        30,
        (i) => Container(
          height: 40,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white24)),
          ),
        ),
      ),
    );
  }

  void _navigateToEditor(BuildContext context, model.Page? page, int treeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorPage(treeId: treeId, page: page),
      ),
    );
  }
}
