class Task {
  final int    id;
  String       title;
  bool         isDone;
  String       priority;
  String?      deadline;
  final String createdAt;
  String       updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.isDone,
    required this.priority,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id:        json['id']         as int,
    title:     json['title']      as String,
    isDone:    json['is_done']    as bool,
    priority:  json['priority']   as String,
    deadline:  json['deadline']   as String?,
    createdAt: json['created_at'] as String,
    updatedAt: json['updated_at'] as String,
  );

  Task copyWith({String? title, bool? isDone, String? priority, String? deadline, bool clearDeadline = false, String? updatedAt}) {
    return Task(
      id:        id,
      title:     title    ?? this.title,
      isDone:    isDone   ?? this.isDone,
      priority:  priority ?? this.priority,
      deadline:  clearDeadline ? null : (deadline ?? this.deadline),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
