import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_todo_second/constants.dart';
import 'package:flutter/material.dart';

class Info extends StatefulWidget {
  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        backgroundColor: Colors.black.withOpacity(0.2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(300),
          child: Image(
            image: AssetImage('assets/check.png'),
            fit: BoxFit.cover,
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: backColor,
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('settings')
            .document('settings')
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> infoSnapshot) {
          if (infoSnapshot.hasData) {
            Widget textList() {
              List<Widget> returnList = [];
              List<dynamic> stringList = infoSnapshot.data['textList'];
              /* returnList = InfoSnapshot.data["textList"].map(
                (String text) {
                  return returnList.add(
                    Text(text),
                  );
                },
              ); */
              returnList = stringList
                  .map(
                    (e) => Container(
                      color: Colors.lime,
                      child: Text(
                        e.toString(),
                      ),
                    ),
                  )
                  .toList();
              return ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stringList[i].toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  );
                },
                itemCount: stringList.length,
              );
            }

            return NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (o) {
                o.disallowGlow();
              },
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    elevation: 0,
                    expandedHeight: 200,
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
                          colors: [
                            mainColor,
                            accentColor,
                          ],
                        ),
                      ),
                      child: FlexibleSpaceBar(
                        background: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                infoSnapshot.data['aboutURL'],
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    pinned: true,
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'About the creator',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              /* Chip(
                                label: Text(
                                  'Aman Meherally',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: mainColor,
                              ), */
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Text(
                                    'Aman Meherally',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: LinearGradient(
                                    colors: [
                                      mainColor,
                                      accentColor,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        /* Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: Image(
                              image: AssetImage(
                                'assets/icon.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ), */
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                infoSnapshot.data["textList"][index],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 8),
                            ],
                          );
                        },
                        childCount: infoSnapshot.data["textList"].length,
                      ),
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
    );
  }
}
