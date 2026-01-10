import 'package:flutter/material.dart';
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

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          DynamicForestBackground(
            treeCount: treesAsync.value?.length ?? 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(todayGrowthAsync),
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
                                return _buildTreeCard(context, trees[index]);
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
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 20, // 端末のセーフエリアを考慮
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

  Widget _buildTreeCard(BuildContext context, Tree tree) {
    return Container(
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
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TreeDetailPage(treeId: tree.id!),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TreeVisualizer(tree: tree, baseSize: 55),
            const SizedBox(height: 8),
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

  void _showAddTreeDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddTreeDialog());
  }
}
