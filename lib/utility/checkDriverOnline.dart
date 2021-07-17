import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hro/model/driverModel.dart';
Future<bool> checkDriverOnlineFunction() async {
  bool haveOnline = false;
  int driverOnlineCount = 0;
  await FirebaseFirestore.instance
      .collection('drivers')
      .get()
      .then((value) {
    value.docs.forEach((element) {
      DriversModel driversModel = driversModelFromJson(jsonEncode(element.data()));
      if (driversModel.driverStatus == '1' || driversModel.driverStatus == '2' || driversModel.driverStatus == '9')  driverOnlineCount += 1;



    });
    print("driver Online = " + driverOnlineCount.toString());
  });
  (driverOnlineCount > 0) ? haveOnline = true : haveOnline = false;
  return haveOnline;
}
