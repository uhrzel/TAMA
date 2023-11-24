// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:qr_id_system/screens/admin_screen/entry_logs.dart';
import 'package:qr_id_system/screens/admin_screen/home.dart';
import 'package:qr_id_system/screens/admin_screen/profile.dart';
import 'package:qr_id_system/screens/admin_screen/registered_users.dart';

class ExitLogs extends StatelessWidget {
  // This widget is the root
  // of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EXIT LOGS"),
        backgroundColor: Colors.cyan,
      ),
      body: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Table(
            border: TableBorder.all(width: 1.0, style: BorderStyle.solid),

            // textDirection: TextDirection.rtl,
            // defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
            // border:TableBorder.all(width: 2.0,color: Colors.red),
            children: [
              TableRow(children: [
                Center(
                    child: Text(
                  "NAME",
                  textScaleFactor: 1.0,
                )),
                Center(child: Text("DATE", textScaleFactor: 1.0)),
                Center(child: Text("TIME", textScaleFactor: 1.0)),
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Sample User", textScaleFactor: 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("03/12/2022", textScaleFactor: 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("08:17 AM", textScaleFactor: 1.0),
                ),
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Sample User", textScaleFactor: 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("03/12/2022", textScaleFactor: 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("08:17 AM", textScaleFactor: 1.0),
                ),
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Sample User", textScaleFactor: 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("03/12/2022", textScaleFactor: 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("08:17 AM", textScaleFactor: 1.0),
                ),
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Sample User", textScaleFactor: 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("03/12/2022", textScaleFactor: 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("08:17 AM", textScaleFactor: 1.0),
                ),
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Sample User", textScaleFactor: 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("03/12/2022", textScaleFactor: 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("08:17 AM", textScaleFactor: 1.0),
                ),
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Sample User", textScaleFactor: 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("03/12/2022", textScaleFactor: 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("08:17 AM", textScaleFactor: 1.0),
                ),
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Sample User", textScaleFactor: 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("03/12/2022", textScaleFactor: 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("08:17 AM", textScaleFactor: 1.0),
                ),
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Sample User", textScaleFactor: 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("03/12/2022", textScaleFactor: 1.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("08:17 AM", textScaleFactor: 1.0),
                ),
              ]),
            ],
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
                Icons.home_max_rounded,
                size: 32.0,
                color: Colors.cyan,
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
                color: Colors.cyan,
              ),
            ),
            label: 'ENTRY LOGS',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => ExitLogs()));
              },
              child: Icon(
                Icons.list_rounded,
                size: 32.0,
                color: Colors.black,
              ),
            ),
            label: 'Exit Logs',
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
                color: Colors.cyan,
              ),
            ),
            label: 'USERS',
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
    );
  }
}
