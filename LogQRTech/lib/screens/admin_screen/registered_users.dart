// ignore_for_file: import_of_legacy_library_into_null_safe, unnecessary_import, non_constant_identifier_names, prefer_typing_uninitialized_variables, prefer_const_constructors, unrelated_type_equality_checks, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, unnecessary_new

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_id_system/screens/admin_screen/database_setup.dart';
import 'package:qr_id_system/screens/admin_screen/entry_logs.dart';
import 'package:qr_id_system/screens/admin_screen/home.dart';
import 'package:qr_id_system/screens/admin_screen/profile.dart';
import 'package:qr_id_system/screens/admin_screen/utility.dart';
import 'package:qr_id_system/screens/sql_helpers/DatabaseHelper.dart';
import 'package:qr_id_system/screens/admin_screen/generate_qr.dart';

class RegisteredUsers extends StatelessWidget {
  const RegisteredUsers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'LOOGQRTECH',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All journals
  List<Map<String, dynamic>> _users = [];

  var new_qrRegistration;
  bool _isLoading = true;
  var fullNameController = TextEditingController();
  var qrCodeController = TextEditingController();
  var courseController = TextEditingController();
  var studentIdController = TextEditingController();
  var semesterController = TextEditingController();
  var schoolYearController = TextEditingController();
  String? studentId;

  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await RegistrationSQLHelper.getItems();
    setState(() {
      _users = data;
      _isLoading = false;
    });
  }

  File? _image;
  final picker = ImagePicker();
  String? imgString;
  TimeOfDay? selectedTime;
  int? selectedYear;
  late TimeOfDay selectedStartTime;

  Future getImage() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 400,
        imageQuality: 50,
        preferredCameraDevice: CameraDevice.front);

    setState(() {
      _image = File(pickedFile!.path);

      imgString = Utility.base64String(_image!.readAsBytesSync());
      Navigator.of(context).pop();
      inputDetails(context);
    });
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    if (fullNameController.text == '') {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Unsuccessful Registration! Please type the student fullname!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0),
          ),
          backgroundColor: Colors.red,
        ));
      });
    } else if (courseController.text == '') {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Unsuccessful Registration! Please include the student course!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0),
          ),
          backgroundColor: Colors.red,
        ));
      });
    } else if (imgString == null) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Unsuccessful Registration! Please select a valid picture!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0),
          ),
          backgroundColor: Colors.red,
        ));
      });
    } else if (semesterController.text == null) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Unsuccessful Registration! Please include the student class!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0),
          ),
          backgroundColor: Colors.red,
        ));
      });
    } else if (schoolYearController == null) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Unsuccessful Registration! Please include the student school year!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.0),
          ),
          backgroundColor: Colors.red,
        ));
      });
    } else {
      // You should provide the 'subject' value too, I am assuming null as a placeholder here
      String? subject = null; // Or provide the actual subject

      await RegistrationSQLHelper.createItem(
        studentId!, // qr
        fullNameController.text, // fullname
        imgString, // imageString
        courseController.text, // course
        semesterController.text, // className
        schoolYearController.text, // schoolYear
        subject, // subject (new parameter)
        0, // late
      );
      _refreshJournals();
    }
  }

  void inputDetails(BuildContext context) {
    fullNameController == '';
    qrCodeController == '';
    studentId == '';
    courseController == '';
    semesterController == '';
    schoolYearController == '';

    _image == null;
    imgString == '';
    FlutterBeep.beep();
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.965,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: Text(
                  'Registration for Students',
                  style: TextStyle(color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            SizedBox(
                              height: 40.0,
                            ),
                            Center(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _image = null;

                                    getImage();
                                  });
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  radius: 92.0,
                                  child: CircleAvatar(
                                    radius: 90.0,
                                    child: ClipOval(
                                      child: (_image != null)
                                          ? Image.file(
                                              _image!,
                                              fit: BoxFit.cover,
                                              width: 200.0,
                                              height: 200.0,
                                            )
                                          : Image.asset('images/add_photo.jpg'),
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                "Tap to capture photo",
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 7,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                ),
                                child: ListTile(
                                  leading: Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: Icon(
                                      Icons.account_box,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  title: GestureDetector(
                                    onTap: () async {
                                      final enteredId =
                                          await showModalBottomSheet<String>(
                                        context: context,
                                        builder: (context) {
                                          return GenerateQRScreen();
                                        },
                                      );
                                      if (enteredId != null) {
                                        setState(() {
                                          studentId = enteredId;
                                        });
                                      }
                                    },
                                    child: Container(
                                      height: 48.0,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.teal),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        studentId != null
                                            ? 'Student ID: $studentId'
                                            : 'Tap to enter Student ID',
                                        style: TextStyle(
                                            fontSize: 16.0, color: Colors.teal),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 12.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 7,
                                      offset: const Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                ),
                                child: ListTile(
                                  leading: const Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: Icon(
                                      Icons.text_fields,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  title: TextField(
                                    controller: fullNameController,
                                    onChanged: (value) {},
                                    style: const TextStyle(
                                        fontSize: 24.0, color: Colors.teal),
                                    decoration: InputDecoration(
                                      hintText: 'Fullname',
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 12.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 7,
                                      offset: const Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                ),
                                child: ListTile(
                                  leading: const Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: Icon(Icons.text_fields,
                                        color: Colors.teal),
                                  ),
                                  title: TextField(
                                    controller: courseController,
                                    onChanged: (value) {},
                                    style: const TextStyle(
                                        fontSize: 24.0, color: Colors.teal),
                                    decoration: InputDecoration(
                                      hintText: 'Course',
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 7,
                                      offset: const Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                ),
                                child: ListTile(
                                  leading: const Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: Icon(Icons.text_fields,
                                        color: Colors.teal),
                                  ),
                                  title: TextField(
                                    controller: semesterController,
                                    onChanged: (value) {},
                                    style: const TextStyle(
                                        fontSize: 24.0, color: Colors.teal),
                                    decoration: InputDecoration(
                                      hintText: 'Semester',
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 7,
                                      offset: const Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: const Padding(
                                        padding: EdgeInsets.all(6.0),
                                        child: Icon(Icons.text_fields,
                                            color: Colors.teal),
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: schoolYearController,
                                              onChanged: (value) {},
                                              style: const TextStyle(
                                                  fontSize: 24.0,
                                                  color: Colors.teal),
                                              decoration: InputDecoration(
                                                hintText: 'School year',
                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior.never,
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.calendar_today),
                                            color: Colors.teal,
                                            onPressed: () async {
                                              final DateTime? pickedDate =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(
                                                    DateTime.now().year - 10),
                                                lastDate: DateTime(
                                                    DateTime.now().year + 10),
                                              );
                                              if (pickedDate != null) {
                                                setState(() {
                                                  selectedYear =
                                                      pickedDate.year;
                                                  schoolYearController.text =
                                                      selectedYear.toString();
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Existing code for "School year" field
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            FractionallySizedBox(
                              widthFactor: 1,
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  _addItem();
                                },
                                child: const Text(
                                  'REGISTER',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                      color: Colors.white),
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.teal),
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          const EdgeInsets.all(12)),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          side: const BorderSide(
                                              color: Colors.teal))),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _coursesController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _schoolyearController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _users.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['qrCode'];
      _descriptionController.text = existingJournal['fullName'];
      _coursesController.text = existingJournal['courses'];
      _semesterController.text = existingJournal['class'];
      _schoolyearController.text = existingJournal['school_year'];
    }

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  top: 15,
                  left: 15,
                  right: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 80,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 12.0),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12.0),
                        ),
                      ),
                      child: ListTile(
                        leading: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.text_fields_outlined,
                            color: Colors.cyan,
                          ),
                        ),
                        title: TextField(
                          style: const TextStyle(
                              fontSize: 24.0, color: Colors.teal),
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'QR Code',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12.0),
                        ),
                      ),
                      child: ListTile(
                        leading: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.text_fields_outlined,
                              color: Colors.teal),
                        ),
                        title: TextField(
                          style: const TextStyle(
                              fontSize: 24.0, color: Colors.teal),
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Fullname',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12.0),
                        ),
                      ),
                      child: ListTile(
                        leading: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.text_fields_outlined,
                            color: Colors.teal,
                          ),
                        ),
                        title: TextField(
                          style: const TextStyle(
                              fontSize: 24.0, color: Colors.teal),
                          controller: _coursesController,
                          decoration: InputDecoration(
                            hintText: 'Course',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12.0),
                        ),
                      ),
                      child: ListTile(
                        leading: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.text_fields_outlined,
                            color: Colors.teal,
                          ),
                        ),
                        title: TextField(
                          style: const TextStyle(
                              fontSize: 24.0, color: Colors.teal),
                          controller: _semesterController,
                          decoration: InputDecoration(
                            hintText: 'Semester',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12.0),
                        ),
                      ),
                      child: ListTile(
                        leading: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.text_fields_outlined,
                            color: Colors.teal,
                          ),
                        ),
                        title: TextField(
                          style: const TextStyle(
                              fontSize: 24.0, color: Colors.teal),
                          controller: _schoolyearController,
                          decoration: InputDecoration(
                            hintText: 'School Year',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    FractionallySizedBox(
                      widthFactor: 1,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Save new journal
                          if (id == null) {
                            await _addItem();
                          }

                          if (id != null) {
                            await _updateItem(id);
                          }

                          // Clear the text fields
                          _titleController.text = '';
                          _descriptionController.text = '';

                          // Close the bottom sheet
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'UPDATE',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: Colors.white),
                        ),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.teal),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.all(12)),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side:
                                        const BorderSide(color: Colors.teal)))),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    final updatedItem = {
      'id': id,
      'qrCode': _titleController.text,
      'fullName': _descriptionController.text,
      'courses': _coursesController.text,
      'class': _semesterController.text,
      'school_year': _schoolyearController.text,
    };

    final db = await RegistrationSQLHelper.db(); // Get the database instance
    await db.update('users', updatedItem, where: 'id = ?', whereArgs: [id]);

    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await RegistrationSQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.teal,
      content: Text(
        'Account successfully deleted!',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        title: Center(
          child: Text(
            'REGISTERED USERS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Column(
              children: [
                const Center(
                  child: CircularProgressIndicator(),
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
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: 500,
                    height: MediaQuery.of(context).size.height / 10,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      color: Colors.teal,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                    ),
                    child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.cyan,
                          radius: 34.0,
                          child: CircleAvatar(
                            radius: 26.0,
                            backgroundColor: Colors.white.withOpacity(0.1),
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
                          _users[index]['fullName'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.white),
                        ),
                        subtitle: Text(
                          _users[index]['courses'],
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: CircleAvatar(
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                    onPressed: () =>
                                        _showForm(_users[index]['id']),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: CircleAvatar(
                                  child: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.white),
                                    onPressed: () {
                                      showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                title:
                                                    const Text('Delete User?'),
                                                content: const Text(
                                                    'Are you sure you want to delete this User?'),
                                                actions: <Widget>[
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(context,
                                                              'cancel'),
                                                      child: const Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54),
                                                      )),
                                                  GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(
                                                            context, 'delete');
                                                        setState(() {
                                                          _deleteItem(
                                                              _users[index]
                                                                  ['id']);
                                                        });
                                                      },
                                                      child: const Text(
                                                        'Ok',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      )),
                                                ],
                                              ));
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),
                );
              },
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
              child: Icon(Icons.home_rounded, size: 32.0, color: Colors.teal),
            ),
            label: 'Home',
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
                color: Colors.black54,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            inputDetails(context);
          });
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
