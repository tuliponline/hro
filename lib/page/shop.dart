import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/addLog.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class ShopPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ShopState();
  }
}

class ShopState extends State<ShopPage> {
  Dialogs dialogs = Dialogs();
  String timeNow;
  String uid;
  List<OrderList> orderList;
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool getData = false;
  List<bool> showDetail = [];
  List<OrderProduct> orderProduct;
  String orderSelected = "";
  String pageNow = 'working';
  int _selectedIndex = 0;
  bool shopOpen = false;
  ShopModel shopModel;

  _setData(AppDataModel appDataModel) async {
    uid = appDataModel.profileUid;
    await db
        .collection('shops')
        .doc(appDataModel.profileUid)
        .update({'token': appDataModel.token});
    await _getOrders(context.read<AppDataModel>());
    await _getShopData(uid);
    setState(() {
      print('setstate');
      getData = true;
    });
  }

  _getShopData(String shopId) async {
    print("shopData" + shopId);
    await db.collection("shops").doc(shopId).get().then((value) {
      shopModel = shopModelFromJson(jsonEncode(value.data()));
      print(shopModel.shopName);
      if (shopModel.shopStatus == "1") {
        shopOpen = true;
      } else if (shopModel.shopStatus == "2") {
        shopOpen = false;
      }
    });
  }

  _getOrders(AppDataModel appDataModel) async {
    showDetail = [];
    await db
        .collection('orders')
        .where('shopId', isEqualTo: uid)
        .orderBy("orderId", descending: true)
        .get()
        .then((value) {
      print('valueType=' + value.runtimeType.toString());

      List<DocumentSnapshot> templist;
      List list = new List();
      templist = value.docs;
      list = templist.map((DocumentSnapshot docSnapshot) {
        showDetail.add(false);
        return docSnapshot.data();
      }).toList();
      print('ListType=' + list.runtimeType.toString());

      var jsonData = jsonEncode(list);
      print('jsonDataType=' + jsonData.runtimeType.toString());
      print('OrdersList' + jsonData.toString());
      orderList = orderListFromJson(jsonData);
    });
  }

