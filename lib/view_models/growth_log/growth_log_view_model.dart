import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kino_ne/models/growth_log.dart';
import 'package:kino_ne/repositories/growth_log/growth_log_repository.dart';
import 'package:kino_ne/repositories/growth_log/growth_log_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'growth_log_view_model.g.dart';

@riverpod
class GrowthLogViewModel extends _$GrowthLogViewModel {
  GrowthLogRepository get _repository => ref.read(growthLogRepositoryProvider);

  @override
  FutureOr<List<GrowthLog>> build(int treeId) async {
    return _fetch();
  }

  Future<List<GrowthLog>> _fetch() async {
    // 日別集計されたログを取得
    return await _repository.fetchAllLogs(treeId);
  }
}

@riverpod
Future<int> todayTotalGrowth(Ref ref) async {
  final repo = ref.watch(growthLogRepositoryProvider);
  return await repo.getTodayTotalGrowth();
}
