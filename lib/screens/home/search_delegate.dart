import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DataSearch extends SearchDelegate<String> {
  List<QuerySnapshot> allSuggestions = [];
  List<String> specificSuggestions = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        close(context, null);
      },
    );
  }

  Future<void> getData() async {
    allSuggestions = [];
    await Firestore.instance.collection('notes').snapshots().forEach((element) {
      print(element);
      allSuggestions.add(element);
    });
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text('results');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return query != ''
        ? StreamBuilder(
            stream: Firestore.instance.collection('notes').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              return snapshot.hasData
                  ? ListView.builder(
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            snapshot.data.documents[index].data["name"],
                          ),
                        );
                      },
                      itemCount:
                          snapshot.hasData ? snapshot.data.documents.length : 0,
                    )
                  : Container(
                      height: double.infinity,
                      width: double.infinity,
                      child: CircularProgressIndicator(),
                      alignment: Alignment.center,
                    );
            },
          )
        : Container();

    /*
    StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('notes').snapshots(),
      builder: (context, streamSnapshot) {
        if (streamSnapshot.hasData) {
          streamSnapshot.data.documents.forEach((element) {
            print(element['name']);
            //allSuggestions.add(element["name"].toString() ?? 'Null!');
          });
          return streamSnapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      //title: Text(allSuggestions[index]),
                      onTap: () {},
                    );
                  },
                  itemCount: allSuggestions.length,
                )
              : Center(child: CircularProgressIndicator());
        }
        return CircularProgressIndicator();
      },
    ); */

    /* allSuggestions = [];
    specificSuggestions = [];
    Firestore.instance.collection('notes').snapshots().forEach((doc) {
      print('Doc: ${doc.toString()}');
      allSuggestions.add(doc.toString());
    });
    return allSuggestions == []
        ? ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(index.toString()),
              );
            },
            itemCount: allSuggestions.length,
          )
        : Center(child: CircularProgressIndicator()); */
  }
}
