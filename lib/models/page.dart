class Page {
  final int? id;
  final int treeId; // 外部キー
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Page({
    this.id,
    required this.treeId,
    this.title = '',
    this.content = '',
    required this.createdAt,
    required this.updatedAt,
  });
  Map<String, dynamic> toMap() {
    return {'id': id, 'tree_id': treeId, 'title': title, 'content': content};
  }

  factory Page.fromMap(Map<String, dynamic> map) {
    return Page(
      id: map['id'],
      treeId: map['tree_id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Page copyWith({String? title, String? content}) {
    return Page(
      id: id,
      treeId: treeId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
