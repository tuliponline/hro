import 'package:cloud_firestore/cloud_firestore.dart';
Future<bool> checkDriverOnlineFunction() async {
  bool haveOnline = false;
  int driverOnlineCount = 0;
  await FirebaseFirestore.instance
      .collection('drivers')
      .where('driverStatus', isEqualTo: '1')
      .get()
      .then((value) {
    value.docs.forEach((element) {
      driverOnlineCount += 1;
    });
    print("driver Onlinr = " + driverOnlineCount.toString());
  });
  (driverOnlineCount > 0) ? haveOnline = true : haveOnline = false;
  return haveOnline;
}
