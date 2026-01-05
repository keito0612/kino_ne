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
      body: DynamicForestBackground(
        treeCount: treesAsync.value?.length ?? 0,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(todayGrowthAsync)),
            // 2. 木のグリッド表示
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: treesAsync.when(
                data: (trees) => trees.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Text('まだ木がありません。\n新しい木を植えてみましょう。'),
                          ),
                        ),
                      )
                    : SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.95,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final tree = trees[index];
                          return _buildTreeCard(context, tree);
                        }, childCount: trees.length),
                      ),
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) =>
                    SliverToBoxAdapter(child: Center(child: Text('エラー: $err'))),
              ),
            ),

            // 3. 「新しい木を植える」ボタン
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: _buildPlantButton(context),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // 修正：隙間を解消したヘッダー
  Widget _buildHeader(AsyncValue<int> todayGrowth) {
    return Container(
      // 太陽アイコンがステータスバーに被らないよう top を調整
      padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            'あなたの森',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),

          // 今日の進捗バー（デザイン案のカード風）
          todayGrowth.when(
            data: (count) {
              const dailyGoal = 500;
              final progress = (count / dailyGoal).clamp(0.0, 1.0);
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '今日の目標',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          '$count / $dailyGoal 文字',
                          style: const TextStyle(
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
                        backgroundColor: Colors.black.withOpacity(0.05),
                        color: AppColors.primaryGreen,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeCard(BuildContext context, Tree tree) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TreeDetailPage(treeId: tree.id!),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TreeVisualizer(tree: tree, baseSize: 60),
            const SizedBox(height: 6),
            Text(
              '合計:${tree.totalChars} 文字',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showAddTreeDialog(context),
      icon: const Icon(Icons.add),
      label: const Text('新しい木を植える'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        side: BorderSide(color: Colors.black.withOpacity(0.05)),
      ),
    );
  }

  void _showAddTreeDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddTreeDialog());
  }
}
