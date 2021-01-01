import 'package:firebase_todo_second/constants.dart';
import 'package:firebase_todo_second/screens/home/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'notes_page.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void getPermissions() async {
    bool isGranted = await Permission.ignoreBatteryOptimizations.isGranted;
    if (!isGranted) {
      PermissionStatus status =
          await Permission.ignoreBatteryOptimizations.request();
      if (!status.isGranted) {
        SystemNavigator.pop();
      }
    }
  }

  @override
  void initState() {
    getPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotesPage(),
    );
  }
}
