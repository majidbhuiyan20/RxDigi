class MedicineReminderModel {
  final int? id;
  final String medicineName;
  final String dosageForm;
  final String dosageStrength;
  final String instructions;
  final bool morning;
  final bool noon;
  final bool evening;
  final bool night;
  final String morningTime;
  final String noonTime;
  final String eveningTime;
  final String nightTime;
  final String startDate;
  final int durationDays; // 0 = ongoing/continuous
  final int totalStock; // Initial/total stock purchased (e.g. 10 tablets)
  final int currentStock; // Remaining stock (e.g. 8 tablets)
  final int lowStockThreshold; // Alert when stock <= this (e.g. 2 tablets)
  final bool isRefillAlertEnabled;
  final bool isActive;
  final String createdAt;

  MedicineReminderModel({
    this.id,
    required this.medicineName,
    this.dosageForm = 'Tablet',
    this.dosageStrength = '',
    this.instructions = 'After Meal',
    this.morning = true,
    this.noon = false,
    this.evening = false,
    this.night = true,
    this.morningTime = '08:00 AM',
    this.noonTime = '01:30 PM',
    this.eveningTime = '06:00 PM',
    this.nightTime = '09:00 PM',
    required this.startDate,
    this.durationDays = 0,
    this.totalStock = 0,
    this.currentStock = 0,
    this.lowStockThreshold = 2,
    this.isRefillAlertEnabled = true,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'medicineName': medicineName,
      'dosageForm': dosageForm,
      'dosageStrength': dosageStrength,
      'instructions': instructions,
      'morning': morning ? 1 : 0,
      'noon': noon ? 1 : 0,
      'evening': evening ? 1 : 0,
      'night': night ? 1 : 0,
      'morningTime': morningTime,
      'noonTime': noonTime,
      'eveningTime': eveningTime,
      'nightTime': nightTime,
      'startDate': startDate,
      'durationDays': durationDays,
      'totalStock': totalStock,
      'currentStock': currentStock,
      'lowStockThreshold': lowStockThreshold,
      'isRefillAlertEnabled': isRefillAlertEnabled ? 1 : 0,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt,
    };
  }

  factory MedicineReminderModel.fromMap(Map<String, dynamic> map) {
    return MedicineReminderModel(
      id: map['id'] as int?,
      medicineName: (map['medicineName'] as String?) ?? '',
      dosageForm: (map['dosageForm'] as String?) ?? 'Tablet',
      dosageStrength: (map['dosageStrength'] as String?) ?? '',
      instructions: (map['instructions'] as String?) ?? 'After Meal',
      morning: (map['morning'] as int? ?? 0) == 1,
      noon: (map['noon'] as int? ?? 0) == 1,
      evening: (map['evening'] as int? ?? 0) == 1,
      night: (map['night'] as int? ?? 0) == 1,
      morningTime: (map['morningTime'] as String?) ?? '08:00 AM',
      noonTime: (map['noonTime'] as String?) ?? '01:30 PM',
      eveningTime: (map['eveningTime'] as String?) ?? '06:00 PM',
      nightTime: (map['nightTime'] as String?) ?? '09:00 PM',
      startDate: (map['startDate'] as String?) ?? DateTime.now().toIso8601String().split('T')[0],
      durationDays: (map['durationDays'] as int?) ?? 0,
      totalStock: (map['totalStock'] as int?) ?? 0,
      currentStock: (map['currentStock'] as int?) ?? 0,
      lowStockThreshold: (map['lowStockThreshold'] as int?) ?? 2,
      isRefillAlertEnabled: (map['isRefillAlertEnabled'] as int? ?? 1) == 1,
      isActive: (map['isActive'] as int? ?? 1) == 1,
      createdAt: (map['createdAt'] as String?) ?? DateTime.now().toIso8601String(),
    );
  }

  MedicineReminderModel copyWith({
    int? id,
    String? medicineName,
    String? dosageForm,
    String? dosageStrength,
    String? instructions,
    bool? morning,
    bool? noon,
    bool? evening,
    bool? night,
    String? morningTime,
    String? noonTime,
    String? eveningTime,
    String? nightTime,
    String? startDate,
    int? durationDays,
    int? totalStock,
    int? currentStock,
    int? lowStockThreshold,
    bool? isRefillAlertEnabled,
    bool? isActive,
    String? createdAt,
  }) {
    return MedicineReminderModel(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      dosageForm: dosageForm ?? this.dosageForm,
      dosageStrength: dosageStrength ?? this.dosageStrength,
      instructions: instructions ?? this.instructions,
      morning: morning ?? this.morning,
      noon: noon ?? this.noon,
      evening: evening ?? this.evening,
      night: night ?? this.night,
      morningTime: morningTime ?? this.morningTime,
      noonTime: noonTime ?? this.noonTime,
      eveningTime: eveningTime ?? this.eveningTime,
      nightTime: nightTime ?? this.nightTime,
      startDate: startDate ?? this.startDate,
      durationDays: durationDays ?? this.durationDays,
      totalStock: totalStock ?? this.totalStock,
      currentStock: currentStock ?? this.currentStock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      isRefillAlertEnabled: isRefillAlertEnabled ?? this.isRefillAlertEnabled,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get scheduleDosePattern {
    if (evening) {
      return '${morning ? '1' : '0'} + ${noon ? '1' : '0'} + ${evening ? '1' : '0'} + ${night ? '1' : '0'}';
    }
    return '${morning ? '1' : '0'} + ${noon ? '1' : '0'} + ${night ? '1' : '0'}';
  }

  List<String> get activeSlots {
    final list = <String>[];
    if (morning) list.add('morning');
    if (noon) list.add('noon');
    if (evening) list.add('evening');
    if (night) list.add('night');
    return list;
  }

  bool get hasStockTracking => totalStock > 0;
  bool get isLowStock => hasStockTracking && currentStock <= lowStockThreshold && currentStock > 0;
  bool get isOutOfStock => hasStockTracking && currentStock <= 0;
  double get stockPercent => totalStock > 0 ? (currentStock / totalStock).clamp(0.0, 1.0) : 1.0;
}
