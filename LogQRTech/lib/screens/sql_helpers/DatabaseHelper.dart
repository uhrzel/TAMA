// ignore: file_names
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class RegistrationSQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS registration(
        regid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        firstname TEXT,
        lastname TEXT,
        username TEXT,
        address TEXT,
        subject TEXT,
        password TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
    await database.execute("""CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        qrCode TEXT,
        fullName TEXT,
        picture TEXT NULL,
        courses TEXT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
    await database.execute("""CREATE TABLE IF NOT EXISTS entrylogs(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        qrCode TEXT NULL,
        fullname TEXT NULL,
        entrydate TEXT NULL,
        entrytime TEXT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
    await database.execute("""CREATE TABLE IF NOT EXISTS exitlogs(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        qrCode TEXT NULL,
        fullname TEXT NULL,
        exitdate TEXT NULL,
        exittime TEXT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
    // Adding student_list table creation
    await database.execute("""CREATE TABLE IF NOT EXISTS student_list(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        first_name TEXT,
        last_name TEXT,
        semester TEXT,
        class TEXT,
        courses TEXT,
        school_year TEXT
      )
      """);
    List<Map> tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='student_list'");
    if (tables.length > 0) {
      // The table exists, just add the new column
      await database.execute(
          "ALTER TABLE student_list ADD COLUMN late INTEGER DEFAULT 0");
    } else {
      // The table doesn't exist, create it with the new column
      await database.execute("""CREATE TABLE IF NOT EXISTS student_list(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            first_name TEXT,
            last_name TEXT,
            semester TEXT,
            class TEXT,
            courses TEXT,
            school_year TEXT,
            late INTEGER DEFAULT 0
        )
        """);
    }
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'db.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<bool> studentExists(String firstName, String lastName) async {
    final db = await RegistrationSQLHelper.db();

    final result = await db.query(
      'student_list',
      where: 'first_name = ? AND last_name = ?',
      whereArgs: [firstName, lastName],
    );

    return result.isNotEmpty;
  }

  // New methods for student_list table

  static Future<bool> insertStudent(
    String firstName,
    String lastName,
    String semester,
    String className,
    String courses,
    String schoolYear,
    int late,
  ) async {
    // Check if student already exists
    if (await studentExists(firstName, lastName)) {
      // Student already exists, do not insert
      return false;
    }

    final db = await RegistrationSQLHelper.db();
    final data = {
      'first_name': firstName,
      'last_name': lastName,
      'semester': semester,
      'class': className,
      'courses': courses,
      'school_year': schoolYear,
      'late': late,
    };
    await db.insert('student_list', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return true;
  }

  static Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await RegistrationSQLHelper.db();
    return db.query('student_list', orderBy: "id");
  }

  static Future<void> deleteStudent(int id) async {
    final db = await RegistrationSQLHelper.db();
    try {
      await db.delete("student_list", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting a student: $err");
    }
  }

  // Existing methods from your original code below

  // ... Rest of your methods (createItem, insertEntry, insertExit, getItems, getEntryLogs, getExitLogs, getItem, updateItem, deleteItem, getQRDetails, insertRegistration, getRegistrations)

  static Future<int> createItem(
      String qr, String? fullname, String? imageString, String? course) async {
    final db = await RegistrationSQLHelper.db();

    final data = {
      'qrCode': qr,
      'fullName': fullname,
      'picture': imageString,
      'courses': course,
    };
    final id = await db.insert('users', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> insertEntry(String? qr, String? fullname,
      String? entry_date, String? entry_time) async {
    final db = await RegistrationSQLHelper.db();
    final data = {
      'qrCode': qr,
      'fullname': fullname,
      'entrydate': entry_date,
      'entrytime': entry_time,
    };
    final id = await db.insert('entrylogs', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> insertExit(String? qr, String? fullname, String? exit_date,
      String? exit_time) async {
    final db = await RegistrationSQLHelper.db();
    final data = {
      'qrCode': qr,
      'fullname': fullname,
      'exitdate': exit_date,
      'exittime': exit_time,
    };
    final id = await db.insert('exitlogs', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await RegistrationSQLHelper.db();
    return db.query('users', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getEntryLogs() async {
    final db = await RegistrationSQLHelper.db();
    return db.rawQuery(
        "SELECT entrylogs.qrCode, entrylogs.fullname, entrylogs.entrydate, entrylogs.entrytime, users.picture FROM entrylogs LEFT JOIN users ON users.qrCode = entrylogs.qrCode ORDER BY entrylogs.createdAt DESC");
  }

  static Future<List<Map<String, dynamic>>> getExitLogs() async {
    final db = await RegistrationSQLHelper.db();
    return db.rawQuery(
        "SELECT exitlogs.qrCode, exitlogs.fullname, exitlogs.exitdate, exitlogs.exittime, users.picture FROM exitlogs LEFT JOIN users ON users.qrCode = exitlogs.qrCode ORDER BY exitlogs.createdAt DESC");
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await RegistrationSQLHelper.db();
    return db.query('users', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(
      int id, String qr, String? fullname, String? course) async {
    final db = await RegistrationSQLHelper.db();

    final data = {
      'qrCode': qr,
      'fullName': fullname,
      'courses': course,
      'createdAt': DateTime.now().toString(),
    };

    final result =
        await db.update('users', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await RegistrationSQLHelper.db();
    try {
      await db.delete("users", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting a user: $err");
    }
  }

  static Future<List<Map<String, dynamic>>> getQRDetails(String? qr) async {
    final db = await RegistrationSQLHelper.db();
    return db.query('users', where: "qrCode = ?", whereArgs: [qr], limit: 1);
  }

  static Future<int> insertRegistration(
    String? firstName,
    String? lastName,
    String? username,
    String? address,
    String? subject,
    String? password,
  ) async {
    final db = await RegistrationSQLHelper.db();
    final data = {
      'firstname': firstName,
      'lastname': lastName,
      'username': username,
      'address': address,
      'subject': subject,
      'password': password,
    };
    final id = await db.insert('registration', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getRegistrations() async {
    final db = await RegistrationSQLHelper.db();
    return db.query('registration', orderBy: "regid");
  }
}
