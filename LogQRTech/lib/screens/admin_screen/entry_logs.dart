import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_id_system/screens/admin_screen/database_setup.dart';
import 'package:qr_id_system/screens/admin_screen/exit_logs.dart';
import 'package:qr_id_system/screens/admin_screen/home.dart';
import 'package:qr_id_system/screens/admin_screen/profile.dart';
import 'package:qr_id_system/screens/admin_screen/registered_users.dart';
import 'package:qr_id_system/screens/sql_helpers/DatabaseHelper.dart';

class EntryLogs extends StatelessWidget {
  // This widget is the root
  // of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ENTRY LOGS',
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

  @override
  void initState() {
    super.initState();
    _refreshJournalsExit(); // Call _refreshJournalsExit first
    _refreshJournals();
  }

  void _refreshJournals() async {
    final data = await RegistrationSQLHelper.getEnLogs();
    setState(() {
      _users = data;
      _isLoading = false;
    });
  }

  void _refreshJournalsExit() async {
    final data = await RegistrationSQLHelper.getExLogs();
    setState(() {
      if (_usersExit.isEmpty) {
        // If the list is empty, directly assign the data
        _usersExit = data;
      } else {
        // Merge the new data with the existing data
        final existingUserIds =
            _usersExit.map((entry) => entry['user_id']).toList();
        for (final entry in data) {
          final userId = entry['user_id'];
          if (existingUserIds.contains(userId)) {
            _usersExit.add(entry);
          }
        }
      }
      _isLoadingExit = false;
    });
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
          title: Text(
            'STUDENTS LOGBOOK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 2.0, color: Colors.black38),
              insets: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            tabs: <Widget>[
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
                    color: Colors.white,
                  ),
                ),
              ),
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
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(children: <Widget>[
          Scaffold(
            body: _isLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                      SizedBox(height: 18.0),
                      Center(
                        child: Text('No data found!'),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      Uint8List _bytesImage;
                      String _imgString = _users[index]['picture'];
                      _bytesImage = base64Decode(_imgString);

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
                                offset: Offset(0, 3),
                              ),
                            ],
                            color: Colors.blue,
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.black,
                              radius: 34.0,
                              child: CircleAvatar(
                                radius: 26.0,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                child: ClipOval(
                                  child: _users[index]['picture'] != null
                                      ? Image.memory(
                                          _bytesImage,
                                          height: 100.0,
                                          width: 100.0,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            title: Text(
                              _users[index]['fullName'] ?? 'No Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              _users[index]['entrydate'] ?? 'No Date',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  Text(
                                    _users[index]['entrytime'] ?? 'No Time',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Scaffold(
            body: _isLoadingExit
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                      SizedBox(height: 18.0),
                      Center(
                        child: Text('No data found!'),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: _usersExit.length,
                    itemBuilder: (context, index1) {
                      Uint8List _bytesImage;
                      String _imgString = _usersExit[index1]['picture'];
                      _bytesImage = base64Decode(_imgString);

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
                                offset: Offset(0, 3),
                              ),
                            ],
                            color: Colors.red,
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.black,
                              radius: 34.0,
                              child: CircleAvatar(
                                radius: 26.0,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                child: ClipOval(
                                  child: _bytesImage != null
                                      ? Image.memory(
                                          _bytesImage,
                                          height: 100.0,
                                          width: 100.0,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(),
                                ),
                              ),
                            ),
                            title: Text(
                              _usersExit[index1]['fullName'] ?? 'No Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              _usersExit[index1]['exitdate'] ?? 'No Date',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  Text(
                                    _usersExit[index1]['exittime'] ?? 'No Time',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                      builder: (BuildContext context) => QRScannerAdmin()));
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
                      builder: (BuildContext context) => EntryLogs()));
                },
                child: Icon(
                  Icons.list_alt,
                  size: 32.0,
                  color: Colors.black54,
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
    );
  }
}
