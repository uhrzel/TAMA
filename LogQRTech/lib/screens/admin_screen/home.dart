// ignore_for_file: unnecessary_import, import_of_legacy_library_into_null_safe, unused_import, use_key_in_widget_constructors, non_constant_identifier_names, prefer_typing_uninitialized_variables, unused_field, prefer_is_empty, unnecessary_new, prefer_const_constructors, sized_box_for_whitespace

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:qr_id_system/main.dart';
import 'package:qr_id_system/screens/admin_screen/database_setup.dart';
import 'package:qr_id_system/screens/admin_screen/entry_logs.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:qr_id_system/screens/admin_screen/registered_users.dart';
import 'package:qr_id_system/screens/sql_helpers/DatabaseHelper.dart';
import 'package:qr_id_system/screens/admin_screen/profile.dart';

class QRScannerAdmin extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Given Title
      title: 'TAMA QRCode Scanner',
      debugShowCheckedModeBanner: false,
      //Given Theme Color
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      //Declared first page of our app
      home: QRHomeAdmin(),
    );
  }
}

class QRHomeAdmin extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<QRHomeAdmin> {
  var new_qrRegistration;
  //Create List Variable
  List<Map<String, dynamic>> _qr_details = [];
  bool _isLoading = true;
  //create fetch function

  void _getQRDetails(BuildContext context) async {
    final data = await RegistrationSQLHelper.getQRDetails(new_qrRegistration);
    setState(() {
      _qr_details = data;

      _isLoading = false;

      if (_qr_details.length == 0) {
        FlutterBeep.beep(false);
        displayDetailsEmpty();
      } else {
        FlutterBeep.beep();
        displayDetails();
      }
    });
  }

  String? fullname;
  String? qrcode;
  String? courses;

