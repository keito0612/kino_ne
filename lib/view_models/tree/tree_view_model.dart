import 'package:kino_ne/repositories/tree/treeRepository_impl.dart';
import 'package:kino_ne/repositories/tree/tree_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/tree.dart';
import '../../core/exceptions.dart'; // 先ほど作成したエラー定義

part 'tree_view_model.g.dart';

@riverpod
class TreeViewModel extends _$TreeViewModel {
  TreeRepository get _repository => ref.read(treeRepositoryProvider);

  @override
  FutureOr<List<Tree>> build() async {
    return _fetch();
  }

  /// 内部用のデータ取得メソッド
  Future<List<Tree>> _fetch() async {
    return await _repository.fetchAllTrees();
  }

  /// 木を新しく植える
  Future<void> addTree({required String name, required String type}) async {
    try {
      if (name.isEmpty) {
        throw ValidationException('木の名前を入力してください');
      }

      final newTree = Tree(name: name, type: type, createdAt: DateTime.now());

      await _repository.plantTree(newTree);

      state = AsyncData(await _fetch());
    } catch (e) {
      // 4. エラー解析（ExceptionHandlerが適切な例外をthrowする）
      ExceptionHandler.handle(e, '新しい木を植えることができませんでした。');
    }
  }

  /// 木を削除する
  Future<void> removeTree(int treeId) async {
    try {
      await _repository.deleteTree(treeId);
      state = AsyncData(await _fetch());
    } catch (e) {
      ExceptionHandler.handle(e, '木の削除に失敗しました。');
    }
  }

  /// 手動リフレッシュ
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }
}
