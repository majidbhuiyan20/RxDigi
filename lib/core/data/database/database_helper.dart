import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'rxdigi.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE doctors ADD COLUMN collegeName TEXT');
          await db.execute('ALTER TABLE doctors ADD COLUMN passingYear TEXT');
          await db.execute('ALTER TABLE doctors ADD COLUMN roomNumber TEXT');
          await db.execute('ALTER TABLE doctors ADD COLUMN serialNumber1 TEXT');
          await db.execute('ALTER TABLE doctors ADD COLUMN serialNumber2 TEXT');
          await db.execute('ALTER TABLE doctors ADD COLUMN offDays TEXT');
          await db.execute('ALTER TABLE doctors ADD COLUMN position TEXT');
          await db.execute('ALTER TABLE doctors ADD COLUMN department TEXT');
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Doctor Info Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS doctors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        fullName TEXT,
        gender TEXT,
        bmdcRegNo TEXT,
        nationalId TEXT,
        mobile TEXT,
        email TEXT,
        degrees TEXT,
        specialization TEXT,
        subSpecialization TEXT,
        experience TEXT,
        collegeName TEXT,
        passingYear TEXT,
        clinicName TEXT,
        address TEXT,
        roomNumber TEXT,
        phoneNumber TEXT,
        serialNumber1 TEXT,
        serialNumber2 TEXT,
        startTime TEXT,
        endTime TEXT,
        offDays TEXT,
        position TEXT,
        department TEXT,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Patient Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER,
        gender TEXT,
        phone TEXT,
        address TEXT,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Prescription Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS prescriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId INTEGER NOT NULL,
        doctorId INTEGER,
        date TEXT,
        diagnosis TEXT,
        notes TEXT,
        medicines TEXT,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(patientId) REFERENCES patients(id),
        FOREIGN KEY(doctorId) REFERENCES doctors(id)
      )
    ''');

    // Medicine Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        genericName TEXT,
        manufacturer TEXT,
        strength TEXT,
        dosageForm TEXT,
        price REAL
      )
    ''');
  }

  // Close database
  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
