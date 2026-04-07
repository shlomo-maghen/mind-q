class QueueItem {
  final String id;
  final String text;
  final DateTime createdAt;

  const QueueItem({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  QueueItem copyWith({String? text}) => QueueItem(
        id: id,
        text: text ?? this.text,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory QueueItem.fromJson(Map<String, dynamic> json) => QueueItem(
        id: json['id'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
