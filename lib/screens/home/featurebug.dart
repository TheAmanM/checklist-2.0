import 'package:firebase_todo_second/constants.dart';
import 'package:firebase_todo_second/services/database.dart';
import 'package:flutter/material.dart';

class FeatureBug extends StatefulWidget {
  final bool isDarkMode;
  FeatureBug(this.isDarkMode);

  @override
  _FeatureBugState createState() => _FeatureBugState();
}

class _FeatureBugState extends State<FeatureBug> {
  bool isDarkMode;
  bool isFeature = true;
  TextEditingController dataController;

  @override
  void initState() {
    isDarkMode = widget.isDarkMode;
    dataController = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: isDarkMode ? backColor : lightModeBackColor,
      appBar: AppBar(
        title: Text('Feature request / Bug report'),
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: backArrowSize,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        // shrinkWrap: true,
        children: [
          ListTile(
            title: Row(
              children: [
                Text(
                  'This is a ',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  isFeature ? 'feature' : 'bug',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: Switch(
              value: isFeature,
              onChanged: (v) {
                setState(() {
                  isFeature = !(isFeature);
                });
              },
              activeColor: mainColor,
              activeTrackColor: mainColor.withOpacity(0.5),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey[350],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: TextField(
              maxLines: null,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              controller: dataController,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: isFeature
                    ? 'Explain the feature you would like to be added'
                    : 'Explain the bug that you found',
                hintStyle: TextStyle(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.4)
                      : Colors.black.withOpacity(0.4),
                ),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            widget.isDarkMode ? Colors.white : Colors.black)),
                disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            widget.isDarkMode ? Colors.white : Colors.black)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            widget.isDarkMode ? Colors.white : Colors.black)),
              ),
            ),
          ),
          // Flexible(child: Spacer()),
          Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: FlatButton(
                child: Text(
                  'SEND',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (dataController.text != '') {
                    await DatabaseServices().submitFeatureBug(
                      isFeature,
                      dataController.text,
                    );
                    Scaffold.of(context).showSnackBar(
                      CustomSnackBar(
                        Text(
                          'Request sent, thank you!',
                        ),
                        Duration(
                          seconds: 1,
                        ),
                      ),
                    );
                  } else {
                    Scaffold.of(context).showSnackBar(
                      CustomSnackBar(
                        Text(
                          'Please fill the text field to send your request',
                        ),
                        Duration(
                          seconds: 1,
                        ),
                      ),
                    );
                  }
                },
                color: mainColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
