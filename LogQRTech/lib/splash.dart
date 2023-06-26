// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:qr_id_system/main.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() async {
    await Future.delayed(
      Duration(seconds: 3),
    );
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Colors.black45,
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/qr.png"), fit: BoxFit.cover)),
          ),
          Container(
              child: Text('LogQrTech',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
        ],
      )),
    ));
  }
}
