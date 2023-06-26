import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Subject {
  String name;
  String startTime;
  String endTime;

  Subject({required this.name, required this.startTime, required this.endTime});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json['name'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}

class NextDashboardScreen extends StatefulWidget {
  @override
  _NextDashboardScreenState createState() => _NextDashboardScreenState();
}

class _NextDashboardScreenState extends State<NextDashboardScreen> {
  List<Subject> subjects = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  void _loadSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? subjectList = prefs.getStringList('subjects');

    if (subjectList != null) {
      setState(() {
        subjects = subjectList
            .map((json) => Subject.fromJson(jsonDecode(json)))
            .toList();
      });
    }
  }

  void _saveSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> subjectList =
        subjects.map((subject) => jsonEncode(subject.toJson())).toList();
    prefs.setStringList('subjects', subjectList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Dashboard'),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              _showAddSubjectDialog(context);
            },
            icon: Icon(Icons.add),
            label: Text('Add Subject'),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.tealAccent,
                  elevation: 2,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      subjects[index].name,
                      style: TextStyle(fontSize: 18),
                    ),
                    subtitle: Text(
                      'Time: ${subjects[index].startTime} - ${subjects[index].endTime}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          subjects.removeAt(index);
                          _saveSubjects();
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    TextEditingController subjectNameController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    TextEditingController endTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectNameController,
                decoration: InputDecoration(labelText: 'Subject'),
              ),
              TextField(
                controller: startTimeController,
                decoration: InputDecoration(labelText: 'Start Time (HH:mm)'),
              ),
              TextField(
                controller: endTimeController,
                decoration: InputDecoration(labelText: 'End Time (HH:mm)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String subjectName = subjectNameController.text;
                String startTime = startTimeController.text;
                String endTime = endTimeController.text;

                if (subjectName.isNotEmpty &&
                    startTime.isNotEmpty &&
                    endTime.isNotEmpty) {
                  Subject newSubject = Subject(
                    name: subjectName,
                    startTime: startTime,
                    endTime: endTime,
                  );

                  setState(() {
                    subjects.add(newSubject);
                  });

                  _saveSubjects();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _saveSubjects();
    super.dispose();
  }
}
