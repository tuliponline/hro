import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

Future<Null> updateToken(String uid,String token) async {
  FirebaseFirestore db = FirebaseFirestore.instance;

  if (token != null) {
    await db
        .collection("users")
        .doc(uid)
        .update({"token": token})
        .then((value) => print("update token User Success"))
        .catchError((onError) => print("update token User Error $onError"));

    await db
        .collection("shops")
        .doc(uid)
        .update({"token": token})
        .then((value) => print("update token Shop Success"))
        .catchError((onError) => print("update token Shop Error $onError"));

    await db
        .collection("drivers")
        .doc(uid)
        .update({"token": token})
        .then((value) => print("update token driver Success"))
        .catchError((onError) => print("update token driver Error $onError"));
  }
}
