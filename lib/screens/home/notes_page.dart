import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_todo_second/constants.dart';
import 'package:firebase_todo_second/screens/home/info.dart';
import 'package:firebase_todo_second/screens/home/help.dart';
import 'package:firebase_todo_second/screens/home/list_detail.dart';
import 'package:firebase_todo_second/screens/home/search_delegate.dart';
import 'package:firebase_todo_second/screens/home/users.dart';
import 'package:firebase_todo_second/services/auth.dart';
import 'package:firebase_todo_second/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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

class _NotesPageState extends State<NotesPage>
    with SingleTickerProviderStateMixin {
  AuthServices _auth = new AuthServices();
  DatabaseServices _db = new DatabaseServices();
  double sliderValue = 0;
  int color = 0;
  Color pickerColor;
  String userID = '';
  double topContainerHeight = 0.15;
  TextEditingController _nameController = new TextEditingController();
  int currentIndex = 0;
  bool enableOK = false;

  TabController tabBarController;

  Future<void> getUserID() async {
    userID = await _auth.getCurrentUserID();
  }

  ValueChanged<Color> onColorChanged(color) {
    //await _db.updateColor(await _auth.getCurrentUserID(), color);
    //pickerColor = color;
    print(color);
  }

  Stream<QuerySnapshot> get notesStream {
    return Firestore.instance.collection('notes').snapshots();
  }

  @override
  void initState() {
    tabBarController = new TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    getUserID();
    super.initState();
  }

  Widget getBottomNavBarItem(
      IconData icon, String text, int givenIndex, Function onPress) {
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
              color: currentIndex == givenIndex
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
            ),
            Text(
              text,
              style: TextStyle(
                color: currentIndex == givenIndex
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
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
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _auth.currentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            color = snapshot.data['color'];
            print((0.2126 * Color(color).red) +
                (0.7152 * Color(color).green) +
                (0.0722 * Color(color).blue));
          }
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
                      IconButton(
                        icon: Text(
                          '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                          ),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Help();
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.info_outline,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Info();
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
                              backgroundColor: backColor,
                              content: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Text(
                                  'Are you sure you want to log out?',
                                  style: TextStyle(
                                    color: Colors.white,
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
                        Tab(text: 'ALL LISTS'),
                        Tab(text: 'MY LISTS'),
                      ],
                    ),
                  )
                : null,
            key: scaffoldKey,
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
                          return AddList();
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
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
                      gradient: LinearGradient(
                          colors: [mainColor, accentColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight),
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
                              SnackBar(
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
                          () => showSettingsSheet(),
                        ),
                        /* IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            //showSearch(context: context, delegate: DataSearch());
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
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
                builder:
                    (context, AsyncSnapshot<DocumentSnapshot> streamSnapshot) {
                  if (streamSnapshot.hasData && snapshot.hasData) {
                    return Drawer(
                      child: Container(
                        color: backColor,
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
                              accountName:
                                  Text(streamSnapshot.data['name'] ?? ''),
                              currentAccountPicture: CircleAvatar(
                                backgroundColor: color == 0
                                    ? Colors.black
                                    : Color(streamSnapshot.data['color']),
                                child: Text(
                                  streamSnapshot.data['name']
                                          .toString()
                                          .substring(0, 1) ??
                                      '',
                                  style: TextStyle(
                                    color: 0.2126 *
                                                    Color(streamSnapshot
                                                            .data['color'])
                                                        .red +
                                                0.7152 *
                                                    Color(streamSnapshot
                                                            .data['color'])
                                                        .red +
                                                0.0722 *
                                                    Color(streamSnapshot
                                                            .data['color'])
                                                        .blue >
                                            240
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Folders',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  InkWell(
                                    child: Icon(Icons.add, color: Colors.white),
                                    onTap: () async {
                                      setState(() {
                                        keyboardVisible = true;
                                      });
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AddFolder();
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
                              color: Colors.white,
                              thickness: 0.5,
                              height: 0.5,
                            ),
                            FolderDisplayStreamBuilder(),
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
                      child: Container(color: backColor),
                    );
                  }
                }),
            backgroundColor: backColor,
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
            body: currentIndex == 0
                ? !keyboardVisible
                    ? Theme(
                        data: Theme.of(context).copyWith(
                          accentColor: mainColor,
                        ),
                        child: TabBarView(
                          controller: tabBarController,
                          children: [
                            MainGridDisplay(
                              stream: Firestore.instance
                                  .collection('notes')
                                  .orderBy("name")
                                  .snapshots(),
                            ),
                            MainGridDisplay(
                              stream: Firestore.instance
                                  .collection('notes')
                                  .where(
                                    'ownerID',
                                    isEqualTo: userID,
                                  )
                                  .orderBy("name")
                                  .snapshots(),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        color: backColor,
                      )
                : currentIndex == 1
                    ? showSearch(
                        context: context,
                        delegate: DataSearch(),
                      )
                    : currentIndex == 2 ? Users() : Container(color: backColor),
          );
        },
      ),
    );
  }

  void showSettingsSheet() async {
    Stream<DocumentSnapshot> mainReference =
        _db.usersCollection.document(userID).snapshots();
    setState(() {
      keyboardVisible = true;
    });
    await showModalBottomSheet(
      backgroundColor: backColor,
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
                                  style: TextStyle(color: Colors.white),
                                  textCapitalization: TextCapitalization.words,
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
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
                                await _db.updateColor(
                                    await _auth.getCurrentUserID(), c.value);
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

class MainGridDisplay extends StatefulWidget {
  final Stream<QuerySnapshot> stream;
  MainGridDisplay({this.stream});

  @override
  _MainGridDisplayState createState() => _MainGridDisplayState();
}

class _MainGridDisplayState extends State<MainGridDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: backColor,
      child: StreamBuilder<QuerySnapshot>(
        stream: widget.stream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          List<Widget> returnList = [];
          if (snapshot.hasData)
            snapshot.data.documents.forEach(
              (DocumentSnapshot element) {
                returnList.add(
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          color: backColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 5,
                              spreadRadius: 0.1,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              element["name"].toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          return snapshot.hasData
              ? Theme(
                  data: Theme.of(context).copyWith(
                    accentColor: mainColor,
                  ),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    semanticChildCount: 2,
                    padding: EdgeInsets.all(8),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      String currentDocID =
                          snapshot.data.documents[index].documentID;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return NotesDetail(
                                    snapshot.data.documents[index].documentID,
                                    snapshot.data.documents[index]["name"],
                                  );
                                },
                              ),
                            );
                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: lightBackColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: NotificationListener<
                                  OverscrollIndicatorNotification>(
                                onNotification: (overScroll) {
                                  overScroll.disallowGlow();
                                },
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              snapshot
                                                  .data.documents[index]["name"]
                                                  .toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            child: Container(
                                              color: lightBackColor,
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
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 25),
                                      StreamBuilder(
                                        stream: Firestore.instance
                                            .collection('notes')
                                            .document(currentDocID)
                                            .snapshots(),
                                        builder: (context,
                                                AsyncSnapshot<DocumentSnapshot>
                                                    orderSnapshot) =>
                                            StreamBuilder<QuerySnapshot>(
                                          stream: Firestore.instance
                                              .collection('notes')
                                              .document(currentDocID)
                                              .collection('items')
                                              .orderBy(orderSnapshot.hasData
                                                  ? orderSnapshot.data[
                                                              'sortByName'] ==
                                                          true
                                                      ? "name"
                                                      : "done"
                                                  : "name")
                                              .snapshots(),
                                          builder: (context,
                                              AsyncSnapshot<QuerySnapshot>
                                                  secondSnapshot) {
                                            List<Widget> widgetList = [];
                                            try {
                                              secondSnapshot.data.documents
                                                  .forEach(
                                                (DocumentSnapshot element) {
                                                  if (element.data['name']
                                                      .toString()
                                                      .isNotEmpty) {
                                                    widgetList.add(
                                                      Text(
                                                        element.data['name'],
                                                        style: TextStyle(
                                                          color: element.data[
                                                                      'done'] ==
                                                                  true
                                                              ? Colors.white
                                                                  .withOpacity(
                                                                      0.5)
                                                              : Colors.white,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          decoration: element
                                                                          .data[
                                                                      'done'] ==
                                                                  true
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : TextDecoration
                                                                  .none,
                                                        ),
                                                        overflow:
                                                            TextOverflow.fade,
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
                                                      color: Colors.white
                                                          .withOpacity(0.9),
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                ];
                                              }
                                            } catch (e) {
                                              widgetList = [];
                                            }
                                            Stream<DocumentSnapshot> sortRef =
                                                Firestore.instance
                                                    .collection("notes")
                                                    .document(currentDocID)
                                                    .snapshots();
                                            return widgetList.isNotEmpty
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: widgetList,
                                                  )
                                                : Text(
                                                    'Loading...',
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.9),
                                                      fontWeight:
                                                          FontWeight.w300,
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
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
          /* return snapshot.hasData
                ? ListView.builder(
                    itemBuilder: (context, int index) {
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
                    },
                    itemCount: snapshot.data.documents.length,
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ); */
        },
      ),
    );
  }
}

