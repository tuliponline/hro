import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/utility/snapshot2list.dart';

Future<int> driverQueue(String driverUid) async {
  int queue = 0;
  List<DriversListModel> driversListModel;
  await FirebaseFirestore.instance
      .collection("drivers")
      .where("driverStatus", isEqualTo: "1")
      .orderBy("onlineTime", descending: false)
      .get()
      .then((value) async {
    var jsonData = await setList2Json(value);
    print(jsonData);
    driversListModel = driversListModelFromJson(jsonData);
    print("driverOnlineCount= " + driversListModel.length.toString());
    int i = 0;
    driversListModel.forEach((element) {
      i++;
      if (element.driverId == driverUid) {
        queue = i;
      }

    });
  });
  print("Queue = " + queue.toString());
  return queue;
}
