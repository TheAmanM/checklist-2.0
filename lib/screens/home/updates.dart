import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_todo_second/constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Updates extends StatefulWidget {
  final bool isDarkMode;
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
      data["downloadUrl"] = value["downloadUrl"];
      data["backupDownloadUrl"] = value["backupDownloadUrl"];
    });
    print(data);
  }

  Widget checkUpdateWidget() {
    if (data["currentVersion"] < data["latestVersion"]) {
      String versionNow = versionConverter(data["currentVersion"].toString());
      String newestVersion = versionConverter(data["latestVersion"].toString());
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.update,
              size: MediaQuery.of(context).size.width * 0.6,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'There is a new update available!',
                    style: TextStyle(
                      fontSize: 20,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (await canLaunch(data["downloadUrl"])) {
                        launch(data["backupDownloadUrl"]);
                      } else if (await canLaunch(data["backupDownloadUrl"])) {
                        launch(data["backupDownloadUrl"]);
                      } else {
                        Navigator.pop(context);
                        SnackBar snackbar = CustomSnackBar(
                          Text("Sorry, an unexpected error occured"),
                          Duration(seconds: 1),
                        );
                        Scaffold.of(context).showSnackBar(snackbar);
                      }
                    },
                    child: Container(
                      color: widget.isDarkMode ? backColor : lightModeBackColor,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(text: '', children: [
                          TextSpan(
                            text: 'Click ',
                            style: TextStyle(
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 20,
                            ),
                          ),
                          TextSpan(
                            text: 'here',
                            style: TextStyle(
                              color: mainColor,
                              fontSize: 20,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' to go from version $versionNow to $newestVersion',
                            style: TextStyle(
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ]),
                        // textAlign: TextAlign.center,
                        /* style: TextStyle(
                          // color: widget.isDarkMode ? Colors.white : Colors.black,
                          color: mainColor,
                          fontSize: 20,
                        ), */
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (data["currentVersion"] > data["latestVersion"]) {
      String version = versionConverter(data["currentVersion"].toString());
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.science_outlined,
              size: MediaQuery.of(context).size.width * 0.6,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: Column(
                children: [
                  Text(
                    'Your app version is in beta! ($version)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (await canLaunch(data["downloadUrl"])) {
                        launch(data["backupDownloadUrl"]);
                      } else if (await canLaunch(data["backupDownloadUrl"])) {
                        launch(data["backupDownloadUrl"]);
                      } else {
                        Navigator.pop(context);
                        SnackBar snackbar = CustomSnackBar(
                          Text("Sorry, an unexpected error occured"),
                          Duration(seconds: 1),
                        );
                        Scaffold.of(context).showSnackBar(snackbar);
                      }
                    },
                    child: Container(
                      color: widget.isDarkMode ? backColor : lightModeBackColor,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: '',
                          children: [
                            TextSpan(
                              text:
                                  'Downgrade to the latest supported version ',
                              style: TextStyle(
                                color: widget.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 20,
                              ),
                            ),
                            TextSpan(
                              text: 'here',
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 20,
                              ),
                            ),
                            TextSpan(
                              text: '.',
                              style: TextStyle(
                                color: widget.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      String displayAppVersion =
          versionConverter(data["currentVersion"].toString());
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              size: MediaQuery.of(context).size.width * 0.6,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: Text(
                'Your current app version ($displayAppVersion) is\nup to date!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      );
    }
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
          ? /* Column(
              children: [
                updateCard('Current version', 'currentVersion'),
                updateCard('Latest version', 'latestVersion'),
              ],
            ) */
          checkUpdateWidget()
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