class FolderDisplayStreamBuilder extends StatefulWidget {
  @override
  _FolderDisplayStreamBuilderState createState() =>
      _FolderDisplayStreamBuilderState();
}

class _FolderDisplayStreamBuilderState
    extends State<FolderDisplayStreamBuilder> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          Firestore.instance.collection('folders').orderBy("name").snapshots(),
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
                              backgroundColor: backColor,
                              content: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  'Are you sure you want to delete this folder?',
                                  style: TextStyle(
                                    color: Colors.white,
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
                          await Firestore.instance
                              .collection('notes')
                              .where("folder",
                                  isEqualTo: folderSnapshot
                                      .data.documents[index].documentID)
                              .getDocuments()
                              .then(
                            (QuerySnapshot value) {
                              for (DocumentSnapshot d in value.documents) {
                                d.reference.updateData(
                                  {"folder": ""},
                                );
                              }
                            },
                          );
                          await folderSnapshot.data.documents[index].reference
                              .delete();
                        }
                        return shouldDeleteFolder;
                      } else {
                        return false;
                      }
                    },
                    child: Theme(
                      data: ThemeData(
                        accentColor: Colors.white,
                        unselectedWidgetColor: Colors.white,
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
                        stream: Firestore.instance
                            .collection('notes')
                            .where('folder',
                                isEqualTo: folderSnapshot
                                    .data.documents[index].documentID)
                            .snapshots(),
                        builder: (context,
                            AsyncSnapshot<QuerySnapshot> subFolderSnapshot) {
                          if (subFolderSnapshot.hasData) {
                            List<Widget> tileWidgets = [];
                            subFolderSnapshot.data.documents.forEach(
                              (DocumentSnapshot element) {
                                tileWidgets.add(
                                  ListTile(
                                    title: Text(
                                      element.data['name'],
                                      style: TextStyle(color: Colors.white),
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
                              backgroundColor: lightBackColor,
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
                                                e.documentID.toString(),
                                                e.data["name"].toString(),
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
                                              color:
                                                  Colors.white.withOpacity(0.8),
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
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onTap: () async {
                                      folderEditNameController.text =
                                          await folderSnapshot
                                              .data.documents[index]["name"];
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return EditFolderName(
                                              folderDocID: folderSnapshot.data
                                                  .documents[index].documentID);
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    folderSnapshot.data.documents[index]
                                        ['name'],
                                    style: TextStyle(
                                      color: Colors.white,
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
  @override
  _AddListState createState() => _AddListState();
}

class _AddListState extends State<AddList> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backColor,
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
              color: enableOK ? mainColor : Colors.white.withOpacity(0.2),
            ),
          ),
          onPressed: enableOK
              ? () async {
                  await DatabaseServices().createList(
                    listNameController.text,
                    await AuthServices().getCurrentUserID(),
                  );
                  enableOK = false;
                  Navigator.pop(context);
                }
              : null,
        ),
      ],
      title: Text(
        'Create new list',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20,
          color: Colors.white,
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
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'List name',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                ),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddFolder extends StatefulWidget {
  @override
  _AddFolderState createState() => _AddFolderState();
}

class _AddFolderState extends State<AddFolder> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backColor,
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
                  : Colors.white.withOpacity(0.2),
            ),
          ),
          onPressed: folderNameController.text != ''
              ? () async {
                  await DatabaseServices()
                      .createFolder(folderNameController.text);
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
          color: Colors.white,
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
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Folder name',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                ),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
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
  NoteEditDelete({
    this.snapshot,
    this.index,
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
      backgroundColor: backColor,
      title: Text(
        'Edit list',
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
                setState(() {
                  enableNoteNameSaving =
                      noteNameController.text == '' ? false : true;
                });
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
                ), */
                FlatButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    'SAVE',
                    style: TextStyle(
                      color: enableNoteNameSaving
                          ? mainColor
                          : Colors.white.withOpacity(0.2),
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
                        content: Text('Updated list name successfully!'),
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
            ),
          ],
        ),
      ),
    );
  }
}

class EditFolderName extends StatefulWidget {
  String folderDocID;
  EditFolderName({
    this.folderDocID,
  });
  @override
  EditFolderNameState createState() => EditFolderNameState();
}

class EditFolderNameState extends State<EditFolderName> {
  String folderDocID;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backColor,
      title: Text(
        'Edit Folder',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: (v) {
              setState(() {});
            },
            autofocus: true,
            controller: folderEditNameController,
            style: TextStyle(color: Colors.white),
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Folder name',
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
          Align(
            alignment: Alignment.centerRight,
            child: FlatButton(
              onPressed: folderEditNameController.text == ''
                  ? null
                  : () async {
                      await Firestore.instance
                          .collection('folders')
                          .document(widget.folderDocID)
                          .updateData(
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
                      ? Colors.white.withOpacity(0.2)
                      : mainColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
