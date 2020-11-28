import 'package:firebase_todo_second/constants.dart';
import 'package:firebase_todo_second/screens/home/users.dart';
import 'package:flutter/material.dart';
import 'notes_page.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentIndex == 0
          ? NotesPage()
          : currentIndex == 1 ? Users() : Container(),
      /* bottomNavigationBar: BottomNavigationBar(
        backgroundColor: mainColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.2),
        currentIndex: currentIndex,
        onTap: (i) {
          setState(() {
            currentIndex = i;
          });
        },
        items: [
          BottomNavigationBarItem(
            title: Text('Home'),
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            title: Text('Users'),
            icon: Icon(Icons.supervised_user_circle),
          ),
          BottomNavigationBarItem(
            title: Text('Profile'),
            icon: Icon(Icons.person),
          ),
        ],
      ), */
    );
  }
}
