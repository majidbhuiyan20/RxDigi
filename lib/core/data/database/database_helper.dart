import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

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
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'rxdigi.db');

    return await openDatabase(
      path,
      version: 10,
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
        if (oldVersion < 3) {
          // Favorite Medicines Table
          await db.execute('''
            CREATE TABLE IF NOT EXISTS favorite_medicines (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              medicineId INTEGER,
              name TEXT,
              genericName TEXT,
              dosageForm TEXT,
              strength TEXT,
              createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
          ''');

          // Common Diagnosis Table
          await db.execute('''
            CREATE TABLE IF NOT EXISTS common_diagnosis (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT UNIQUE,
              usageCount INTEGER DEFAULT 1,
              lastUsed TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
          ''');
        }
        if (oldVersion < 4) {
          // Add missing columns to prescriptions table if they don't exist
          final List<String> columnsToAdd = [
            'chiefComplaints', 'diagnosis', 'vitalSigns', 'pastHistory', 
            'medicines', 'advice', 'nextVisit', 'labTests'
          ];
          
          for (var column in columnsToAdd) {
            try {
              await db.execute('ALTER TABLE prescriptions ADD COLUMN $column TEXT');
            } catch (e) {
              // Column might already exist
              print('Error adding column $column: $e');
            }
          }
        }
        if (oldVersion < 5) {
          try {
            await db.execute('ALTER TABLE doctors ADD COLUMN signaturePath TEXT');
            await db.execute('ALTER TABLE doctors ADD COLUMN clinicLogoPath TEXT');
          } catch (e) {
            print('Error adding signature/logo columns: $e');
          }
        }
        if (oldVersion < 6) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS common_advice (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT UNIQUE,
              usageCount INTEGER DEFAULT 1,
              lastUsed TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS common_lab_tests (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT UNIQUE,
              usageCount INTEGER DEFAULT 1,
              lastUsed TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS common_complaints (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT UNIQUE,
              usageCount INTEGER DEFAULT 1,
              lastUsed TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS common_past_history (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT UNIQUE,
              usageCount INTEGER DEFAULT 1,
              lastUsed TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
          ''');
        }
        if (oldVersion < 7) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS common_vital_signs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT UNIQUE,
              usageCount INTEGER DEFAULT 1,
              lastUsed TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
          ''');
        }
        if (oldVersion < 8) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS user_vitals (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              type TEXT NOT NULL,
              value1 REAL NOT NULL,
              value2 REAL,
              unit TEXT NOT NULL,
              category TEXT,
              notes TEXT,
              recordedAt TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 9) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS medicine_reminders (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              medicineName TEXT NOT NULL,
              dosageForm TEXT,
              dosageStrength TEXT,
              instructions TEXT,
              morning INTEGER DEFAULT 0,
              noon INTEGER DEFAULT 0,
              night INTEGER DEFAULT 0,
              morningTime TEXT DEFAULT '08:00',
              noonTime TEXT DEFAULT '13:00',
              nightTime TEXT DEFAULT '20:00',
              startDate TEXT NOT NULL,
              durationDays INTEGER DEFAULT 0,
              isActive INTEGER DEFAULT 1,
              createdAt TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS medicine_adherence_logs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              reminderId INTEGER NOT NULL,
              date TEXT NOT NULL,
              slot TEXT NOT NULL,
              isTaken INTEGER DEFAULT 1,
              takenAt TEXT NOT NULL,
              UNIQUE(reminderId, date, slot)
            )
          ''');
        }
        if (oldVersion < 10) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS health_habits (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              category TEXT NOT NULL,
              icon TEXT DEFAULT 'check_circle',
              color TEXT DEFAULT '#00897B',
              reminderTime TEXT,
              isActive INTEGER DEFAULT 1,
              createdAt TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS habit_logs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              habitId INTEGER NOT NULL,
              date TEXT NOT NULL,
              completed INTEGER DEFAULT 1,
              completedAt TEXT NOT NULL,
              UNIQUE(habitId, date)
            )
          ''');
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
        signaturePath TEXT,
        clinicLogoPath TEXT,
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
        chiefComplaints TEXT,
        diagnosis TEXT,
        vitalSigns TEXT,
        pastHistory TEXT,
        medicines TEXT,
        advice TEXT,
        nextVisit TEXT,
        labTests TEXT,
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

    // Favorite Medicines Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorite_medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicineId INTEGER,
        name TEXT,
        genericName TEXT,
        dosageForm TEXT,
        strength TEXT,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Common Diagnosis Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS common_diagnosis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        usageCount INTEGER DEFAULT 1,
        lastUsed TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Common Advice Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS common_advice (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        usageCount INTEGER DEFAULT 1,
        lastUsed TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Common Lab Tests Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS common_lab_tests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        usageCount INTEGER DEFAULT 1,
        lastUsed TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Common Complaints Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS common_complaints (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        usageCount INTEGER DEFAULT 1,
        lastUsed TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Common Past History Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS common_past_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        usageCount INTEGER DEFAULT 1,
        lastUsed TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Common Vital Signs Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS common_vital_signs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        usageCount INTEGER DEFAULT 1,
        lastUsed TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // User Vitals Log Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_vitals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        value1 REAL NOT NULL,
        value2 REAL,
        unit TEXT NOT NULL,
        category TEXT,
        notes TEXT,
        recordedAt TEXT NOT NULL
      )
    ''');

    // Medicine Reminders Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medicine_reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicineName TEXT NOT NULL,
        dosageForm TEXT,
        dosageStrength TEXT,
        instructions TEXT,
        morning INTEGER DEFAULT 0,
        noon INTEGER DEFAULT 0,
        night INTEGER DEFAULT 0,
        morningTime TEXT DEFAULT '08:00',
        noonTime TEXT DEFAULT '13:00',
        nightTime TEXT DEFAULT '20:00',
        startDate TEXT NOT NULL,
        durationDays INTEGER DEFAULT 0,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');

    // Medicine Adherence Logs Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medicine_adherence_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reminderId INTEGER NOT NULL,
        date TEXT NOT NULL,
        slot TEXT NOT NULL,
        isTaken INTEGER DEFAULT 1,
        takenAt TEXT NOT NULL,
        UNIQUE(reminderId, date, slot)
      )
    ''');

    // Daily Health Habits Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS health_habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        icon TEXT DEFAULT 'check_circle',
        color TEXT DEFAULT '#00897B',
        reminderTime TEXT,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');

    // Daily Health Habit Completion Logs Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS habit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId INTEGER NOT NULL,
        date TEXT NOT NULL,
        completed INTEGER DEFAULT 1,
        completedAt TEXT NOT NULL,
        UNIQUE(habitId, date)
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
