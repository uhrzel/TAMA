import 'package:flutter/material.dart';

Map<int, Color> color = const {
  50: Color.fromRGBO(64, 64, 64, 19),
  100: Color.fromRGBO(64, 64, 64, 19),
  200: Color.fromRGBO(64, 64, 64, 19),
  300: Color.fromRGBO(64, 64, 64, 19),
  400: Color.fromRGBO(64, 64, 64, 19),
  500: Color.fromRGBO(64, 64, 64, 19),
  600: Color.fromRGBO(64, 64, 64, 19),
  700: Color.fromRGBO(64, 64, 64, 19),
  800: Color.fromRGBO(64, 64, 64, .19),
  900: Color.fromRGBO(64, 64, 64, .19),
};

MaterialColor colorCustom = MaterialColor(0x8B4513, color);

Map<int, Color> color1 = const {
  50: Color.fromRGBO(0, 0, 0, 19),
  100: Color.fromRGBO(0, 0, 0, 19),
  200: Color.fromRGBO(0, 0, 0, 19),
  300: Color.fromRGBO(0, 0, 0, 19),
  400: Color.fromRGBO(0, 0, 0, 19),
  500: Color.fromRGBO(0, 0, 0, 19),
  600: Color.fromRGBO(0, 0, 0, 19),
  700: Color.fromRGBO(0, 0, 0, 19),
  800: Color.fromRGBO(0, 0, 0, 19),
  900: Color.fromRGBO(0, 0, 0, 19),
};

MaterialColor colorCustom1 = MaterialColor(0x000000, color);


const MaterialColor primaryBlack = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(_blackPrimaryValue),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);
const int _blackPrimaryValue = 0xFF000000;