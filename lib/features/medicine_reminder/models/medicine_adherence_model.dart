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
