import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'dart:convert';
import 'dart:typed_data';
import 'package:qr_id_system/screens/sql_helpers/DatabaseHelper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StudentListPage(),
    );
  }
}

class StudentListPage extends StatefulWidget {
  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  List<Map<String, dynamic>> students = [];
  List<String> startTimes = [];

  @override
  void initState() {
    super.initState();
    fetchStudents();
    fetchStartTimes();
  }

  Future<void> fetchStudents() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(path.join(dbPath, 'db.db'));

    final List<Map<String, dynamic>> studentList = await db.rawQuery('''
    SELECT users.*, subject_details.subject, subject_details.start_time, subject_details.end_time 
    FROM users
    LEFT JOIN subject_details ON users.subject_id = subject_details.id
  ''');

    print('Raw student data: $studentList'); // print the raw data

    setState(() {
      students = studentList;
    });
  }

  Future<void> fetchStartTimes() async {
    final startTimesList =
        await RegistrationSQLHelper.fetchStartTimesWithUsers();
    print('Start Times List: $startTimesList'); // Add this line
    setState(() {
      startTimes = startTimesList;
    });
  }

  String? getStartTimeByIndex(int index) {
    if (index >= 0 && index < startTimes.length) {
      return startTimes[index];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student List'),
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (ctx, index) {
          final student = students[index];

          // Decode base64 string to Uint8List
          Uint8List bytesImage = base64Decode(student['picture']);

          return Card(
            color: Colors.tealAccent[700],
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: MemoryImage(bytesImage),
                    radius: 30,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Full Name: ${student['fullName']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('QR Code: ${student['qrCode']}'),
                          SizedBox(height: 4),
                          Text('Courses: ${student['courses']}'),
                          SizedBox(height: 4),
                          Text('Semester: ${student['class']}'),
                          SizedBox(height: 4),
                          Text('School Year: ${student['school_year']}'),
                          SizedBox(height: 4),
                          Text('Late: ${student['late'] == 1 ? 'Yes' : 'No'}'),
                          SizedBox(height: 4),
                        ]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
