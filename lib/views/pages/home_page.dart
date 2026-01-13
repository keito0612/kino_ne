import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kino_ne/models/tree.dart';
import 'package:kino_ne/theme/app_colors.dart';
import 'package:kino_ne/view_models/growth_log/growth_log_view_model.dart';
import 'package:kino_ne/view_models/tree/tree_view_model.dart';
import 'package:kino_ne/views/widgets/add_tree_dialog_widget.dart';
import 'package:kino_ne/views/widgets/dynamic_forest_background.dart';
import 'package:kino_ne/views/widgets/tree_visualizer_widget.dart';
import 'tree_detail_page.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treesAsync = ref.watch(treeViewModelProvider);
    final todayGrowthAsync = ref.watch(todayTotalGrowthProvider);

    final isSelectionMode = useState(false);

    final selectedIds = useState<Set<int>>({});

    void clearSelection() {
      isSelectionMode.value = false;
      selectedIds.value = {};
    }

    useEffect(() {
      ref.invalidate(treeViewModelProvider);
      ref.invalidate(todayTotalGrowthProvider);
      return null;
    }, const []);
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: isSelectionMode.value
          ? AppBar(
              backgroundColor: AppColors.primaryGreen,
              title: Text(
                '${selectedIds.value.length} 個選択中',
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: clearSelection,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: selectedIds.value.isEmpty
                      ? null
                      : () => _showBulkDeleteDialog(
                          context,
                          ref,
                          selectedIds.value,
                          clearSelection,
                        ),
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          DynamicForestBackground(
            treeCount: treesAsync.value?.length ?? 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  if (!isSelectionMode.value) _buildHeader(todayGrowthAsync),
                  Expanded(
                    child: treesAsync.when(
                      data: (trees) => trees.isEmpty
                          ? const Center(
                              child: Text(
                                'まだ木がありません。\n新しい木を植えてみましょう。',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.only(
                                top: 10,
                                left: 20,
                                right: 20,
                                bottom: 100,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.95,
                                  ),
                              itemCount: trees.length,
                              itemBuilder: (context, index) {
                                return _buildSelectableTreeCard(
                                  context,
                                  trees[index],
                                  isSelectionMode,
                                  selectedIds,
                                );
                              },
                            ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('エラー: $err')),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isSelectionMode.value)
            Positioned(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).padding.bottom + 20,
              child: _buildPlantButton(context),
            ),
        ],
      ),
    );
  }

  // 固定ヘッダーのデザイン
  Widget _buildHeader(AsyncValue<int> todayGrowth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          const Text(
            'あなたの森',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white, // 木の背景に合わせて白に変更
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 4,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          todayGrowth.when(
            data: (count) {
              const dailyGoal = 500;
              final progress = (count / dailyGoal).clamp(0.0, 1.0);
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15), // 背景に馴染む透過白
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '今日の目標',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          '$count / $dailyGoal 文字',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        color: AppColors.primaryGreen,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(height: 60),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeCardContent(Tree tree) {
    return Container(
      // カード全体の装飾（背景画像と角丸）
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/page_image.png'),
          fit: BoxFit.fitWidth,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 木のビジュアル表示（サイズはグリッドに合わせて調整）
          TreeVisualizer(tree: tree, baseSize: 55),
          const SizedBox(height: 8),
          // 文字数バッジ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${tree.totalChars} 文字',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showAddTreeDialog(context),
      icon: const Icon(Icons.park_rounded), // アイコンを木に変更
      label: const Text(
        '新しい木を植える',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
    );
  }

  Widget _buildSelectableTreeCard(
    BuildContext context,
    Tree tree,
    ValueNotifier<bool> isSelectionMode,
    ValueNotifier<Set<int>> selectedIds,
  ) {
    final isSelected = selectedIds.value.contains(tree.id);
    return GestureDetector(
      onLongPress: () {
        isSelectionMode.value = true;
        selectedIds.value = {...selectedIds.value, tree.id!};
      },
      onTap: () {
        if (isSelectionMode.value) {
          final newSet = {...selectedIds.value};
          if (isSelected) {
            newSet.remove(tree.id);
            if (newSet.isEmpty) isSelectionMode.value = false;
          } else {
            newSet.add(tree.id!);
          }
          selectedIds.value = newSet;
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TreeDetailPage(treeId: tree.id!),
            ),
          );
        }
      },
      child: Stack(
        children: [
          Opacity(
            opacity: isSelected ? 0.5 : 1.0,
            child: _buildTreeCardContent(tree),
          ),
          // 選択中マーク
          if (isSelected)
            const Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.green,
                radius: 12,
                child: Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _showBulkDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Set<int> ids,
    VoidCallback onSuccess,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${ids.length}本の木を削除しますか？'),
        content: const Text('選択した木と、そのすべてのメモが完全に削除されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              final notifier = ref.read(treeViewModelProvider.notifier);
              for (final id in ids) {
                await notifier.removeTree(id);
              }
              onSuccess();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddTreeDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddTreeDialog());
  }
}
