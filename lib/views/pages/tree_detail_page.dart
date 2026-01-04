import 'package:flutter/material.dart' hide Page;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kino_ne/models/growth_log.dart';
import 'package:kino_ne/models/page.dart';
import 'package:kino_ne/models/tree.dart';
import 'package:kino_ne/theme/app_colors.dart';
import 'package:kino_ne/view_models/growth_log/growth_log_view_model.dart';
import 'package:kino_ne/view_models/page/page_view_model.dart';
import 'package:kino_ne/view_models/tree/tree_view_model.dart';
import 'package:kino_ne/views/pages/editor_page.dart';
import 'package:kino_ne/views/pages/preview_page.dart';
import 'package:kino_ne/views/widgets/tree_visualizer_widget.dart';

class TreeDetailPage extends HookConsumerWidget {
  final int treeId;
  const TreeDetailPage({super.key, required this.treeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsync = ref.watch(pageViewModelProvider(treeId));
    final tree = ref
        .watch(treeViewModelProvider)
        .value
        ?.firstWhere((t) => t.id == treeId);

    if (tree == null) {
      return const Scaffold(body: Center(child: Text('データが見つかりません')));
    }

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tree.name,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context, ref, tree.name),
          ),
          IconButton(
            icon: const Icon(
              Icons.visibility_outlined,
              color: AppColors.primaryGreen,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PreviewPage(
                    tree: tree,
                    allPages: pagesAsync.value ?? [],
                    initialIndex: 0,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 2. 統計カード (累計文字数)
            _buildStatsCard(tree),

            // 4. ノート一覧セクション
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsetsGeometry.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        'ノート一覧',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                  pagesAsync.when(
                    data: (pages) => Column(
                      children: pages.isEmpty
                          ? [
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Text('まだノートがありません。'),
                                ),
                              ),
                            ]
                          : [_bulidNoteCardList(context, pages)],
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) =>
                        Center(child: Text('ページ一覧の情報を取得することができませんでした。')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80), // 下部の余白
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditorPage(treeId: treeId)),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // 木のヒーローセクション
  Widget _buildTreeHero(Tree tree) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TreeVisualizer(
        tree: tree,
        titleFontSize: 22,
        baseSize: 160,
        isProgressIndicator: false,
      ),
    );
  }

  // 統計カード
  Widget _buildStatsCard(Tree tree) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          _buildTreeHero(tree),
          Text(
            '現在のレベル: ${tree.level}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            textAlign: TextAlign.start,
            '合計: ${tree.totalChars} 文字',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (tree.totalChars % 1000) / 1000, // 1000文字ごとの進捗例
              backgroundColor: AppColors.bgColor,
              color: AppColors.primaryGreen,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulidNoteCardList(BuildContext context, List<Page> pages) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      child: ListView(
        children: pages.map((page) => _buildNoteCard(context, page)).toList(),
      ),
    );
  }

  // ノート（Page）のカードデザイン
  Widget _buildNoteCard(BuildContext context, Page page) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          page.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${page.content.length} 文字 • ${page.updatedAt.toString().split(' ')[0]}',
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditorPage(treeId: treeId, page: page),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String treeName) {
    // 既存の日本語ダイアログ処理を継続
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('木の削除'),
        content: Text('「$treeName」を削除しますか？\n書いたノートもすべて消えてしまいます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(treeViewModelProvider.notifier).removeTree(treeId);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('削除する', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
