import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final CollectionReference usersCollection =
      Firestore.instance.collection('users');
  final CollectionReference notesCollection =
      Firestore.instance.collection('notes');
  final CollectionReference foldersCollection =
      Firestore.instance.collection('folders');

  Future<void> addItem(String docID, String itemName) async {
    notesCollection.document(docID).collection('items').add({
      "name": itemName,
      "done": false,
    });
  }

  Future<void> createList(String name, String ownerID) async {
    await notesCollection.document().setData({
      "name": name,
      "sortByName": true,
      "folder": "",
      "ownerID": ownerID,
    });
  }

  Future<void> createFolder(String name) async {
    await foldersCollection.document().setData({
      "name": name,
    });
  }

  Future<void> editItem(
      String docID, String updatedName, String itemID, bool done) async {
    notesCollection
        .document(docID)
        .collection('items')
        .document(itemID)
        .updateData({"name": updatedName, "done": done});
  }

  Future<void> createUserTemplate(uid, name) {
    usersCollection.document(uid).setData({
      "name": name,
      "color": 0,
    });
  }

  Future<void> getCurrentUsersName(uid) {
    var userDoc = usersCollection.document(uid);
    print(userDoc.snapshots());
  }

  Future<void> updateColor(uid, int color) async {
    await usersCollection.document(uid).updateData({
      "color": color,
    });
    print('executed updateColor');
  }

  Future<void> updateName(uid, String name) async {
    await usersCollection.document(uid).updateData({
      "name": name,
    });
    print('executed updateColor');
  }
}
