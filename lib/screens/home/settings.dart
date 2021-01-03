import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_todo_second/constants.dart';
import 'package:firebase_todo_second/screens/home/featurebug.dart';
import 'package:firebase_todo_second/screens/home/notes_page.dart';
import 'package:firebase_todo_second/screens/home/updates.dart';
import 'package:firebase_todo_second/services/database.dart';
import 'package:flutter/material.dart';

TextEditingController nameController = new TextEditingController();

class Settings extends StatefulWidget {
  final bool isDarkMode;
  final String userID;
  Settings(
    this.isDarkMode,
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
            bool isAdmin = userData["isAdmin"] ?? false;
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
                actions: [
                  if (isAdmin)
                    IconButton(
                      icon: Icon(
                        Icons.admin_panel_settings,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return AdminMenu(isDarkMode);
                            },
                          ),
                        );
                      },
                    ),
                ],
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
                      isDarkMode ? 'Dark mode' : 'Dark mode (recommended)',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: getCustomSwitch(
                      userData["isDarkMode"],
                      (val) async {
                        // setNavBarColor(!isDarkMode);
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
                    onTap: () async {
                      String prevName =
                          await DatabaseServices().getCurrentUsersName(userID);
                      changeNameDialog(
                        context,
                        isDarkMode,
                        prevName,
                      );
                    },
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
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    title: Text(
                      'Update app',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Updates(isDarkMode);
                          },
                        ),
                      );
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    title: Text(
                      'Feature request / Bug report',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return FeatureBug(isDarkMode);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return Scaffold(
              backgroundColor:
                  widget.isDarkMode ? backColor : lightModeBackColor,
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
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}

class AdminMenu extends StatefulWidget {
  bool isDarkMode;
  AdminMenu(
    this.isDarkMode,
  );
  @override
  AdminMenuState createState() => AdminMenuState();
}

class AdminMenuState extends State<AdminMenu> {
  bool isDarkMode;
  GlobalKey<ScaffoldState> adminKey;

  @override
  void initState() {
    isDarkMode = widget.isDarkMode;
    adminKey = new GlobalKey<ScaffoldState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: adminKey,
        backgroundColor: isDarkMode ? backColor : lightModeBackColor,
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
          title: Text('Admin menu'),
          //backgroundColor: Colors.white,
        ),
        body: StreamBuilder(
          stream: DatabaseServices().settingsSnapshot,
          builder: (context, AsyncSnapshot<DocumentSnapshot> settingsSnapshot) {
            if (settingsSnapshot.hasData && !settingsSnapshot.hasError) {
              Map<String, dynamic> data = settingsSnapshot.data.data;
              print(data.keys);
              // String, arrray, bool, double
              return ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 16,
                ),
                children: data.keys
                    .map((String e) => ListTile(
                          onTap: () {
                            if (data[e] is String ||
                                data[e] is double ||
                                data[e] is bool) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  /* if (data[e] is String) {
                                    return AlertDialog();
                                  } else if (data[e] is double) {
                                    return AlertDialog();
                                  } else {
                                    return AlertDialog();
                                  } */
                                  return ChangeSettingDialog(
                                    isDarkMode: isDarkMode,
                                    data: data,
                                    mapKey: e,
                                    value: data[e],
                                  );
                                },
                              );
                            } else {
                              Scaffold.of(context).showSnackBar(
                                CustomSnackBar(
                                  // backgroundColor: Color(0xFF323232),
                                  Text(
                                    'Sorry, an unsupported type error occured. ',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 0,
                          ),
                          title: Text(
                            e.toString(),
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ))
                    .toList(),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}

class ChangeSettingDialog extends StatefulWidget {
  final bool isDarkMode;
  final Map<String, dynamic> data;
  final String mapKey;
  final dynamic value;

  ChangeSettingDialog({
    this.isDarkMode,
    this.data,
    this.mapKey,
    this.value,
  });

  @override
  _ChangeSettingDialogState createState() => _ChangeSettingDialogState();
}

class _ChangeSettingDialogState extends State<ChangeSettingDialog> {
  Widget getChangeSettingDialog(String key, dynamic value,
      void Function() popFunction, void Function() changeFunction) {
    if (value is String) {
      TextEditingController controller = new TextEditingController();
      bool didChange = false;
      controller.text = value;
      return TextField(
        onChanged: (v) {
          didChange = true;
        },
        controller: controller,
        style: TextStyle(
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Enter a value',
          hintStyle: TextStyle(
            color: widget.isDarkMode
                ? Colors.white.withOpacity(0.4)
                : Colors.black.withOpacity(0.4),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          // color: isDarkMode ? backColor : lightModeBackColor,
          suffixIcon: IconButton(
            onPressed: () async {
              if (!(didChange)) {
                await DatabaseServices().settingsDoc.updateData({
                  key: controller.text,
                });
              }
              popFunction();
            },
            icon: Text(
              'OK',
              style: TextStyle(
                color: mainColor,
              ),
            ),
          ),
        ),
      );
    } else if (value is bool) {
      bool switchValue = value;
      return Container(
        child: ListTile(
          trailing: Switch(
            value: switchValue,
            onChanged: (v) async {
              switchValue = !(switchValue);
              await DatabaseServices().settingsDoc.updateData({
                key: switchValue,
              });
              changeFunction();
            },
          ),
        ),
      );
    } else if (value is double) {
      double doubleValue = value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () async {
              value += 0.01;
              print('current doubleValue: $value');
              await DatabaseServices().settingsDoc.updateData({
                key: value,
              });
              changeFunction();
            },
          ),
          Text(
            value.toString(),
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.remove,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () async {
              value -= 0.01;
              print('current doubleValue: $value');
              await DatabaseServices().settingsDoc.updateData({
                key: value,
              });
              changeFunction();
            },
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? backColor : lightModeBackColor,
      title: Text(
        'Change ${widget.mapKey}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        /* child: getChangeSettingDialog(
          widget.mapKey,
          widget.value,
          () {
            Navigator.pop(context);
          },
          () {
            setState(() {});
          },
        ), */
        child: GetChangeSettingWidget(
          widget.isDarkMode,
          widget.mapKey,
          widget.value,
          () {
            Navigator.pop(context);
          },
          () {
            setState(() {});
          },
        ),
      ),
    );
  }
}

class GetChangeSettingWidget extends StatefulWidget {
  final bool isDarkMode;
  final String mapKey;
  final dynamic value;
  final void Function() popFunction;
  final void Function() changeFunction;

  GetChangeSettingWidget(
    this.isDarkMode,
    this.mapKey,
    this.value,
    this.popFunction,
    this.changeFunction,
  );

  @override
  _GetChangeSettingWidgetState createState() => _GetChangeSettingWidgetState();
}

class _GetChangeSettingWidgetState extends State<GetChangeSettingWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.value is String) {
      TextEditingController controller = new TextEditingController();
      bool didChange = false;
      controller.text = widget.value;
      return TextField(
        onChanged: (v) {
          didChange = true;
        },
        controller: controller,
        style: TextStyle(
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Enter a value',
          hintStyle: TextStyle(
            color: widget.isDarkMode
                ? Colors.white.withOpacity(0.4)
                : Colors.black.withOpacity(0.4),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          // color: isDarkMode ? backColor : lightModeBackColor,
          suffixIcon: IconButton(
            onPressed: () async {
              if (!(didChange)) {
                await DatabaseServices().settingsDoc.updateData({
                  widget.mapKey: controller.text,
                });
              }
              widget.popFunction();
            },
            icon: Text(
              'OK',
              style: TextStyle(
                color: mainColor,
              ),
            ),
          ),
        ),
      );
    } else if (widget.value is bool) {
      bool switchValue = widget.value;
      return Container(
        child: ListTile(
          trailing: Switch(
            value: switchValue,
            onChanged: (v) async {
              switchValue = !(switchValue);
              await DatabaseServices().settingsDoc.updateData({
                widget.mapKey: switchValue,
              });
              widget.changeFunction();
            },
          ),
        ),
      );
    } else if (widget.value is double) {
      double doubleValue = widget.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () async {
              setState(() {
                doubleValue += 0.01;
              });
              print('current doubleValue: ${widget.value}');
              await DatabaseServices().settingsDoc.updateData({
                widget.mapKey: doubleValue,
              });
              // widget.changeFunction();
            },
          ),
          Text(
            doubleValue.toString(),
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.remove,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () async {
              setState(() {
                doubleValue -= 0.01;
              });
              print('current doubleValue: ${widget.value}');
              await DatabaseServices().settingsDoc.updateData({
                widget.mapKey: doubleValue,
              });
              // widget.changeFunction();
            },
          ),
        ],
      );
    } else {
      return Container();
    }
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

class ChangeNameDialog extends StatefulWidget {
  final BuildContext context;
  final bool isDarkMode;
  // final String prevName;

  ChangeNameDialog({
    this.context,
    this.isDarkMode,
    // this.prevName,
  });

  @override
  _ChangeNameDialogState createState() => _ChangeNameDialogState();
}

class _ChangeNameDialogState extends State<ChangeNameDialog> {
  bool canUpdate = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 8,
      title: Text('Update name'),
      titleTextStyle: TextStyle(
        color: widget.isDarkMode ? Colors.white : Colors.black,
        fontWeight: FontWeight.w400,
        fontSize: 20,
      ),
      backgroundColor: widget.isDarkMode ? backColor : lightModeBackColor,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              controller: nameController,
              onChanged: (v) {
                setState(() {
                  canUpdate = true;
                });
              },
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Name',
                hintStyle: TextStyle(
                  color: widget.isDarkMode
                      ? Colors.white.withOpacity(0.4)
                      : Colors.black.withOpacity(0.4),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: widget.isDarkMode ? Colors.white : Colors.black),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: widget.isDarkMode ? Colors.white : Colors.black),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: widget.isDarkMode ? Colors.white : Colors.black),
                ),
              ),
            )
          ],
        ),
      ),
      actions: [
        FlatButton(
          child: Text(
            'CANCEL',
            style: TextStyle(color: mainColor),
          ),
          onPressed: () {
            Navigator.pop(context);
            // nameController.text = '';
          },
        ),
        FlatButton(
          child: Text(
            'UPDATE',
            style: TextStyle(
              color: nameController.text == '' || !canUpdate
                  ? widget.isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.2)
                  : mainColor,
            ),
          ),
          onPressed: nameController.text != ''
              ? () async {
                  await DatabaseServices().updateName(
                    userID,
                    nameController.text.trim(),
                  );
                  Navigator.pop(context);
                }
              : null,
        ),
      ],
    );
  }
}

void changeNameDialog(BuildContext context, bool isDarkMode, String prevName) {
  showDialog(
    context: context,
    builder: (context) {
      nameController.text = prevName;
      return ChangeNameDialog(
        context: context,
        isDarkMode: isDarkMode,
      );
    },
  );
}
