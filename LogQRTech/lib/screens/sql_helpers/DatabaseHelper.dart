//ignore: file_names
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:intl/intl.dart';

class RegistrationSQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS registration(
        regid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
               email TEXT, 
        firstname TEXT,
        lastname TEXT,
        username TEXT,
        address TEXT,
        subject TEXT,
        password TEXT,
        status TEXT DEFAULT 'not verified',
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
    await database.execute("""CREATE TABLE IF NOT EXISTS subject_details(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    subject TEXT,
    start_time TEXT,
    end_time TEXT,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
  )
  """);
    await database.execute("""
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      qrCode TEXT,
      fullName TEXT,
      picture TEXT,
      courses TEXT,
      class TEXT,
      school_year TEXT,
      late INTEGER DEFAULT 0, -- Add the 'late' column
      subject_id INTEGER,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (subject_id) REFERENCES subject_details(id)
    )
  """);

    await database.execute("""CREATE TABLE IF NOT EXISTS entrylogs(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        user_id INTEGER,
        entrydate TEXT NULL,
        entrytime TEXT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
      """);

    await database.execute("""CREATE TABLE IF NOT EXISTS exitlogs(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        user_id INTEGER,
        exitdate TEXT NULL,
        exittime TEXT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
      """);
  }

  static Future<List<Map<String, dynamic>>> fetchSubjectDetails() async {
    try {
      final db = await RegistrationSQLHelper.db();
      final List<Map<String, dynamic>> subjectDetailsList =
          await db.query('subject_details');
      return subjectDetailsList;
    } catch (e) {
      print('Error fetching subject details: $e');
      return [];
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

  // ... Rest of your methods (createItem, insertEntry, insertExit, getItems, getEntryLogs, getExitLogs, getItem, updateItem, deleteItem, getQRDetails, insertRegistration, getRegistrations)
  static Future<int> createItem(
    String qr,
    String? fullname,
    String? imageString,
    String? course,
    String? className,
    String? schoolYear,
    String? subjectName, // Pass the subject name here
    int late,
  ) async {
    final db = await RegistrationSQLHelper.db();

    int? subjectId;
    if (subjectName != null) {
      List<Map<String, dynamic>> subjectDetails = await db.query(
          'subject_details',
          where: 'subject = ?',
          whereArgs: [subjectName]);
      if (subjectDetails.isNotEmpty) {
        subjectId = subjectDetails.first['id'];
      }
    }

    final data = {
      'qrCode': qr,
      'fullName': fullname,
      'picture': imageString,
      'courses': course,
      'class': className,
      'school_year': schoolYear,
      'subject_id': subjectId, // Set the subject_id here
      'late': late,
    };

    final id = await db.insert(
      'users',
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      return await getItems();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  static Future<int> insertEntry(
      int? userId, String? entry_date, String? entry_time) async {
    final db = await RegistrationSQLHelper.db();
    final data = {
      'user_id': userId,
      'entrydate': entry_date,
      'entrytime': entry_time,
    };
    final id = await db.insert('entrylogs', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> insertExit(
      int userId, String? exit_date, String? exit_time) async {
    final db = await RegistrationSQLHelper.db();
    final user = await db.query('users', where: 'id = ?', whereArgs: [userId]);

    if (user.isNotEmpty) {
      final data = {
        'user_id': userId,
        'exitdate': exit_date,
        'exittime': exit_time,
      };

      try {
        final id = await db.insert('exitlogs', data,
            conflictAlgorithm: sql.ConflictAlgorithm.replace);
        return id;
      } catch (e) {
        print('Error inserting into exitlogs: $e');
        return -1; // Return -1 or handle appropriately
      }
    } else {
      print('User with id $userId does not exist');
      return -1; // Return -1 or handle appropriately
    }
  }

  static Future<int> insertSubjectDetail(
      String? subject, String? startTime, String? endTime) async {
    final db = await RegistrationSQLHelper.db();
    final data = {
      'subject': subject,
      'start_time': startTime,
      'end_time': endTime,
    };
    final id = await db.insert('subject_details', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await RegistrationSQLHelper.db();
    return db.query('users',
        columns: [
          'id',
          'qrCode',
          'fullName',
          'picture',
          'courses',
          'class',
          'school_year',
          'late',
          'subject_id'
        ],
        orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getEnLogs() async {
    final db = await RegistrationSQLHelper.db();
    return db.rawQuery('''
    SELECT entrylogs.id, entrylogs.entrydate, entrylogs.entrytime, users.picture, users.fullName
    FROM entrylogs
    LEFT JOIN users ON entrylogs.user_id = users.id
    ORDER BY entrylogs.createdAt DESC
  ''');
  }

  static Future<List<Map<String, dynamic>>> getExLogs() async {
    final db = await RegistrationSQLHelper.db();
    return db.rawQuery('''
    SELECT exitlogs.id, exitlogs.exitdate, exitlogs.exittime, users.picture, users.fullName
    FROM exitlogs
    LEFT JOIN users ON exitlogs.user_id = users.id
    ORDER BY exitlogs.createdAt DESC
  ''');
  }

  static Future<List<Map<String, dynamic>>> getEntryLogs() async {
    final db = await RegistrationSQLHelper.db();
    return db.query('entrylogs',
        columns: ['id', 'user_id', 'entrydate', 'entrytime'],
        orderBy: 'createdAt DESC');
  }

  static Future<List<Map<String, dynamic>>> getExitLogs() async {
    final db = await RegistrationSQLHelper.db();
    return db.query('exitlogs',
        columns: ['id', 'user_id', 'exitdate', 'exittime'],
        orderBy: 'createdAt DESC');
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await RegistrationSQLHelper.db();
    return db.query('users', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(Map<String, dynamic> item) async {
    final db = await RegistrationSQLHelper.db();
    return await db
        .update('users', item, where: 'id = ?', whereArgs: [item['id']]);
  }

  static Future<void> deleteItem(int id) async {
    final db = await RegistrationSQLHelper.db();
    try {
      await db.delete("users", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting a user: $err");
    }
  }

  static Future<int> updateSubjectDetail(
      int id, String? subject, String? startTime, String? endTime) async {
    final db = await RegistrationSQLHelper.db();
    final updatedItem = {
      'id': id,
      'subject': subject,
      'start_time': startTime,
      'end_time': endTime,
    };
    return await db.update('subject_details', updatedItem,
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteSubjectDetail(int id) async {
    final db = await RegistrationSQLHelper.db();
    try {
      await db.delete("subject_details", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting a subject detail: $err");
    }
  }

  static Future<List<Map<String, dynamic>>> getQRDetails(String? qr) async {
    final db = await RegistrationSQLHelper.db();
    return db.query('users', where: "qrCode = ?", whereArgs: [qr], limit: 1);
  }

  static Future<int> updateRegistrationStatus(
      int registrationId, String status) async {
    final db = await RegistrationSQLHelper.db();
    final updatedItem = {
      'regid': registrationId,
      'status': status,
    };
    return await db.update('registration', updatedItem,
        where: 'regid = ?', whereArgs: [registrationId]);
  }

  static Future<int> insertRegistration(
    String? email,
    String? firstName,
    String? lastName,
    String? username,
    String? address,
    String? subject,
    String? password,
  ) async {
    final db = await RegistrationSQLHelper.db();
    final data = {
      'email': email,
      'firstname': firstName,
      'lastname': lastName,
      'username': username,
      'address': address,
      'subject': subject,
      'password': password,
      'status': 'not verified', // Add the status here
    };
    final id = await db.insert('registration', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getRegistrations() async {
    final db = await RegistrationSQLHelper.db();
    return db.query('registration', orderBy: "regid");
  }

  static Future<List<Map<String, dynamic>>> getSubjectDetails() async {
    final db = await RegistrationSQLHelper.db();
    return db.query('subject_details');
  }

  static Future<List<String>> fetchStartTimesWithUsers() async {
    try {
      final db = await RegistrationSQLHelper.db();
      final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT subject_details.start_time, users.fullName
FROM subject_details
LEFT JOIN users ON subject_details.id = users.subject_id

    ''');

      print('Result: $result'); // Print the result

      final startTimes = result
          .map((row) => '${row['start_time']} (${row['fullName']})')
          .toList();

      print('Start Times: $startTimes'); // Print the start times

      return startTimes;
    } catch (e) {
      print('Error fetching start times with users: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>>
      fetchUsersWithSubjectDetails() async {
    try {
      final db = await RegistrationSQLHelper.db();
      final List<Map<String, dynamic>> result = await db.rawQuery('''
        SELECT users.*, subject_details.subject, subject_details.start_time, subject_details.end_time
        FROM users
        LEFT JOIN subject_details ON users.subject_id = subject_details.id
      ''');
      print(result); // Debugging line to print the result
      return result;
    } catch (e) {
      print('Error fetching users with subject details: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getUsersByDateRange(
      DateTime fromDate, DateTime toDate) async {
    final db = await RegistrationSQLHelper.db();

    final startDate = DateFormat('yyyy-MM-dd').format(fromDate);
    final endDate = DateFormat('yyyy-MM-dd').format(toDate);

    return db.rawQuery('''
    SELECT id, qrCode, fullName, courses, school_year,class, late
    FROM users
    WHERE createdAt BETWEEN ? AND ?
  ''', [startDate, endDate]);
  }

  static Future<bool> checkUserExists(
    String firstName,
    String lastName,
    String username,
  ) async {
    final db = await RegistrationSQLHelper.db();

    final result = await db.query(
      'registration',
      where: 'firstName = ? AND lastName = ? OR username = ?',
      whereArgs: [firstName, lastName, username],
    );
    return result.isNotEmpty;
  }
}
