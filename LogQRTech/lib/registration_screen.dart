import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_id_system/screens/sql_helpers/DatabaseHelper.dart';
import 'package:http/http.dart' as http;

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _registerUser() async {
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String username = _usernameController.text;
    String address = _addressController.text;
    String subject = _subjectController.text;
    String password = _passwordController.text;
    String email = _emailController.text;
    RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        username.isEmpty ||
        address.isEmpty ||
        subject.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    // Check if the user already exists based on the first name, last name, and username
    bool userExists = await RegistrationSQLHelper.checkUserExists(
      firstName,
      lastName,
      username,
    );

    if (userExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data already exists')),
      );
      return;
    }

    int registrationId = await RegistrationSQLHelper.insertRegistration(
      email,
      firstName,
      lastName,
      username,
      address,
      subject,
      password,
    );

    if (registrationId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful')),
      );

      // Clear the text fields after successful registration
      _emailController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _usernameController.clear();
      _addressController.clear();
      _subjectController.clear();
      _passwordController.clear();

      // Perform any additional actions after successful registration, such as navigation or showing a success dialog
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register')),
      );
    }

    // Make a request to the PHP script to get OTP
    final response = await http.post(
      Uri.parse('http://192.168.43.102:8080/SMTP-cas/SENDER.php'),
      body: {'email': email},
    );

    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('otp')) {
        int otp = data['otp'];

        // Show a modal to verify OTP
        _showOtpVerificationModal(otp);
      } else if (data.containsKey('error')) {
        // Handle the error from PHP script
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data['error']}')),
        );
      }
    } else {
      // Handle the HTTP error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get OTP')),
      );
    }
  }

  void _showOtpVerificationModal(int otp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verify OTP'),
          content: TextField(
            controller: TextEditingController(),
            decoration: InputDecoration(labelText: 'Enter OTP'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                String enteredOtp = TextEditingController().text;
                if (enteredOtp == otp.toString()) {
                  Navigator.of(context).pop();
                  // Add your navigation logic here
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid OTP')),
                  );
                }
              },
              child: Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: 'Subject'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _registerUser,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
