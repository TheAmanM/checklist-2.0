import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_todo_second/constants.dart';

class DatabaseServices {
  final CollectionReference usersCollection =
      Firestore.instance.collection('users');
  final CollectionReference notesCollection =
      Firestore.instance.collection('notes');
  final CollectionReference foldersCollection =
      Firestore.instance.collection('folders');
  final CollectionReference requestsCollection =
      Firestore.instance.collection('requests');

  final Stream<DocumentSnapshot> settingsSnapshot = Firestore.instance
      .collection('settings')
      .document('settings')
      .snapshots();
  final DocumentReference settingsDoc =
      Firestore.instance.collection('settings').document('settings');

  Future<void> addItem(String docID, String itemName) async {
    notesCollection.document(docID).collection('items').add({
      "name": itemName,
      "done": false,
    });
  }

  Future<void> createList(String name, String ownerID) async {
    Map data = {
      "canReadAndExport": true,
      "canEditName": false,
      "canEditFolder": false,
      "canEditItems": false,
      "canMarkIncomplete": false,
      "canDelete": false,
    };
    await notesCollection.document().setData({
      "name": name,
      "sortByName": true,
      "folder": "",
      "ownerID": ownerID,
      "security": data,
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

  Future<String> getCurrentUsersName(uid) async {
    DocumentSnapshot userDoc = await usersCollection.document(uid).get();
    // print(userDoc.snapshots());
    return userDoc.data["name"].toString();
  }

  Future<void> updateColor(uid, int color) async {
    await usersCollection.document(uid).updateData({
      "color": color,
    });
    print('executed updateColor');
  }

  Stream<DocumentSnapshot> getUserDataAsStream(String uid) {
    return usersCollection.document(uid).snapshots();
  }

  Future<void> sendVersionNumber(String userID) async {
    usersCollection.document(userID).updateData({
      "appVersion": appVersion,
    });
  }

  Future<int> getColor(uid) async {
    int color;
    await usersCollection.document(uid).get().then((DocumentSnapshot value) {
      color = value['color'];
    });
    return color;
  }

  Future<void> updateName(uid, String name) async {
    await usersCollection.document(uid).updateData({
      "name": name,
    });
    // print('executed updateColor');
  }

  Future<void> updateData(String uid, Map<String, dynamic> data) async {
    await usersCollection.document(uid).updateData(data);
  }

  Future<Map<String, dynamic>> getUpdates() async {
    Map<String, dynamic> docData = await Firestore.instance
        .collection('settings')
        .document('settings')
        .get()
        .then((DocumentSnapshot doc) {
      return doc.data;
    });
    Map<String, dynamic> returnVal = {
      "minimumVersion": docData["minimumVersion"].toDouble(),
      "latestVersion": docData["latestVersion"].toDouble(),
      "downloadUrl": docData["downloadUrl"],
      "backupDownloadUrl": docData["backupDownloadUrl"],
    };
    return returnVal;
  }

  Future<void> setSecuritySettings(String documentID, Map securitySettings) {
    notesCollection.document(documentID).updateData({
      "security": securitySettings,
    });
  }

  Future<void> submitFeatureBug(bool isFeature, String text) async {
    Map<String, dynamic> data = {
      "isFeature": isFeature,
      "text": text,
    };
    await requestsCollection.add(data);
  }

  Stream<DocumentSnapshot> getPreferredTheme(String uid) {
    print('uid given: $uid');
    return Firestore.instance.collection('users').document(uid).snapshots();
  }
}
