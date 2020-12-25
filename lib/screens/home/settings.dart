import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_todo_second/constants.dart';
import 'package:firebase_todo_second/services/database.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  // final bool isDarkMode;
  final String userID;
  Settings(
    // this.isDarkMode,
    this.userID,
  );

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(widget.userID)
            .snapshots(),
        builder:
            (context, AsyncSnapshot<DocumentSnapshot> userSettingsSnapshot) {
          if (userSettingsSnapshot.hasData) {
            Map userData = userSettingsSnapshot.data.data;
            bool isDarkMode = userData["isDarkMode"];
            print('userData = $userData');
            // print(userData["isDarkMode"]);
            return Scaffold(
              backgroundColor: isDarkMode ? backColor : lightModeBackColor,
              appBar: AppBar(
                title: Text('Settings'),
                elevation: 0,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        mainColor,
                        accentColor,
                      ],
                    ),
                  ),
                ),
              ),
              body: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 12,
                ),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    title: Text(
                      'Dark mode',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    /* trailing: getCustomSwitch(
                      userData["isDarkMode"],
                      () async {
                        await DatabaseServices().updateData(
                          userID,
                          {"isDarkMode": !userData["isDarkMode"]},
                        );
                      },
                      userData["isDarkMode"],
                    ), */

                    /* trailing: Container(
                      child: CustomSwitch(
                        value: userData["isDarkMode"],
                        onTap: () {
                          DatabaseServices().updateData(
                            userID,
                            {
                              "isDarkMode":
                                  userData["isDarkMode"] ? false : true,
                            },
                          );
                        },
                        isDarkMode: userData["isDarkMode"],
                      ),  
                    ), */

                    trailing: getCustomSwitch(
                      userData["isDarkMode"],
                      (val) async {
                        await DatabaseServices().updateData(
                          widget.userID,
                          {
                            "isDarkMode": userData["isDarkMode"] ? false : true,
                          },
                        );
                        print('data updated!');
                      },
                      userData["isDarkMode"],
                    ),
                    /*   
                    trailing:  Switch(
          value: userData["isDarkMode"],
          onChanged: (val) {
                          DatabaseServices().updateData(
                            userID,
                            {
                              "isDarkMode":
                                  userData["isDarkMode"] ? false : true,
                            },
                          );
                        },
          activeColor: mainColor,
          activeTrackColor: mainColor.withOpacity(0.5),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey[300],
        )    */
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    title: Text(
                      'Change name',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    title: Text(
                      'Change color',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return PickColor(
                            isDarkMode,
                            widget.userID,
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class PickColor extends StatefulWidget {
  final bool isDarkMode;
  final String userID;
  PickColor(
    this.isDarkMode,
    this.userID,
  );
  @override
  _PickColorState createState() => _PickColorState();
}

class _PickColorState extends State<PickColor> {
  List colors = [];
  String userName = '';
  Stream<DocumentSnapshot> currentColor;

  void getUserData() async {
    await Firestore.instance
        .collection('settings')
        .document('settingsColors')
        .get()
        .then((DocumentSnapshot data) {
      colors = data.data["colors"];
      setState(() {});
    });
  }

  void getCurrentColor() async {
    currentColor = DatabaseServices().getUserDataAsStream(widget.userID);
  }

  void getUserName() async {
    String data = await DatabaseServices().getCurrentUsersName(widget.userID);
    userName = data.toString()[0].toUpperCase();
  }

  @override
  void initState() {
    getUserData();
    getCurrentColor();
    getUserName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? backColor : lightModeBackColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          iconSize: backArrowSize,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mainColor, accentColor],
            ),
          ),
        ),
        title: Text('Change color'),
        //backgroundColor: Colors.white,
      ),
      body: colors.isNotEmpty && currentColor != null
          ? StreamBuilder(
              stream: currentColor,
              builder:
                  (context, AsyncSnapshot<DocumentSnapshot> colorSnapshot) {
                if (colorSnapshot.hasData) {
                  return ListView(
                    // shrinkWrap: true,
                    children: [
                      Container(
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(width: 24),
                              Text(
                                'Preview: ',
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                              Spacer(),
                              CircleAvatar(
                                backgroundColor: Color(
                                  colorSnapshot.data.data["color"],
                                ),
                                child: Text(
                                  userName,
                                  style: TextStyle(
                                    color: getRealColor(
                                      colorSnapshot.data.data["color"],
                                    ),
                                    fontSize: 24,
                                  ),
                                ),
                                radius: 50,
                              ),
                              SizedBox(width: 24),
                            ],
                          ),
                        ),
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.all(
                          8,
                        ),
                        crossAxisCount: 6,
                        children: colors.map((dynamic color) {
                          return Container(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: GestureDetector(
                                onTap: () async {
                                  await DatabaseServices()
                                      .updateColor(widget.userID, color);
                                  setState(() {});
                                },
                                child: CircleAvatar(
                                  backgroundColor: Color(color),
                                  child: color == colorSnapshot.data["color"]
                                      ? Icon(
                                          Icons.check,
                                          color: getRealColor(color),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              })
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
