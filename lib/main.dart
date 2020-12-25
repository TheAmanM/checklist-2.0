import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_todo_second/constants.dart';
import 'package:firebase_todo_second/screens/wrapper.dart';
import 'package:firebase_todo_second/services/auth.dart';
import 'package:firebase_todo_second/services/database.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  //await FlutterDownloader.initialize(
  //  debug: true,
  //);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>.value(
      value: AuthServices().userStream,
      child: Wrapper(),
    );
  }
}
