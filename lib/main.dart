import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_todo_second/screens/wrapper.dart';
import 'package:firebase_todo_second/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>.value(
      value: AuthServices().userStream,
      child: Wrapper(),
    );
  }
}
