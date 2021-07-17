import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/logListModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/addLog.dart';
import 'package:hro/utility/getStatusString.dart';

import 'package:hro/utility/getTimeNow.dart';
import 'package:hro/utility/style.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class OrderShowPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OrderShowState();
  }
}

class TextIconItem {
  String text;
  IconData iconData;

  TextIconItem(this.text, this.iconData);
}

class OrderShowState extends State<OrderShowPage> {
  Dialogs dialogs = Dialogs();
  List<TextIconItem> _textIconChoice = [];

  bool getOrderDataStatus = false;
  OrderDetail orderDetail;
  List<OrderProduct> orderProduct;
  String orderIdSelected;
  FirebaseFirestore fireDb = FirebaseFirestore.instance;
  String statusString;

  ShopModel shopModel;
  DriversModel driversModel;

  List<LogsListModel> logsList;

  int _currentStep = 0;

  _getOrderData(AppDataModel appDataModel) async {
    orderIdSelected = appDataModel.orderIdSelected;
    print('orderId= ' + orderIdSelected);
    await fireDb
        .collection('orders')
        .doc(orderIdSelected)
        .get()
        .then((value) async {
      print('orderDetail = ' + value.data().toString());
      orderDetail = orderDetailFromJson(jsonEncode(value.data()));
      if (orderDetail.status == '1' || orderDetail.status == '9') {
        _textIconChoice.add(TextIconItem("ยกเลิก Order", MdiIcons.cancel));
      }
      String status = orderDetail.status;

      await getStatusString(status).then((value) => statusString = value);

      await fireDb
          .collection('orders')
          .doc(orderIdSelected)
          .collection('product')
          .get()
          .then((products) async {
        List<DocumentSnapshot> templist;
        List list = new List();
        templist = products.docs;
        list = templist.map((DocumentSnapshot docSnapshot) {
          return docSnapshot.data();
        }).toList();
        var jsonData = jsonEncode(list);
        orderProduct = orderProductFromJson(jsonData);

        await fireDb
            .collection('shops')
            .doc(orderDetail.shopId)
            .get()
            .then((shopData) {
          shopModel = shopModelFromJson(jsonEncode(shopData.data()));
          print('productData =' + shopModel.shopName);
        });

        if (orderDetail.driver != '0') {
          await fireDb
              .collection('drivers')
              .doc(orderDetail.driver)
              .get()
              .then((driverData) async {
            driversModel = driversModelFromJson(jsonEncode(driverData.data()));
            print('driverData =' + driversModel.driverName);
          });
        }
        await _getLog();
      });
    });

    setState(() {
      getOrderDataStatus = true;
    });
  }

