import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_todo_second/services/database.dart';

class AuthServices {
  //instantiate _auth as instance
  final _auth = FirebaseAuth.instance;
  DatabaseServices db = new DatabaseServices();

  Future<String> getCurrentUserID() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    print(user.uid);
    return user.uid;
  }

  //current user
  Future<Map<String, dynamic>> currentUser() async {
    Map<String, dynamic> returnMap = {
      'userName': '',
      'userEmail': '',
      'color': 0,
    };
    FirebaseUser currentUser = await _auth.currentUser();

    String currentUserUID = currentUser.uid;
    print('currentUserUID: $currentUserUID');
    String userName;
    int color;
    await db.usersCollection.document(currentUserUID).get().then((value) {
      userName = value.data['name'] ?? 0;
      color = value.data['color'] ?? 0;
    });

    returnMap.update(
      'userName',
      (value) => value = userName.toString(),
    );
    returnMap.update(
      'userEmail',
      (value) => value = currentUser.email,
    );
    returnMap.update(
      'color',
      (value) => value = color,
    );

    return returnMap;
  }

  //register
  Future register(String email, String pass, String name) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      FirebaseUser user = result.user;
      await db.createUserTemplate(user.uid, name);
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign in
  Future signIn(String email, String pass) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      FirebaseUser user = result.user;
      return user;
    } catch (e) {
      print('Error: ${e.toString()}');
      return null;
    }
  }

  //sign out
  Future signOut() {
    try {
      _auth.signOut();
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //stream
  Stream<FirebaseUser> get userStream {
    return _auth.onAuthStateChanged;
  }
}
