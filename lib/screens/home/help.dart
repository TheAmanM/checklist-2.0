import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_todo_second/constants.dart';
import 'package:flutter/material.dart';

class Help extends StatefulWidget {
  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Help'),
        backgroundColor: Colors.blue,
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
      backgroundColor: backColor,
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('settings')
            .document('settings')
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> helpSnapshot) {
          if (helpSnapshot.hasData) {
            return ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              itemBuilder: (context, index) {
                return Text(
                  helpSnapshot.data["usage"][index],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(height: 12);
              },
              itemCount: helpSnapshot.data["usage"].length,
            );
            /* Widget textList() {
              List<Widget> returnList = [];
              List<dynamic> stringList = HelpSnapshot.data['textList'];
              /* returnList = HelpSnapshot.data["textList"].map(
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

            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height * 0.2,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
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
                              HelpSnapshot.data['aboutURL'],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
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
                            Chip(
                              label: Text(
                                'Aman Meherally',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: mainColor,
                            ),
                          ],
                        ),
                      ),
                      /* Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 24,
                        ),
                        child: textList(),
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
                              HelpSnapshot.data["textList"][index],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                        );
                      },
                      childCount: HelpSnapshot.data["textList"].length,
                    ),
                  ),
                ),
              ],
            ); */
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
