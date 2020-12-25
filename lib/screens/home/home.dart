import 'package:firebase_todo_second/constants.dart';
import 'package:firebase_todo_second/screens/home/users.dart';
import 'package:flutter/material.dart';
import 'notes_page.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotesPage(),
    );
  }
}
