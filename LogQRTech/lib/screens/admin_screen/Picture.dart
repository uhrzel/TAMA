// ignore_for_file: file_names

import 'dart:typed_data';

class Picture {
  String qr;
  String fullname;
  Uint8List picture;
  Picture({required this.qr, required this.fullname, required this.picture});

  Picture.fromMap(Map map, this.qr, this.fullname, this.picture) {
    qr = map[qr];
    fullname = map[fullname];
    picture = map[picture];
  }
  Map<String, dynamic> toMap() => {
        "qr": qr,
        "fullname": fullname,
        "picture": picture,
      };
}
