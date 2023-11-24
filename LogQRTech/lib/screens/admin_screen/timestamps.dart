import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_id_system/screens/sql_helpers/DatabaseHelper.dart';

class NextDashboardScreen extends StatefulWidget {
  @override
  _NextDashboardScreenState createState() => _NextDashboardScreenState();
}

class _NextDashboardScreenState extends State<NextDashboardScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _subjectController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();

  List<Map<String, dynamic>> _subjectDetails = [];

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _startTimeController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _endTimeController.text = pickedTime.format(context);
      });
    }
  }

  void _saveSubjectDetails() async {
    if (_formKey.currentState!.validate()) {
      String subject = _subjectController.text.trim();
      String startTime = _startTimeController.text.trim();
      String endTime = _endTimeController.text.trim();

      int id = await RegistrationSQLHelper.insertSubjectDetail(
        subject,
        startTime,
        endTime,
      );

      if (id != 0) {
        // Success message or any other desired action
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subject details saved successfully.')),
        );

        // Clear the form
        _formKey.currentState!.reset();
        _subjectController.clear();
        _startTimeController.clear();
        _endTimeController.clear();

        // Fetch updated subject details and update the drawer
        _fetchSubjectDetails();
      } else {
        // Error message or any other desired action
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save subject details.')),
        );
      }
    }
  }

  Future<void> _fetchSubjectDetails() async {
    List<Map<String, dynamic>> subjectDetails =
        await RegistrationSQLHelper.getSubjectDetails();

    setState(() {
      _subjectDetails = subjectDetails;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchSubjectDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timestamps'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              // Handle back button press
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white, // Set the background color to white
          child: ListView.builder(
            itemCount: _subjectDetails.length,
            itemBuilder: (BuildContext context, int index) {
              String subject = _subjectDetails[index]['subject'];
              String startTime = _subjectDetails[index]['start_time'];
              String endTime = _subjectDetails[index]['end_time'];

              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(
                        0.8), // Set the background color with opacity
                    borderRadius: BorderRadius.circular(
                        8), // Add rounded corners to the container
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          8), // Add rounded corners to the image
                      child: Image.asset(
                        'images/student.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      subject,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Set the text color to white
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Start Time: $startTime',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white, // Set the text color to white
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'End Time: $endTime',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white, // Set the text color to white
                          ),
                        ),
                        SizedBox(height: 4),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.white, // Set the icon color to white
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete Subject Detail'),
                              content: Text(
                                  'Are you sure you want to delete this subject detail?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await RegistrationSQLHelper
                                        .deleteSubjectDetail(
                                            _subjectDetails[index]['id']);
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                    _fetchSubjectDetails(); // Fetch updated subject details
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    onTap: () {
                      // Handle onTap event for the list tile
                      // e.g., navigate to subject details page
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: 'Subject'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a subject.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              InkWell(
                onTap: () => _selectStartTime(context),
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _startTimeController,
                    decoration: InputDecoration(
                      labelText: 'Start Time',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please select a start time.';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              InkWell(
                onTap: () => _selectEndTime(context),
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _endTimeController,
                    decoration: InputDecoration(
                      labelText: 'End Time',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please select an end time.';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveSubjectDetails,
                child: Text('Save Subject Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
