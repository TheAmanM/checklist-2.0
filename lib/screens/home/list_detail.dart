import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_todo_second/constants.dart';
import 'package:firebase_todo_second/screens/home/notes_page.dart';
import 'package:firebase_todo_second/services/auth.dart';
import 'package:flutter/material.dart';
import '../../services/database.dart';

class NotesDetail extends StatefulWidget {
  String docID;
  String title;
  NotesDetail(
    this.docID,
    this.title,
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

class _NotesDetailState extends State<NotesDetail>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    aniTween = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0.0),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticIn,
      ),
    );
  }

  @override
  String sortQueryString = 'name';
  Widget build(BuildContext context) {
    Firestore.instance
        .collection('notes')
        .document(widget.docID)
        .get()
        .then((DocumentSnapshot value) {
      sortQueryString = value.data['sortByName'] ? 'name' : 'done';
      //setState(() {});
    });
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection('notes')
          .document(widget.docID)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> sortSnapshot) =>
          sortSnapshot.hasData
              ? StreamBuilder(
                  stream: sortSnapshot.data['sortByName'] == false
                      ? Firestore.instance
                          .collection('notes')
                          .document(widget.docID)
                          .collection('items')
                          .orderBy("done")
                          .orderBy("name")
                          .snapshots()
                      : Firestore.instance
                          .collection('notes')
                          .document(widget.docID)
                          .collection('items')
                          .orderBy("name")
                          .snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                    /* Firestore.instance
                .collection('notes')
                .document(widget.docID)
                .get()
                .then((DocumentSnapshot value) {
              sortQueryString = value.data['sortByName'] ? 'name' : 'done';
              //setState(() {});
            }); */
                    String whatToSortBy =
                        sortSnapshot.data['sortByName'] ? "name" : "done";
                    print(sortSnapshot.data["sortByName"]);
                    return Scaffold(
                      key: newScaffoldKey,
                      backgroundColor: backColor,
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
                        title: Text(widget.title),
                        actions: [
                          /* IconButton(
                            icon: Icon(
                              whatToSortBy == 'done' ? Icons.check : Icons.sort,
                            ),
                            onPressed: () {
                              Firestore.instance
                                  .collection('notes')
                                  .document(widget.docID)
                                  .updateData(
                                {
                                  "sortByName":
                                      whatToSortBy == 'done' ? true : false,
                                },
                              ).whenComplete(
                                () {
                                  Scaffold.of(context).hideCurrentSnackBar();
                                  Scaffold.of(context).showSnackBar(
                                    SnackBar(
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
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () async {
                              setState(() {
                                keyboardVisible = true;
                              });
                              await showDialog(
                                context: context,
                                builder: (context) {
                                  return AddItemDialog(widget.docID);
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
                              stream: Firestore.instance
                                  .collection('notes')
                                  .document(widget.docID)
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<DocumentSnapshot>
                                      sortValueSnapshot) {
                                return PopupMenuButton<int>(
                                  onSelected: (int value) async {
                                    /* popupMenuFunctionsList[value](
                                      context, widget.title, widget.docID); */
                                    if (value == 0) {
                                      setState(() {
                                        keyboardVisible = true;
                                      });
                                      noteNameController.text = widget.title;
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return EditNoteName(
                                            noteName: widget.title,
                                            docID: widget.docID,
                                          );
                                        },
                                      );
                                      setState(() {
                                        keyboardVisible = false;
                                      });
                                      setState(() {
                                        Firestore.instance
                                            .collection('notes')
                                            .document(widget.docID)
                                            .get()
                                            .then(
                                              (DocumentSnapshot value) =>
                                                  widget.title = value["name"],
                                            );
                                      });
                                      noteNameController.text = widget.title;
                                    } else if (value == 1) {
                                      setState(() {
                                        keyboardVisible = true;
                                      });
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return FolderSelectorMenu(
                                              docID: widget.docID);
                                        },
                                      );
                                      setState(() {
                                        keyboardVisible = false;
                                      });
                                    } else if (value == 2) {
                                      Firestore.instance
                                          .collection('notes')
                                          .document(widget.docID)
                                          .updateData({
                                        "sortByName": !sortValueSnapshot
                                            .data['sortByName'],
                                      });
                                      setState(() {});
                                    } else if (value == 3) {
                                      bool isOwner = false;
                                      isOwner = await sortValueSnapshot
                                              .data["ownerID"] ==
                                          await AuthServices()
                                              .getCurrentUserID();
                                      print(sortValueSnapshot.data["ownerID"]);
                                      isOwner
                                          ? await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  backgroundColor: backColor,
                                                  content: Text(
                                                    'Are you sure you want to mark all items as incomplete?',
                                                    style: TextStyle(
                                                      color: Colors.white,
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
                                                        await Firestore.instance
                                                            .collection('notes')
                                                            .document(
                                                                widget.docID)
                                                            .collection('items')
                                                            .getDocuments()
                                                            .then(
                                                          (QuerySnapshot
                                                              snapshot) {
                                                            for (DocumentSnapshot ds
                                                                in snapshot
                                                                    .documents) {
                                                              ds.reference
                                                                  .updateData({
                                                                "done": false,
                                                              });
                                                            }
                                                          },
                                                        );
                                                        print(
                                                            'all items updated!');
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            )
                                          : newScaffoldKey.currentState
                                              .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "You can only edit all items at once from your own list!",
                                                ),
                                                duration: Duration(seconds: 1),
                                                action: SnackBarAction(
                                                  label: 'OK',
                                                  onPressed: () => newScaffoldKey
                                                      .currentState
                                                      .hideCurrentSnackBar(),
                                                ),
                                              ),
                                            );
                                    } else if (value == 4) {
                                      if (await sortValueSnapshot
                                              .data["ownerID"] ==
                                          await AuthServices()
                                              .getCurrentUserID()) {
                                        await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor: backColor,
                                              content: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Are you sure you want to delete the list?',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Text(
                                                      '(Note: This action can not be undone)',
                                                      style: TextStyle(
                                                        color: Colors.white,
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
                                                    Navigator.pop(context);
                                                    await Firestore.instance
                                                        .collection('notes')
                                                        .document(widget.docID)
                                                        .delete();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        newScaffoldKey.currentState
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "You can only delete your own list!",
                                            ),
                                            duration: Duration(seconds: 1),
                                            action: SnackBarAction(
                                              label: 'OK',
                                              onPressed: () => newScaffoldKey
                                                  .currentState
                                                  .hideCurrentSnackBar(),
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      newScaffoldKey.currentState.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'An unexpected error occured',
                                          ),
                                          action: SnackBarAction(
                                            label: 'OK',
                                            onPressed: () {
                                              newScaffoldKey.currentState
                                                  .hideCurrentSnackBar();
                                            },
                                          ),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  },
                                  color: backColor,
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                        value: 0,
                                        child: Text(
                                          'Edit list name',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 1,
                                        child: Text(
                                          'Edit folder',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 2,
                                        child: Text(
                                          sortValueSnapshot.hasData
                                              ? sortValueSnapshot
                                                          .data['sortByName'] ==
                                                      true
                                                  ? 'Sort by completed'
                                                  : 'Sort alphabetically'
                                              : '',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 3,
                                        child: Text(
                                          'Mark all items incomplete',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 4,
                                        child: Text(
                                          'Delete List',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
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
                                              onDismissed:
                                                  (DismissDirection d) async {
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
                                                      widget.docID,
                                                    )
                                                    .collection('items')
                                                    .document(
                                                      streamSnapshot
                                                          .data
                                                          .documents[index]
                                                          .documentID,
                                                    )
                                                    .delete();
                                                setState(() {});
                                              },
                                              confirmDismiss:
                                                  (DismissDirection d) async {
                                                if (sortSnapshot
                                                    .data['sortByName']) {
                                                  if (d ==
                                                      DismissDirection
                                                          .startToEnd) {
                                                    bool returnBool = false;
                                                    await showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          backgroundColor:
                                                              backColor,
                                                          content: Text(
                                                            'Are you sure you want to delete this task?',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                          actions: [
                                                            FlatButton(
                                                              child: Text(
                                                                'NO',
                                                                style: TextStyle(
                                                                    color:
                                                                        mainColor),
                                                              ),
                                                              onPressed: () {
                                                                returnBool =
                                                                    false;
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                            FlatButton(
                                                              child: Text(
                                                                'YES',
                                                                style: TextStyle(
                                                                    color:
                                                                        mainColor),
                                                              ),
                                                              onPressed: () {
                                                                returnBool =
                                                                    true;
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
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

                                                    Firestore.instance
                                                        .collection('notes')
                                                        .document(widget.docID)
                                                        .collection('items')
                                                        .document(streamSnapshot
                                                            .data
                                                            .documents[index]
                                                            .documentID)
                                                        .updateData(
                                                      {
                                                        "done": !streamSnapshot
                                                                .data.documents[
                                                            index]["done"],
                                                      },
                                                    );
                                                    print(streamSnapshot
                                                        .data
                                                        .documents[index]
                                                        .documentID);
                                                    return false;
                                                  }
                                                } else {
                                                  newScaffoldKey.currentState
                                                      .showSnackBar(
                                                    SnackBar(
                                                      action: SnackBarAction(
                                                        label: 'OK',
                                                        onPressed: () {
                                                          newScaffoldKey
                                                              .currentState
                                                              .hideCurrentSnackBar();
                                                        },
                                                      ),
                                                      content: Text(
                                                        'You can only toggle items when the list is sorted alphabetically!',
                                                      ),
                                                      duration:
                                                          Duration(seconds: 1),
                                                    ),
                                                  );
                                                  return false;
                                                }
                                              },
                                              key: Key(
                                                streamSnapshot
                                                    .data
                                                    .documents[index]
                                                    .documentID,
                                              ),
                                              secondaryBackground: Container(
                                                color: Colors.white
                                                    .withOpacity(0.1),
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 20),
                                                  child: Icon(Icons.edit,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              background: Container(
                                                color: Colors.red,
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 20),
                                                  child: Icon(Icons.delete,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              child: ListTile(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 28,
                                                  vertical: 0,
                                                ),
                                                title: Text(
                                                  streamSnapshot.data
                                                      .documents[index]["name"]
                                                      .toString(),
                                                  style: TextStyle(
                                                    color: streamSnapshot
                                                                .data.documents[
                                                            index]["done"]
                                                        ? Colors.white
                                                            .withOpacity(0.5)
                                                        : Colors.white,
                                                    decoration: streamSnapshot
                                                                .data.documents[
                                                            index]["done"]
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : TextDecoration.none,
                                                  ),
                                                ),
                                                onTap: () async {
                                                  initialValue = streamSnapshot
                                                              .data
                                                              .documents[index]
                                                          ["done"] ??
                                                      false;
                                                  editItemController.text =
                                                      streamSnapshot.data
                                                              .documents[index]
                                                          ["name"];
                                                  //enableOK = false;
                                                  setState(() {
                                                    keyboardVisible = true;
                                                  });
                                                  await showDialog(
                                                    //barrierDismissible: false,
                                                    context: context,
                                                    builder: (context) {
                                                      print(
                                                          'initialValue = $initialValue');
                                                      return EditItemWidget(
                                                        docID: widget.docID,
                                                        itemID: streamSnapshot
                                                            .data
                                                            .documents[index]
                                                            .documentID,
                                                      );
                                                    },
                                                  );
                                                  setState(() {
                                                    keyboardVisible = false;
                                                  });
                                                  enableOK = false;
                                                },
                                              ),
                                            );
                                          },
                                          itemCount: streamSnapshot.hasData
                                              ? streamSnapshot
                                                  .data.documents.length
                                              : 0,
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        'Nothing here yet!',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                              : Center(
                                  child: CircularProgressIndicator(),
                                )
                          : Container(color: backColor),
                    );
                  })
              : Center(
                  child: Text('sortSnapshot data has not arrived yet!'),
                ),
    );
  }
}

class EditItemWidget extends StatefulWidget {
  String docID;
  String itemID;
  EditItemWidget({
    this.docID,
    this.itemID,
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
        color: Colors.white,
        fontWeight: FontWeight.w400,
        fontSize: 20,
      ),
      backgroundColor: backColor,
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
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Item name',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Task Completed?',
                  style: TextStyle(color: Colors.white),
                ),
                Theme(
                  data: ThemeData(
                    unselectedWidgetColor: Colors.white,
                  ),
                  child: Checkbox(
                    activeColor: mainColor,
                    checkColor: Colors.white,
                    onChanged: (v) {
                      enableOK = true;
                      print('v: $v');
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
                  await DatabaseServices().editItem(
                      docID, editItemController.text, itemID, initialValue);
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
  AddItemDialog(this.docId);
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
        color: Colors.white,
        fontWeight: FontWeight.w400,
        fontSize: 20,
      ),
      backgroundColor: backColor,
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
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Item name',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
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
                  ? Colors.white.withOpacity(0.2)
                  : mainColor,
            ),
          ),
          onPressed: addItemController.text != ''
              ? () async {
                  await DatabaseServices()
                      .addItem(widget.docId, addItemController.text);
                  Navigator.pop(context);
                  addItemController.text = '';
                }
              : null,
        ),
      ],
    );
  }
}

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

