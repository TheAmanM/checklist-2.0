//import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_todo_second/services/import_export.dart';
import 'package:firebase_todo_second/constants.dart';

import 'package:clipboard/clipboard.dart';

class ItemSelectorScreen extends StatefulWidget {
  AsyncSnapshot<QuerySnapshot> importedSnapshot;
  bool isAlphabeticallySorted;
  ItemSelectorScreen({
    this.importedSnapshot,
    this.isAlphabeticallySorted,
  });

  @override
  _ItemSelecorScreenState createState() => _ItemSelecorScreenState();
}

class _ItemSelecorScreenState extends State<ItemSelectorScreen> {
  ImportExport ie;
  AsyncSnapshot<QuerySnapshot> importedSnapshot;
  bool isAlphabeticallySorted;
  List<bool> values;

  void unselectAllItems() {
    values = List.generate(
      importedSnapshot.data.documents.length,
      (index) => false,
    );
  }

  void selectAllItems() {
    values = List.generate(
      importedSnapshot.data.documents.length,
      (index) => true,
    );
  }

  void handleOnCheckmarkPress(BuildContext customContext) {
    List<Map<String, dynamic>> maps = [];
    String returnValue = '';
    /*
      1) Get List of Maps
      2) Pass List to export function
      3) Alert dialog
    */

    for (int i = 0; i < importedSnapshot.data.documents.length; i++) {
      if (values[i] == true)
        maps.add({
          "name": importedSnapshot.data.documents[i].data["name"],
          "isDone": values[i],
        });
    }

    returnValue = ie.exportData(maps);

    showDialog(
      context: customContext,
      child: AlertDialog(
        backgroundColor: backColor,
        title: Text(
          'Data has been exported!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        /* content:
            /* Text(
              'Exported code',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ), */
          Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            color: lightBackColor,
            height: 100,
            child: Text(
              returnValue,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ), */
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 1,
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.content_copy,
                  ),
                  color: Colors.white,
                  onPressed: () {
                    //Navigator.pop(context);
                    /* ClipboardManager.copyToClipBoard(returnValue).then((_) {
                    Navigator.pop(context);
                    final snackBar = SnackBar(
                      content: Text('Copied to Clipboard!'),
                      duration: Duration(seconds: 1),
                    );
                    Scaffold.of(context).showSnackBar(snackBar); 
                  });
                    */
                    FlutterClipboard.copy(returnValue).then((value) {
                      final snackBar = SnackBar(
                        content: Text('Copied to Clipboard!'),
                        duration: Duration(seconds: 1),
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.share,
                  ),
                  color: Colors.white,
                  onPressed: () {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Feature currently in development!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    importedSnapshot = widget.importedSnapshot;
    values = new List.generate(
      importedSnapshot.data.documents.length,
      (index) => false,
    );
    isAlphabeticallySorted = widget.isAlphabeticallySorted;
    ie = new ImportExport();

    for (int i = 0; i < importedSnapshot.data.documents.length; i++) {
      values[i] = false;
    }

    print(values);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
        leading: IconButton(
          iconSize: backArrowSize,
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            color: Colors.white,
            onPressed: () {
              bool isEmpty = true;
              for (int i = 0; i < importedSnapshot.data.documents.length; i++) {
                if (values[i] == true) {
                  isEmpty = false;
                }
              }
              if (isEmpty) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Nothing selected!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              } else {
                handleOnCheckmarkPress(context);
              }
            },
          ),
          SizedBox(width: 4),
        ],
        title: Text(
          'Export items',
          style: TextStyle(
            color: Colors.white,
          ),
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
        bottom: PreferredSize(
          child: Row(
            children: [
              SizedBox(width: 12),
              FlatButton(
                child: Text(
                  'Select All',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    selectAllItems();
                  });
                },
              ),
              FlatButton(
                child: Text(
                  'Deselect All',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    unselectAllItems();
                  });
                },
              ),
            ],
          ),
          preferredSize: Size(
            MediaQuery.of(context).size.width,
            52,
          ),
        ),
      ),
      body: ListView.builder(
          padding: EdgeInsets.symmetric(
            vertical: 16,
          ),
          itemCount: importedSnapshot.data.documents.length,
          itemBuilder: (context, i) {
            String name = importedSnapshot.data.documents[i].data["name"];
            return ListTile(
              leading: Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.white,
                ),
                child: Checkbox(
                  activeColor: mainColor,
                  value: values[i],
                  onChanged: (bool val) {
                    setState(() {
                      if (values[i] == true) {
                        values[i] = false;
                      } else {
                        values[i] = true;
                      }
                      print(values[i]);
                    });
                  },
                ),
              ),
              title: Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          }),
    );
  }
}
