// ignore_for_file: unnecessary_import, import_of_legacy_library_into_null_safe, use_key_in_widget_constructors, prefer_typing_uninitialized_variables, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class QRScanner extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Given Title
      title: 'QRCode Scanner',
      debugShowCheckedModeBanner: false,
      //Given Theme Color
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      //Declared first page of our app
      home: QRHome(),
    );
  }
}

class QRHome extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<QRHome> {
  var qrCodeResult;

  void displayDetails() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          margin: EdgeInsets.all(20.0),
          width: 500,
          height: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('images/qr.png'),
              SizedBox(
                height: 10.0,
              ),
              FractionallySizedBox(
                widthFactor: 1,
                child: ElevatedButton(
                  onPressed: () async {
                    String codeSanner = await FlutterBarcodeScanner.scanBarcode(
                        '#ff6666',
                        'cancel',
                        true,
                        ScanMode.QR); //barcode scanner
                    setState(() {
                      qrCodeResult = codeSanner;

                      if (qrCodeResult == '') {
                      } else {
                        displayDetails();
                      }
                    });
                  },
                  child: const Text(
                    'Scan QR',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.cyan),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.all(12)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                              side: const BorderSide(color: Colors.cyan)))),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          enableFeedback: true,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => QRScanner()));
                },
                child: Icon(
                  Icons.qr_code_outlined,
                  size: 32.0,
                  color: Colors.cyan,
                ),
              ),
              label: 'Scanner',
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: InkWell(
                onTap: () {},
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
                onTap: () {},
                child: Icon(
                  Icons.list_rounded,
                  size: 32.0,
                  color: Colors.cyan,
                ),
              ),
              label: 'Exit Logs',
              backgroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
