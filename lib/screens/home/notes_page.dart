//import 'dart:isolate';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_todo_second/constants.dart';
import 'package:firebase_todo_second/screens/home/credits.dart';
import 'package:firebase_todo_second/screens/home/help.dart';
import 'package:firebase_todo_second/screens/home/list_detail.dart';
import 'package:firebase_todo_second/screens/home/search_delegate.dart';
import 'package:firebase_todo_second/screens/home/settings.dart';
import 'package:firebase_todo_second/screens/home/updates.dart';
import 'package:firebase_todo_second/screens/home/users.dart';
import 'package:firebase_todo_second/services/auth.dart';
import 'package:firebase_todo_second/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
//import 'package:flutter_downloader/flutter_downloader.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

TextEditingController listNameController = new TextEditingController();
TextEditingController folderNameController = new TextEditingController();
TextEditingController noteNameController = new TextEditingController();
TextEditingController folderEditNameController = new TextEditingController();
bool keyboardVisible = false;
bool enableNoteNameSaving = false;
GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();

ScrollController allListsScrollController = new ScrollController();
ScrollController myListsScrollController = new ScrollController();

String userID = '';

class _NotesPageState extends State<NotesPage> with SingleTickerProviderStateMixin {
  AuthServices _auth = new AuthServices();
  DatabaseServices _db = new DatabaseServices();
  double sliderValue = 0;
  int color = 0;
  Color pickerColor;
  double topContainerHeight = 0.15;
  TextEditingController _nameController = new TextEditingController();
  int currentIndex = 0;
  bool enableOK = false;

  bool isDarkMode;
  bool isGridView;

  TabController tabBarController;

  Stream<DocumentSnapshot> preferenceStream;

  void setPreferenceStream() async {
    preferenceStream = DatabaseServices().getPreferredTheme(userID);
    setState(() {});
  }

  void sendVersionNumber() async {
    _db.sendVersionNumber(userID);
  }

  Future<void> getUserID() async {
    userID = await _auth.getCurrentUserID();
    setPreferenceStream();
    sendVersionNumber();
  }

  ValueChanged<Color> onColorChanged(color) {
    //await _db.updateColor(await _auth.getCurrentUserID(), color);
    //pickerColor = color;
    print(color);
  }

  Stream<QuerySnapshot> get notesStream {
    return Firestore.instance.collection('notes').snapshots();
  }

  Widget infoTileBuilder(String text, Function onPress) {
    return ListTile(
      title: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      onTap: onPress,
    );
  }

  @override
  void initState() {
    tabBarController = new TabController(
      initialIndex: 1,
      length: 2,
      vsync: this,
    );

    getUserID();

    super.initState();
  }

