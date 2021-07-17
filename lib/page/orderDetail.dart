import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/appStatusModel.dart';
import 'package:hro/model/cartModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/userModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/addLog.dart';
import 'package:hro/utility/checkDriverOnline.dart';
import 'package:hro/utility/getAddressName.dart';
import 'package:hro/utility/getLocationData.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class OrderDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OrderDetailState();
  }
}

class OrderDetailState extends State<OrderDetailPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  Dialogs dialogs = Dialogs();
  String addressComment;
  String addressName;

  int costDelivery;
  int amount;
  double lat, lng;

  String token;

  int riderOnline = 0;
  int riderFree = 0;

  bool checkRiderOnline = false;
  List<DriversListModel> driverListModel;

  AppStatusModel appStatusModel;
  bool customerOpen = false;
  String dateOpen = '';

  bool inService;

  _getRiderOnline(AppDataModel appDataModel) async {
    riderOnline = 0;
    riderFree = 0;
    await FirebaseFirestore.instance
        .collection('appstatus')
        .doc('001')
        .get()
        .then((value) async {
      appStatusModel = appStatusModelFromJson(jsonEncode(value.data()));
      print("date Open = " + appStatusModel.dateopen);
      DateTime dateOpenRow = DateTime.parse(appStatusModel.dateopen);
      dateOpen = dateOpenRow.day.toString() +
          "/" +
          dateOpenRow.month.toString() +
          "/" +
          dateOpenRow.year.toString();

      (appStatusModel.customerOpen == "1")
          ? customerOpen = true
          : customerOpen = false;

      riderOnline = 0;
      await FirebaseFirestore.instance
          .collection('drivers')
          .get()
          .then((value) async {
        var jsonData = await setList2Json(value);
        driverListModel = driversListModelFromJson(jsonData);

        driverListModel.forEach((element) {
          DriversModel driversModel = driversModelFromJson(jsonEncode(element));
          if (driversModel.driverStatus == "1" ||
              driversModel.driverStatus == "2" ||
              driversModel.driverStatus == "9") {
            riderOnline += 1;
            if (driversModel.driverStatus == "1") riderFree += 1;
          }
        });

        print("riderOnline " + riderOnline.toString());
        print("riderFree " + riderFree.toString());

        _calData(context.read<AppDataModel>());
      });
    });
  }

  Future<Null> _calData(AppDataModel appDataModel) async {
    print("startCallData");

    LocationData locationData = await getLocationData();
    double lat = locationData.latitude;
    double lng = locationData.longitude;

    addressName = await getAddressName(lat, lng);
    print("Get Now LocationCallData");

    inService = await checkLocationLimit(appDataModel.latStart,
        appDataModel.lngStart, lat, lng, appDataModel.distanceLimit);
    print("inService = " + inService.toString());

    amount = appDataModel.allPrice;
    if (appDataModel.allPcs == 1) {
      costDelivery = 20;
    } else {
      int pcs;
      int addCost;

      pcs = appDataModel.allPcs - 1;
      addCost = pcs * 2;
      costDelivery = 20 + addCost;
    }
    setState(() {
      checkRiderOnline = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (checkRiderOnline == false)
      _getRiderOnline(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Style().darkColor,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              body: Container(
                child: (addressName == null)
                    ? Style().circularProgressIndicator(Style().darkColor)
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            buildAddressDetail(appDataModel),
                            buildOrderDetail(context.read<AppDataModel>()),
                            Container(
                              width: appDataModel.screenW * 0.9,
                              child: (inService == false)
                                  ? ElevatedButton(
                                      onPressed: () async {
                                        //_getOrder(context.read<AppDataModel>());
                                      },
                                      child: Style().textBlackSize(
                                          "ท่านอยู่นอกพื้นที่ให้บริการ เกิน " +
                                              appDataModel.distanceLimit
                                                  .toString() +
                                              " กม.",
                                          14),
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.yellow,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5))),
                                    )
                                  : (customerOpen == false)
                                      ? ElevatedButton(
                                          onPressed: () async {
                                            await checkDriverOnlineFunction()
                                                .then((value) {
                                              print(value);
                                            });
                                          },
                                          child: Style()
                                              .titleH3('ปิดให้บริการชั่วคราว'),
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.grey,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5))),
                                        )
                                      : (appDataModel.shopOpen == true)
                                          ? (riderOnline == 0)
                                              ? ElevatedButton(
                                                  onPressed: () {},
                                                  child: Style().textBlackSize(
                                                      'ไม่มี Rider Online โปรดสั่งใหม่ภายหลัง',
                                                      14),
                                                  style: ElevatedButton.styleFrom(
                                                      primary:
                                                          Colors.grey.shade200,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5))),
                                                )
                                              : ElevatedButton(
                                                  onPressed: () async {
                                                    await checkDriverOnlineFunction()
                                                        .then((value) async {
                                                      if (value == true) {
                                                        if (riderFree > 0) {
                                                          _addOrder(context.read<
                                                              AppDataModel>());
                                                        } else {
                                                          var result =
                                                              await Dialogs().confirm(
                                                                  context,
                                                                  "Rider คิวเต็ม",
                                                                  "ใช้เวลานานกว่าปกติ",
                                                                  Icon(
                                                                    FontAwesomeIcons
                                                                        .clock,
                                                                    color: Colors
                                                                        .deepOrange,
                                                                  ));
                                                          if (result != null &&
                                                              result == true)
                                                            _addOrder(context.read<
                                                                AppDataModel>());
                                                        }
                                                      } else {
                                                        dialogs.information(
                                                            context,
                                                            Style().textBlackSize(
                                                                "ไม่มี Rider Online",
                                                                16),
                                                            Style().textBlackSize(
                                                                "โปรดสั่งใหม่ภายหลัง",
                                                                16));
                                                      }
                                                    });

                                                    //_getOrder(context.read<AppDataModel>());
                                                  },
                                                  child: Style().titleH3(
                                                      'สั่งซื้อ ' +
                                                          (amount +
                                                                  costDelivery)
                                                              .toString() +
                                                          ' ฿'),
                                                  style: ElevatedButton.styleFrom(
                                                      primary:
                                                          Style().primaryColor,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5))),
                                                )
                                          : ElevatedButton(
                                              onPressed: () {},
                                              child: Style().titleH3(
                                                  'ร้านปิด ไม่สามารถสั่งอาหารได้'),
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors.grey,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5))),
                                            ),
                            ),
                          ],
                        ),
                      ),
              ),
            ));
  }

  Container buildOrderDetail(AppDataModel appDataModel) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 3),
      child: Column(
        children: [
          Container(
            child: Style().textSizeColor('สรุปรายการ', 16, Style().textColor),
          ),
          Container(
              margin: EdgeInsets.all(1),
              child: Divider(
                color: Colors.grey,
                height: 0,
              )),
          Column(
            children: appDataModel.currentOrder.map((e) {
              print('e = ' + e.productName);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: ListTile(
                    title: (e.productName?.isEmpty ?? true)
                        ? Text('')
                        : Style().textFlexibleBackSize(
                            e.productName,
                            2,
                            14,
                          ),
                    subtitle: (e.comment?.isEmpty ?? true)
                        ? Text('')
                        : Style()
                            .textSizeColor(e.comment, 12, Style().textColor),
                  )),
                  Column(
                    children: [
                      Style()
                          .textSizeColor(e.price + ' ฿', 16, Style().textColor),
                      Style().textSizeColor(
                          'จำนวน x ' + e.pcs, 12, Style().darkColor)
                    ],
                  )
                ],
              );
            }).toList(),
          ),
          Container(
              margin: EdgeInsets.all(1),
              child: Divider(
                color: Colors.grey,
                height: 0,
              )),
          Container(
            margin: EdgeInsets.only(top: 5),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Style()
                        .textSizeColor('รวมค่าสินค้า', 16, Style().textColor),
                    Style().textSizeColor('$amount ฿', 16, Style().textColor)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Style().textSizeColor('ค่าส่ง', 16, Style().textColor),
                    Style()
                        .textSizeColor('$costDelivery ฿', 14, Style().textColor)
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Container buildAddressDetail(AppDataModel appDataModel) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 3),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Style().textSizeColor('จัดส่งที่', 16, Style().textColor),
          Row(
            children: [
              Icon(
                FontAwesomeIcons.mapMarkerAlt,
                color: Style().darkColor,
              ),
              Expanded(
                  child: ListTile(
                title: (addressName?.isEmpty ?? true)
                    ? Text('')
                    : Style().textFlexibleBackSize(addressName, 2, 14),
                subtitle: Style().textFlexibleBackSize(addressName, 2, 10),
              )),
              // IconButton(icon: Icon(Icons.navigate_next), onPressed: () {})
            ],
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Style()
                      .textSizeColor('ที่อยู่เพิ่มเติม', 14, Style().textColor),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                width: appDataModel.screenW * 0.9,
                height: 40,
                child: TextField(
                  style: TextStyle(fontSize: 14),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Style().labelColor)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: Style().labelColor)),
                      hintText: 'ไม่ระบุก็ได้',
                      hintStyle: TextStyle(fontSize: 10, fontFamily: "prompt")),
                  onChanged: (value) {
                    addressComment = value;
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  _addOrder(AppDataModel appDataModel) async {
    List<CartModel> currentOrder;
    currentOrder = appDataModel.currentOrder;

    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('orders');

    var now = DateTime.now();
    String dateString = now.year.toString() +
        "/" +
        now.month.toString() +
        "/" +
        now.day.toString() +
        " " +
        now.hour.toString() +
        ':' +
        now.minute.toString();
    String orderId = await _getTimeStamp();
    await collectionRef.doc(orderId).set({
      'comment': addressComment,
      'customerId': appDataModel.profileUid,
      'driver': '0',
      'location':
          appDataModel.latYou.toString() + ',' + appDataModel.lngYou.toString(),
      'orderId': orderId,
      'shopId': appDataModel.storeSelectId,
      'startTime': dateString,
      'inTime': '30',
      'finishTime': dateString,
      'status': '1',
      'distance': appDataModel.distanceDelivery,
      'amount': (amount).toString(),
      'costDelivery': (costDelivery).toString()
    }).then((value) async {
      int allTime = 0;
      int finalTime = 0;

      for (int i = 0; i < currentOrder.length; i++) {
        allTime +=
            (int.parse(currentOrder[i].time) * int.parse(currentOrder[i].pcs));
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .collection('product')
            .doc(currentOrder[i].productId)
            .set({
          'productId': currentOrder[i].productId,
          'comment': currentOrder[i].comment,
          'pcs': currentOrder[i].pcs,
          'price': currentOrder[i].price,
          'name': currentOrder[i].productName
        }).then((value) async {
          await addLog(orderId, '1', 'user', appDataModel.profileUid, '');
        });
      }

      // await _getDriver();

      finalTime = allTime + 15;
      await dialogs.information(
          context,
          Style().textSizeColor('สั่งสินค้าแล้ว', 16, Style().textColor),
          Style().textSizeColor(
              'โปรดรอรับการติดต่อจาก Rider', 14, Style().textColor));
      appDataModel.currentOrder = [];
      Navigator.pushNamedAndRemoveUntil(
          context, '/home-page', (route) => false);
    });
  }

  _getTimeStamp() {
    String dateString = DateTime.now().millisecondsSinceEpoch.toString();
    return dateString;
  }

  sendNotify(AppDataModel appDataModel, String token, String title,
      String body) async {
    print("notiserver = " + appDataModel.notifyServer);
    http.post(
      Uri.parse(appDataModel.notifyServer),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'token': token, 'title': title, 'body': body}),
    );
  }


}
