class HealthHabitModel {
  final int? id;
  final String title;
  final String category;
  final String icon;
  final String color;
  final String? reminderTime;
  final bool isActive;
  final String createdAt;

  const HealthHabitModel({
    this.id,
    required this.title,
    required this.category,
    this.icon = 'check_circle',
    this.color = '#00897B',
    this.reminderTime,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'category': category,
        'icon': icon,
        'color': color,
        'reminderTime': reminderTime,
        'isActive': isActive ? 1 : 0,
        'createdAt': createdAt,
      };

  factory HealthHabitModel.fromMap(Map<String, dynamic> map) {
    return HealthHabitModel(
      id: map['id'] as int?,
      title: (map['title'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'Wellness',
      icon: (map['icon'] as String?) ?? 'check_circle',
      color: (map['color'] as String?) ?? '#00897B',
      reminderTime: map['reminderTime'] as String?,
      isActive: (map['isActive'] as int? ?? 1) == 1,
      createdAt: (map['createdAt'] as String?) ?? DateTime.now().toIso8601String(),
    );
  }
}
