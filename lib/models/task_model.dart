class Task {
  final String name;
  final int duration;
  final String priority;

  Task({
    required this.name,
    required this.duration,
    required this.priority,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'duration': duration,
      'priority': priority,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      name: map['name'] ?? '',
      duration: map['duration'] ?? 0,
      priority: map['priority'] ?? 'Sedang',
    );
  }
}
