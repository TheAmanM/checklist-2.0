import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_todo_second/constants.dart';
import 'package:firebase_todo_second/services/database.dart';
import 'package:flutter/material.dart';

class SecurityScreen extends StatefulWidget {
  Map security;
  String docID;
  bool isDarkMode;
  SecurityScreen(
    this.security,
    this.docID,
    this.isDarkMode,
  );

  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  Map security;
  List<Map> details;

  GlobalKey<ScaffoldState> securityKey = new GlobalKey();

  @override
  void initState() {
    security = widget.security;
    print("security: $security");
    details = [
      {
        "text": "Allow others to read and export data from this list",
        "value": security["canReadAndExport"] ?? false,
      },
      {
        "text": "Allow others to edit the name of this list",
        "value": security["canEditName"] ?? false,
      },
      {
        "text": "Allow others to edit the folder this list is in",
        "value": security["canEditFolder"] ?? false,
      },
      {
        "text": "Allow others to modify the items in this list",
        "value": security["canEditItems"] ?? false,
      },
      {
        "text": "Allow others to mark all items as incomplete",
        "value": security["canMarkIncomplete"] ?? false,
      },
      {
        "text": "Allow others to delete this list",
        "value": security["canDelete"] ?? false,
      },
    ];
    print("details: $details");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(details[1][1]);
    return Scaffold(
      key: securityKey,
      backgroundColor: widget.isDarkMode ? backColor : lightModeBackColor,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mainColor, accentColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Text(
          'Security Settings',
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          iconSize: backArrowSize,
          onPressed: () async {
            Map data = {
              "canReadAndExport": details[0]["value"],
              "canEditName": details[1]["value"],
              "canEditFolder": details[2]["value"],
              "canEditItems": details[3]["value"],
              "canMarkIncomplete": details[4]["value"],
              "canDelete": details[5]["value"],
            };
            DatabaseServices().setSecuritySettings(
              widget.docID,
              data,
            );
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 6,
        ),
        child:
            /* FlatButton(
          child: Text('Set all security flags to maximum'),
          onPressed: () async {
            Map data = {
              "canReadAndExport": false,
              "canEditName": false,
              "canEditFolder": false,
              "canEditItems": false,
              "canMarkIncomplete": false,
              "canDelete": false,
            };
            await DatabaseServices()
                .notesCollection
                .getDocuments()
                .then((QuerySnapshot value) {
              for (int i = 0; i < value.documents.length; i++) {
                value.documents[i].reference.updateData({
                  "security": data,
                });
              }
            });
            print('All done!');
          },
        ), */
            ListView.builder(
          itemBuilder: (context, index) {
            var data = details[index];
            return ListTile(
              title: Text(
                data["text"].toString(),
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              trailing: Switch(
                value: data["value"] ?? false,
                activeColor: mainColor,
                onChanged: (bool val) {
                  setState(() {
                    if (index != 0 && !(details[0]["value"])) {
                      final SnackBar snackBar = new SnackBar(
                        content: Text(
                            'Please allow others to read to toggle this option!'),
                        duration: Duration(seconds: 1),
                      );
                      securityKey.currentState.showSnackBar(
                        snackBar,
                      );
                    }
                    bool getVal = details[index]["value"];
                    details[index]["value"] = !getVal;

                    if (!details[0]["value"]) {
                      for (int i = 0; i < details.length; i++) {
                        details[i]["value"] = false;
                      }
                    }
                  });
                },
              ),
            );
          },
          itemCount: details.length,
        ),
      ),
    );
  }
}