  void _insertEntryLogs(BuildContext context) async {
    final now = new DateTime.now();
    String entry_date = DateFormat.yMMMMd('en_US').format(now);
    String entry_time = DateFormat.jm().format(now);

    // Retrieve the user id that corresponds to the qrcode
    int? userId = await _getUserIdFromQRCode(qrcode);

    // Check if userId is not null
    if (userId != null) {
      await RegistrationSQLHelper.insertEntry(userId, entry_date, entry_time);

      Navigator.of(context).pop();

      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Entrance Data successfully Log',
              style: TextStyle(fontSize: 20.0),
            ),
            backgroundColor: Colors.teal));
      });
    } else {
      // Handle the case where the user is not found in the database
      print('User not found');
    }
  }

  Future<int?> _getUserIdFromQRCode(String? qrcode) async {
    if (qrcode == null) return null;
    final db = await RegistrationSQLHelper.db();
    List<Map<String, dynamic>> result = await db.query('users',
        where: "qrCode = ?", whereArgs: [qrcode], limit: 1);
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }
    return null;
  }

  void _insertExitLogs(BuildContext context, int userId) async {
    final now = DateTime.now();
    String exit_date = DateFormat.yMMMMd('en_US').format(now);
    String exit_time = DateFormat.jm().format(now);

    int id =
        await RegistrationSQLHelper.insertExit(userId, exit_date, exit_time);

    // Check if id is not -1 (which is returned in case of an error)
    if (id != -1) {
      Navigator.of(context).pop();

      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Exit Data successfully Log',
              style: TextStyle(fontSize: 20.0),
            ),
            backgroundColor: Colors.teal));
      });
    } else {
      // handle error, maybe show a message that insertion failed
    }
  }

  void displayDetails() {
    final qrdetails = _qr_details
        .firstWhere((element) => element['qrCode'] == new_qrRegistration);
    qrcode = qrdetails['qrCode'];
    fullname = qrdetails['fullName'];
    courses = qrdetails['courses'];
    Uint8List _bytesImage;
    String _imgString = qrdetails['picture'];
    _bytesImage = Base64Decoder().convert(_imgString);

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.965,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(
                      height: 16.0,
                    ),
                    Container(
                      width: 300.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: Center(
                        child: CircleAvatar(
                          backgroundColor: Colors.teal,
                          radius: 152.0,
                          child: CircleAvatar(
                            child: ClipOval(
                                child: new Image.memory(
                              _bytesImage,
                              width: 280.0,
                              fit: BoxFit.cover,
                            )),
                            backgroundColor: Colors.white.withOpacity(0.1),
                            radius: 140.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 2,
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
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 16.0,
                            ),
                            Center(
                              child: Text(
                                'QR Code Identification Details',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.teal),
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Divider(
                              color: Colors.teal,
                              thickness: 2.0,
                            ),
                            SizedBox(
                              height: 18.0,
                            ),
                            Center(
                              child: Text(
                                fullname!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 38.0,
                                    color: Colors.teal),
                              ),
                            ),
                            Center(
                              child: Text(
                                "Student",
                                style: TextStyle(
                                    fontSize: 19.0, color: Colors.teal),
                              ),
                            ),
                            SizedBox(
                              height: 18.0,
                            ),
                            Center(
                              child: Text(
                                qrcode!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32.0,
                                    color: Colors.teal),
                              ),
                            ),
                            Center(
                              child: Text(
                                'ID Number',
                                style: TextStyle(
                                    fontSize: 19.0, color: Colors.teal),
                              ),
                            ),
                            SizedBox(
                              height: 18.0,
                            ),
                            Center(
                              child: Text(
                                courses.toString().toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32.0,
                                    color: Colors.teal),
                              ),
                            ),
                            Center(
                              child: Text(
                                'Course',
                                style: TextStyle(
                                    fontSize: 19.0, color: Colors.teal),
                              ),
                            ),
                            SizedBox(
                              height: 30.0,
                            ),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        _insertEntryLogs(context);
                                      },
                                      child: const Text(
                                        'RECORD ENTRY',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 18),
                                      ),
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(
                                              Colors.teal),
                                          padding: MaterialStateProperty.all<EdgeInsets>(
                                              const EdgeInsets.all(12)),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  side: const BorderSide(
                                                      color: Colors.black54)))),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        int userId = _qr_details[0][
                                            'id']; // Replace 'id' with the correct key for the user ID
                                        _insertExitLogs(context, userId);
                                      },
                                      child: const Text(
                                        'RECORD EXIT    ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 18),
                                      ),
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(
                                              Colors.red),
                                          padding: MaterialStateProperty.all<EdgeInsets>(
                                              const EdgeInsets.all(12)),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  side: const BorderSide(
                                                      color: Colors.black54)))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              color: Colors.teal,
                              thickness: 1.0,
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Center(
                              child: Text(
                                '© College of Information and Communication Technology',
                                style: TextStyle(color: Colors.teal),
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  void displayDetailsEmpty() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white,
          child: ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: 16.0),
                    Center(
                      child: Image.asset(
                        'images/warn.gif',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Center(
                      child: Text(
                        'Unregistered QR Code',
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: Text(
                        'This entry will be logged. Please register the student using the registration.',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _registerLate(int late) async {
    final db = await RegistrationSQLHelper.db();
    final updatedItem = {
      'late': late,
    };
    await db.update('users', updatedItem,
        where: 'qrCode = ?', whereArgs: [new_qrRegistration]);
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            title: Text(
              'TAMA QR CODE SCANNER',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Container(
            margin: EdgeInsets.all(20.0),
            width: 500,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'Please tap the image below to scan:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(360.0)),
                    onTap: () async {
                      final subjectDetailsList =
                          await RegistrationSQLHelper.getSubjectDetails();
                      if (subjectDetailsList.isNotEmpty) {
                        final subjectDetails = subjectDetailsList.first;
                        final startTimeString =
                            subjectDetails['start_time'] as String;
                        final dateFormat = DateFormat('hh:mm a');
                        final startTime = dateFormat.parse(startTimeString);

                        int lateValue;

                        if (DateTime.now().isBefore(startTime)) {
                          // Scanning allowed before start time
                          lateValue = 0;
                        } else {
                          // Scanning allowed after start time (late)
                          lateValue = 1;
                        }

                        String codeScannerReg =
                            await FlutterBarcodeScanner.scanBarcode(
                          '#ff6666',
                          'cancel',
                          true,
                          ScanMode.QR,
                        );

                        setState(() {
                          new_qrRegistration = codeScannerReg;
                          if (new_qrRegistration.isEmpty) {
                            // QR code scan was canceled
                          } else if (new_qrRegistration == _qr_details) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Student already registered',
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                backgroundColor: Colors.teal,
                              ),
                            );
                          } else {
                            new_qrRegistration = codeScannerReg;
                            _getQRDetails(context);
                            _registerLate(lateValue);

                            if (lateValue == 1) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'You are late!',
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'No subject details found.',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Center(
                      child: CircleAvatar(
                        radius: 204,
                        backgroundColor: Colors.teal[200],
                        child: CircleAvatar(
                          radius: 130.0,
                          backgroundImage:
                              AssetImage('images/scansahomepage.gif'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            enableFeedback: true,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: InkWell(
                  onTap: () async {},
                  child: Icon(
                    Icons.qr_code_outlined,
                    size: 32.0,
                    color: Colors.black54,
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
                    Icons.list_alt_rounded,
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
                    color: Colors.teal,
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
        ),
      ),
    );
  }
}
