import 'package:cloud_firestore/cloud_firestore.dart';

Future<Null> addLog(String orderId, String status, String setBy, String setId,
    String comment) async {

  var now = DateTime.now();
  String timeString = now.year.toString() +
      "/" +
      now.month.toString() +
      "/" +
      now.day.toString() +
      " " +
      now.hour.toString() +
      ':' +
      now.minute.toString();


  String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
  var fireDb = FirebaseFirestore.instance;
  var data = {
    'logId': timeStamp,
    'orderId': orderId,
    'status': status,
    'setBy': setBy,
    'setId': setId,
    'time': timeString,
    'comment': comment
  };
  print('addLogSuccess');
  await fireDb.collection('logs').doc(timeStamp).set(data).then((value) {
  }).catchError((onError) {
    print('addLogError = $onError');
  });
}
