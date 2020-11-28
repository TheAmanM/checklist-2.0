import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_todo_second/constants.dart';
import 'package:firebase_todo_second/screens/authentication/authenticate.dart';
import 'package:firebase_todo_second/screens/home/home.dart';
import 'package:firebase_todo_second/screens/home/notes_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);
    print('User: $user');
    return MaterialApp(
      title: 'Checklist 2.0',
      color: mainColor,
      theme: ThemeData(
        primaryColor: mainColor,
        primarySwatch: Colors.blue,
        accentColor: mainColor,
        // brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: user == null ? Authenticate() : Home(),
    );
  }
}
