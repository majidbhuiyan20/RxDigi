import '../database/database_helper.dart';

class CommonAdviceRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Define defaults to ensure they are always available alongside custom entries
  static const List<String> _defaultAdvice = [
    'Drink plenty of water',
    'Rest for 2 days',
    'Avoid spicy food',
    'Walk for 30 mins daily',
    'Avoid smoking',
    'Regular follow-up',
    'Take medicine after meal',
    'Avoid lifting heavy weights'
  ];

  Future<List<String>> getCommonAdvice() async {
    final db = await _databaseHelper.database;
    
    // Load manually inserted/used data from local storage first
    final result = await db.query(
      'common_advice',
      orderBy: 'usageCount DESC, lastUsed DESC',
    );
    
    final savedItems = result.map((map) => map['name'] as String).toList();
    
    // Merge with defaults so they are never lost, but prioritize used items
    final combined = List<String>.from(savedItems);
    for (var item in _defaultAdvice) {
      if (!combined.any((e) => e.toLowerCase() == item.toLowerCase())) {
        combined.add(item);
      }
    }
    
    return combined;
  }

  Future<void> addOrUpdateAdvice(String name) async {
    if (name.trim().isEmpty) return;
    final db = await _databaseHelper.database;
    final trimmedName = name.trim();

    final exists = await db.query(
      'common_advice',
      where: 'name = ?',
      whereArgs: [trimmedName],
    );

    if (exists.isNotEmpty) {
      final count = (exists.first['usageCount'] as int) + 1;
      await db.update(
        'common_advice',
        {
          'usageCount': count,
          'lastUsed': DateTime.now().toIso8601String(),
        },
        where: 'name = ?',
        whereArgs: [trimmedName],
      );
    } else {
      await db.insert('common_advice', {
        'name': trimmedName,
        'usageCount': 1,
        'lastUsed': DateTime.now().toIso8601String(),
      });
    }
  }
}
