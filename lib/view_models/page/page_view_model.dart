import 'package:kino_ne/core/exceptions.dart';
import 'package:kino_ne/models/page.dart';
import 'package:kino_ne/repositories/page/page_repository.dart';
import 'package:kino_ne/repositories/page/page_repository_impl.dart';
import 'package:kino_ne/view_models/tree/tree_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'page_view_model.g.dart';

@riverpod
class PageViewModel extends _$PageViewModel {
  // RepositoryをProvider経由で取得
  PageRepository get _repository => ref.read(pageRepositoryProvider);

  @override
  FutureOr<List<Page>> build(int treeId) async {
    return _fetch();
  }

  Future<List<Page>> _fetch() async {
    return await _repository.fetchPagesByTreeId(treeId);
  }

  /// ノートの新規作成
  Future<void> createNewPage() async {
    try {
      await _repository.createPage(treeId);
      state = AsyncData(await _fetch());
    } catch (e) {
      ExceptionHandler.handle(e, '新しいページの作成に失敗しました。');
    }
  }

  /// ノートの保存と「木の成長」
  Future<void> saveAndGrowPage({
    required Page page,
    required String newTitle,
    required String newContent,
  }) async {
    try {
      if (newTitle.trim().isEmpty) {
        throw ValidationException('タイトルを入力してください');
      }
      await _repository.saveAndGrow(
        page: page.copyWith(title: newTitle, content: newContent),
        deltaChars: _getDelta(newContent, page),
      );

      // リスト更新
      state = AsyncData(await _fetch());

      // 木の成長（ホーム画面）を反映
      ref.invalidate(treeViewModelProvider);
    } catch (e) {
      ExceptionHandler.handle(e, 'ノートの保存に失敗しました。');
    }
  }

  /// ノートの削除
  Future<void> deletePage(int pageId) async {
    try {
      await _repository.deletePage(pageId);
      state = AsyncData(await _fetch());
    } catch (e) {
      ExceptionHandler.handle(e, 'ノートの削除に失敗しました。');
    }
  }

  int _getDelta(String newContent, Page page) {
    if (page.id != null) {
      return (newContent.length > page.content.length)
          ? (newContent.length - page.content.length)
          : 0;
    } else {
      return newContent.length;
    }
  }
}
