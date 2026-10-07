class MedicineAdherenceModel {
  final int? id;
  final int reminderId;
  final String date; // YYYY-MM-DD
  final String slot; // 'morning', 'noon', 'night'
  final bool isTaken;
  final String takenAt;

  MedicineAdherenceModel({
    this.id,
    required this.reminderId,
    required this.date,
    required this.slot,
    this.isTaken = true,
    required this.takenAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'reminderId': reminderId,
      'date': date,
      'slot': slot,
      'isTaken': isTaken ? 1 : 0,
      'takenAt': takenAt,
    };
  }

  factory MedicineAdherenceModel.fromMap(Map<String, dynamic> map) {
    return MedicineAdherenceModel(
      id: map['id'] as int?,
      reminderId: (map['reminderId'] as int?) ?? 0,
      date: (map['date'] as String?) ?? '',
      slot: (map['slot'] as String?) ?? '',
      isTaken: (map['isTaken'] as int? ?? 1) == 1,
      takenAt: (map['takenAt'] as String?) ?? '',
    );
  }
}

class DailyAdherenceStat {
  final DateTime date;
  final String dateString;
  final String dayNameBn;
  final String dayNameEn;
  final int totalScheduled;
  final int totalTaken;

  DailyAdherenceStat({
    required this.date,
    required this.dateString,
    required this.dayNameBn,
    required this.dayNameEn,
    required this.totalScheduled,
    required this.totalTaken,
  });

  bool get isFull => totalScheduled > 0 && totalTaken >= totalScheduled;
  bool get isPartial => totalTaken > 0 && totalTaken < totalScheduled;
  bool get isMissed => totalScheduled > 0 && totalTaken == 0;
  bool get isNoMeds => totalScheduled == 0;
  double get rate => totalScheduled > 0 ? (totalTaken / totalScheduled) : 0.0;
}

class WeeklyAdherenceReport {
  final double adherenceRate; // 0.0 to 1.0
  final int totalTaken;
  final int totalScheduled;
  final int currentStreak;
  final int missedDoses;
  final List<DailyAdherenceStat> dailyStats;

  WeeklyAdherenceReport({
    required this.adherenceRate,
    required this.totalTaken,
    required this.totalScheduled,
    required this.currentStreak,
    required this.missedDoses,
    required this.dailyStats,
  });
}

