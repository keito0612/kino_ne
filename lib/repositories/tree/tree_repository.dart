import '../../models/tree.dart';

abstract class TreeRepository {
  Future<List<Tree>> fetchAllTrees();
  Future<int> plantTree(Tree tree);
  Future<void> updateTreeLevel(int treeId, int newLevel);
  Future<void> deleteTree(int treeId);
}
