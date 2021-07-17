import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';


// var jsonData = await setList2Json(value);
// print(jsonData);
// orderProduct = orderProductFromJson(jsonData);

 setList2Json(QuerySnapshot<Map<String, dynamic>> value) {

  String jsonData;
  List<DocumentSnapshot> templist;
  List list = new List();
  templist = value.docs;
  list = templist.map((DocumentSnapshot docSnapshot) {
     return docSnapshot.data();
  }).toList();
  print('ListType=' + list.runtimeType.toString());

 jsonData = jsonEncode(list);

  return jsonData.toString();
}


