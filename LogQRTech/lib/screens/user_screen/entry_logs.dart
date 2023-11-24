// ignore_for_file: unused_import, import_of_legacy_library_into_null_safe, use_key_in_widget_constructors, non_constant_identifier_names, unnecessary_new, prefer_const_constructors, prefer_is_empty, avoid_print, empty_statements, annotate_overrides, duplicate_ignore

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_id_system/screens/sql_helpers/DatabaseHelper.dart';
import 'package:qr_id_system/screens/user_screen/home.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class EntryLogsUser extends StatelessWidget {
  // This widget is the root
  // of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Entry Logs',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  bool _isLoadingExit = true;
  List<Map<String, dynamic>> _usersExit = [];

  void _refreshJournals() async {
    final data = await RegistrationSQLHelper.getEntryLogs();
    setState(() {
      _users = data;
      _isLoading = false;
    });
  }

  void _refreshJournalsExit() async {
    final data = await RegistrationSQLHelper.getExitLogs();
    setState(() {
      _usersExit = data;
      _isLoadingExit = false;
    });
  }

  void backup_local(BuildContext context) async {
    final now = new DateTime.now();
    String backup_date = DateFormat.yMMMMd('en_US').format(now);
    String backup_time = DateFormat.jm().format(now);

    final dbFolder = await getDatabasesPath();
    File source1 = File('$dbFolder/db.db');

    Directory copyTo = Directory(
        "storage/emulated/0/backup/${backup_date + " " + backup_time}");
    if ((await copyTo.exists())) {
      // print("Path exist");
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    } else {
      if (await Permission.storage.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
        await copyTo.create();
      } else {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                'Unable to get permission!',
                style: TextStyle(fontSize: 20.0),
              ),
              backgroundColor: Colors.red));
        });
      }
    }

    String newPath = "${copyTo.path}/db.db";

    if (newPath.length == 0) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'No Data to Backup!',
              style: TextStyle(fontSize: 20.0),
            ),
            backgroundColor: Colors.red));
      });
    } else {
      await source1.copy(newPath);
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Database exported successfully to db Backup/${backup_date + " " + backup_time}',
              style: TextStyle(fontSize: 20.0),
            ),
            backgroundColor: Colors.cyan));
      });
    }
  }

  List<String> attachments = [];
  bool isHTML = false;
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
        'marc.bucayu@gmail.comm',
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
    ;
    ;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.teal,
        content: Text(platformResponse),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
    _refreshJournalsExit();
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            centerTitle: true,
            title: ListTile(
              title: Center(
                child: Text(
                  'STUDENTS LOGBOOK',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              leading: InkWell(
                onTap: () {
                  backup_local(context);
                },
                child: Icon(
                  Icons.update,
                  color: Colors.white,
                ),
              ),
              trailing: InkWell(
                onTap: () {
                  send(context);
                },
                child: Icon(
                  Icons.backup_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            // ignore: prefer_const_constructors
            bottom: TabBar(
              indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 2.0, color: Colors.black38),
                  insets: EdgeInsets.symmetric(horizontal: 16.0)),
              tabs: const <Widget>[
                // ignore: prefer_const_constructors
                Tab(
                    icon: Icon(
                      Icons.list_alt_outlined,
                      color: Colors.lightBlueAccent,
                    ),
                    child: Text(
                      'ENTRANCE',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
                Tab(
                  icon: Icon(
                    Icons.list_alt_outlined,
                    color: Colors.red,
                  ),
                  child: Text(
                    'EXIT',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            )),
        body: TabBarView(children: <Widget>[
          Scaffold(
            body: _isLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                      SizedBox(
                        height: 18.0,
                      ),
                      Center(
                        child: Text('No data found!'),
                      )
                    ],
                  )
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      Uint8List _bytesImage;
                      String _imgString = _users[index]['picture'];
                      _bytesImage = Base64Decoder().convert(_imgString);

                      return Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
                          width: 500,
                          height: MediaQuery.of(context).size.height / 11,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                            color: Colors.blue,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.black,
                                radius: 34.0,
                                child: CircleAvatar(
                                  radius: 26.0,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.1),
                                  child: ClipOval(
                                      child: new Image.memory(
                                    _bytesImage,
                                    height: 100.0,
                                    width: 100.0,
                                    fit: BoxFit.cover,
                                  )),
                                ),
                              ),
                              title: Text(
                                _users[index]['fullname'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colors.white),
                              ),
                              subtitle: Text(
                                _users[index]['entrydate'],
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                              ),
                              trailing: SizedBox(
                                width: 100,
                                child: Row(
                                  children: [
                                    Text(
                                      _users[index]['entrytime'],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18.0),
                                    )
                                  ],
                                ),
                              )),
                        ),
                      );
                    },
                  ),
          ),
          Scaffold(
            body: _isLoadingExit
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                      SizedBox(
                        height: 18.0,
                      ),
                      Center(
                        child: Text('No data found!'),
                      )
                    ],
                  )
                : ListView.builder(
                    itemCount: _usersExit.length,
                    itemBuilder: (context, index1) {
                      Uint8List _bytesImage;
                      String _imgString = _usersExit[index1]['picture'];
                      _bytesImage = Base64Decoder().convert(_imgString);

                      return Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Container(
                          width: 500,
                          height: MediaQuery.of(context).size.height / 11,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                            color: Colors.red,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.black,
                                radius: 34.0,
                                child: CircleAvatar(
                                  radius: 26.0,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.1),
                                  child: ClipOval(
                                      child: new Image.memory(
                                    _bytesImage,
                                    height: 100.0,
                                    width: 100.0,
                                    fit: BoxFit.cover,
                                  )),
                                ),
                              ),
                              title: Text(
                                _usersExit[index1]['fullname'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colors.white),
                              ),
                              subtitle: Text(
                                _usersExit[index1]['exitdate'],
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                              ),
                              trailing: SizedBox(
                                width: 100,
                                child: Row(
                                  children: [
                                    Text(
                                      _usersExit[index1]['exittime'],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    )
                                  ],
                                ),
                              )),
                        ),
                      );
                    },
                  ),
          ),
        ]),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          enableFeedback: true,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: InkWell(
                onTap: () async {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => QRScannerUser()));
                },
                child: Icon(
                  Icons.home_rounded,
                  size: 32.0,
                  color: Colors.teal,
                ),
              ),
              label: 'Home',
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: InkWell(
                onTap: () async {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => EntryLogsUser()));
                },
                child: Icon(
                  Icons.list_alt,
                  size: 40.0,
                  color: Colors.black54,
                ),
              ),
              label: 'ENTRY LOGS',
              backgroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