  Widget getBottomNavBarItem(IconData icon, String text, int givenIndex, Function onPress) {
    return GestureDetector(
      onTap: () {
        if (currentIndex != givenIndex) {
          setState(onPress);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 8,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: currentIndex == givenIndex ? Colors.white : Colors.white.withOpacity(0.5),
            ),
            Text(
              text,
              style: TextStyle(
                color: currentIndex == givenIndex ? Colors.white : Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('keyboard visible? $keyboardVisible');
    return MaterialApp(
      title: 'Checklist 2.0',
      color: mainColor,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: mainColor,
        primarySwatch: Colors.blue,
        accentColor: mainColor,
        snackBarTheme: SnackBarThemeData(
          contentTextStyle: TextStyle(
            color: Colors.white,
          ),
        ),
        // brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: _db.settingsSnapshot,
        builder: (context, AsyncSnapshot<DocumentSnapshot> isMaintainenceModeSnapshot) {
          if (isMaintainenceModeSnapshot.hasData) {
            bool isMaintainenceMode = isMaintainenceModeSnapshot.data["isMaintainenceMode"];
            return !(isMaintainenceMode)
                ? StreamBuilder(
                    stream: preferenceStream,
                    builder: (
                      context,
                      AsyncSnapshot<DocumentSnapshot> preferenceSnapshot,
                    ) {
                      if (preferenceSnapshot.hasData) {
                        isDarkMode = preferenceSnapshot.data["isDarkMode"];
                        print("isDarkMode = $isDarkMode");
                        // setNavBarColor(isDarkMode);
                        if (shouldCheckForUpdates) {
                          checkForUpdates(context, isDarkMode);
                          shouldCheckForUpdates = false;
                        }
                        isGridView = preferenceSnapshot.data["isGridView"];
                        print("isGridView = $isGridView");
                        return FutureBuilder(
                          future: _auth.currentUser(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              color = snapshot.data['color'];
                            }
                            if (isDarkMode != null) {
                              return Scaffold(
                                appBar: currentIndex == 0
                                    ? AppBar(
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
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Checklists',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          if (isGridView != null)
                                            IconButton(
                                              icon: Icon(
                                                isGridView ? Icons.list : Icons.grid_on,
                                              ),
                                              onPressed: () async {
                                                await _db.updateData(
                                                  userID,
                                                  {
                                                    "isGridView": !isGridView,
                                                  },
                                                );
                                              },
                                            ),
                                          /* IconButton(
                                    icon: Text(
                                      '?',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            //return Help();
                                            return HelpMenu(isDarkMode);
                                          },
                                        ),
                                      );
                                    },
                                  ), */
                                          IconButton(
                                            icon: Icon(
                                              Icons.copyright,
                                            ),
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return Credits(isDarkMode);
                                                },
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.exit_to_app),
                                            onPressed: () async {
                                              bool shouldLogOut = false;
                                              await showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  backgroundColor: isDarkMode ? backColor : lightModeBackColor,
                                                  content: Container(
                                                    width: MediaQuery.of(context).size.width * 0.8,
                                                    child: Text(
                                                      'Are you sure you want to log out?',
                                                      style: TextStyle(
                                                        color: isDarkMode ? Colors.white : Colors.black,
                                                      ),
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
                                                        shouldLogOut = false;
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
                                                      onPressed: () {
                                                        shouldLogOut = true;
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (shouldLogOut) {
                                                AuthServices().signOut();
                                              }
                                            },
                                          ),
                                        ],
                                        bottom: TabBar(
                                          controller: tabBarController,
                                          unselectedLabelColor: Colors.white.withOpacity(0.5),
                                          labelColor: Colors.white,
                                          indicatorColor: Colors.white,
                                          tabs: <Tab>[
                                            Tab(text: 'OTHER LISTS'),
                                            Tab(text: 'MY LISTS'),
                                          ],
                                        ),
                                      )
                                    : null,
                                key: scaffoldKey,
                                resizeToAvoidBottomPadding: false,
                                floatingActionButton: !keyboardVisible
                                    ? FloatingActionButton(
                                        onPressed: () async {
                                          setState(() {
                                            keyboardVisible = true;
                                          });
                                          listNameController.text = '';
                                          enableOK = false;
                                          await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AddList(isDarkMode);
                                            },
                                          );
                                          setState(() {
                                            keyboardVisible = false;
                                          });
                                          listNameController.text = '';
                                          enableOK = false;
                                        },
                                        backgroundColor: mainColor,
                                        //elevation: 0,
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          child: Icon(Icons.add, color: Colors.white),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                mainColor.withOpacity(0.6),
                                                accentColor.withOpacity(0.6),
                                              ],
                                              stops: [0.0, 100.0],
                                            ),
                                            //color: accentColor,
                                          ),
                                        ),
                                      )
                                    : Container(),
                                floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                                /* bottomNavigationBar: BottomNavigationBar(
                          //backgroundColor: mainColor,
                          selectedItemColor: Colors.white,
                          unselectedItemColor: Colors.white.withOpacity(0.2),
                          currentIndex: currentIndex,
                          type: BottomNavigationBarType.fixed,
                          onTap: (i) {
                            setState(() {
                              currentIndex = i;
                            });
                          },
                          items: [
                            BottomNavigationBarItem(
                              title: Text('Home'),
                              icon: Icon(Icons.home),
                            ),
                            BottomNavigationBarItem(
                              title: Text('Users'),
                              icon: Icon(Icons.supervised_user_circle),
                            ),
                            BottomNavigationBarItem(
                              title: Text('Profile'),
                              icon: Icon(Icons.person),
                            ),
                          ],
                        ), */
                                bottomNavigationBar: !keyboardVisible
                                    ? Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [mainColor, accentColor], begin: Alignment.centerLeft, end: Alignment.centerRight),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            getBottomNavBarItem(
                                              Icons.home,
                                              'Home',
                                              0,
                                              () {
                                                currentIndex = 0;
                                              },
                                            ),
                                            getBottomNavBarItem(
                                              Icons.search,
                                              'Search',
                                              1,
                                              () {
                                                Scaffold.of(context).showSnackBar(
                                                  CustomSnackBar(
                                                    Text(
                                                      'This feature has not been developed yet!',
                                                    ),
                                                    /* action: SnackBarAction(
                                                      label: 'OK',
                                                      onPressed: () {
                                                        Scaffold.of(context)
                                                            .hideCurrentSnackBar();
                                                      },
                                                    ), */
                                                    Duration(seconds: 1),
                                                  ),
                                                );
                                              },
                                            ),
                                            Opacity(
                                              opacity: 0.0,
                                              child: Icon(Icons.edit),
                                            ),
                                            getBottomNavBarItem(
                                              Icons.supervisor_account,
                                              'Users',
                                              2,
                                              () {
                                                currentIndex = 2;
                                              },
                                            ),
                                            getBottomNavBarItem(
                                              Icons.settings,
                                              'Settings',
                                              3,
                                              //() => showSettingsSheet(),
                                              () {
                                                currentIndex = 3;
                                              },
                                            ),
                                            /* IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  //showSearch(context: context, delegate: DataSearch());
                                  Scaffold.of(context).showSnackBar(
                                   CustomSnackBar(
                                      content: Text(
                                        'This feature has not been developed yet!',
                                      ),
                                      action: SnackBarAction(
                                        label: 'OK',
                                        onPressed: () {
                                          Scaffold.of(context).hideCurrentSnackBar();
                                        },
                                      ),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                color: currentIndex == 1
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                splashColor: Colors.white,
                              ), */
                                            /* Icon(Icons.edit, color: Colors.transparent),
                              IconButton(
                                icon: Icon(Icons.supervised_user_circle),
                                onPressed: () {
                                  if (currentIndex != 2) {
                                    setState(() {
                                      currentIndex = 2;
                                    });
                                  }
                                },
                                color: currentIndex == 2
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                              IconButton(
                                icon: Icon(Icons.settings),
                                onPressed: () {
                                  showSettingsSheet();
                                },
                                color: currentIndex == 3
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ), */
                                          ],
                                        ))
                                    : null,
                                /* appBar: AppBar(
                        backgroundColor: mainColor,
                        elevation: 0,
                        leading: IconButton(
                          icon: Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            scaffoldKey.currentState.openDrawer();
                          },
                        ),
                        actions: [
                          IconButton(
                              icon: Icon(
                                Icons.exit_to_app,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _auth.signOut();
                              })
                        ],
                      ), */
                                drawer: StreamBuilder<DocumentSnapshot>(
                                    stream: _db.usersCollection.document(userID).snapshots(),
                                    builder: (context, AsyncSnapshot<DocumentSnapshot> streamSnapshot) {
                                      if (streamSnapshot.hasData && snapshot.hasData) {
                                        return Drawer(
                                          child: Container(
                                            color: isDarkMode ? backColor : lightModeBackColor,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                UserAccountsDrawerHeader(
                                                  decoration: BoxDecoration(
                                                    //color: mainColor,
                                                    gradient: LinearGradient(
                                                      colors: [mainColor, accentColor],
                                                    ),
                                                  ),
                                                  accountEmail: Text(
                                                    snapshot.data['userEmail'] ?? '',
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.75),
                                                    ),
                                                  ),
                                                  accountName: Text(streamSnapshot.data['name'] ?? ''),
                                                  currentAccountPicture: CircleAvatar(
                                                    backgroundColor: color == 0 ? Colors.black : Color(streamSnapshot.data['color']),
                                                    child: Text(
                                                      streamSnapshot.data['name'].toString().substring(0, 1) ?? '',
                                                      style: TextStyle(
                                                        /* 
                                                color: 0.2126 *
                                                                Color(streamSnapshot
                                                                            .data[
                                                                        'color'])
                                                                    .red +
                                                            0.7152 *
                                                                Color(streamSnapshot
                                                                            .data[
                                                                        'color'])
                                                                    .red +
                                                            0.0722 *
                                                                Color(streamSnapshot
                                                                            .data[
                                                                        'color'])
                                                                    .blue >
                                                        240
                                                    ? Colors.black
                                                    : Colors.white,
                                                     */
                                                        color: getRealColor(
                                                          streamSnapshot.data['color'],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Folders',
                                                        style: TextStyle(
                                                          color: isDarkMode ? Colors.white : Colors.black,
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      InkWell(
                                                        child: Icon(
                                                          Icons.add,
                                                          color: isDarkMode ? Colors.white : Colors.black,
                                                        ),
                                                        onTap: () async {
                                                          setState(() {
                                                            keyboardVisible = true;
                                                          });
                                                          await showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AddFolder(isDarkMode);
                                                            },
                                                          );
                                                          setState(() {
                                                            keyboardVisible = false;
                                                          });
                                                          folderNameController.text = '';
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Divider(
                                                  color: isDarkMode ? Colors.white : Colors.black,
                                                  thickness: 0.5,
                                                  height: 0.5,
                                                ),
                                                FolderDisplayStreamBuilder(isDarkMode),
                                                /* Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon:
                                                Icon(Icons.settings, color: Colors.white),
                                            onPressed: () {
                                              //print(streamSnapshot.data['name']);
                                              _nameController.text =
                                                  streamSnapshot.data['name'];
                                              showSettingsSheet();
                                            },
                                          ),
                                        ],
                                      ) */
                                              ],
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Drawer(
                                          child: Container(color: isDarkMode ? backColor : lightModeBackColor),
                                        );
                                      }
                                    }),
                                backgroundColor: isDarkMode ? backColor : lightModeBackColor,
                                //backgroundColor: backColor,
                                /* body: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppBar(
                            backgroundColor: mainColor,
                            elevation: 0,
                            leading: IconButton(
                              icon: Icon(
                                Icons.menu,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                scaffoldKey.currentState.openDrawer();
                              },
                            ),
                            actions: [
                              IconButton(
                                  icon: Icon(
                                    Icons.exit_to_app,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    _auth.signOut();
                                  })
                            ],
                          ),
                          SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height *
                                                topContainerHeight -
                                            56,
                                        width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [mainColor, mainColor],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.vertical(
                                            bottom: Radius.circular(50),
                                          ),
                                        ),
                                      ),
                                      /* Column(
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(Icons.exit_to_app),
                                                )
                                              ],
                                            ),
                                            Container(
                                              alignment: Alignment.bottomCenter,
                                              height: MediaQuery.of(context).size.height * 0.4 - 24,
                                              child: FloatingActionButton(
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                                elevation: 0,
                                                backgroundColor: mainColor,
                                                onPressed: () {},
                                              ),
                                            ),
                                          ],
                                        ), */
                                      Container(
                                        height: MediaQuery.of(context).size.height *
                                                topContainerHeight +
                                            24 -
                                            56,
                                        child: Column(
                                          children: [
                                            Spacer(),
                                            Center(
                                              child: FloatingActionButton(
                                                highlightElevation: 0,
                                                backgroundColor: backColor,
                                                elevation: 0,
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {},
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                StreamBuilder(
                                  stream: Firestore.instance
                                      .collection('notes')
                                      .getDocuments()
                                      .asStream(),
                                  builder: (context, snapshot) {
                                    return snapshot.hasData
                                        ?
                                        /* List<Widget> gridList;
                                                    int i = 0;
                                                    while (i < snapshot.data.documents.length) {
                                                      print(
                                                          'DocumentSnapshot: ${snapshot.data.documents[i]['name']}');
                                                      gridList.add(
                                                        Text(
                                                          snapshot.data.documents[0]['name']
                                                                  .toString() ??
                                                              'Null',
                                                        ),
                                                      );
                                                      i++;
                                                    }
                                                    return GridView.count(
                                                      crossAxisCount: 2,
                                                      children: gridList,
                                                    ); */
                                        GridView.count(
                                            shrinkWrap: true,
                                            crossAxisCount: 2,
                                            children: List.generate(2, (customIndex) {
                                              return Padding(
                                                padding: const EdgeInsets.all(20),
                                                child: InkWell(
                                                  onTap: () {},
                                                  child: Center(
                                                    child: Text(
                                                      'Item $customIndex',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline5,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          )
                                        : Center(child: CircularProgressIndicator());
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ), */
                                /* body: currentIndex == 0
                          ? CustomScrollView(
                              slivers: [
                                SliverAppBar(
                                  backgroundColor: mainColor,
                                  elevation: 0,
                                  automaticallyImplyLeading: false,
                                  leading: IconButton(
                                    icon: Icon(Icons.menu, color: Colors.white),
                                    onPressed: () {
                                      scaffoldKey.currentState.openDrawer();
                                    },
                                  ),
                                  actions: [
                                    IconButton(
                                      icon: Icon(Icons.exit_to_app, color: Colors.white),
                                      onPressed: () {
                                        _auth.signOut();
                                      },
                                    ),
                                  ],
                                  /* title: Container(
                                    color: Colors.lime,
                                    height: 56,
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.menu),
                                              color: Colors.white,
                                              onPressed: () {
                                                scaffoldKey.currentState.openDrawer();
                                              },
                                            )
                                          ],
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.exit_to_app),
                                          color: Colors.white,
                                          onPressed: () {
                                            _auth.signOut();
                                          },
                                        ),
                                      ],
                                    ),
                                  ), */
                                  expandedHeight: MediaQuery.of(context).size.height *
                                          topContainerHeight +
                                      24,
                                  pinned: true,
                                  forceElevated: false,
                                  flexibleSpace: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [mainColor, accentColor],
                                      ),
                                    ),
                                    child: FlexibleSpaceBar(
                                      centerTitle: true,
                                      title: Text('Checklists'),
                                      titlePadding: EdgeInsets.only(
                                          bottom: 16, left: 60, right: 60),
                                      background: Container(
                                        color: Colors.white,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(30)),
                                          child: Container(
                                            height: MediaQuery.of(context).size.height *
                                                    topContainerHeight +
                                                24,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [mainColor, accentColor],
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  height:
                                                      MediaQuery.of(context).size.height *
                                                          topContainerHeight,
                                                ),
                                                /* Align(
                                            child: Container(
                                              alignment: Alignment.bottomCenter,
                                              height: MediaQuery.of(context).size.height *
                                                  topContainerHeight,
                                              child: FloatingActionButton(
                                                backgroundColor: backColor,
                                                elevation: 0,
                                                child: Icon(Icons.add, color: Colors.white),
                                                onPressed: () {},
                                              ),
                                            ),
                                          ), */
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  //floating: true,
                                ),
                                SliverToBoxAdapter(child: SizedBox(height: 30)),
                                StreamBuilder(
                                  stream: notesStream,
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                                    return SliverPadding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      /* sliver: SliverGrid(
                                          gridDelegate:
                                              SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 300.0,
                                            mainAxisSpacing: 10.0,
                                            crossAxisSpacing: 10.0,
                                            childAspectRatio: 1.0,
                                          ),
                                          delegate: SliverChildBuilderDelegate(
                                            (BuildContext context, int index) {
                                              return GestureDetector(
                                                onTap: () {},
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(30),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(20),
                                                    child: Text(
                                                      '${streamSnapshot.data.documents[index]["name"]}',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            childCount: streamSnapshot.hasData
                                                ? streamSnapshot.data.documents.length
                                                : 0,
                                          ),
                                        ), */
                                      sliver: SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 10),
                                              child: CheckListTile(
                                                title:
                                                    '${streamSnapshot.data.documents[index]["name"]}',
                                                backgroundColor: backColor,
                                                primaryColor: Colors.white,
                                                onPress: () {
                                                  print('${index + 1}');
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) {
                                                        return NotesDetail(
                                                          streamSnapshot
                                                              .data
                                                              .documents[index]
                                                              .documentID,
                                                          streamSnapshot.data
                                                              .documents[index]["name"],
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                inkColor: Colors.black,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.limeAccent,
                                                    blurRadius: 20,
                                                    spreadRadius: 20,
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                          childCount: streamSnapshot.hasData
                                              ? streamSnapshot.data.documents.length
                                              : 0,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SliverToBoxAdapter(
                                  child: SizedBox(height: 20),
                                )
                              ],
                            )
                          : currentIndex == 1
                              ? Container(
                                  color: backColor,
                                  child: Center(
                                    child: Text(
                                      'Profie',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                              : currentIndex == 2
                                  ? Users()
                                  : Container(
                                      color: backColor,
                                      child: Center(
                                        child: Text(
                                          'Profile',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ), */
                                body: isDarkMode != null
                                    ? currentIndex == 0
                                        ? !keyboardVisible
                                            ? Theme(
                                                data: Theme.of(context).copyWith(
                                                  accentColor: mainColor,
                                                ),
                                                child: TabBarView(
                                                  controller: tabBarController,
                                                  children: [
                                                    MainGridDisplay(
                                                      isGridView: isGridView,
                                                      isAll: true,
                                                      controller: allListsScrollController,
                                                      isDarkMode: isDarkMode,
                                                    ),
                                                    MainGridDisplay(
                                                      isGridView: isGridView,
                                                      isAll: false,
                                                      controller: myListsScrollController,
                                                      isDarkMode: isDarkMode,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(
                                                color: isDarkMode ? backColor : lightModeBackColor,
                                              )
                                        : currentIndex == 1
                                            ? showSearch(
                                                context: context,
                                                delegate: DataSearch(),
                                              )
                                            : currentIndex == 2
                                                ? Users(isDarkMode)
                                                : Settings(
                                                    isDarkMode,
                                                    userID,
                                                  )
                                    : Center(
                                        child: CircularProgressIndicator(),
                                      ),
                              );
                            } else {
                              print('isDarkMode currently not defined');
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    })
                : StreamBuilder(
                    stream: preferenceStream,
                    builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasData) {
                        bool isDarkMode = snapshot.data["isDarkMode"];
                        return Scaffold(
                          backgroundColor: isDarkMode ? backColor : lightModeBackColor,
                          body: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.handyman_outlined,
                                  size: MediaQuery.of(context).size.width * 0.6,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                                SizedBox(height: 16),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    'Sorry, construction in progress!',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    });
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void showSettingsSheet() async {
    Stream<DocumentSnapshot> mainReference = _db.usersCollection.document(userID).snapshots();
    setState(() {
      keyboardVisible = true;
    });
    await showModalBottomSheet(
      backgroundColor: isDarkMode ? backColor : lightModeBackColor,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        /* child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  child: MaterialPicker(
                    pickerColor: pickerColor,
                    onColorChanged: onColorChanged,
                    enableLabel: false,
                  ),
                ),
              ],
            ), */
        return StreamBuilder<DocumentSnapshot>(
            stream: mainReference,
            builder: (context, AsyncSnapshot<DocumentSnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                _nameController.text = streamSnapshot.data['name'];
              }
              return streamSnapshot.hasData
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            //mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: TextField(
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: mainColor),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.check, color: mainColor),
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  Navigator.pop(context);
                                  scaffoldKey.currentState.openDrawer();
                                  await _db.updateName(
                                    await _auth.getCurrentUserID(),
                                    _nameController.text,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          //height: MediaQuery.of(context).size.height * 0.7,
                          child: Container(
                            child: MaterialPicker(
                              pickerColor: Color(streamSnapshot.data['color']),
                              onColorChanged: (c) async {
                                //setState(() {});
                                scaffoldKey.currentState.openDrawer();
                                //Navigator.pop(context);
                                await _db.updateColor(await _auth.getCurrentUserID(), c.value);
                              },
                              enableLabel: false,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(child: CircularProgressIndicator());
            });
      },
    );
    setState(() {
      keyboardVisible = false;
    });
  }
}

class HelpMenu extends StatefulWidget {
  bool isDarkMode;
  HelpMenu(
    this.isDarkMode,
  );
  @override
  _HelpMenuState createState() => _HelpMenuState();
}

class _HelpMenuState extends State<HelpMenu> {
  List<DocumentSnapshot> data = [];

  void getData() {
    Firestore.instance
        .collection('settings')
        .document('settings')
        .collection('help')
        .orderBy(
          "question",
          descending: false,
        )
        .getDocuments()
        .then((QuerySnapshot value) {
      setState(() {
        data = value.documents;
      });
      print(data);
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? backColor : lightModeBackColor,
      appBar: AppBar(
        title: Text('Help'),
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
          ? ListView(
              padding: EdgeInsets.symmetric(
                vertical: 16,
              ),
              children: data.map((DocumentSnapshot doc) {
                return ListTile(
                  title: Text(
                    doc.data["question"].toString(),
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: widget.isDarkMode ? backColor : lightModeBackColor,
                          title: Text(
                            doc.data["question"].toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: widget.isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          content: Text(
                            doc.data["answer"].toString(),
                            style: TextStyle(
                              color: widget.isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          actions: [
                            FlatButton(
                              child: Text(
                                'OK',
                                style: TextStyle(
                                  color: mainColor,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              }).toList(),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      /* 
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<MaterialColor> colors = Colors.primaries;
          List<int> colorValues = [];
          print(colors.length);
          for (int i = 0; i < colors.length; i++) {
            // colorValues.add(colors[i].value);
            // colorValues.add(colors[i].shade100.value);
            colorValues.add(colors[i].shade200.value);
            // colorValues.add(colors[i].shade300.value);
            colorValues.add(colors[i].shade400.value);
            colorValues.add(colors[i].value);
            // colorValues.add(colors[i].shade500.value);
            colorValues.add(colors[i].shade600.value);
            // colorValues.add(colors[i].shade700.value);
            colorValues.add(colors[i].shade800.value);
            colorValues.add(colors[i].shade900.value);
          }
          print(colorValues);
          // print(colors);
          await Firestore.instance
              .collection('settings')
              .document('settingsColors')
              .setData({
            'colors': colorValues,
          });
          print('done!');
        },
      ), 
      */
    );
  }
}

class MainGridDisplay extends StatefulWidget {
  //final Stream<QuerySnapshot> stream;
  final bool isGridView;
  final bool isAll;
  final ScrollController controller;
  final bool isDarkMode;
  MainGridDisplay({
    //this.stream,
    this.isGridView,
    this.isAll,
    this.controller,
    this.isDarkMode,
  });

  @override
  _MainGridDisplayState createState() => _MainGridDisplayState();
}

class _MainGridDisplayState extends State<MainGridDisplay> {
  bool isAllItemsDone(List<DocumentSnapshot> docs) {
    bool returnVal;
    docs.forEach((DocumentSnapshot doc) {
      if (!doc.data["done"]) {
        returnVal = false;
      }
    });
    if (docs.length != 0) {
      return returnVal ?? true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> stream = Firestore.instance.collection('notes').orderBy("name").snapshots();

    return Container(
      //TODO: SWAP HERE 2
      color: widget.isDarkMode ? backColor : lightModeBackColor,
      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if (!widget.isAll) {
              for (int i = 0; i < snapshot.data.documents.length; i++) {
                if (snapshot.data.documents[i].data["ownerID"] != userID) {
                  snapshot.data.documents.removeAt(i);
                  i--;
                }
              }
            } else {
              for (int i = 0; i < snapshot.data.documents.length; i++) {
                bool isCurrentUsersList = userID == snapshot.data.documents[i].data["ownerID"];
                if (!(snapshot.data.documents[i].data["security"]["canReadAndExport"]) || isCurrentUsersList) {
                  snapshot.data.documents.removeAt(i);
                  i--;
                }
              }
            }
            if (snapshot.data.documents.length != 0) {
              return Theme(
                data: Theme.of(context).copyWith(
                  accentColor: mainColor,
                ),
                child: widget.isGridView
                    ? GridView.builder(
                        controller: widget.controller,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                        semanticChildCount: 2,
                        padding: EdgeInsets.all(8),
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          String currentDocID = snapshot.data.documents[index].documentID;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: InkWell(
                              onTap: () async {
                                print("security values: ${snapshot.data.documents[index].data["security"]}");
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return NotesDetail(
                                        /* snapshot
                                            .data.documents[index].documentID,
                                        snapshot.data.documents[index]["name"],
                                        snapshot.data.documents[index]
                                            ["ownerID"],
                                        userID,
                                        snapshot.data.documents[index]
                                            ["security"], */
                                        userID,
                                        snapshot.data.documents[index],
                                        widget.isDarkMode,
                                      );
                                    },
                                  ),
                                );
                                setState(() {});
                              },
                              child: Container(
                                //TODO: SWAP HERE
                                decoration: BoxDecoration(
                                  color: widget.isDarkMode ? lightBackColor : lightModeLightBackColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: NotificationListener<OverscrollIndicatorNotification>(
                                    onNotification: (overScroll) {
                                      overScroll.disallowGlow();
                                    },
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  snapshot.data.documents[index]["name"].toString(),
                                                  style: TextStyle(
                                                    color: widget.isDarkMode ? Colors.white : Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              /* GestureDetector(
                                          child: Container(
                                            color: widget.isDarkMode
                                                ? lightBackColor
                                                : lightModeLightBackColor,
                                            child: Icon(
                                              Icons.more_vert,
                                              color: Colors.white,
                                            ),
                                          ),
                                          onTap: () async {
                                            setState(() {
                                              keyboardVisible = true;
                                            });
                                            noteNameController.text = snapshot
                                                .data.documents[index]['name']
                                                .toString();
                                            enableNoteNameSaving =
                                                snapshot.data.documents[index]
                                                            ['name'] ==
                                                        ''
                                                    ? false
                                                    : true;
                                            await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return NoteEditDelete(
                                                  snapshot: snapshot,
                                                  index: index,
                                                );
                                              },
                                            );
                                            noteNameController.text = '';
                                            await Future.delayed(
                                              Duration(milliseconds: 500),
                                            );
                                            setState(() {
                                              keyboardVisible = false;
                                            });
                                          },
                                        ), */
                                            ],
                                          ),
                                          SizedBox(height: 25),
                                          StreamBuilder(
                                            stream: Firestore.instance.collection('notes').document(currentDocID).snapshots(),
                                            builder: (context, AsyncSnapshot<DocumentSnapshot> orderSnapshot) => StreamBuilder<QuerySnapshot>(
                                              stream: Firestore.instance
                                                  .collection('notes')
                                                  .document(currentDocID)
                                                  .collection('items')
                                                  .orderBy(orderSnapshot.hasData
                                                      ? orderSnapshot.data['sortByName'] == true
                                                          ? "name"
                                                          : "done"
                                                      : "name")
                                                  .snapshots(),
                                              builder: (context, AsyncSnapshot<QuerySnapshot> secondSnapshot) {
                                                List<Widget> widgetList = [];
                                                try {
                                                  secondSnapshot.data.documents.forEach(
                                                    (DocumentSnapshot element) {
                                                      if (element.data['name'].toString().isNotEmpty) {
                                                        widgetList.add(
                                                          Text(
                                                            element.data['name'],
                                                            style: TextStyle(
                                                              color: widget.isDarkMode
                                                                  ? element.data['done'] == true
                                                                      ? Colors.white.withOpacity(0.5)
                                                                      : Colors.white
                                                                  : element.data['done']
                                                                      ? Colors.black.withOpacity(0.5)
                                                                      : Colors.black,
                                                              fontWeight: FontWeight.w300,
                                                              decoration: element.data['done'] == true ? TextDecoration.lineThrough : TextDecoration.none,
                                                            ),
                                                            overflow: TextOverflow.fade,
                                                          ),
                                                        );
                                                        widgetList.add(
                                                          SizedBox(height: 8),
                                                        );
                                                      }
                                                    },
                                                  );
                                                  if (widgetList.isEmpty) {
                                                    widgetList = [
                                                      Text(
                                                        'This list is empty!',
                                                        style: TextStyle(
                                                          color: widget.isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.9),
                                                          fontWeight: FontWeight.w300,
                                                        ),
                                                      ),
                                                    ];
                                                  }
                                                } catch (e) {
                                                  widgetList = [];
                                                }
                                                Stream<DocumentSnapshot> sortRef = Firestore.instance.collection("notes").document(currentDocID).snapshots();
                                                return widgetList.isNotEmpty
                                                    ? Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: widgetList,
                                                      )
                                                    : Text(
                                                        'Loading...',
                                                        style: TextStyle(
                                                          color: widget.isDarkMode ? Colors.white : Colors.black.withOpacity(0.9),
                                                          fontWeight: FontWeight.w300,
                                                        ),
                                                      );
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        /* itemBuilder: (context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 0,
                              bottom: 20,
                              left: 15,
                              right: 15,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: backColor,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 5,
                                    spreadRadius: 0.2,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              height: 100,
                              alignment: Alignment.center,
                              child: Text(
                                '${snapshot.data.documents[index]["name"].toString()}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }, */
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        itemBuilder: (context, int index) {
                          DocumentSnapshot doc = snapshot.data.documents[index];
                          // bool allItemsDone = getQuerySnapshot(doc.reference);
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return NotesDetail(
                                        /* 
                                        doc.documentID,
                                        doc.data["name"],
                                        doc.data["ownerID"],
                                        userID,
                                        doc.data["security"],
                                         */
                                        userID,
                                        doc,
                                        widget.isDarkMode,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                // padding: EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  // borderRadius: BorderRadius.circular(12),
                                  color: widget.isDarkMode ? lightBackColor : lightModeLightBackColor,
                                ),
                                child: StreamBuilder(
                                    stream: doc.reference.collection('items').snapshots(),
                                    builder: (context, AsyncSnapshot<QuerySnapshot> isDoneSnapshot) {
                                      if (isDoneSnapshot.hasData) {
                                        bool allItemsDone = isAllItemsDone(isDoneSnapshot.data.documents);
                                        print(allItemsDone);
                                        return ListTile(
                                          title: Text(
                                            doc.data["name"],
                                            style: !allItemsDone
                                                ? TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black)
                                                : TextStyle(
                                                    color: widget.isDarkMode ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
                                                    decoration: TextDecoration.lineThrough,
                                                  ),
                                          ),
                                        );
                                      } else {
                                        /* return Center(
                                          child: CircularProgressIndicator(),
                                        ); */
                                        return Container();
                                      }
                                    }),
                              ),
                            ),
                          );
                        },
                        itemCount: snapshot.data.documents.length,
                      ),
              );
            } else {
              return Center(
                child: Text(
                  'No lists yet!',
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class FolderDisplayStreamBuilder extends StatefulWidget {
  bool isDarkMode;
  FolderDisplayStreamBuilder(
    this.isDarkMode,
  );

  @override
  _FolderDisplayStreamBuilderState createState() => _FolderDisplayStreamBuilderState();
}

class _FolderDisplayStreamBuilderState extends State<FolderDisplayStreamBuilder> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('folders').orderBy("name").snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> folderSnapshot) {
        if (folderSnapshot.hasData) {
          /* List<Widget> returnList = [];
            folderSnapshot.data.documents.forEach(
              (DocumentSnapshot element) {
                returnList.add(
                  ListTile(
                    title: Text(
                      element.data["name"].toString(),
                      style:
                          TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ); */
          return Expanded(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (o) {
                o.disallowGlow();
              },
              /* child: ListView(
                  padding: EdgeInsets.only(top: 0),
                  shrinkWrap: true,
                  children: returnList,
                ), */
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemBuilder: (content, index) {
                  return Dismissible(
                    direction: DismissDirection.startToEnd,
                    key: Key(
                      folderSnapshot.data.documents[index]["name"],
                    ),
                    /* secondaryBackground: Container(
                        color: Colors.white.withOpacity(0.1),
                        child: Icon(Icons.edit, color: Colors.white),
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                      ), */
                    secondaryBackground: Container(
                      color: Colors.transparent,
                    ),
                    background: Container(
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    confirmDismiss: (DismissDirection d) async {
                      if (d == DismissDirection.startToEnd) {
                        bool shouldDeleteFolder = false;
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: widget.isDarkMode ? backColor : lightModeBackColor,
                              content: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  'Are you sure you want to delete this folder?',
                                  style: TextStyle(
                                    color: widget.isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              actions: [
                                FlatButton(
                                  child: Text(
                                    'NO',
                                    style: TextStyle(color: mainColor),
                                  ),
                                  onPressed: () {
                                    shouldDeleteFolder = false;
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  color: Colors.red,
                                  child: Text(
                                    'YES',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    shouldDeleteFolder = true;
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        if (shouldDeleteFolder) {
                          await Firestore.instance.collection('notes').where("folder", isEqualTo: folderSnapshot.data.documents[index].documentID).getDocuments().then(
                            (QuerySnapshot value) {
                              for (DocumentSnapshot d in value.documents) {
                                d.reference.updateData(
                                  {"folder": ""},
                                );
                              }
                            },
                          );
                          await folderSnapshot.data.documents[index].reference.delete();
                        }
                        return shouldDeleteFolder;
                      } else {
                        return false;
                      }
                    },
                    child: Theme(
                      data: ThemeData(
                        accentColor: Colors.white,
                        unselectedWidgetColor: widget.isDarkMode ? Colors.white : Colors.black,
                      ),
                      /* 

                        STRUCTURE DATABSE HERE:

                        Each FolderColelction document has its documentId
                        Each note can be given an empty string if uncategorized by folder, or docId as folder
                        Property name: "folder"
                        When folder deleted, search through notes for that folder and empty out string
                        When note unassigned to folder, note folder string should be emptied out
                        When note assigned, folder proerty should be given folder docId

                        */
                      child: StreamBuilder(
                        stream: Firestore.instance.collection('notes').where('folder', isEqualTo: folderSnapshot.data.documents[index].documentID).snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> subFolderSnapshot) {
                          if (subFolderSnapshot.hasData) {
                            List<Widget> tileWidgets = [];
                            subFolderSnapshot.data.documents.forEach(
                              (DocumentSnapshot element) {
                                tileWidgets.add(
                                  ListTile(
                                    title: Text(
                                      element.data['name'],
                                      style: TextStyle(
                                        color: widget.isDarkMode ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    onTap: () {
                                      /* print(subFolderSnapshot
                                            .data.documents[index]["name"]); */
                                      /* Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return NotesDetail(
                                                subFolderSnapshot.data
                                                    .documents[index].documentID,
                                                subFolderSnapshot.data
                                                    .documents[index]["name"],
                                              );
                                            },
                                          ),
                                        ); */
                                    },
                                  ),
                                );
                              },
                            );
                            return ExpansionTile(
                              maintainState: true,
                              backgroundColor: widget.isDarkMode ? lightBackColor : lightModeLightBackColor,
                              /* children: [
                                ListTile(
                                    title: Text('Test tile',
                                        style: TextStyle(
                                            color: Colors
                                                .white))),
                                ListTile(
                                    title: Text('Test tile',
                                        style: TextStyle(
                                            color: Colors
                                                .white))),
                                ListTile(
                                    title: Text('Test tile',
                                        style: TextStyle(
                                            color: Colors
                                                .white))),
                              ], */
                              children: subFolderSnapshot.data.documents
                                  .map(
                                    (DocumentSnapshot e) => ListTile(
                                      leading: Opacity(
                                        opacity: 0,
                                        child: Icon(Icons.edit),
                                      ),
                                      onTap: () {
                                        print(e.documentID);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (content) {
                                              return NotesDetail(
                                                /* 
                                                e.documentID.toString(),
                                                e.data["name"].toString(),
                                                e.data["ownerID"].toString(),
                                                userID,
                                                e.data["security"], 
                                                */
                                                userID,
                                                e,
                                                widget.isDarkMode,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      title: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          //SizedBox(width: 30),
                                          Text(
                                            e.data['name'],
                                            style: TextStyle(
                                              color: widget.isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.8),
                                            ),
                                            overflow: TextOverflow.fade,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              /* children: tileWidgets, */
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    child: Icon(
                                      Icons.edit,
                                      color: widget.isDarkMode ? Colors.white : Colors.black,
                                      size: 20,
                                    ),
                                    onTap: () async {
                                      folderEditNameController.text = await folderSnapshot.data.documents[index]["name"];
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return EditFolderName(
                                            folderDocID: folderSnapshot.data.documents[index].documentID,
                                            isDarkMode: isDarkMode,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    folderSnapshot.data.documents[index]['name'],
                                    style: TextStyle(
                                      color: widget.isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                  );
                },
                itemCount: folderSnapshot.data.documents.length,
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class AddList extends StatefulWidget {
  bool isDarkMode;
  AddList(
    this.isDarkMode,
  );
  @override
  _AddListState createState() => _AddListState();
}

class _AddListState extends State<AddList> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? backColor : lightModeBackColor,
      actions: [
        FlatButton(
            child: Text(
              'CANCEL',
              style: TextStyle(color: mainColor),
            ),
            onPressed: () {
              setState(() {
                enableOK = false;
              });
              Navigator.pop(context);
            }),
        FlatButton(
          child: Text(
            'ADD',
            style: TextStyle(
              color: enableOK
                  ? mainColor
                  : widget.isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.2),
            ),
          ),
          onPressed: enableOK
              ? () async {
                  Navigator.pop(context);
                  await DatabaseServices().createList(
                    listNameController.text,
                    await AuthServices().getCurrentUserID(),
                  );
                  enableOK = false;
                }
              : null,
        ),
      ],
      title: Text(
        'Create new list',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20,
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              controller: listNameController,
              onChanged: (s) {
                if (listNameController.text == '') {
                  setState(() {
                    enableOK = false;
                  });
                } else {
                  setState(() {
                    enableOK = true;
                  });
                }
              },
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'List name',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                ),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.isDarkMode ? Colors.white : Colors.black)),
                disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.isDarkMode ? Colors.white : Colors.black)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.isDarkMode ? Colors.white : Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddFolder extends StatefulWidget {
  bool isDarkMode;
  AddFolder(
    this.isDarkMode,
  );
  @override
  _AddFolderState createState() => _AddFolderState();
}

class _AddFolderState extends State<AddFolder> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? backColor : lightModeBackColor,
      actions: [
        FlatButton(
            child: Text(
              'CANCEL',
              style: TextStyle(color: mainColor),
            ),
            onPressed: () {
              Navigator.pop(context);
              folderNameController.text = '';
            }),
        FlatButton(
          child: Text(
            'ADD',
            style: TextStyle(
              color: folderNameController.text != ''
                  ? mainColor
                  : widget.isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.2),
            ),
          ),
          onPressed: folderNameController.text != ''
              ? () async {
                  await DatabaseServices().createFolder(folderNameController.text);
                  Navigator.pop(context);
                  folderNameController.text = '';
                }
              : null,
        ),
      ],
      title: Text(
        'Create new folder',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20,
          color: widget.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              controller: folderNameController,
              onChanged: (s) {
                setState(() {});
              },
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Folder name',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                ),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.isDarkMode ? Colors.white : Colors.black)),
                disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.isDarkMode ? Colors.white : Colors.black)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.isDarkMode ? Colors.white : Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoteEditDelete extends StatefulWidget {
  var snapshot;
  int index;
  bool isDarkMode;
  NoteEditDelete({
    this.snapshot,
    this.index,
    this.isDarkMode,
  });
  @override
  _NoteEditDeleteState createState() => _NoteEditDeleteState();
}

class _NoteEditDeleteState extends State<NoteEditDelete> {
  @override
  Widget build(BuildContext context) {
    var snapshot = widget.snapshot;
    int index = widget.index;
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? backColor : lightModeBackColor,
      title: Text(
        'Edit list',
        style: TextStyle(
          color: widget.isDarkMode ? Colors.white : Colors.black,
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
                setState(() {
                  enableNoteNameSaving = noteNameController.text == '' ? false : true;
                });
              },
              autofocus: true,
              controller: noteNameController,
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'List name',
                hintStyle: TextStyle(
                  color: widget.isDarkMode ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
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
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /* FlatButton(
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
                ), */
                FlatButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    'SAVE',
                    style: TextStyle(
                      color: enableNoteNameSaving
                          ? mainColor
                          : widget.isDarkMode
                              ? Colors.white.withOpacity(0.2)
                              : Colors.black.withOpacity(0.2),
                    ),
                  ),
                  onPressed: () async {
                    await Firestore.instance.collection('notes').document(snapshot.data.documents[index].documentID).updateData({
                      "name": noteNameController.text,
                    });
                    Navigator.pop(context);
                    scaffoldKey.currentState.showSnackBar(
                      CustomSnackBar(
                        Text('Updated list name successfully!'),
                        Duration(seconds: 1),
                        /* action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {
                            scaffoldKey.currentState.hideCurrentSnackBar();
                          },
                        ), */
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
}

class EditFolderName extends StatefulWidget {
  String folderDocID;
  bool isDarkMode;
  EditFolderName({
    this.folderDocID,
    this.isDarkMode,
  });
  @override
  EditFolderNameState createState() => EditFolderNameState();
}

class EditFolderNameState extends State<EditFolderName> {
  String folderDocID;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? backColor : lightModeBackColor,
      title: Text(
        'Edit Folder',
        style: TextStyle(
          color: widget.isDarkMode ? Colors.white : Colors.black,
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
              controller: folderEditNameController,
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Folder name',
                hintStyle: TextStyle(
                  color: widget.isDarkMode ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
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
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FlatButton(
                onPressed: folderEditNameController.text == ''
                    ? null
                    : () async {
                        await Firestore.instance.collection('folders').document(widget.folderDocID).updateData(
                          {
                            "name": folderEditNameController.text,
                          },
                        );
                        Navigator.pop(context);
                      },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: folderEditNameController.text == ''
                        ? widget.isDarkMode
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.2)
                        : mainColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* 
ReceivePort recievePort = ReceivePort();
double progressValue = 0;

downloadCallback(id, status, progress) {
  SendPort sendport = IsolateNameServer.lookupPortByName("downloading");
  sendport.send([id, status, progress]);
}
*/

void checkForUpdates(BuildContext context, bool isDarkMode) async {
  double currentVersion = appVersion;
  Map<String, dynamic> data = await DatabaseServices().getUpdates();
  double minimumVersion = data["minimumVersion"];
  double latestVersion = data["latestVersion"];
  String downloadUrl = data["downloadUrl"];
  String backupDownloadUrl = data["backupDownloadUrl"];

  print("isDarkMode = $isDarkMode");

  //minimumVersion =
  //    0.8; //TODO: I SWEAR TO GOD IF I DON'T REMOVE THIS I WILL HATE MYSELF FOREVER :D

  print("minimumVersion: $minimumVersion");
  print("latestVersion: $latestVersion");
  print("currentVersion: $currentVersion");

  print(backupDownloadUrl);
  print(downloadUrl);

  if (currentVersion < minimumVersion) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: UpdateDialog(
            downloadUrl: downloadUrl,
            backupDownloadUrl: backupDownloadUrl,
            isRequired: true,
            isDarkMode: isDarkMode,
          ),
        );
      },
    );
  } else {
    if (currentVersion < latestVersion) {
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return UpdateDialog(
            downloadUrl: downloadUrl,
            backupDownloadUrl: backupDownloadUrl,
            isRequired: false,
            isDarkMode: isDarkMode,
          );
        },
      );
    }
  }
}

class UpdateDialog extends StatefulWidget {
  final bool isRequired;
  final String backupDownloadUrl;
  final String downloadUrl;
  final bool isDarkMode;
  UpdateDialog({
    this.downloadUrl,
    this.backupDownloadUrl,
    this.isRequired,
    this.isDarkMode,
  });
  @override
  _UpdateDialogState createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool isRequired;
  String updateInstructions;

  @override
  void initState() {
    updateInstructions = widget.isRequired == true ? "Please update the app to continue. Once the download is complete, " : "The developer has released a new update! It is recommended that you update the app, and once the app is done downloading, ";
    isRequired = widget.isRequired;
    updateInstructions += "please follow through the instructions, allow all permissions and don't report to the Google Play Store!";

    /* 
    FlutterDownloader.registerCallback(downloadCallback);
    IsolateNameServer.registerPortWithName(recievePort.sendPort, "downloading");

    recievePort.listen((message) {
      print(progressValue);
      setState(() {
        progressValue = message[2];
      });
    }); 
    */
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? backColor : lightModeBackColor,
      title: Text(
        'New update available',
        style: TextStyle(
          color: widget.isDarkMode ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
      ),
      content: Text(
        updateInstructions,
        style: TextStyle(
          color: widget.isDarkMode ? Colors.white.withOpacity(0.75) : Colors.black.withOpacity(0.75),
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
      ),
      actions: [
        if (!isRequired)
          FlatButton(
            color: Colors.red,
            child: Text(
              'Later',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        /* FlatButton(
          child: Text(
            'Close App',
            style: TextStyle(
              color: mainColor,
            ),
          ),
          onPressed: () {
            SystemNavigator.pop();
          },
        ), */
        FlatButton(
          child: Text(
            'Update App',
            style: TextStyle(color: mainColor),
          ),
          /* onPressed: () async {
            final status = await Permission.storage.request();
            final externalDirectory = await getExternalStorageDirectory();

            if (status.isGranted) {
              final id = await FlutterDownloader.enqueue(
                url: widget.downloadUrl,
                savedDir: externalDirectory.path,
                fileName: 'Updating app...',
                showNotification: true,
                openFileFromNotification: true,
              );
            } else {
              print('Failed to grant storage permission');
              SystemNavigator.pop();
            }
          }, */
          onPressed: () async {
            if (await canLaunch(widget.downloadUrl)) {
              launch(widget.downloadUrl);
            } else if (await canLaunch(widget.backupDownloadUrl)) {
              launch(widget.backupDownloadUrl);
            } else {
              Navigator.pop(context);
              SnackBar snackbar = CustomSnackBar(
                Text("Sorry, an unexpected error occured"),
                Duration(seconds: 1),
              );
              scaffoldKey.currentState.showSnackBar(snackbar);
            }
          },
        ),
      ],
    );
  }
}
