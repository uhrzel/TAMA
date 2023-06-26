import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import '../sql_helpers/DatabaseHelper.dart';

Future<void> exportToExcel(BuildContext context) async {
  try {
    // Check for storage permission, and request if not granted
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Storage permission is denied')));
        return;
      }
    }

    // Retrieve data from the database
    var students = await RegistrationSQLHelper.getStudents();

    // Create a new Excel package
    var excel = Excel.createExcel();

    // Create a new sheet
    var sheet = excel['Student List'];

    // Insert the headers in the first row
    var headers = [
      'ID',
      'First Name',
      'Last Name',
      'Semester',
      'Class',
      'Courses',
      'School Year',
      'late'
    ];
    sheet.appendRow(headers);

    // Insert data in the rows
    for (var student in students) {
      List<dynamic> row = [
        student['id'],
        student['first_name'],
        student['last_name'],
        student['semester'],
        student['class'],
        student['courses'],
        student['school_year'],
        student['late'],
      ];
      sheet.appendRow(row);
    }

    // Save the Excel file to external storage
    Directory? externalDir = await getExternalStorageDirectory()!;
    String filePath = '${externalDir?.path}/data.xlsx';
    excel.encode().then((onValue) {
      File file = File(filePath);
      file.createSync(recursive: true);
      file.writeAsBytesSync(onValue);

      // Show a Snackbar instead of printing to console
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Excel file successfully created at $filePath')));
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while exporting to Excel: $e')));
  }
}
