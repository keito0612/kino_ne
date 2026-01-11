import 'package:flutter/material.dart' hide Page;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart'; // Hooksを追加
import 'package:kino_ne/models/page.dart';
import 'package:kino_ne/models/tree.dart';
import 'package:kino_ne/theme/app_colors.dart';
import 'package:kino_ne/view_models/page/page_view_model.dart';
import 'package:kino_ne/view_models/tree/tree_view_model.dart';
import 'package:kino_ne/views/pages/editor_page.dart';
import 'package:kino_ne/views/pages/preview_page.dart';
import 'package:kino_ne/views/widgets/tree_background.dart';
import 'package:kino_ne/views/widgets/tree_visualizer_widget.dart';

class TreeDetailPage extends HookConsumerWidget {
  final int treeId;
  const TreeDetailPage({super.key, required this.treeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- 状態管理 (Hooks) ---
    final isEditMode = useState(false); // 削除モードかどうか
    final selectedPageIds = useState<List<int>>([]); // 選択されたPageのIDリスト

    final pagesAsync = ref.watch(pageViewModelProvider(treeId));
    final tree = ref
        .watch(treeViewModelProvider)
        .value
        ?.firstWhere((t) => t.id == treeId);

    if (tree == null) {
      return const Scaffold(body: Center(child: Text('データが見つかりません')));
    }

    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isEditMode.value ? Icons.close : Icons.arrow_back_ios,
            color: AppColors.cardColor,
          ),
          onPressed: () {
            if (isEditMode.value) {
              isEditMode.value = false;
              selectedPageIds.value = [];
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          '詳細',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // 削除ボタン：モードによって表示が変わる
          if (isEditMode.value)
            TextButton.icon(
              onPressed: selectedPageIds.value.isEmpty
                  ? null
                  : () => _confirmBulkDelete(context, ref, selectedPageIds),
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              label: Text(
                '削除（${selectedPageIds.value.length}）',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => isEditMode.value = true,
            ),

          if (!isEditMode.value)
            IconButton(
              icon: const Icon(
                Icons.visibility_outlined,
                color: AppColors.cardColor,
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
      body: TreeBackground(
        tree: tree,
        child: Column(
          children: [
            _buildStatsCard(tree),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _buildPageList(
                context,
                pagesAsync,
                isEditMode,
                selectedPageIds,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isEditMode.value
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.primaryGreen,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditorPage(treeId: treeId),
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildPageList(
    BuildContext context,
    AsyncValue<List<Page>> pagesAsync,
    ValueNotifier<bool> isEditMode,
    ValueNotifier<List<int>> selectedPageIds,
  ) {
    return Column(
      children: [
        const SizedBox(
          width: double.infinity,
          child: Text(
            'ページ一覧',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.46,
          child: SingleChildScrollView(
            child: pagesAsync.when(
              data: (pages) => pages.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'まだページがありません。',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : _buildPageCardList(
                      context,
                      pages,
                      isEditMode,
                      selectedPageIds,
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => const Center(child: Text('情報の取得に失敗しました')),
            ),
          ),
        ),
      ],
    );
  }

  //ページ一覧リスト
  Widget _buildPageCardList(
    BuildContext context,
    List<Page> pages,
    ValueNotifier<bool> isEditMode,
    ValueNotifier<List<int>> selectedPageIds,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final page = pages[index];
        final isSelected = selectedPageIds.value.contains(page.id);

        return _buildNoteCard(context, page, isEditMode.value, isSelected, () {
          if (isEditMode.value) {
            // IDを取得。もしページIDがnullならスキップ
            final id = page.id;
            if (id == null) return;

            if (isSelected) {
              selectedPageIds.value = selectedPageIds.value
                  .where((val) => val != id)
                  .toList();
            } else {
              selectedPageIds.value = [...selectedPageIds.value, id];
            }
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditorPage(treeId: treeId, page: page),
              ),
            );
          }
        });
      },
    );
  }

  // 1枚のノートカード
  Widget _buildNoteCard(
    BuildContext context,
    Page page,
    bool isEditMode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final cardTextStyle = TextStyle(
      color: Colors.white,
      shadows: [
        Shadow(
          offset: const Offset(1, 1),
          blurRadius: 3.0,
          color: Colors.black.withOpacity(0.6),
        ),
      ],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/page_image.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // 削除モード時はチェックボックス、通常時はなし
        leading: isEditMode
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => onTap(),
                activeColor: Colors.redAccent,
                side: const BorderSide(color: Colors.white, width: 2),
              )
            : null,
        title: Text(
          page.title,
          style: cardTextStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          '${page.content.length} 文字 • ${page.updatedAt?.toString().split(' ')[0] ?? page.createdAt.toString().split(' ')[0]}',
          style: cardTextStyle.copyWith(fontSize: 12),
        ),
        trailing: isEditMode
            ? null
            : const Icon(Icons.chevron_right, color: Colors.white),
      ),
    );
  }

  // まとめて削除のダイアログ
  void _confirmBulkDelete(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<List<int>> selectedPageIds,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ページの削除'),
        content: Text(
          '${selectedPageIds.value.length}件のページを削除しますか？\nこの操作は取り消せません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              final notifier = ref.read(pageViewModelProvider(treeId).notifier);
              // ViewModelにまとめて削除するメソッドがあると仮定（またはループで削除）
              for (final id in selectedPageIds.value) {
                await notifier.deletePage(id);
              }
              selectedPageIds.value = []; // クリア
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('削除する', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- 統計カードなどは元のデザインを維持 ---
  Widget _buildStatsCard(Tree tree) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // --- 追加：カードの背景を木の画像にする ---
        image: const DecorationImage(
          image: AssetImage('assets/images/page_image.png'),
          fit: BoxFit.cover,
        ),
        // 木の画像より少し暗いシャドウを入れると浮き出て見えます
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
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
            style: const TextStyle(color: Colors.white),
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

  Widget _buildTreeHero(Tree tree) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TreeVisualizer(
        tree: tree,
        titleFontSize: 22,
        baseSize: 80,
        isProgressIndicator: false,
      ),
    );
  }
}
