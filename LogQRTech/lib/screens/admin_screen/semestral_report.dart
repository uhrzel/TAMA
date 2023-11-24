import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../sql_helpers/DatabaseHelper.dart';

class SemestralReportScreen extends StatefulWidget {
  const SemestralReportScreen({Key? key}) : super(key: key);

  @override
  _SemestralReportScreenState createState() => _SemestralReportScreenState();
}

class _SemestralReportScreenState extends State<SemestralReportScreen> {
  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  void _showDatePicker(BuildContext context, bool isFromDate) async {
    final currentDate = DateTime.now();
    final initialDate = isFromDate
        ? selectedFromDate ?? currentDate
        : selectedToDate ?? currentDate;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(currentDate.year - 1),
      lastDate: DateTime(currentDate.year + 1),
    );

    if (pickedDate != null) {
      setState(() {
        if (isFromDate) {
          selectedFromDate = pickedDate;
        } else {
          selectedToDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String fromDateText = selectedFromDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedFromDate!)
        : 'Select date from';

    String toDateText = selectedToDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedToDate!)
        : 'Select date to';

    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Semestral Report',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              Text(
                'Selected Date Range:',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showDatePicker(context, true),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        fromDateText,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'to',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(width: 8.0),
                  GestureDetector(
                    onTap: () => _showDatePicker(context, false),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        toDateText,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (selectedFromDate != null && selectedToDate != null) {
                    _performAnalysis(selectedFromDate!, selectedToDate!);
                  } else {
                    // Handle case when dates are not selected
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Date Range Not Selected'),
                          content: Text('Please select a date range.'),
                          actions: [
                            TextButton(
                              child: Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Perform Analysis'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _performAnalysis(
    DateTime selectedFromDate,
    DateTime selectedToDate,
  ) async {
    // Retrieve the users who have createdAt within the selected date range
    final List<Map<String, dynamic>> users =
        await RegistrationSQLHelper.getUsersByDateRange(
      selectedFromDate,
      selectedToDate,
    );
    final List<Map<String, dynamic>> entryLogs =
        await RegistrationSQLHelper.getEnLogs(); // Get entry logs
    final List<Map<String, dynamic>> exitLogs =
        await RegistrationSQLHelper.getExLogs(); // Get exit logs

    // Display the users table
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Students'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Qr Code')),
                DataColumn(label: Text('Full Name')),
                DataColumn(label: Text('Courses')),
                DataColumn(label: Text('Semester')),
                DataColumn(label: Text('School Year')),
                DataColumn(label: Text('Entry Date')),
                DataColumn(label: Text('Entry Time')),
                DataColumn(label: Text('Exit Date')),
                DataColumn(label: Text('Exit Time')),
                DataColumn(label: Text('Late')),
              ],
              rows: [
                for (int i = 0; i < users.length; i++)
                  DataRow(
                    cells: [
                      DataCell(Text(users[i]['id'].toString())),
                      DataCell(Text(users[i]['qrCode'] ?? '')),
                      DataCell(Text(users[i]['fullName'] ?? '')),
                      DataCell(Text(users[i]['courses'] ?? '')),
                      DataCell(Text(users[i]['class'] ?? '')),
                      DataCell(Text(users[i]['school_year'] ?? '')),
                      DataCell(Text(entryLogs[i]['entrydate'] ?? '')),
                      DataCell(Text(entryLogs[i]['entrytime'] ?? '')),
                      DataCell(Text(exitLogs[i]['exitdate'] ?? '')),
                      DataCell(Text(exitLogs[i]['exittime'] ?? '')),
                      DataCell(Text(users[i]['late'].toString())),
                    ],
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
