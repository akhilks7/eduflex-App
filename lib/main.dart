import 'package:eduflex/Userregistration.dart';
import 'package:eduflex/classfiles.dart';
import 'package:eduflex/feedback.dart';
import 'package:eduflex/landingpage.dart';
import 'package:eduflex/loginpage.dart';
import 'package:eduflex/myprofile.dart';
import 'package:eduflex/userhomepage.dart';
import 'package:eduflex/viewassignment.dart';
import 'package:eduflex/viewnote.dart';
import 'package:eduflex/viewresult.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage()
    );
  }
}
