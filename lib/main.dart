import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ouwuehdfokrsxwnqtymg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im91d3VlaGRmb2tyc3h3bnF0eW1nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEwNjk1NDAsImV4cCI6MjA1NjY0NTU0MH0.oeC97CVO18ogWy8Pd5Wz47V8TJDCShGBtp6dgQN-_qs',
  );

  runApp(const MainApp());
}

  final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
    );
  }
}
