import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_todo_second/constants.dart';
import 'package:firebase_todo_second/screens/home/item_selector_screen.dart';
import 'package:firebase_todo_second/screens/home/notes_page.dart';
import 'package:firebase_todo_second/screens/home/security_screen.dart';
import 'package:firebase_todo_second/services/auth.dart';
import 'package:flutter/material.dart';
import '../../services/database.dart';

class NotesDetail extends StatefulWidget {
  String currentUserID;
  DocumentSnapshot data;
  bool isDarkMode;

  NotesDetail(
    // this.docID,
    // this.title,
    // this.listOwnerID,
    this.currentUserID,
    // this.securitySettings,

    this.data,
    this.isDarkMode,
  );

  @override
  _NotesDetailState createState() => _NotesDetailState();
}

TextEditingController addItemController = new TextEditingController();
TextEditingController editItemController = new TextEditingController();
bool initialValue = false;
bool enableOK = false;
bool keyboardVisible = false;
TextEditingController noteNameController = new TextEditingController();
bool enableSave = false;
GlobalKey<ScaffoldState> newScaffoldKey = new GlobalKey<ScaffoldState>();
AnimationController controller;
Animation<Offset> aniTween;
bool isDarkMode;

bool isUsersList;
bool othersCanRead = false;
bool canEditItems = false;
bool canEditFolder = false;
bool canDeleteList = false;
bool canEditListName = false;
bool canMarkIncomplete = false;

String docID;
String title;
String folderID;

String listOwnerID;
String currentUserID;

Map securitySettings;

class _NotesDetailState extends State<NotesDetail> {
  @override
  void initState() {
    super.initState();

    isDarkMode = widget.isDarkMode;
    docID = widget.data.documentID;
    title = widget.data["name"];
    listOwnerID = widget.data["ownerID"];
    currentUserID = widget.currentUserID;
    securitySettings = widget.data["security"];
    folderID = widget.data["folder"];

    print('list name: $title');
    print('document id: $docID');

    isUsersList = currentUserID == listOwnerID;
    DatabaseServices().notesCollection.document(docID).get().then((DocumentSnapshot value) {
      Map security = value.data["security"];
      othersCanRead = security["canReadAndExport"];
      canEditFolder = security["canEditFolder"];
      canEditItems = security["canEditItems"];
      canDeleteList = security["canDelete"];
      canEditListName = security["canEditName"];
      canMarkIncomplete = security["canMarkIncomplete"];
    });
  }