class EditNoteName extends StatefulWidget {
  String noteName;
  String docID;
  EditNoteName({
    this.noteName,
    this.docID,
  });
  @override
  _EditNoteNameState createState() => _EditNoteNameState();
}

class _EditNoteNameState extends State<EditNoteName> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backColor,
      title: Text(
        'Edit list name',
        style: TextStyle(
          color: Colors.white,
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
              style: TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'List name',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
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
                        ? Colors.white.withOpacity(0.2)
                        : mainColor,
                  ),
                ),
                onPressed: noteNameController.text == ''
                    ? null
                    : () async {
                        await Firestore.instance
                            .collection('notes')
                            .document(widget.docID)
                            .updateData(
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
                      SnackBar(
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
                      SnackBar(
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
  FolderSelectorMenu({this.docID});
  @override
  _FolderSelectorMenuState createState() => _FolderSelectorMenuState();
}

class _FolderSelectorMenuState extends State<FolderSelectorMenu> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: backColor,
      content: StreamBuilder(
        stream: Firestore.instance.collection('folders').snapshots(),
        builder:
            (context, AsyncSnapshot<QuerySnapshot> folderSelectorSnapshot) {
          if (folderSelectorSnapshot.hasData) {
            List<Widget> returnList = folderSelectorSnapshot.data.documents
                .map(
                  (DocumentSnapshot doc) => ListTile(
                    onTap: () async {
                      await Firestore.instance
                          .collection('notes')
                          .document(widget.docID)
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
                .toList();
            returnList.insert(
              0,
              ListTile(
                title: Text(
                  'Uncategorized',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () async {
                  await Firestore.instance
                      .collection('notes')
                      .document(widget.docID)
                      .updateData({"folder": ""});
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
                                    .document(widget.docID)
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
                                    .document(widget.docID)
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
