import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_id_system/screens/sql_helpers/DatabaseHelper.dart';

class Payrolls extends StatelessWidget {
  const Payrolls({Key? key}) : super(key: key);

  // This widget is the root
  // of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ENTRY LOGS',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: const Color(0xFF000000),
      ),
      home: const PayRollsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PayRollsPage extends StatefulWidget {
  const PayRollsPage({super.key});
  @override
  _PayRollsPageState createState() => _PayRollsPageState();
}

class _PayRollsPageState extends State<PayRollsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  bool _isLoadingExit = true;
  List<Map<String, dynamic>> _usersExit = [];

  @override
  void initState() {
    super.initState();
    _refreshJournals();
    _refreshJournalsExit();
  }

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            centerTitle: true,
            title: const Text(
              'CAFE CERVEZA EBOOK',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            ),
            // ignore: prefer_const_constructors
            bottom: TabBar(
              indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(width: 2.0, color: Colors.black38),
                  insets: EdgeInsets.symmetric(horizontal: 16.0)),
              tabs: const <Widget>[
                // ignore: prefer_const_constructors
                Tab(
                    icon: Icon(
                      Icons.list_alt_outlined,
                      color: Colors.black87,
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
                      _bytesImage = const Base64Decoder().convert(_imgString);

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
                                offset: const Offset(
                                    0, 3), // changes position of shadow
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
                                      child: Image.memory(
                                    _bytesImage,
                                    height: 100.0,
                                    width: 100.0,
                                    fit: BoxFit.cover,
                                  )),
                                ),
                              ),
                              title: Text(
                                _users[index]['fullname'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colors.white),
                              ),
                              subtitle: Text(
                                _users[index]['entrydate'],
                                style: const TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                              ),
                              trailing: SizedBox(
                                width: 100,
                                child: Row(
                                  children: [
                                    Text(
                                      _users[index]['entrytime'],
                                      style: const TextStyle(
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
                      _bytesImage = const Base64Decoder().convert(_imgString);

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
                                offset: const Offset(
                                    0, 3), // changes position of shadow
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
                                      child: Image.memory(
                                    _bytesImage,
                                    height: 100.0,
                                    width: 100.0,
                                    fit: BoxFit.cover,
                                  )),
                                ),
                              ),
                              title: Text(
                                _usersExit[index1]['fullname'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colors.white),
                              ),
                              subtitle: Text(
                                _usersExit[index1]['exitdate'],
                                style: const TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                              ),
                              trailing: SizedBox(
                                width: 100,
                                child: Row(
                                  children: [
                                    Text(
                                      _usersExit[index1]['exittime'],
                                      style: const TextStyle(
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
      ),
    );
  }
}
