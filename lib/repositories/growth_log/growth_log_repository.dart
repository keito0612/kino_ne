import 'package:kino_ne/models/growth_log.dart';

abstract class GrowthLogRepository {
  Future<List<GrowthLog>> fetchAllLogs(int treeId);

  Future<List<GrowthLog>> fetchLogsByTreeId(
    int treeId, {
    DateTime? start,
    DateTime? end,
  });

  Future<int> getTodayTotalGrowth();
}
