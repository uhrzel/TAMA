import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_id_system/screens/sql_helpers/DatabaseHelper.dart';

class ExitLogsReportScreen extends StatefulWidget {
  final String? imgString; // Declare the imgString parameter

  ExitLogsReportScreen({this.imgString});
  @override
  _ExitLogsReportScreenState createState() => _ExitLogsReportScreenState();
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exit Logs Report',
      home: ExitLogsReportScreen(),
    );
  }
}

class _ExitLogsReportScreenState extends State<ExitLogsReportScreen> {
  List<Map<String, dynamic>> exitLogs = [];

  @override
  void initState() {
    super.initState();
    fetchExitLogs();
  }

  Future<void> fetchExitLogs() async {
    List<Map<String, dynamic>> logs = await RegistrationSQLHelper.getExitLogs();
    setState(() {
      exitLogs = logs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exit Logs Report'),
      ),
      body: ListView.builder(
        itemCount: exitLogs.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> log = exitLogs[index];
          Uint8List? _bytesImage;
          String? _base64String = log['picture'];
          if (_base64String != null) {
            _bytesImage = Base64Decoder().convert(_base64String);
          }
          return ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  _bytesImage != null ? MemoryImage(_bytesImage) : null,
            ),
            title: Text(log['fullname'] ?? 'Unknown'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${log['exitdate']}'),
                Text('Time: ${log['exittime']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
