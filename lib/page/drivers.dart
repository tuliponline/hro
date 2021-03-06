import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/addLog.dart';
import 'package:hro/utility/driverStatus.dart';
import 'package:hro/utility/getTimeNow.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class DriversPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DriversState();
  }
}

class DriversState extends State<DriversPage> {
  Dialogs dialogs = Dialogs();

  bool driverStatus = false;
  String timeNow;
  DriversModel driversModel;
  bool getDriverData = false;
  String uid;
  List<OrderList> orderList;
  int driverQueueNow;

  List<OrderList> orderWaiteList;

  bool inWork = false;

  FirebaseFirestore db = FirebaseFirestore.instance;

  _setData(AppDataModel appDataModel) async {
    uid = appDataModel.profileUid;
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(uid)
        .update({'token': appDataModel.token});
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(uid)
        .get()
        .then((value) async {
      driversModel = driversModelFromJson(jsonEncode(value.data()));


      if (driversModel.driverStatus == "1") {
        inWork = false;
      } else {
        inWork = true;
      }
      print('drivers Status =  ' + driversModel.driverStatus);
      print('inwork = ' + inWork.toString());


      print('location ' + driversModel.driverStatus);
      await _getOrders(context.read<AppDataModel>());

      driverQueueNow = await driverQueue(uid);
      (driversModel.driverStatus != '0')
          ? driverStatus = true
          : driverStatus = false;
      setState(() {
        // print('status=' + driverStatus.toString());
        getDriverData = true;
      });
    });

  }

  _getOrders(AppDataModel appDataModel) async {
    await db
        .collection('orders')
        .where('driver', isEqualTo: driversModel.driverId)
        .orderBy("orderId", descending: true)
        .limit(5)
        .get()
        .then((value) async {
      print('valueType=' + value.runtimeType.toString());

      List<DocumentSnapshot> templist;
      List list = new List();
      templist = value.docs;
      list = templist.map((DocumentSnapshot docSnapshot) {
        return docSnapshot.data();
      }).toList();
      print('ListType=' + list.runtimeType.toString());

      var jsonData = jsonEncode(list);
      print('jsonDataType=' + jsonData.runtimeType.toString());
      print('OrdersList' + jsonData.toString());
      orderList = orderListFromJson(jsonData);
    });

    await db
        .collection('orders')
        .where('status', isEqualTo: "1")
        .orderBy("orderId", descending: true)
        .get()
        .then((valueWaite) async {
      var jsonData = await setList2Json(valueWaite);
      orderWaiteList = orderListFromJson(jsonData);
      print("orderWait = " + orderWaiteList.length.toString());
    });
  }

