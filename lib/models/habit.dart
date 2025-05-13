enum HabitType { positive, negative }

enum FrequencyUnit { daily, weekly, monthly }

class Habit {
  final int? id;
  final int userId;
  final String name;
  final String description;
  final HabitType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int goal;
  final FrequencyUnit frequencyUnit;
  final bool reminderEnabled;
  final String? reminderTime;
  final String? reminderDays;
  final String? color;
  final String? icon;
  final bool isArchived;

  Habit({
    this.id,
    required this.userId,
    required this.name,
    this.description = '',
    required this.type,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.goal = 1,
    this.frequencyUnit = FrequencyUnit.daily,
    this.reminderEnabled = false,
    this.reminderTime,
    this.reminderDays,
    this.color,
    this.icon,
    this.isArchived = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'] ?? '',
      type: HabitType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => HabitType.positive,
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      goal: json['goal'] ?? 1,
      frequencyUnit: FrequencyUnit.values.firstWhere(
        (e) => e.toString().split('.').last == json['frequency_unit'],
        orElse: () => FrequencyUnit.daily,
      ),
      reminderEnabled: json['reminder_enabled'] ?? false,
      reminderTime: json['reminder_time'],
      reminderDays: json['reminder_days'],
      color: json['color'],
      icon: json['icon'],
      isArchived: json['is_archived'] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    // Create the base map
    final json = <String, dynamic>{
      'user_id': userId, // This should be an integer
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'goal': goal,
      'frequency_unit': frequencyUnit.toString().split('.').last,
      'reminder_enabled': reminderEnabled,
      'color': color,
      'icon': icon,
      'is_archived': isArchived,
    };

    // Only include ID if it's not null
    if (id != null) {
      json['id'] = id;
    }

    // Only include optional fields if they're not null
    if (reminderTime != null) json['reminder_time'] = reminderTime;
    if (reminderDays != null) json['reminder_days'] = reminderDays;

    // Let the backend handle timestamps for new habits
    // Only provide timestamps for existing habits (with ID)
    if (id != null) {
      json['created_at'] = createdAt.toIso8601String();
      json['updated_at'] = updatedAt.toIso8601String();
    }

    return json;
  }

  Habit copyWith({
    int? id,
    int? userId,
    String? name,
    String? description,
    HabitType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? goal,
    FrequencyUnit? frequencyUnit,
    bool? reminderEnabled,
    String? reminderTime,
    String? reminderDays,
    String? color,
    String? icon,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      goal: goal ?? this.goal,
      frequencyUnit: frequencyUnit ?? this.frequencyUnit,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDays: reminderDays ?? this.reminderDays,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
