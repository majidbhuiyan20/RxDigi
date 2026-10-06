class VitalLogModel {
  final int? id;
  final String type; // 'BP', 'SUGAR', 'WEIGHT'
  final double value1;
  final double? value2;
  final String unit;
  final String? category; // 'Fasting', 'Post-Meal', 'Random'
  final String? notes;
  final DateTime recordedAt;

  VitalLogModel({
    this.id,
    required this.type,
    required this.value1,
    this.value2,
    required this.unit,
    this.category,
    this.notes,
    required this.recordedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'value1': value1,
      'value2': value2,
      'unit': unit,
      'category': category,
      'notes': notes,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  factory VitalLogModel.fromMap(Map<String, dynamic> map) {
    return VitalLogModel(
      id: map['id'] as int?,
      type: map['type'] as String,
      value1: (map['value1'] as num).toDouble(),
      value2: map['value2'] != null ? (map['value2'] as num).toDouble() : null,
      unit: map['unit'] as String,
      category: map['category'] as String?,
      notes: map['notes'] as String?,
      recordedAt: DateTime.parse(map['recordedAt'] as String),
    );
  }

  String getBpStatus() {
    if (type != 'BP' || value2 == null) return '';
    final sys = value1;
    final dia = value2!;
    if (sys < 120 && dia < 80) return 'Normal';
    if (sys <= 129 && dia < 80) return 'Elevated';
    if (sys <= 139 || dia <= 89) return 'Stage 1 HTN';
    return 'Stage 2 HTN';
  }

  double? getBmi() {
    if (type != 'WEIGHT' || value2 == null || value2! <= 0) return null;
    final heightMeters = value2! / 100.0;
    return value1 / (heightMeters * heightMeters);
  }

  String get displayValue {
    if (type == 'BP') {
      return value2 != null ? '${value1.toInt()}/${value2!.toInt()}' : '${value1.toInt()}';
    } else if (type == 'SUGAR') {
      return value1.toStringAsFixed(1);
    } else if (type == 'WEIGHT') {
      return value1.toStringAsFixed(1);
    }
    return '$value1';
  }
}