  _Notififation() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // await normalDialog(context, message.notification.title + '',
        //      message.notification.body);
        print(message.notification.title);
        if (message.notification.title.contains('Rider')) {
          print('Shop');
          setState(() {
            getDriverData = false;
          });
        }
      }
    });
  }

  void initState() {
    super.initState();
    _Notififation();
  }

  Widget build(BuildContext context) {
    if (getDriverData == false) _setData(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) =>
            Scaffold(
              backgroundColor: Color.fromRGBO(18, 22, 23, 1),
              appBar: (driversModel == null)
                  ? null
                  : AppBar(
                iconTheme: IconThemeData(color: Style().darkColor),
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                title:
                Style().textSizeColor('Rider', 18, Style().darkColor),
                actions: [
                  IconButton(
                      icon: Icon(
                        FontAwesomeIcons.exclamationTriangle,
                        color: Colors.deepOrangeAccent,
                        size: 20,
                      ),
                      onPressed: () async {
                        await Dialogs().confirmRider(context);
                      }),
                  IconButton(
                      icon: Icon(
                        FontAwesomeIcons.sync,
                        color: Style().darkColor,
                        size: 20,
                      ),
                      onPressed: () {
                        _setData(context.read<AppDataModel>());
                      }),
                  Container(
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, "/driverSetup-page",
                                  arguments: 'OLD');
                            },
                            child: Style().textSizeColor(
                                '?????????????????? Rider', 14, Colors.white),
                            style: ElevatedButton.styleFrom(
                                primary: Style().darkColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(5))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              body: Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: (driversModel == null)
                      ? Style()
                      .circularProgressIndicator(Style().drivePrimaryColor)
                      : ListView(
                    children: [
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 10),
                            child: buildShopMenu(
                                context.read<AppDataModel>()),
                          ),
                          Container(
                            child: SingleChildScrollView(
                              child: (orderWaiteList.length == null ||
                                  inWork == true)
                                  ? Container()
                                  : buildOrderWaite(
                                  context.read<AppDataModel>()),
                            ),
                          ),
                          Container(
                            child: SingleChildScrollView(
                              child: (orderList.length == 0)
                                  ? Container(
                                child: Center(
                                  child: Style().textBlackSize(
                                      "?????????????????????????????????", 16),
                                ),
                              )
                                  : buildOrderList(
                                  context.read<AppDataModel>()),
                            ),
                          )
                          //buildPopularProduct(),
                          //buildPopularShop((context.read<AppDataModel>()))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  Row buildShopMenu(AppDataModel appDataModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        (driverStatus == true)
            ? Expanded(
          child: ListTile(
            title: (driversModel.driverStatus == '1')
                ? Row(
              children: [
                Style().textSizeColor('Online ', 16, Colors.green),
              ],
            )
                : (driversModel.driverStatus == '3')
                ? Style()
                .textSizeColor("???????????????????????????", 16, Colors.orange)
                : Style()
                .textSizeColor("?????????????????????????????????", 16, Colors.green),
            subtitle:
            Style().textSizeColor('??????????????? ', 14, Style().textColor),
          ),
        )
            : Expanded(
          child: ListTile(
            title:
            Style().textSizeColor('Offline', 16, Colors.deepOrange),
            subtitle:
            Style().textSizeColor('??????????????? ', 14, Style().textColor),
          ),
        ),
        Switch(
            activeColor: Style().darkColor,
            value: driverStatus,
            onChanged: (driversModel.driverStatus == '0' ||
                driversModel.driverStatus == '1')
                ? (value) async {
              if (value == true) {
                timeNow = _getTineNow();
                await FirebaseFirestore.instance
                    .collection('drivers')
                    .doc(uid)
                    .update({'onlineTime': timeNow, 'driverStatus': '1'});
              } else {
                await FirebaseFirestore.instance
                    .collection('drivers')
                    .doc(uid)
                    .update({'driverStatus': '0'});
              }
              setState(() {
                driverStatus = value;
                getDriverData = false;
              });
            }
                : null)
      ],
    );
  }

  Column buildOrderWaite(AppDataModel appDataModel) {
    return Column(
      children: orderWaiteList.map((e) {
        String statusStr = '';
        switch (e.status) {
          case '0':
            {
              statusStr = '??????????????????';
            }
            break;

          case '1':
            {
              statusStr = '?????????Order';
            }
            break;

          case '2':
            {
              statusStr = '?????????????????????????????? Order ????????????';
            }
            break;

          case '3':
            {
              statusStr = '??????????????????????????????????????????????????????';
            }
            break;

          case '4':
            {
              statusStr = '?????????????????????????????????';
            }
            break;
          case '5':
            {
              statusStr = '???????????????????????????';
            }
            break;
          case '6':
            {
              statusStr = '????????????????????????????????????/??????????????????';
            }
        }

        return InkWell(
          onTap: () async {
            appDataModel.orderIdSelected = e.orderId;
            if (e.comment != null){ appDataModel.orderAddressComment = e.comment;}else{
              appDataModel.orderAddressComment = "";
            }
            print(e.location);
            List<String> locationLatLng = e.location.split(',');
            appDataModel.latOrder = double.parse(locationLatLng[0]);
            appDataModel.lngOrder = double.parse(locationLatLng[1]);

            Navigator.pushNamed(context, "/order2driver-page");
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: (e.status == '9' ||
                  e.status == '1' ||
                  e.status == '2' ||
                  e.status == '3' ||
                  e.status == '4')
                  ? Color.fromRGBO(255, 187, 147, 0.8)
                  : Colors.white,
            ),
            margin: EdgeInsets.only(top: 8, left: 8, right: 8),
            child: Row(
              children: [
                Expanded(
                    child: ListTile(
                      title:
                      Style().textFlexibleBackSize('order ' + e.orderId, 2, 14),
                      subtitle: Style().textBlackSize(
                          '?????????????????? ' + e.startTime, 12),
                    )),
                (e.status == '1')
                    ? Container(
                  margin: EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                    onPressed: () async {
                      print('confirm');
                      var result = await Dialogs().confirm(
                          context,
                          "????????? Order ?",
                          "????????? Order " + e.orderId,
                          Icon(FontAwesomeIcons.question));
                      print("Resulr = $result");
                      if (result == true) {
                        _confirmOrder(
                            context.read<AppDataModel>(), e.orderId);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Style().titleH3('?????????Order'),
                        Icon(Icons.check)
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: Style().primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                  ),
                )
                    : (e.status == '2' || e.status == '4')
                    ? Container(
                  margin:
                  EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  child: Column(
                    children: [
                      Style().textBlackSize(statusStr, 14),
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 5),
                            child: ElevatedButton(
                              onPressed: () async {
                                print('cancelOrder By Driver');
                                _cancelOrder(
                                    context.read<AppDataModel>(),
                                    e.orderId);
                              },
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Style().textSizeColor(
                                      '??????????????????', 14, Colors.white),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(5))),
                            ),
                          ),
                          (e.status == '2')
                              ? Container(
                            margin: EdgeInsets.only(
                                right: 8, top: 8, bottom: 8),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      right: 10),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      var result =
                                      await Dialogs().confirm(
                                          context,
                                          "???????????????????????????",
                                          "?????????????????????????????????????????????????????????",
                                          Icon(
                                            FontAwesomeIcons
                                                .questionCircle,
                                            color: Style()
                                                .darkColor,
                                          ));
                                      print('Delivering');
                                      if (result == true) {
                                        _delivering(
                                            context.read<
                                                AppDataModel>(),
                                            e.orderId);
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                      children: [
                                        Style().textSizeColor(
                                            '???????????????????????????',
                                            14,
                                            Colors.white)
                                      ],
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        primary:
                                        Style().darkColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                                5))),
                                  ),
                                )
                              ],
                            ),
                          )
                              : Container(
                            margin: EdgeInsets.only(right: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                print('Order Success');
                                _orderSuccess(
                                    context
                                        .read<AppDataModel>(),
                                    e.orderId);
                              },
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Style().textSizeColor(
                                      '????????????????????????????????????',
                                      12,
                                      Colors.white),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Style().darkColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          5))),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
                    : (e.status == '3')
                    ? Container(
                  margin: EdgeInsets.only(
                      right: 8, top: 8, bottom: 8),
                  child: Column(
                    children: [
                      Style().textBlackSize(statusStr, 14),
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            var result = await Dialogs().confirm(
                                context,
                                "???????????????????????????",
                                "?????????????????????????????????????????????????????????",
                                Icon(
                                  FontAwesomeIcons.questionCircle,
                                  color: Style().darkColor,
                                ));
                            if (result == true) {
                              print('Delivering');
                              _delivering(
                                  context.read<AppDataModel>(),
                                  e.orderId);
                            }
                          },
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Style().textSizeColor(
                                  '???????????????????????????', 14, Colors.white),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Style().darkColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(5))),
                        ),
                      )
                    ],
                  ),
                )
                    : Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Style().textSizeColor(
                      statusStr, 14, Style().textColor),
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Column buildOrderList(AppDataModel appDataModel) {
    return Column(
      children: orderList.map((e) {
        String statusStr = '';
        switch (e.status) {
          case '0':
            {
              statusStr = '??????????????????';
            }
            break;

          case '1':
            {
              statusStr = '?????????Order';
            }
            break;

          case '2':
            {
              statusStr = '?????????????????????????????? Order ????????????';
            }
            break;

          case '3':
            {
              statusStr = '??????????????????????????????????????????????????????';
            }
            break;

          case '4':
            {
              statusStr = '?????????????????????????????????';
            }
            break;
          case '5':
            {
              statusStr = '???????????????????????????';
            }
            break;
          case '6':
            {
              statusStr = '????????????????????????????????????/??????????????????';
            }
        }

        return InkWell(
          onTap: () async {
            appDataModel.orderIdSelected = e.orderId;
            if (e.comment != null) appDataModel.orderAddressComment = e.comment;
            print(e.location);
            List<String> locationLatLng = e.location.split(',');
            appDataModel.latOrder = double.parse(locationLatLng[0]);
            appDataModel.lngOrder = double.parse(locationLatLng[1]);

            Navigator.pushNamed(context, "/order2driver-page");
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: (e.status == '9' ||
                  e.status == '1' ||
                  e.status == '2' ||
                  e.status == '3' ||
                  e.status == '4')
                  ? Color.fromRGBO(255, 187, 147, 0.8)
                  : Colors.white,
            ),
            margin: EdgeInsets.only(top: 8, left: 8, right: 8),
            child: Row(
              children: [
                Expanded(
                    child: ListTile(
                      title:
                      Style().textFlexibleBackSize('order ' + e.orderId, 2, 14),
                      subtitle: Style().textBlackSize(
                           e.startTime, 12),
                    )),
                (e.status == '1')
                    ? Container(
                  margin: EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                    onPressed: () async {
                      print('confirm');
                      var result = await Dialogs().confirm(
                          context,
                          "????????? Order ?",
                          "????????? Order " + e.orderId,
                          Icon(FontAwesomeIcons.question));
                      print("Resulr = $result");
                      if (result == true) {
                        _confirmOrder(
                            context.read<AppDataModel>(), e.orderId);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Style().titleH3('?????????Order'),
                        Icon(Icons.check)
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: Style().primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                  ),
                )
                    : (e.status == '2' || e.status == '4')
                    ? Container(
                  margin:
                  EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  child: Column(
                    children: [
                      Style().textBlackSize(statusStr, 14),
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 5),
                            child: ElevatedButton(
                              onPressed: () async {
                                print('cancelOrder By Driver');
                                _cancelOrder(
                                    context.read<AppDataModel>(),
                                    e.orderId);
                              },
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Style().textSizeColor(
                                      '??????????????????', 14, Colors.white),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(5))),
                            ),
                          ),
                          (e.status == '2')
                              ? Container(
                            margin: EdgeInsets.only(
                                right: 8, top: 8, bottom: 8),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      right: 10),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      var result =
                                      await Dialogs().confirm(
                                          context,
                                          "???????????????????????????",
                                          "?????????????????????????????????????????????????????????",
                                          Icon(
                                            FontAwesomeIcons
                                                .questionCircle,
                                            color: Style()
                                                .darkColor,
                                          ));
                                      print('Delivering');
                                      if (result == true) {
                                        _delivering(
                                            context.read<
                                                AppDataModel>(),
                                            e.orderId);
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                      children: [
                                        Style().textSizeColor(
                                            '???????????????????????????',
                                            14,
                                            Colors.white)
                                      ],
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        primary:
                                        Style().darkColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                                5))),
                                  ),
                                )
                              ],
                            ),
                          )
                              : Container(
                            margin: EdgeInsets.only(right: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                print('Order Success');
                                _orderSuccess(
                                    context
                                        .read<AppDataModel>(),
                                    e.orderId);
                              },
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Style().textSizeColor(
                                      '????????????????????????????????????',
                                      12,
                                      Colors.white),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Style().darkColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          5))),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
                    : (e.status == '3')
                    ? Container(
                  margin: EdgeInsets.only(
                      right: 8, top: 8, bottom: 8),
                  child: Column(
                    children: [
                      Style().textBlackSize(statusStr, 14),
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            var result = await Dialogs().confirm(
                                context,
                                "???????????????????????????",
                                "?????????????????????????????????????????????????????????",
                                Icon(
                                  FontAwesomeIcons.questionCircle,
                                  color: Style().darkColor,
                                ));
                            if (result == true) {
                              print('Delivering');
                              _delivering(
                                  context.read<AppDataModel>(),
                                  e.orderId);
                            }
                          },
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Style().textSizeColor(
                                  '???????????????????????????', 14, Colors.white),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Style().darkColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(5))),
                        ),
                      )
                    ],
                  ),
                )
                    : Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Style().textSizeColor(
                      statusStr, 14, Style().textColor),
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  _orderSuccess(AppDataModel appDataModel, String orderId) async {
    String finishTime = await getTimeStringNow();
    db
        .collection("orders")
        .doc(orderId)
        .update({'status': '5', 'finishTime': finishTime}).then((value) async {
      String onlineTime = await getTimeStampNow();
      addLog(orderId, '5', 'driver', uid, '').then((value) {
        db.collection('drivers').doc(uid).update(
            {'driverStatus': '1', 'onlineTime': onlineTime}).then((value) {
          setState(() {
            getDriverData = false;
          });
        });
      });
    });
  }

  _delivering(AppDataModel appDataModel, String orderId) {
    db.collection('orders').doc(orderId).update({'status': '4'}).then((value) {
      addLog(orderId, '4', 'driver', uid, '').then((value) {
        setState(() {
          getDriverData = false;
        });
      });
    });
  }

  _cancelOrder(AppDataModel appDataModel, String orderId) async {
    String onlineTime = await getTimeStampNow();
    db.collection('orders').doc(orderId).get().then((value) async {
      OrderDetail orderDetail = orderDetailFromJson(jsonEncode(value.data()));
      if (orderDetail.status == '2' || orderDetail.status == '4') {
        var result = await dialogs.inputDialog(
            context,
            Style().textSizeColor('??????????????????', 16, Style().textColor),
            '?????????????????????????????????????????????????????????');
        if (result != null && result[0] == true) {
          db
              .collection('orders')
              .doc(orderId)
              .update({'status': '6'}).then((value) {
            addLog(orderId, '6', 'driver', uid, result[1]).then((value) {
              db
                  .collection('drivers')
                  .doc(uid)
                  .update({'driverStatus': '1', 'onlineTime': onlineTime}).then(
                      (value) {
                        getDriverData = false;
                    setState(() {

                    });
                  });
            });
          });
        }
      } else {
        await dialogs.information(
            context,
            Style().textSizeColor('?????????????????????', 16, Style().textColor),
            Style().textSizeColor(
                '????????????????????????????????????????????????????????????????????????????????????????????????????????????', 14, Style().textColor));
        getDriverData = false;
        setState(() {

        });
      }
    });

    // print(result);
  }

  _confirmOrder(AppDataModel appDataModel, String orderId) async {

    db.collection('drivers').doc(appDataModel.profileUid).get().then((value) async {
      driversModel = driversModelFromJson(
          jsonEncode(value.data()));
      print('DriverStatusBefor Confirm = ' + driversModel.driverStatus);

      if (driversModel.driverStatus != "1") {
        await Dialogs().information(
            context, Style().textBlackSize("????????? Order ??????????????????", 14),
            Style().textBlackSize("????????????????????????????????? Order ????????????????????????", 14));
        getDriverData = false;
        setState(() {

        });
      }else{
        db.collection('orders').doc(orderId).get().then((value) async {
          OrderDetail orderDetail = orderDetailFromJson(jsonEncode(value.data()));
          print('status = ' + orderDetail.status);
          if (orderDetail.status == '1') {
            print('change Status Success');
            await db
                .collection('orders')
                .doc(orderId)
                .update({'status': '2', 'driver': uid}).then((value) async {
                  await db.collection("drivers").doc(uid).update({"driverStatus" : "2"}).then((value) async{
                    await addLog(orderId, '2', 'driver', uid, '').then((value) {
                      inWork = true;
                      getDriverData = false;
                      setState(() {

                      });
                    });
                  });

            });
          } else {
            await dialogs.information(
                context,
                Style().textSizeColor('?????????????????????', 16, Style().textColor),
                Style().textSizeColor('Order ?????????????????????????????????', 14, Style().textColor));

            getDriverData = false;
            setState(() {

            });
          }
        });
      }
    });



  }

  _getTineNow() {
    String dateString = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    return dateString;
  }
}
