import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_id_system/screens/sql_helpers/DatabaseHelper.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Map<String, dynamic>> entryLogs = [];

  @override
  void initState() {
    super.initState();
    fetchEntryLogs();
  }

  Future<void> fetchEntryLogs() async {
    List<Map<String, dynamic>> logs =
        await RegistrationSQLHelper.getEntryLogs();
    setState(() {
      entryLogs = logs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entry Logs Report'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: entryLogs.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> log = entryLogs[index];
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
                Text('Date: ${log['entrydate']}'),
                Text('Time: ${log['entrytime']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
