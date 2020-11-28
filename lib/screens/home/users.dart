import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_todo_second/constants.dart';
import 'package:firebase_todo_second/screens/home/list_detail.dart';
import 'package:firebase_todo_second/services/auth.dart';
import 'package:flutter/material.dart';

class Users extends StatefulWidget {
  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mainColor, accentColor],
            ),
          ),
        ),
        title: Text('Users'),
        //backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('users').snapshots(),
          builder: (context, streamSnapshot) {
            return Theme(
              data: Theme.of(context).copyWith(
                accentColor: mainColor,
              ),
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Colors.white.withOpacity(0.2),
                    thickness: 0.5,
                  );
                },
                itemBuilder: (context, i) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: i == 0 ? 15 : 5,
                      bottom: i == streamSnapshot.data.documents.length - 1
                          ? 15
                          : 5,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(
                              streamSnapshot.data.documents[i]['color'],
                            ) ??
                            Colors.black,
                        child: Text(
                          '${streamSnapshot.data.documents[i]['name'].toString().substring(0, 1)}' ??
                              '',
                          style: TextStyle(
                            color: getColor(
                              streamSnapshot.data.documents[i]['color']
                                      .toInt() ??
                                  000000000,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        '${streamSnapshot.data.documents[i]['name']}' ?? '',
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.notifications,
                            color: Colors.white.withOpacity(0.8)),
                        onPressed: () {},
                      ),
                    ),
                  );
                },
                itemCount: streamSnapshot.hasData
                    ? streamSnapshot.data.documents.length
                    : 0,
              ),
            );
          }),
    );
  }
}
