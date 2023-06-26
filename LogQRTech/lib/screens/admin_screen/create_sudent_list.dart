import 'package:flutter/material.dart';
import 'package:qr_id_system/screens/sql_helpers/DatabaseHelper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _semesterController = TextEditingController();
  TextEditingController _classController = TextEditingController();
  TextEditingController _coursesController = TextEditingController();
  TextEditingController _schoolYearController = TextEditingController();
  TextEditingController _lateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student List'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Navigate to the previous screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Wrap the column with SingleChildScrollView
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _semesterController,
                decoration: InputDecoration(labelText: 'Semester'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _classController,
                decoration: InputDecoration(labelText: 'Class'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _coursesController,
                decoration: InputDecoration(labelText: 'Courses'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _schoolYearController,
                decoration: InputDecoration(labelText: 'School Year'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _lateController,
                decoration: InputDecoration(labelText: 'Late'),
                keyboardType:
                    TextInputType.number, // Make sure the keyboard is numeric
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Attempt to insert the student into the database
                bool wasAdded = await RegistrationSQLHelper.insertStudent(
                    _firstNameController.text,
                    _lastNameController.text,
                    _semesterController.text,
                    _classController.text,
                    _coursesController.text,
                    _schoolYearController.text,
                    int.parse(_lateController.text));

                // Clear the text fields
                _firstNameController.clear();
                _lastNameController.clear();
                _semesterController.clear();
                _classController.clear();
                _coursesController.clear();
                _schoolYearController.clear();

                // Show Snackbar based on whether the student was added
                String message = wasAdded
                    ? 'Student added successfully'
                    : 'Student already exists';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );

                // Update the UI
                setState(() {});
              },
              child: Text('Add Student'),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: RegistrationSQLHelper.getStudents(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasData && snapshot.data != null) {
                final students = snapshot.data!;
                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (ctx, index) {
                    String firstName = students[index]['first_name'] ?? 'N/A';
                    String lastName = students[index]['last_name'] ?? 'N/A';
                    String semester = students[index]['semester'] ?? 'N/A';
                    String className = students[index]['class'] ?? 'N/A';
                    String courses = students[index]['courses'] ?? 'N/A';
                    String schoolYear = students[index]['school_year'] ?? 'N/A';
                    String late = students[index]['late'].toString() ?? 'N/A';
                    return Dismissible(
                      key: Key('$firstName$lastName'),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete Student'),
                              content: Text(
                                  'Are you sure you want to delete this student?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context)
                                      .pop(false), // Cancel the deletion
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context)
                                      .pop(true), // Confirm the deletion
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) async {
                        // Delete the student from the database
                        await RegistrationSQLHelper.deleteStudent(
                            students[index]['id']);

                        // Show a snackbar indicating the deletion
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Student deleted')),
                        );

                        // Update the UI
                        setState(() {});
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 16.0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child: Card(
                        elevation: 5,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          title: Text(
                            '$firstName $lastName',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Semester: $semester\n'
                              'Class: $className\n'
                              'Courses: $courses\n'
                              'School Year: $schoolYear\n'
                              'Late: $late', // <- Display the late field here
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage('images/student.png'),
                            child: Text(''),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              bool confirmDelete = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Delete Student'),
                                    content: Text(
                                        'Are you sure you want to delete this student?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context)
                                            .pop(false), // Cancel the deletion
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context)
                                            .pop(true), // Confirm the deletion
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (confirmDelete == true) {
                                // Delete the student from the database
                                await RegistrationSQLHelper.deleteStudent(
                                    students[index]['id']);

                                // Show a snackbar indicating the deletion
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Student deleted')),
                                );

                                // Update the UI
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: Text('No students found!'),
                );
              }
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _semesterController.dispose();
    _classController.dispose();
    _coursesController.dispose();
    _schoolYearController.dispose();
    _lateController.dispose();

    super.dispose();
  }
}
