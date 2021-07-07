import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

Future<Null> getAndSetLocation(String uid) async {
  FirebaseFirestore db = FirebaseFirestore.instance;

  print('getting and set Location');
  Location location;
  location = Location();

  String locationStr;

  try {
    locationStr = location.getLocation().toString();
  } catch (e) {
    print('location Error = ' + e);
    return null;
  }

  if (locationStr != null) {
    await db
        .collection("users")
        .doc(uid)
        .update({"location": locationStr})
        .then((value) => print("update Location User Success"))
        .catchError((onError) => print("update Location User Error $onError"));

    // await db
    //     .collection("shops")
    //     .doc(uid)
    //     .update({"shop_location": locationStr})
    //     .then((value) => print("update Location Shop Success"))
    //     .catchError((onError) => print("update Location Shop Error $onError"));

    await db
        .collection("drivers")
        .doc(uid)
        .update({"driverLocation": locationStr})
        .then((value) => print("update Location driver Success"))
        .catchError((onError) => print("update Location driver Error $onError"));
  }
}