  _getLog() async {
    print('getlog');
    await fireDb
        .collection('logs')
        .where('orderId', isEqualTo: orderDetail.orderId)
        .get()
        .then((value) {
      value.docs.forEach((e) {
        var jsonData = jsonEncode(e.data());
        print(jsonData);
      });

      List<DocumentSnapshot> templist;
      List list = new List();
      templist = value.docs;
      list = templist.map((DocumentSnapshot docSnapshot) {
        return docSnapshot.data();
      }).toList();
      var jsonData = jsonEncode(list);
      logsList = logsListModelFromJson(jsonData);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (getOrderDataStatus == false)
      _getOrderData(context.read<AppDataModel>());

    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: (orderDetail == null)
                  ? null
                  : AppBar(
                      iconTheme: IconThemeData(color: Style().darkColor),
                      backgroundColor: Colors.white,
                      bottomOpacity: 0.0,
                      elevation: 0.0,
                      title: Style().textDarkAppbar('รายละเอียด Order'),
                    ),
              body: (orderDetail == null)
                  ? Center(
                      child:
                          Style().circularProgressIndicator(Style().darkColor),
                    )
                  : SingleChildScrollView(
                      child: Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        bottom: 8, top: 8, right: 10, left: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(28),
                                          blurRadius: 5,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.only(left: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                left: 8,
                                                top: 16,
                                                bottom: 16,
                                                right: 8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Style().textFlexibleBackSize(
                                                              "Order: " +
                                                                  orderDetail
                                                                      .orderId,
                                                              2,
                                                              12),
                                                          Style().textFlexibleBackSize(
                                                              "วันที่สั่ง: " +
                                                                  orderDetail
                                                                      .startTime,
                                                              2,
                                                              12),
                                                          Style().textFlexibleBackSize(
                                                              "ร้าน: " +
                                                                  shopModel
                                                                      .shopName +
                                                                  ' ' +
                                                                  shopModel
                                                                      .shopPhone,
                                                              2,
                                                              12),
                                                          (driversModel == null)
                                                              ? Container()
                                                              : Style().textFlexibleBackSize(
                                                                  "พนักงานส่ง: " +
                                                                      driversModel
                                                                          .driverName +
                                                                      ' ' +
                                                                      driversModel
                                                                          .driverPhone,
                                                                  2,
                                                                  12)
                                                        ],
                                                      ),
                                                    ),
                                                    (orderDetail.status ==
                                                                '1' ||
                                                            orderDetail
                                                                    .status ==
                                                                '9')
                                                        ? Container(
                                                            child:
                                                                PopupMenuButton(
                                                              onSelected:
                                                                  (choice) async {
                                                                print(choice
                                                                    .text);
                                                                if (choice
                                                                        .text ==
                                                                    'ยกเลิก Order') {
                                                                  if (orderDetail
                                                                              .status ==
                                                                          '1' ||
                                                                      orderDetail
                                                                              .status ==
                                                                          '9') {
                                                                    print("test");
                                                                    var result = await dialogs.inputDialog(
                                                                        context,
                                                                        Style().textBlackSize(
                                                                            'ยกเลิก Order',
                                                                            14),
                                                                        'โปรดระบุเหตุผล');
                                                                    print(
                                                                        result[
                                                                            0]);
                                                                    if (result[
                                                                            0] ==
                                                                        true) {
                                                                      print('OK' +
                                                                          result[1]
                                                                              .toString());

                                                                      await fireDb
                                                                          .collection(
                                                                              'orders')
                                                                          .doc(orderDetail
                                                                              .orderId)
                                                                          .update({
                                                                        'status':
                                                                            '0'
                                                                      }).then(
                                                                              (value) async {
                                                                        await addLog(orderDetail.orderId, '0', 'user', appDataModel.profileUid, result[1]).then(
                                                                            (value) {
                                                                          Navigator.pop(
                                                                              context,
                                                                              'reload');
                                                                        }).catchError(
                                                                            (onError) {
                                                                          print(
                                                                              'addLogError = $onError');
                                                                        });
                                                                      }).catchError(
                                                                              (onError) {
                                                                        print(
                                                                            'ChangeStatusError = $onError');
                                                                      });
                                                                    }
                                                                  } else {
                                                                    Toast.show(
                                                                        "ทำรายการไม่ได้",
                                                                        context,
                                                                        duration:
                                                                            Toast
                                                                                .LENGTH_SHORT,
                                                                        gravity:
                                                                            Toast.CENTER);
                                                                  }
                                                                }else{print("text+" + orderDetail.status );}
                                                              },
                                                              itemBuilder:
                                                                  (BuildContext
                                                                      context) {
                                                                return _textIconChoice.map(
                                                                    (TextIconItem
                                                                        choice) {
                                                                  return PopupMenuItem(
                                                                    value:
                                                                        choice,
                                                                    child: Row(
                                                                      children: (choice.text ==
                                                                              'ยกเลิก Order')
                                                                          ? <Widget>[
                                                                              Icon(
                                                                                choice.iconData,
                                                                                size: 18,
                                                                                color: Colors.red,
                                                                              ),
                                                                              Padding(
                                                                                  padding: EdgeInsets.only(left: 8),
                                                                                  child: Text(
                                                                                    choice.text,
                                                                                  )),
                                                                            ]
                                                                          : <Widget>[
                                                                              Icon(choice.iconData, size: 18),
                                                                              Padding(
                                                                                  padding: EdgeInsets.only(left: 8),
                                                                                  child: Text(
                                                                                    choice.text,
                                                                                  )),
                                                                            ],
                                                                    ),
                                                                  );
                                                                }).toList();
                                                              },
                                                              icon: Icon(
                                                                MdiIcons
                                                                    .dotsVertical,
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Style().textBlackSize(
                                                        'สถานะ: ', 14),
                                                    Style().textSizeColor(
                                                        statusString,
                                                        14,
                                                        Style().darkColor),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              setState(() {
                                                appDataModel.orderIdSelected =
                                                    orderDetail.orderId;
                                                if (orderDetail.comment != null)
                                                  appDataModel
                                                          .orderAddressComment =
                                                      orderDetail.comment;
                                                print(orderDetail.location);
                                                List<String> locationLatLng =
                                                    orderDetail.location
                                                        .split(',');
                                                appDataModel.latOrder =
                                                    double.parse(
                                                        locationLatLng[0]);
                                                appDataModel.lngOrder =
                                                    double.parse(
                                                        locationLatLng[1]);

                                                Navigator.pushNamed(context,
                                                    "/order2driver-page");
                                              });
                                            },
                                            icon: Icon(
                                                FontAwesomeIcons.arrowRight))
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            (logsList == null)
                                ? Container()
                                : (logsList.length <= 0)
                                    ? Container()
                                    : stepStatus()
                          ],
                        ),
                      ),
                    ),
            ));
  }

  Container stepStatus() {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 24, left: 16, right: 16),
            child: Text(
              "ติดตาม Order",
            ),
          ),
          Container(
            child: Stepper(
                physics: ClampingScrollPhysics(),
                controlsBuilder: (BuildContext context,
                    {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                  return Container();
                },
                currentStep: _currentStep,
                onStepTapped: (current) {
                  setState(() {
                    _currentStep = current;
                  });
                },
                steps: logsList.map((e) {
                  String setBy;
                  switch (e.setBy) {
                    case 'user':
                      {
                        setBy = 'ลูกค้า';
                      }
                      break;
                    case 'shop':
                      {
                        setBy = 'ร้านค้า';
                      }
                      break;
                    case 'driver':
                      {
                        setBy = 'พนักงานส่ง';
                      }
                      break;
                  }

                  String status;
                  switch (e.status) {
                    case '0':
                      {
                        status = 'ยกเลิก';
                      }
                      break;
                    case '1':
                      {
                        status = 'รับOrder';
                      }
                      break;

                    case '2':
                      {
                        status = 'พนักงานส่งตอบรับ';
                      }
                      break;

                    case '3':
                      {
                        status = 'กำลังเตรียมสินค้า';
                      }
                      break;
                    case '4':
                      {
                        status = 'กำลังออกจัดส่ง';
                      }
                      break;
                    case '5':
                      {
                        status = 'จัดส่งสำเร็จ';
                      }
                      break;
                    case '6':
                      {
                        status = 'จัดส่งไม่สำเร็จ';
                      }
                  }

                  return Step(
                    isActive: true,
                    state: (e.status == '0')
                        ? StepState.error
                        : (e.status == '6')
                            ? StepState.error
                            : StepState.complete,
                    title: Style().textSizeColor(
                        status + ' - ' + e.time,
                        14,
                        (e.status == '0')
                            ? Colors.orange
                            : (e.status == '6')
                                ? Colors.red
                                : Style().textColor),
                    subtitle: (e.status == '1')
                        ? Style().textBlackSize('รอพนักงานส่งตอบรับ', 12)
                        : null,
                    content: (e.comment == null)
                        ? Container()
                        : (e.comment.length <= 0)
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Row(
                                  //   children: [
                                  //     Icon(
                                  //       MdiIcons.account,
                                  //       color: Colors.blueAccent,
                                  //     ),
                                  //     Style().textSizeColor(
                                  //         ' ' + setBy, 14, Style().textColor)
                                  //   ],
                                  // ),
                                  (e.comment == null)
                                      ? Container()
                                      : (e.comment.length <= 0)
                                          ? Container()
                                          : Row(
                                              children: [
                                                Icon(
                                                  MdiIcons.comment,
                                                  color: Colors.blueAccent,
                                                ),
                                                Text(' ' + e.comment)
                                              ],
                                            )
                                ],
                              ),
                  );
                }).toList()),
          ),
        ],
      ),
    );
  }
}
