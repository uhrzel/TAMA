import 'package:flutter/material.dart';

import 'package:qr_id_system/screens/admin_screen/report_entry.dart';
import 'package:qr_id_system/screens/admin_screen/report_exit.dart';
import 'package:qr_id_system/screens/admin_screen/semestral_report.dart'; // Import the Semestral Report Screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Logs Report',
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Logs Report'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportScreen()),
                    );
                  },
                  child: Text('View Entry Logs Report'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ExitLogsReportScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red, // Set the button background color to red
                  ),
                  child: Text('View Exit Logs Report'),
                ),
              ],
            ),
            SizedBox(height: 16.0), // Add spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SemestralReportScreen()), // Navigate to Semestral Report Screen
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blue, // Set the button background color to blue
              ),
              child: Text('View Semestral Report'),
            ),
            // Add more options/buttons for other dashboard functionalities
          ],
        ),
      ),
    );
  }
}
