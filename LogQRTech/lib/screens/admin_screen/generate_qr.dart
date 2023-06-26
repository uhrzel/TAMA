import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRScreen extends StatefulWidget {
  @override
  _GenerateQRScreenState createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  TextEditingController studentIdController = TextEditingController();
  String? qrData;

  // Dummy function for saving QR code to database
  Future<void> saveQrCodeToDatabase(String qrCode) async {
    // Here, add logic to save the QR code to your database
    // For this example, showing an AlertDialog instead of actually saving
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("QR Code Saved"),
          content: Text("QR Code is saved to database: $qrCode"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: studentIdController,
          decoration: InputDecoration(
            labelText: "Enter student ID",
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              qrData = studentIdController.text;
            });
          },
          child: Text("Generate QR Code"),
        ),
        SizedBox(height: 16),
        if (qrData != null) ...[
          QrImage(
            data: qrData!,
            version: QrVersions.auto,
            size: 200.0,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, studentIdController.text);
            },
            child: Text("Save QR Code"),
          ),
        ],
      ],
    );
  }
}
