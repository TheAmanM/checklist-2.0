import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_todo_second/constants.dart';
import 'package:flutter/material.dart';

class Updates extends StatefulWidget {
  bool isDarkMode;
  Updates(
    this.isDarkMode,
  );
  @override
  _UpdatesState createState() => _UpdatesState();
}

class _UpdatesState extends State<Updates> {
  double width = 0;
  double height = 0;
  Map<String, dynamic> data = {};
  Widget updateCard(String title, String mapKey) {
    return (width == 0 || height == 0)
        ? Container()
        : Container(
            width: width,
            height: height / 2,
            child: Padding(
              padding: EdgeInsets.only(
                top: 16,
                //bottom: height / 4,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: height / 5),
                  Text(
                    data[mapKey].toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Future<void> setData() async {
    DocumentSnapshot doc = await Firestore.instance
        .collection('settings')
        .document('settings')
        .get();
    Map value = doc.data;

    setState(() {
      data["minimumVersion"] = value["minimumVersion"];
      data["latestVersion"] = value["latestVersion"];
      data["currentVersion"] = appVersion;
    });
    print(data);
  }

  @override
  void initState() {
    setData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height - 80;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: widget.isDarkMode ? backColor : lightModeBackColor,
      appBar: AppBar(
        title: Text('Updates'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          iconSize: backArrowSize,
        ),
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
      body: data.isNotEmpty
          ? Column(
              children: [
                updateCard('Current version', 'currentVersion'),
                updateCard('Latest version', 'latestVersion'),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
