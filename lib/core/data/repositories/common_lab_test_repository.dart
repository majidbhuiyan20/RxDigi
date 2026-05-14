import '../database/database_helper.dart';

class CommonLabTestRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Define defaults to ensure they are always available alongside custom entries
  static const List<String> _defaultLabTests = [
    'CBC', 'RBS', 'S. Creatinine', 'Lipid Profile', 'ALT (SGPT)', 'TSH', 
    'USG of W/A', 'Chest X-ray P/A View', 'ECG', 'Urine R/E', 'HbA1c'
  ];

  Future<List<String>> getCommonLabTests() async {
    final db = await _databaseHelper.database;
    
    // Load manually inserted/used data from local storage first
    final result = await db.query(
      'common_lab_tests',
      orderBy: 'usageCount DESC, lastUsed DESC',
    );
    
    final savedItems = result.map((map) => map['name'] as String).toList();
    
    // Merge with defaults so they are never lost, but prioritize used items
    final combined = List<String>.from(savedItems);
    for (var item in _defaultLabTests) {
      if (!combined.any((e) => e.toLowerCase() == item.toLowerCase())) {
        combined.add(item);
      }
    }
    
    return combined;
  }

  Future<void> addOrUpdateLabTest(String name) async {
    if (name.trim().isEmpty) return;
    final db = await _databaseHelper.database;
    final trimmedName = name.trim();

    final exists = await db.query(
      'common_lab_tests',
      where: 'name = ?',
      whereArgs: [trimmedName],
    );

    if (exists.isNotEmpty) {
      final count = (exists.first['usageCount'] as int) + 1;
      await db.update(
        'common_lab_tests',
        {
          'usageCount': count,
          'lastUsed': DateTime.now().toIso8601String(),
        },
        where: 'name = ?',
        whereArgs: [trimmedName],
      );
    } else {
      await db.insert('common_lab_tests', {
        'name': trimmedName,
        'usageCount': 1,
        'lastUsed': DateTime.now().toIso8601String(),
      });
    }
  }
}