  _getProduct(orderIdSelect) {
    db
        .collection('orders')
        .doc(orderIdSelect)
        .collection('product')
        .get()
        .then((value) async {
      var jsonData = await setList2Json(value);
      print(jsonData);
      orderProduct = orderProductFromJson(jsonData);
      setState(() {});
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

        print("nowPage = " + ModalRoute
            .of(context)
            .settings
            .name);

        if (message.notification.title.contains('Shop')) {
          print('Shop');
          setState(() {
            getData = false;
          });
        }
      }
    });
  }

  void initState() {
    super.initState();
    _Notififation();
  }

  @override
  Widget build(BuildContext context) {
    if (getData == false) _setData(context.read<AppDataModel>());

    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) =>
            Scaffold(
                appBar: (shopModel == null)
                    ? null
                    : AppBar(
                  iconTheme: IconThemeData(color: Style().darkColor),
                  backgroundColor: Colors.white,
                  bottomOpacity: 0.0,
                  elevation: 0.0,
                  // leading: IconButton(
                  //     icon: Icon(
                  //       Icons.menu,
                  //       color: Style().darkColor,
                  //     ),
                  //     onPressed: () {}),
                  title:
                  Style().textSizeColor('ร้านค้า', 18, Style().darkColor),
                  actions: [
                    IconButton(
                        icon: Icon(
                          FontAwesomeIcons.sync,
                          color: Style().darkColor,
                        ),
                        onPressed: () {
                          setState(() {
                            getData = false;
                          });
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
                                Navigator.pushNamed(context, "/menu-page");
                              },
                              child: Style().textSizeColor(
                                  'สินค้า', 14, Colors.white),
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

                    Container(
                      child: Container(
                        margin: EdgeInsets.only(right: 5),
                        padding: EdgeInsets.all(1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/shopSetup-page");
                              },
                              child: Style().textSizeColor(
                                  'ข้อมูลร้าน', 14, Colors.white),
                              style: ElevatedButton.styleFrom(
                                  primary: Style().darkColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(5))),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                body: (shopModel == null)
                    ? Style().circularProgressIndicator(Style().darkColor)
                    : Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: ListView(
                      children: [
                        Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            (orderList == null)
                                ? Container()
                                : buildShopStatus(
                                context.read<AppDataModel>()),
                            (orderList == null || orderList.length == 0)
                                ? Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Style().textSizeColor(
                                      "ไม่มี Order",
                                      16,
                                      Colors.black87),
                                ),
                              ],
                            )
                                : buildOrderList(context.read<AppDataModel>())

                            //buildPopularProduct(),
                            //buildPopularShop((context.read<AppDataModel>()))
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(
                        FontAwesomeIcons.clock,
                        color: Colors.orangeAccent,
                      ),
                      title: Text(
                        'กำลังดำเนินการ',
                        style: TextStyle(fontFamily: 'prompt', fontSize: 12),
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        FontAwesomeIcons.check,
                        color: Colors.lightGreen,
                      ),
                      title: Text(
                        'Rider รับสินค้าแล้ว',
                        style: TextStyle(fontFamily: 'prompt', fontSize: 12),
                      ),
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: Theme
                      .of(context)
                      .primaryColor,
                  unselectedItemColor: Colors.grey,
                  onTap: _onItemTapped,
                )));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  buildOrderList(AppDataModel appDataModel) {
    return Column(
      children: orderList.map((e) {
        int index = orderList.indexOf(e);

        if (_selectedIndex == 0) {
          if (e.status == "2" || e.status == "3") {
            String statusStr = '';
            switch (e.status) {
              case '0':
                {
                  statusStr = 'ยกเลิก';
                }
                break;

              case '1':
                {
                  statusStr = 'รอ Rider ยืนยัน';
                }
                break;

              case '2':
                {
                  statusStr = 'รอการตอบรับ โปรดตอบรับOrder';
                }
                break;

              case '3':
                {
                  statusStr = 'โปรดจัดเตรียมสินค้า';
                }
                break;

              case '4':
                {
                  statusStr = 'Rider กำลังออกส่ง';
                }
                break;
              case '5':
                {
                  statusStr = 'ส่งสำเร็จ';
                }
                break;
              case '6':
                {
                  statusStr = 'ส่งไม่สำเร็จ/ยกเลิก';
                }
            }
            return InkWell(
              onTap: () async {
                print(index.toString());
                print(showDetail[index]);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                margin: EdgeInsets.only(top: 8, left: 8, right: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Style().textSizeColor(
                                      'order No.' + e.orderId,
                                      14,
                                      Style().textColor),
                                  subtitle: Style().textSizeColor(
                                      statusStr,
                                      14,
                                      (e.status == '0' ||
                                          e.status == '5' ||
                                          e.status == '6')
                                          ? Style().textColor
                                          : (e.status == "2")
                                          ? Colors.deepOrange
                                          : (e.status == "3")
                                          ? Colors.orangeAccent
                                          : Style().darkColor),
                                )
                              ],
                            )),
                        IconButton(
                            onPressed: () {
                              orderSelected = e.orderId;
                              for (int i = 0; i < showDetail.length; i++) {
                                if (index != i) showDetail[i] = false;
                              }

                              if (showDetail[index] == false) {
                                showDetail[index] = true;
                              } else {
                                showDetail[index] = false;
                              }
                              setState(() {
                                orderProduct = null;
                                _getProduct(e.orderId);
                              });
                            },
                            icon: Icon((showDetail[index] == false)
                                ? FontAwesomeIcons.angleDown
                                : FontAwesomeIcons.angleUp))
                      ],
                    ),
                    (showDetail[index] == true)
                        ? (orderProduct == null)
                        ? Style().circularProgressIndicator(
                        Style().shopPrimaryColor)
                        : showDetailList(e.orderId, e.status)
                        : Container()
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        } else {
          if (e.status == "0" ||
              e.status == "4" ||
              e.status == "5" ||
              e.status == "6") {
            String statusStr = '';
            switch (e.status) {
              case '0':
                {
                  statusStr = 'ยกเลิก';
                }
                break;

              case '1':
                {
                  statusStr = 'รอ Rider ยืนยัน';
                }
                break;

              case '2':
                {
                  statusStr = 'รอการตอบรับ โปรดตอบรับOrder';
                }
                break;

              case '3':
                {
                  statusStr = 'โปรดจัดเตรียมสินค้า';
                }
                break;

              case '4':
                {
                  statusStr = 'Rider กำลังออกส่ง';
                }
                break;
              case '5':
                {
                  statusStr = 'ส่งสำเร็จ';
                }
                break;
              case '6':
                {
                  statusStr = 'ส่งไม่สำเร็จ/ยกเลิก';
                }
            }
            return InkWell(
              onTap: () async {
                print(index.toString());
                print(showDetail[index]);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                margin: EdgeInsets.only(top: 8, left: 8, right: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Style().textSizeColor(
                                      'order No.' + e.orderId,
                                      14,
                                      Style().textColor),
                                  subtitle: Style().textSizeColor(
                                      statusStr,
                                      14,
                                      (e.status == '0' ||
                                          e.status == '5' ||
                                          e.status == '6')
                                          ? Style().textColor
                                          : (e.status == "2")
                                          ? Colors.deepOrange
                                          : (e.status == "3")
                                          ? Colors.orangeAccent
                                          : Style().darkColor),
                                )
                              ],
                            )),
                        IconButton(
                            onPressed: () {
                              orderSelected = e.orderId;
                              for (int i = 0; i < showDetail.length; i++) {
                                if (index != i) showDetail[i] = false;
                              }

                              if (showDetail[index] == false) {
                                showDetail[index] = true;
                              } else {
                                showDetail[index] = false;
                              }
                              setState(() {
                                orderProduct = null;
                                _getProduct(e.orderId);
                              });
                            },
                            icon: Icon((showDetail[index] == false)
                                ? FontAwesomeIcons.angleDown
                                : FontAwesomeIcons.angleUp))
                      ],
                    ),
                    (showDetail[index] == true)
                        ? (orderProduct == null)
                        ? Style().circularProgressIndicator(
                        Style().shopPrimaryColor)
                        : showDetailList(e.orderId, e.status)
                        : Container()
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        }
      }).toList(),
    );
  }

  showDetailList(String orderIdSelect, String orderStatus) {
    return Column(
      children: [
        Column(
            children: orderProduct.map((e) {
              return Row(
                children: [
                  Expanded(
                      child: ListTile(
                        title: Style().textBlackSize(e.name, 14),
                        subtitle: Style().textBlackSize(e.comment, 12),
                      )),
                  Column(
                    children: [
                      Style().textSizeColor(
                          (int.parse(e.pcs) * int.parse(e.price)).toString() +
                              ' ฿',
                          14,
                          Style().textColor),
                      Style()
                          .textSizeColor(
                          'จำนวน x ' + e.pcs, 12, Style().darkColor)
                    ],
                  )
                ],
              );
            }).toList()),
        buildAmount(),
        (orderStatus == '2') ? buildConfirmMenu() : Container()
      ],
    );
  }

  buildConfirmMenu() {
    return Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 5),
                child: ElevatedButton(
                  onPressed: () {
                    print('cancelOrder By Shop');
                    _cancelOrder(context.read<AppDataModel>(), orderSelected);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Style().textSizeColor('ยกเลิก', 14, Colors.white),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                ),
              )
            ],
          ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 5),
                child: ElevatedButton(
                  onPressed: () {
                    _conFirmOrder(context.read<AppDataModel>(), orderSelected);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Style().textSizeColor('ยืนยัน', 14, Colors.white),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Style().darkColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                ),
              )
            ],
          )
        ]));
  }

  Row buildShopStatus(AppDataModel appDataModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        (shopModel.shopStatus == '3')
            ? Expanded(
          child: ListTile(
            title: Style().textSizeColor(
                'อยู่ระหว่างการตรวจสอบ', 16, Colors.orange),
            subtitle:
            Style().textSizeColor('สถานะ ', 14, Style().textColor),
          ),
        )
            : (shopOpen == true)
            ? Expanded(
          child: ListTile(
            title:
            Style().textSizeColor('เปิดร้าน', 16, Colors.green),
            subtitle: Style()
                .textSizeColor('สถานะ ', 14, Style().textColor),
          ),
        )
            : Expanded(
          child: ListTile(
            title: Style()
                .textSizeColor('ปิดร้าน', 16, Colors.deepOrange),
            subtitle: Style()
                .textSizeColor('สถานะ ', 14, Style().textColor),
          ),
        ),
        (shopModel.shopStatus == "3")
            ? Container()
            : Switch(
            activeColor: Style().darkColor,
            value: shopOpen,
            onChanged:
            (shopModel.shopStatus == '1' || shopModel.shopStatus == '2')
                ? (value) async {
              if (value == true) {
                db
                    .collection('shops')
                    .doc(uid)
                    .update({"shop_status": "1"});
              } else {
                db
                    .collection('shops')
                    .doc(uid)
                    .update({"shop_status": "2"});
              }
              setState(() {
                shopOpen = value;
              });
            }
                : null)
      ],
    );
  }

  _cancelOrder(AppDataModel appDataModel, String orderId) async {
    db.collection('orders').doc(orderId).get().then((value) async {
      OrderDetail orderDetail = orderDetailFromJson(jsonEncode(value.data()));
      if (orderDetail.status == '2') {
        var result = await dialogs.inputDialog(
            context,
            Style().textSizeColor('เหตุผล', 16, Style().textColor),
            'ระบุเหตุผลที่ยกเลิก');
        if (result != null && result[0] == true) {
          db
              .collection('orders')
              .doc(orderId)
              .update({'status': '0'}).then((value) {
            addLog(orderId, '0', 'shop', uid, result[1]).then((value) {
              setState(() {
                getData = false;
              });
            });
          });
        }
      } else {
        await dialogs.information(
            context,
            Style().textSizeColor('ผิดพลาด', 16, Style().textColor),
            Style()
                .textSizeColor('Order ถูกยกเลิกแล้ว', 14, Style().textColor));
        setState(() {
          getData = false;
        });
      }
    });
  }

  _conFirmOrder(AppDataModel appDataModel, String orderId) async {
    db.collection('orders').doc(orderId).get().then((value) async {
      OrderDetail orderDetail = orderDetailFromJson(jsonEncode(value.data()));
      if (orderDetail.status == '2') {
        db
            .collection('orders')
            .doc(orderId)
            .update({'status': '3'}).then((value) {
          addLog(orderId, '3', 'shop', uid, '').then((value) {
            setState(() {
              getData = false;
            });
          });
        });
      } else {
        await dialogs.information(
            context,
            Style().textSizeColor('ผิดพลาด', 16, Style().textColor),
            Style()
                .textSizeColor('Order ถูกยกเลิกแล้ว', 14, Style().textColor));
        setState(() {
          getData = false;
        });
      }
    });
  }

  buildAmount() {
    int amount = 0;
    orderProduct.forEach((e) {
      amount += (int.parse(e.price) * int.parse(e.pcs));
    });

    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Divider(
                color: Colors.grey,
                height: 0,
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Style().textSizeColor('รวมค่าสินค้า', 16, Style().darkColor),
              Style().textSizeColor('$amount ฿', 16, Style().darkColor)
            ],
          ),
        ],
      ),
    );
  }
}