  @override
  String sortQueryString = 'name';
  Widget build(BuildContext context) {
    Firestore.instance.collection('notes').document(docID).get().then((DocumentSnapshot value) {
      sortQueryString = value.data['sortByName'] ? 'name' : 'done';
      //setState(() {});
    });
    return StreamBuilder(
      stream: Firestore.instance.collection('notes').document(docID).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> securitySnapshot) {
        if (securitySnapshot.hasData) {
          Map security = securitySnapshot.data["security"];
          // print('security values are: $security');
          // print(security["canEditFolder"]);
          othersCanRead = security["canReadAndExport"];
          canEditFolder = security["canEditFolder"];
          canEditItems = security["canEditItems"];
          canDeleteList = security["canDelete"];
          canEditListName = security["canEditName"];
          canMarkIncomplete = security["canMarkIncomplete"];
        }
        print("");
        print("othersCanRead: $othersCanRead");
        print("canEditFolder: $canEditFolder");
        print("canEditItems: $canEditItems");
        print("canDeleteList: $canDeleteList");
        print("canEditListName: $canEditListName");
        print("canMarkIncomplete: $canMarkIncomplete");
        print("");
        return StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance.collection('notes').document(docID).snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> sortSnapshot) => sortSnapshot.hasData
              ? StreamBuilder(
                  stream: sortSnapshot.data['sortByName'] == false ? Firestore.instance.collection('notes').document(docID).collection('items').orderBy("done").orderBy("name").snapshots() : Firestore.instance.collection('notes').document(docID).collection('items').orderBy("name").snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    /* Firestore.instance
                  .collection('notes')
                  .document(docID)
                  .get()
                  .then((DocumentSnapshot value) {
                sortQueryString = value.data['sortByName'] ? 'name' : 'done';
                //setState(() {});
              }); */
                    return Scaffold(
                      key: newScaffoldKey,
                      backgroundColor: isDarkMode ? backColor : lightModeBackColor,
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
                        leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                          ),
                          iconSize: backArrowSize,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        title: Text(title),
                        actions: [
                          /* IconButton(
                              icon: Icon(
                                whatToSortBy == 'done' ? Icons.check : Icons.sort,
                              ),
                              onPressed: () {
                                Firestore.instance
                                    .collection('notes')
                                    .document(docID)
                                    .updateData(
                                  {
                                    "sortByName":
                                        whatToSortBy == 'done' ? true : false,
                                  },
                                ).whenComplete(
                                  () {
                                    Scaffold.of(context).hideCurrentSnackBar();
                                    Scaffold.of(context).showSnackBar(
                                     CustomSnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Text(
                                          whatToSortBy == 'done'
                                              ? 'Now sorted by item names!'
                                              : 'Now sorted by incomplete tasks on top!',
                                        ),
                                        action: SnackBarAction(
                                          label: 'OK',
                                          onPressed: () {
                                            Scaffold.of(context)
                                                .hideCurrentSnackBar();
                                          },
                                        ),
                                      ),
                                    );
                                    setState(() {});
                                  },
                                );
                              },
                            ), */
                          if (canEditItems || isUsersList)
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () async {
                                setState(() {
                                  keyboardVisible = true;
                                });
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AddItemDialog(docID, isDarkMode);
                                  },
                                );
                                setState(() {
                                  keyboardVisible = false;
                                });
                              },
                            ),
                          /* 
                            Edit list name
                            Edit list folder
                            Sort list
                            Clear list
                            Delete list
                            */
                          StreamBuilder(
                              stream: Firestore.instance.collection('notes').document(docID).snapshots(),
                              builder: (context, AsyncSnapshot<DocumentSnapshot> sortValueSnapshot) {
                                return PopupMenuButton<int>(
                                  onSelected: (int value) async {
                                    /* popupMenuFunctionsList[value](
                                        context, title, docID); */
                                    if (value == 0) {
                                      setState(() {
                                        keyboardVisible = true;
                                      });
                                      noteNameController.text = title;
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return EditNoteName(
                                            noteName: title,
                                            docID: docID,
                                            isDarkMode: isDarkMode,
                                          );
                                        },
                                      );
                                      setState(() {
                                        keyboardVisible = false;
                                      });
                                      setState(() {
                                        Firestore.instance.collection('notes').document(docID).get().then(
                                              (DocumentSnapshot value) => title = value["name"],
                                            );
                                      });
                                      noteNameController.text = title;
                                    } else if (value == 1) {
                                      setState(() {
                                        keyboardVisible = true;
                                      });
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return FolderSelectorMenu(
                                            docID: docID,
                                            isDarkMode: isDarkMode,
                                          );
                                        },
                                      );
                                      setState(() {
                                        keyboardVisible = false;
                                      });
                                    } else if (value == 2) {
                                      Firestore.instance.collection('notes').document(docID).updateData({
                                        "sortByName": !sortValueSnapshot.data['sortByName'],
                                      });
                                      setState(() {});
                                    } else if (value == 3) {
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: isDarkMode ? backColor : lightModeBackColor,
                                            content: Text(
                                              'Are you sure you want to mark all items as incomplete?',
                                              style: TextStyle(
                                                color: isDarkMode ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            actions: [
                                              FlatButton(
                                                child: Text(
                                                  'NO',
                                                  style: TextStyle(
                                                    color: mainColor,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FlatButton(
                                                child: Text(
                                                  'YES',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                color: Colors.red,
                                                onPressed: () async {
                                                  //Navigator.pop(context);
                                                  await Firestore.instance.collection('notes').document(docID).collection('items').getDocuments().then(
                                                    (QuerySnapshot snapshot) {
                                                      for (DocumentSnapshot ds in snapshot.documents) {
                                                        ds.reference.updateData({
                                                          "done": false,
                                                        });
                                                      }
                                                    },
                                                  );
                                                  print('all items updated!');
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else if (value == 4) {
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: isDarkMode ? backColor : lightModeBackColor,
                                            content: Container(
                                              width: MediaQuery.of(context).size.width * 0.8,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Are you sure you want to delete the list?',
                                                    style: TextStyle(
                                                      color: isDarkMode ? Colors.white : Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                  Text(
                                                    '(Note: This action can not be undone)',
                                                    style: TextStyle(
                                                      color: isDarkMode ? Colors.white : Colors.black,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              FlatButton(
                                                child: Text(
                                                  'NO',
                                                  style: TextStyle(
                                                    color: mainColor,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              FlatButton(
                                                color: Colors.red,
                                                child: Text(
                                                  'YES',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  // Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  // await Future.delayed(
                                                  //   Duration(
                                                  //     seconds: 3,
                                                  //   ),
                                                  // );
                                                  // Navigator.pop(context);
                                                  // await Future.delayed(
                                                  //   Duration(
                                                  //     seconds: 3,
                                                  //   ),
                                                  // );
                                                  await Firestore.instance.collection('notes').document(docID).delete();
                                                  Navigator.pop(context);
                                                  // Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else if (value == 5) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ItemSelectorScreen(
                                              importedSnapshot: streamSnapshot,
                                              isAlphabeticallySorted: sortSnapshot.data['sortByName'] == true,
                                              darkMode: isDarkMode,
                                            );
                                          },
                                        ),
                                      );
                                    } else if (value == 6) {
                                      Map<String, dynamic> sendSettings = {
                                        "canMarkIncomplete": canMarkIncomplete,
                                        "canEditName": canEditListName,
                                        "canReadAndExport": othersCanRead,
                                        "canDelete": canDeleteList,
                                        "canEditItems": canEditItems,
                                        "canEditFolder": canEditFolder,
                                      };
                                      print('sendSettings: $sendSettings');
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return SecurityScreen(
                                              sendSettings,
                                              docID,
                                              isDarkMode,
                                            );
                                          },
                                        ),
                                      );
                                    } else {
                                      newScaffoldKey.currentState.showSnackBar(
                                        CustomSnackBar(
                                          Text(
                                            'An unexpected error occured',
                                          ),
                                          /* action: SnackBarAction(
                                                label: 'OK',
                                                onPressed: () {
                                                  newScaffoldKey.currentState
                                                      .hideCurrentSnackBar();
                                                },
                                              ), */
                                          Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  },
                                  color: isDarkMode ? backColor : lightModeBackColor,
                                  itemBuilder: (context) {
                                    return [
                                      if (canEditListName || isUsersList)
                                        PopupMenuItem(
                                          value: 0,
                                          child: Text(
                                            'Edit list name',
                                            style: TextStyle(
                                              color: isDarkMode ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        ),
                                      if (canEditFolder || isUsersList)
                                        PopupMenuItem(
                                          value: 1,
                                          child: Text(
                                            'Edit folder',
                                            style: TextStyle(
                                              color: isDarkMode ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        ),
                                      PopupMenuItem(
                                        value: 2,
                                        child: Text(
                                          sortValueSnapshot.hasData
                                              ? sortValueSnapshot.data['sortByName'] == true
                                                  ? 'Sort by completed'
                                                  : 'Sort alphabetically'
                                              : '',
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ),
                                      if (canMarkIncomplete || isUsersList)
                                        PopupMenuItem(
                                          value: 3,
                                          child: Text(
                                            'Mark all items incomplete',
                                            style: TextStyle(
                                              color: isDarkMode ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        ),
                                      if (canDeleteList || isUsersList)
                                        PopupMenuItem(
                                          value: 4,
                                          child: Text(
                                            'Delete list',
                                            style: TextStyle(
                                              color: isDarkMode ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        ),
                                      PopupMenuItem(
                                        value: 5,
                                        child: Text(
                                          'Export items',
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ),
                                      if (isUsersList)
                                        PopupMenuItem(
                                          value: 6,
                                          child: Text(
                                            'Security',
                                            style: TextStyle(
                                              color: isDarkMode ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        )
                                    ];
                                  },
                                );
                              })
                        ],
                      ),
                      body: !keyboardVisible
                          ? streamSnapshot.hasData
                              ? streamSnapshot.data.documents.length != 0
                                  ? Padding(
                                      padding: EdgeInsets.all(0),
                                      child: Theme(
                                        data: Theme.of(context).copyWith(
                                          accentColor: mainColor,
                                        ),
                                        child: ListView.builder(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 0,
                                            vertical: 16,
                                          ),
                                          itemBuilder: (
                                            BuildContext context,
                                            int index,
                                          ) {
                                            return Dismissible(
                                              onDismissed: (DismissDirection d) async {
                                                /* await Firestore.instance
                                          .collection('notes')
                                          .document(
                                            streamSnapshot
                                                  .data.documents[index].documentID,
                                          )
                                          .delete(); */

                                                //TODO: DO I NEED THIS FUNCTION?

                                                await Firestore.instance
                                                    .collection('notes')
                                                    .document(
                                                      docID,
                                                    )
                                                    .collection('items')
                                                    .document(
                                                      streamSnapshot.data.documents[index].documentID,
                                                    )
                                                    .delete();
                                                setState(() {});
                                              },
                                              confirmDismiss: (DismissDirection d) async {
                                                if (sortSnapshot.data['sortByName']) {
                                                  if (d == DismissDirection.startToEnd) {
                                                    bool returnBool = false;
                                                    if (canEditItems || isUsersList) {
                                                      await showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            backgroundColor: widget.isDarkMode ? backColor : lightModeBackColor,
                                                            content: Text(
                                                              'Are you sure you want to delete this task?',
                                                              style: TextStyle(
                                                                color: widget.isDarkMode ? Colors.white : Colors.black,
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                            actions: [
                                                              FlatButton(
                                                                child: Text(
                                                                  'NO',
                                                                  style: TextStyle(color: mainColor),
                                                                ),
                                                                onPressed: () {
                                                                  returnBool = false;
                                                                  Navigator.pop(context);
                                                                },
                                                              ),
                                                              FlatButton(
                                                                child: Text(
                                                                  'YES',
                                                                  style: TextStyle(color: mainColor),
                                                                ),
                                                                onPressed: () {
                                                                  returnBool = true;
                                                                  Navigator.pop(context);
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      final SnackBar snackBar = CustomSnackBar(
                                                        Text('Sorry, you do not have permissions to edit this list!'),
                                                        Duration(seconds: 1),
                                                      );
                                                      newScaffoldKey.currentState.showSnackBar(snackBar);
                                                    }
                                                    return returnBool;
                                                  } else {
                                                    bool completedBool = false;
                                                    /* await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                                backgroundColor: backColor,
                                                content: Text(
                                                  'Has this task been completed?',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                actions: [
                                                  FlatButton(
                                                    child: Text(
                                                      'NO',
                                                      style:
                                                          TextStyle(color: mainColor),
                                                    ),
                                                    onPressed: () {
                                                      completedBool = false;
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  FlatButton(
                                                    child: Text(
                                                      'YES',
                                                      style:
                                                          TextStyle(color: mainColor),
                                                    ),
                                                    onPressed: () {
                                                      completedBool = true;
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                            );
                                          },
                                          ); */

                                                    /* Firestore.instance
                                                            .collection('notes')
                                                            .document(
                                                                docID)
                                                            .collection('items')
                                                            .document(
                                                                streamSnapshot
                                                                    .data
                                                                    .documents[
                                                                        index]
                                                                    .documentID)
                                                            .updateData(
                                                          {
                                                            "done": !streamSnapshot
                                                                    .data
                                                                    .documents[
                                                                index]["done"],
                                                          },
                                                        ); */
                                                    if (canEditItems || isUsersList) {
                                                      streamSnapshot.data.documents[index].reference.updateData({"done": !streamSnapshot.data.documents[index]["done"]});
                                                      print(streamSnapshot.data.documents[index].documentID);
                                                    } else {
                                                      final SnackBar snackBar = CustomSnackBar(
                                                        Text('Sorry, you do not have permissions to edit this list!'),
                                                        Duration(seconds: 1),
                                                      );
                                                      newScaffoldKey.currentState.showSnackBar(snackBar);
                                                    }
                                                    return false;
                                                  }
                                                } else {
                                                  newScaffoldKey.currentState.showSnackBar(
                                                    CustomSnackBar(
                                                      /* action:
                                                              SnackBarAction(
                                                            label: 'OK',
                                                            onPressed: () {
                                                              newScaffoldKey
                                                                  .currentState
                                                                  .hideCurrentSnackBar();
                                                            },
                                                          ), */
                                                      Text(
                                                        'You can only toggle items when the list is sorted alphabetically!',
                                                      ),
                                                      Duration(seconds: 1),
                                                    ),
                                                  );
                                                  return false;
                                                }
                                              },
                                              key: Key(
                                                streamSnapshot.data.documents[index].documentID,
                                              ),
                                              secondaryBackground: Container(
                                                color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.2),
                                                alignment: Alignment.centerRight,
                                                child: Padding(
                                                  padding: EdgeInsets.only(right: 20),
                                                  child: Icon(Icons.edit, color: Colors.white),
                                                ),
                                              ),
                                              background: Container(
                                                color: Colors.red,
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 20),
                                                  child: Icon(Icons.delete, color: Colors.white),
                                                ),
                                              ),
                                              child: ListTile(
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 28,
                                                  vertical: 0,
                                                ),
                                                title: Text(
                                                  streamSnapshot.data.documents[index]["name"].toString(),
                                                  style: TextStyle(
                                                    color: isDarkMode
                                                        ? streamSnapshot.data.documents[index]["done"]
                                                            ? Colors.white.withOpacity(0.5)
                                                            : Colors.white
                                                        : streamSnapshot.data.documents[index]["done"]
                                                            ? Colors.black.withOpacity(0.5)
                                                            : Colors.black,
                                                    decoration: streamSnapshot.data.documents[index]["done"] ? TextDecoration.lineThrough : TextDecoration.none,
                                                  ),
                                                ),
                                                onTap: () async {
                                                  if (canEditItems || isUsersList) {
                                                    initialValue = streamSnapshot.data.documents[index]["done"] ?? false;
                                                    editItemController.text = streamSnapshot.data.documents[index]["name"];
                                                    //enableOK = false;
                                                    setState(() {
                                                      keyboardVisible = true;
                                                    });
                                                    await showDialog(
                                                      //barrierDismissible: false,
                                                      context: context,
                                                      builder: (context) {
                                                        print('initialValue = $initialValue');
                                                        return EditItemWidget(
                                                          docID: docID,
                                                          itemID: streamSnapshot.data.documents[index].documentID,
                                                          isDarkMode: isDarkMode,
                                                        );
                                                      },
                                                    );
                                                    setState(() {
                                                      keyboardVisible = false;
                                                    });
                                                    enableOK = false;
                                                  } else {
                                                    final SnackBar snackBar = CustomSnackBar(
                                                      Text('Sorry, you do not have permissions to edit this list!'),
                                                      Duration(seconds: 1),
                                                    );
                                                    newScaffoldKey.currentState.showSnackBar(snackBar);
                                                  }
                                                },
                                              ),
                                            );
                                          },
                                          itemCount: streamSnapshot.hasData ? streamSnapshot.data.documents.length : 0,
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        'Nothing here yet!',
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.white : Colors.black,
                                        ),
                                      ),
                                    )
                              : Center(
                                  child: CircularProgressIndicator(),
                                )
                          : Container(
                              color: isDarkMode ? backColor : lightModeBackColor,
                            ),
                    );
                  })
              : Center(
                  child: Text('sortSnapshot data has not arrived yet!'),
                ),
        );
      },
    );
  }
}

class EditItemWidget extends StatefulWidget {
  String docID;
  String itemID;
  bool isDarkMode;
  EditItemWidget({
    this.docID,
    this.itemID,
    this.isDarkMode,
  });
  @override
  _EditItemWidgetState createState() => _EditItemWidgetState();
}

class _EditItemWidgetState extends State<EditItemWidget> {
  @override
  Widget build(BuildContext context) {
    String docID = widget.docID;
    String itemID = widget.itemID;
    return AlertDialog(
      elevation: 8,
      title: Text('Edit Item'),
      titleTextStyle: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
        fontWeight: FontWeight.w400,
        fontSize: 20,
      ),
      backgroundColor: isDarkMode ? backColor : lightModeBackColor,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (text) {
                if (!enableOK) {
                  setState(() {
                    enableOK = true;
                  });
                }
              },
              controller: editItemController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Item name',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Task Completed?',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Theme(
                  data: ThemeData(
                    unselectedWidgetColor: isDarkMode ? Colors.white : backColor,
                  ),
                  child: Checkbox(
                    activeColor: mainColor,
                    checkColor: Colors.white,
                    onChanged: (v) {
                      enableOK = true;
                      //print('v: $v');
                      setState(() {
                        v != v;
                        initialValue = v;
                        print(initialValue);
                      });
                    },
                    value: initialValue,
                  ),
                ),
              ],
            ),
            /* Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FlatButton(
                      child: Text('DETELE'),
                      onPressed: () {},
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FlatButton(
                      child: Text(
                        'CANCEL',
                        style: TextStyle(color: mainColor),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        editItemController.text = '';
                      },
                    ),
                    FlatButton(
                      child: Text(
                        'DONE',
                        style: TextStyle(
                          color: enableOK
                              ? mainColor
                              : Colors.white.withOpacity(0.2),
                        ),
                      ),
                      onPressed: enableOK == true
                          ? () async {
                              await DatabaseServices().editItem(
                                  docID,
                                  editItemController.text,
                                  itemID,
                                  initialValue);
                              Navigator.pop(context);
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ), */
            /* Row(
              children: [
                FlatButton(
                  child: Text(
                    'DETELE',
                    style: TextStyle(color: mainColor),
                  ),
                  onPressed: () {},
                ),
                SizedBox(
                  child: Expanded(
                    child: Container(),
                  ),
                ),
                FlatButton(
                  child: Text(
                    'CANCEL',
                    style: TextStyle(color: mainColor),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    editItemController.text = '';
                  },
                ),
                FlatButton(
                  child: Text(
                    'DONE',
                    style: TextStyle(
                      color:
                          enableOK ? mainColor : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  onPressed: enableOK == true
                      ? () async {
                          await DatabaseServices().editItem(docID,
                              editItemController.text, itemID, initialValue);
                          Navigator.pop(context);
                        }
                      : null,
                ),
              ],
            ) */
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
            editItemController.text = '';
          },
        ),
        FlatButton(
          child: Text(
            'DONE',
            style: TextStyle(
              color: enableOK ? mainColor : Colors.white.withOpacity(0.2),
            ),
          ),
          onPressed: enableOK == true
              ? () async {
                  await DatabaseServices().editItem(docID, editItemController.text, itemID, initialValue);
                  Navigator.pop(context);
                }
              : null,
        ),
      ],
    );
  }
}

class AddItemDialog extends StatefulWidget {
  String docId;
  bool isDarkMode;
  AddItemDialog(
    this.docId,
    this.isDarkMode,
  );
  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 8,
      title: Text('Add new Item'),
      titleTextStyle: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
        fontWeight: FontWeight.w400,
        fontSize: 20,
      ),
      backgroundColor: isDarkMode ? backColor : lightModeBackColor,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (v) {
                setState(() {});
              },
              controller: addItemController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Item name',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
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
            addItemController.text = '';
          },
        ),
        FlatButton(
          child: Text(
            'ADD',
            style: TextStyle(
              color: addItemController.text == ''
                  ? isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.2)
                  : mainColor,
            ),
          ),
          onPressed: addItemController.text != ''
              ? () async {
                  await DatabaseServices().addItem(widget.docId, addItemController.text);
                  Navigator.pop(context);
                  addItemController.text = '';
                }
              : null,
        ),
      ],
    );
  }
}

/* 
List<Function> popupMenuFunctionsList = [
// Edit list name
  (context, String title, String docID) async {
    noteNameController.text = title;
    await showDialog(
      context: context,
      builder: (context) {
        return EditNoteName(
          noteName: title,
          docID: docID,
        );
      },
    );
    noteNameController.text = title;
  },
// Edit list folder
// Sort list
// Clear list
// Delete list
]; 
*/

class EditNoteName extends StatefulWidget {
  String noteName;
  String docID;
  bool isDarkMode;
  EditNoteName({
    this.noteName,
    this.docID,
    this.isDarkMode,
  });
  @override
  _EditNoteNameState createState() => _EditNoteNameState();
}

class _EditNoteNameState extends State<EditNoteName> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: isDarkMode ? backColor : lightModeBackColor,
      title: Text(
        'Edit list name',
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (v) {
                setState(() {});
              },
              autofocus: true,
              controller: noteNameController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'List name',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Align(
              alignment: Alignment.centerRight,
              child: FlatButton(
                child: Text(
                  'SAVE',
                  style: TextStyle(
                    color: noteNameController.text == ''
                        ? isDarkMode
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.4)
                        : mainColor,
                  ),
                ),
                onPressed: noteNameController.text == ''
                    ? null
                    : () async {
                        await Firestore.instance.collection('notes').document(docID).updateData(
                          {
                            "name": noteNameController.text,
                          },
                        );
                        Navigator.pop(context);
                        setState(() {});
                      },
              ),
            )
            /* Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FlatButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    'DELETE',
                    style: TextStyle(
                      color: mainColor,
                    ),
                  ),
                  onPressed: () async {
                    await Firestore.instance
                        .collection('notes')
                        .document(snapshot.data.documents[index].documentID)
                        .delete();
                    Navigator.pop(context);
                    scaffoldKey.currentState.showSnackBar(
                     CustomSnackBar(
                        duration: Duration(seconds: 1),
                        content: Text('Deleted note successfully!'),
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {
                            scaffoldKey.currentState.hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
                  },
                ),
                FlatButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    'SAVE',
                    style: TextStyle(
                      color: enableNoteNameSaving
                          ? mainColor
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  onPressed: () async {
                    await Firestore.instance
                        .collection('notes')
                        .document(snapshot.data.documents[index].documentID)
                        .updateData({
                      "name": noteNameController.text,
                    });
                    Navigator.pop(context);
                    scaffoldKey.currentState.showSnackBar(
                     CustomSnackBar(
                        duration: Duration(seconds: 1),
                        content: Text('Updated note name successfully!'),
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {
                            scaffoldKey.currentState.hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ), */
          ],
        ),
      ),
    );
  }
}

