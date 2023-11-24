// ignore_for_file: import_of_legacy_library_into_null_safe, unused_import, use_key_in_widget_constructors, dead_code, unnecessary_new, non_constant_identifier_names, prefer_const_constructors, avoid_print, prefer_const_literals_to_create_immutables, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:qr_id_system/screens/admin_screen/email_sender.dart';
import 'package:qr_id_system/screens/admin_screen/entry_logs.dart';
import 'package:qr_id_system/screens/admin_screen/export_excell.dart';
import 'package:qr_id_system/screens/admin_screen/home.dart';
import 'package:qr_id_system/screens/admin_screen/profile.dart';
import 'package:qr_id_system/screens/admin_screen/registered_users.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:qr_id_system/screens/admin_screen/timestamps.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_id_system/screens/admin_screen/dashboard_report.dart';
import 'package:qr_id_system/screens/admin_screen/student_list.dart';

class DatabaseScreen extends StatefulWidget {
  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DatabaseHome(),
      theme: ThemeData(primarySwatch: Colors.teal),
    );
    throw UnimplementedError();
  }
}

class DatabaseHome extends StatefulWidget {
  @override
  State<DatabaseHome> createState() => _DatabaseHomeState();
}

class _DatabaseHomeState extends State<DatabaseHome> {
  List<String> attachments = [];
  bool isHTML = false;

  get codeScanner => null;

  Future<void> send(BuildContext context) async {
    final now = new DateTime.now();
    String backup_date = DateFormat.yMMMMd('en_US').format(now);
    String backup_time = DateFormat.jm().format(now);

    try {
      final appDocumentDir = await getDatabasesPath();
      final filePath = appDocumentDir + '/db.db';
      setState(() {
        attachments.clear();
        attachments.add(filePath);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create file in applicion directory'),
        ),
      );
    }
    final Email email = Email(
      body: 'TAMA Backup \n'
          'This is a system generated email.\n\n'
          'Please Secure this in case of need.',
      subject: backup_date + ' ' + backup_time + ' ' + 'Database Backup',
      recipients: [
        'ajmixrhyme@gmail.com',
      ],
      attachmentPaths: attachments,
      isHTML: isHTML,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'Email Backup successfully generated!';
    } catch (error) {
      print(error);
      platformResponse = error.toString();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.teal,
        content: Text(platformResponse),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        title: Center(
          child: Column(
            children: [
              Text(
                'SETTINGS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 12.0,
            ),
            const SizedBox(
              height: 20.0,
            ),
            Center(
                child: CircleAvatar(
              radius: 80.0,
              backgroundImage: AssetImage('images/set1.png'),
              backgroundColor: Colors.teal[200],
            )),
            SizedBox(
              height: 20.0,
            ),
            Container(
              width: 500.0,
              height: MediaQuery.of(context).size.height / 1.0,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 14.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 2,
                          color: Colors.white,
                          child: GridView.count(
                            crossAxisCount: 2,
                            children: <Widget>[
                              InkWell(
                                onTap: () async {
                                  var databasesPath = await getDatabasesPath();
                                  var dbPath = join(databasesPath, 'db.db');

                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles();

                                  if (result != null) {
                                    File source =
                                        File(result.files.single.path!);
                                    await source.copy(dbPath);
                                    setState(() {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                'Database imported successfully',
                                                style:
                                                    TextStyle(fontSize: 20.0),
                                              ),
                                              backgroundColor: Colors.teal));
                                    });
                                  } else {
                                    // User canceled the picker

                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(32.0),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            'images/restoration.png',
                                            height: 60,
                                            width: 60,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                              child: Text(
                                            'Backup\nRestoration',
                                            style: TextStyle(
                                                color: Colors.teal,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  var databasesPath = await getDatabasesPath();
                                  var dbPath = join(databasesPath, 'db.db');
                                  await deleteDatabase(dbPath);
                                  setState(() {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            content: Text(
                                              'Database cleared successfully',
                                              style: TextStyle(fontSize: 20.0),
                                            ),
                                            backgroundColor: Colors.teal));
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(32.0),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            'images/reset.png',
                                            height: 70,
                                            width: 70,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                              child: Text(
                                            'Reset',
                                            style: TextStyle(
                                                color: Colors.teal,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  send(context);
                                  //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>EmailSenderApp()));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(32.0),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            'images/emails1.png',
                                            height: 60,
                                            width: 60,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                              child: Text(
                                            'Create\nBackup',
                                            style: TextStyle(
                                                color: Colors.teal,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // Callback function to navigate to the next dashboard
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            NextDashboardScreen()),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(32.0),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            'images/t.png',
                                            height: 70,
                                            width: 70,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                              child: Text(
                                            'Timestamps',
                                            style: TextStyle(
                                                color: Colors.teal,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // Callback function to navigate to the next dashboard
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DashboardScreen(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(32.0),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            'images/report.png',
                                            height: 70,
                                            width: 70,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                              child: Text(
                                            'Reports',
                                            style: TextStyle(
                                                color: Colors.teal,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // Callback function to navigate to the next dashboard
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentListPage(),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(32.0),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            'images/student.png',
                                            height: 70,
                                            width: 70,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                              child: Text(
                                            'Students',
                                            style: TextStyle(
                                                color: Colors.teal,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      return AlertDialog(
                                        title: Text('Export to Excel'),
                                        content: Text(
                                            'Do you want to continue and export the data to Excel?'),
                                        actions: [
                                          TextButton(
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(dialogContext)
                                                  .pop(); // Close the dialog
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Yes'),
                                            onPressed: () async {
                                              await exportToExcel(context);
                                              Navigator.of(dialogContext)
                                                  .pop(); // Close the dialog
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(32.0),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            'images/excel.png',
                                            height: 70,
                                            width: 70,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                              child: Text(
                                            'Export',
                                            style: TextStyle(
                                                color: Colors.teal,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: Text('Logout Confirmation'),
                                      content: Text(
                                          'Are you sure you want to logout?'),
                                      actions: [
                                        TextButton(
                                          child: Text('No'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                        TextButton(
                                          child: Text('Yes'),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the confirmation dialog
                                            Navigator.of(context)
                                                .pop(); // Navigate back to the login screen
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Logged out successfully!'),
                                            ));
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(32.0),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            'images/logout.png',
                                            height: 70,
                                            width: 70,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Center(
                                            child: Text(
                                              'Logout',
                                              style: TextStyle(
                                                color: Colors.teal,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        enableFeedback: true,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () async {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => QRScannerAdmin()));
              },
              child: Icon(
                Icons.qr_code_outlined,
                size: 32.0,
                color: Colors.teal,
              ),
            ),
            label: 'Scanner',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () async {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => EntryLogs()));
              },
              child: Icon(
                Icons.list_alt,
                size: 32.0,
                color: Colors.teal,
              ),
            ),
            label: 'ENTRY LOGS',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => RegisteredUsers()));
              },
              child: Icon(
                Icons.supervised_user_circle,
                size: 32.0,
                color: Colors.teal,
              ),
            ),
            label: 'USERS',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => DatabaseScreen()));
              },
              child: Icon(
                Icons.settings_outlined,
                size: 32.0,
                color: Colors.black54,
              ),
            ),
            label: 'SETTINGS',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => ProfileScreen()));
              },
              child: Icon(
                Icons.person_outline_rounded,
                size: 32.0,
                color: Colors.teal,
              ),
            ),
            label: 'Profile',
            backgroundColor: Colors.white,
          ),
        ],
      ),
    ));
    throw UnimplementedError();
  }
}
