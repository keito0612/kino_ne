class GrowthLog {
  final int? id;
  final int treeId;
  final int deltaChars;
  final String logDate; // YYYY-MM-DD

  GrowthLog({
    this.id,
    required this.treeId,
    required this.deltaChars,
    required this.logDate,
  });

  factory GrowthLog.fromMap(Map<String, dynamic> map) => GrowthLog(
    id: map['id'],
    treeId: map['tree_id'],
    deltaChars: map['delta_chars'],
    logDate: map['log_date'] ?? map['created_at'].toString().split(' ')[0],
  );

  // DB保存用
  Map<String, dynamic> toMap() => {
    'id': id,
    'tree_id': treeId,
    'delta_chars': deltaChars,
    'created_at': logDate,
  };
}