class FolderSelectorMenu extends StatefulWidget {
  String docID;
  bool isDarkMode;
  FolderSelectorMenu({
    this.docID,
    this.isDarkMode,
  });
  @override
  _FolderSelectorMenuState createState() => _FolderSelectorMenuState();
}

class _FolderSelectorMenuState extends State<FolderSelectorMenu> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: isDarkMode ? backColor : lightModeBackColor,
      content: StreamBuilder(
        stream: Firestore.instance.collection('folders').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> folderSelectorSnapshot) {
          if (folderSelectorSnapshot.hasData) {
            List<Widget> returnList = folderSelectorSnapshot.data.documents
                .map(
                  (DocumentSnapshot doc) => ListTile(
                    // groupValue: "groupValue",
                    // value: folderID == doc.documentID,
                    onTap: () async {
                      await Firestore.instance.collection('notes').document(docID).updateData(
                        {
                          "folder": doc.documentID,
                        },
                      );
                      Navigator.pop(context);
                      setState(() {});
                    },
                    title: Text(
                      doc['name'].toString(),
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                )
                .toList();
            returnList.insert(
              0,
              ListTile(
                // groupValue: "groupValue",
                // value: folderID == "",
                title: Text(
                  'Uncategorized',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () async {
                  await Firestore.instance.collection('notes').document(docID).updateData({"folder": ""});
                  Navigator.pop(context);
                },
              ),
            );
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    /* folderSelectorSnapshot.data.documents
                          .map(
                            (DocumentSnapshot doc) => ListTile(
                              onTap: () async {
                                await Firestore.instance
                                    .collection('notes')
                                    .document(docID)
                                    .updateData(
                                  {
                                    "folder": doc.documentID,
                                  },
                                );
                                Navigator.pop(context);
                                setState(() {});
                              },
                              title: Text(
                                doc['name'].toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList()
                          .insert(
                            0,
                            ListTile(
                              title: Text('Uncategorized'),
                              onTap: () async {
                                await Firestore.instance
                                    .collection('notes')
                                    .document(docID)
                                    .updateData({"folder": ""});
                                Navigator.pop(context);
                              },
                            ),
                          ), */
                    returnList,
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
