class Task {
  String id;
  String title;
  String description;
  DateTime createdAt;
  String userId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'userId': userId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      userId: map['userId'] ?? '',
    );
  }
}