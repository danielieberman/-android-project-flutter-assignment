import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';


enum LoginStatus { OUT, TRY, IN }

class User with ChangeNotifier {
  late String name;
  late String pass;
  late Set<WordPair> favorites;
  late LoginStatus status;
  late Image img;

  User() {
    name = "";
    pass = "";
    favorites = Set<WordPair>();
    status = LoginStatus.OUT;
    img = Image.network('https://www.google.com'); //placeholder, cuz null made problems
  }

  String _favsToString() {
    String str = "[";
    favorites.forEach((pair) {
      str += "{ First: " + pair.first + ", Second:" + pair.second + " }, ";
    });
    str = str.substring(0, str.length - 1) + "]";
    return str;
  }

  Future<void> addFav(WordPair p) async {
    favorites.add(p);
    if (status == LoginStatus.IN) updateDB();
    notifyListeners();
  }

  Future<void> updateDB() async {
    String favStr = _favsToString();
    var db = FirebaseFirestore.instance;
    Future<String> id = db
        .collection('users')
        .where('Email', isEqualTo: name)
        .where('password', isEqualTo: pass)
        .get()
        .then((snapshot) => snapshot.docs.first.id);
    db.collection('users').doc(await id).update({
      'favorites':
          favorites.map((f) => {'First': f.first, 'Second': f.second}).toList()
    });
  }

  Future<void> deleteFav(WordPair p) async {
    favorites.remove(p);
    if (status == LoginStatus.IN) updateDB();
    notifyListeners();
  }

  Future<bool> tryLogIn(String email, String password) async {
    try {
      status = LoginStatus.TRY;
      final _auth = FirebaseAuth.instance;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      status = LoginStatus.IN;
      name = email;
      pass = password;
      await fetchFavsFromDB();
      await fetchProfilePicFromDB();
      return true;
    } catch (e) {
      status = LoginStatus.OUT;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchFavsFromDB() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    var info = users
        .where('Email', isEqualTo: name)
        .where('password', isEqualTo: pass)
        .get()
        .then((snapshot) => snapshot.docs.first.data()['favorites']);
    info.then((favs) => favs.forEach(
        (fav) => favorites.add(WordPair(fav['First'], fav['Second']))));
    updateDB();
  }

  void logOut() {
    name = "";
    pass = "";
    final _auth = FirebaseAuth.instance;
    _auth.signOut();
    status = LoginStatus.OUT;
    notifyListeners();
  }

  Future<void> fetchProfilePicFromDB() async {
    late final String downloadURL;
    try {
      downloadURL = await FirebaseStorage.instance
          .ref('images/'+name)
          .getDownloadURL();
    } catch (e) {
      downloadURL = await FirebaseStorage.instance
          .ref('images/emptyAvatar.png')
          .getDownloadURL();
    }
    img = Image.network(downloadURL);
    notifyListeners();
  }

  Future<void> signUpAndLogin(String username, String password) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    status = LoginStatus.TRY;
    notifyListeners();
    final _auth = FirebaseAuth.instance;
    await _auth.createUserWithEmailAndPassword(email: username, password: password);
    await users.add({'Email' : username, 'password' : password, 'favorites' : {}});
    tryLogIn(username, password);
    updateDB();
  }

  //Future<Image> getImgFromDB()

}
