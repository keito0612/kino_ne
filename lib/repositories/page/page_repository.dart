import '../../models/page.dart';

abstract class PageRepository {
  Future<List<Page>> fetchPagesByTreeId(int treeId);
  Future<int> createPage(int treeId);
  Future<void> updatePage(Page page);
  Future<void> deletePage(int id);
  Future<void> saveAndGrow({
    required Page page,
    required int deltaChars, // 今回の編集で増えた文字数
  });
}
