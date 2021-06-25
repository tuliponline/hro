import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/utility/getStatusString.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class OrderListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OrderListState();
  }
}

class OrderListState extends State<OrderListPage> {
  bool getOrderStatus = false;
  List<OrderList> orderListModel = [];
  List<OrderList> orderListInProcess = [];
  List<OrderList> orderListComplete = [];
  List<OrderList> orderListCancel = [];
  List<OrderList> orderListFail = [];

  int _selectedIndex = 0;

  Color darkColor;

  Future<Null> _getOrderListAll(AppDataModel appDataModel) async {
    darkColor = Style().darkColor;
    await FirebaseFirestore.instance
        .collection('orders')
        .where('customerId', isEqualTo: appDataModel.profileUid)
        .get()
        .then((value) {
      List<DocumentSnapshot> templist;
      List list = new List();
      templist = value.docs;
      list = templist.map((DocumentSnapshot docSnapshot) {
        return docSnapshot.data();
      }).toList();
      var jsonData = jsonEncode(list);
      print(jsonData);
      orderListModel = orderListFromJson(jsonData);
      print('langth=' + orderListModel.length.toString());

      orderListModel.forEach((element) async {
        print(jsonEncode(element));

        await FirebaseFirestore.instance
            .collection('orders')
            .doc(element.orderId)
            .collection('product')
            .get()
            .then((value) {
          value.docs.forEach((element) {
            // print(jsonEncode(element.data()));
          });
        });
      });
      orderListInProcess = orderListModel
          .where((e) =>
              e.status == '1' ||
              e.status == '2' ||
              e.status == '3' ||
              e.status == '4')
          .toList();
      orderListComplete = orderListModel.where((e) => e.status == '5').toList();
      orderListCancel = orderListModel.where((e) => e.status == '0').toList();
      orderListFail = orderListModel.where((e) => e.status == '6').toList();

      setState(() {
        getOrderStatus = true;
      });
    }).catchError((onError) {
      print('error = ' + onError.toString());
      setState(() {
        getOrderStatus = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (getOrderStatus == false) _getOrderListAll(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
            appBar: AppBar(
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
              title: Style().textDarkAppbar('รายการ Order'),
            ),
            body: Container(
              child: buildOrderList(),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesomeIcons.clock,
                    color: Color(0xff009c86),
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
                    'สำเร็จ',
                    style: TextStyle(fontFamily: 'prompt', fontSize: 12),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    FontAwesomeIcons.times,
                    color: Colors.red,
                  ),
                  title: Text(
                    'ไม่สำเร็จ/ยกเลิก',
                    style: TextStyle(fontFamily: 'prompt', fontSize: 12),
                  ),
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
            )));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  SingleChildScrollView buildOrderList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildInProcess(context.read<AppDataModel>()),
          buildInProComplete(context.read<AppDataModel>()),
          buildInFail(context.read<AppDataModel>()),
          (_selectedIndex == 2)
              ? Container(
                  margin: EdgeInsets.all(1),
                  child: Divider(
                    color: Colors.grey,
                    height: 0,
                  ))
              : Container(),
          buildInCancel(context.read<AppDataModel>()),
        ],
      ),
    );
  }

  Container buildInProcess(AppDataModel appDataModel) {
    return (_selectedIndex == 0)
        ? (orderListInProcess != null && orderListInProcess.length != 0)
            ? Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Style().textSizeColor(
                            'กำลังดำเนินการ', 15, Style().textColor)
                      ],
                    ),
                    Column(
                      children: orderListInProcess.map((e){

                        return InkWell(
                          onTap: () async {
                            appDataModel.orderIdSelected = e.orderId;
                            var result = await Navigator.pushNamed(
                                context, "/orderShow-page");
                            debugPrint('resultBackFromOrderShow = $result');
                            if (result != null) {
                              setState(() {
                                getOrderStatus = false;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Expanded(
                                  child: ListTile(
                                title: Row(
                                  children: [
                                    Style().textSizeColor(
                                        e.startTime, 14, Style().textColor),
                                    Style().textSizeColor(
                                        " " +
                                            (int.parse(e.costDelivery) +
                                                    int.parse(e.amount))
                                                .toString() +
                                            '฿',
                                        18,
                                        Style().darkColor)
                                  ],
                                ),
                                subtitle: Style().textSizeColor(
                                    'Order No.' + e.orderId,
                                    12,
                                    Style().textColor),
                              )),
                              (e.status == '1')
                                  ? Container(
                                      child: Column(
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.fileSignature,
                                            color: Style().darkColor,
                                          ),
                                          Style().textSizeColor('รับ Order', 12,
                                              Style().textColor)
                                        ],
                                      ),
                                    )
                                  : (e.status == '2' || e.status == '3')
                                      ? Container(
                                          child: Column(
                                            children: [
                                              Icon(
                                                FontAwesomeIcons.clock,
                                                color: Style().darkColor,
                                              ),
                                              Style().textSizeColor(
                                                  'กำลังเตรียมสินค้า',
                                                  12,
                                                  Style().textColor)
                                            ],
                                          ),
                                        )
                                      : (e.status == '4')
                                          ? Container(
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons.motorcycle,
                                                    color: Style().darkColor,
                                                  ),
                                                  Style().textSizeColor(
                                                      'กำลังออกจัดส่ง',
                                                      12,
                                                      Style().textColor)
                                                ],
                                              ),
                                            )
                                          : (e.status == '9')
                                  ? Container(
                                child: Column(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.clock,
                                      color: Style().darkColor,
                                    ),
                                    Style().textSizeColor(
                                        'รอพนักงานตอบรับ',
                                        12,
                                        Style().textColor)
                                  ],
                                ),
                              ):Container()
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              )
            : (Container(
                child: Center(
                  child: Style()
                      .textSizeColor('ไม่มีรายการ', 14, Style().textColor),
                ),
              ))
        : Container();
  }

  Container buildInProComplete(AppDataModel appDataModel) {
    print('cpLength = ' + orderListComplete.length.toString());
    return (_selectedIndex == 1)
        ? (orderListComplete != null && orderListComplete.length != 0)
            ? Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Style().textSizeColor('สำเร็จ', 15, Style().textColor)
                      ],
                    ),
                    Column(
                      children: orderListComplete.map((e) {
                        return InkWell(
                            onTap: () {
                              appDataModel.orderIdSelected = e.orderId;
                              Navigator.pushNamed(context, "/orderShow-page");
                            },
                            child: Row(children: [
                              Expanded(
                                  child: ListTile(
                                title: Row(
                                  children: [
                                    Style().textSizeColor(
                                        e.startTime, 14, Style().textColor),
                                    Style().textSizeColor(
                                        " " +
                                            (int.parse(e.costDelivery) +
                                                    int.parse(e.amount))
                                                .toString() +
                                            '฿',
                                        18,
                                        Style().darkColor)
                                  ],
                                ),
                                subtitle: Style().textSizeColor(
                                    'Order No.' + e.orderId,
                                    12,
                                    Style().textColor),
                              )),
                              Container(
                                child: Column(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.check,
                                      color: Colors.blueAccent,
                                    ),
                                    Style().textSizeColor(
                                        'สำเร็จ', 12, Style().textColor)
                                  ],
                                ),
                              )
                            ]));
                      }).toList(),
                    )
                  ],
                ),
              )
            : Container(
                child: Center(
                  child: Style()
                      .textSizeColor('ไม่มีรายการ', 14, Style().textColor),
                ),
              )
        : Container();
  }

  Container buildInFail(AppDataModel appDataModel) {
    return (_selectedIndex == 2)
        ? (orderListFail != null && orderListFail.length != 0)
            ? Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Style().textSizeColor(
                            'จัดส่งไม่สำเร็จ', 15, Style().textColor)
                      ],
                    ),
                    Column(
                      children: orderListFail.map((e) {
                        return InkWell(
                            onTap: () {
                              appDataModel.orderIdSelected = e.orderId;
                              Navigator.pushNamed(context, "/orderShow-page");
                            },
                            child: Row(children: [
                              Expanded(
                                  child: ListTile(
                                title: Row(
                                  children: [
                                    Style().textSizeColor(
                                        e.startTime, 14, Style().textColor),
                                    Style().textSizeColor(
                                        " " +
                                            (int.parse(e.costDelivery) +
                                                    int.parse(e.amount))
                                                .toString() +
                                            '฿',
                                        18,
                                        Style().darkColor)
                                  ],
                                ),
                                subtitle: Style().textSizeColor(
                                    'Order No.' + e.orderId,
                                    12,
                                    Style().textColor),
                              )),
                              Container(
                                child: Column(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.timesCircle,
                                      color: Colors.red,
                                    ),
                                    Style().textSizeColor(
                                        'ส่งไม่สำเร็จ', 12, Style().textColor)
                                  ],
                                ),
                              )
                            ]));
                      }).toList(),
                    )
                  ],
                ),
              )
            : (Container(
                child: Center(
                  child: Style()
                      .textSizeColor('ไม่มีรายการ', 14, Style().textColor),
                ),
              ))
        : Container();
  }

  Container buildInCancel(AppDataModel appDataModel) {
    return (_selectedIndex == 2)
        ? (orderListCancel != null && orderListCancel.length != 0)
            ? Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Style().textSizeColor('ยกเเลิก', 15, Style().textColor)
                      ],
                    ),
                    Column(
                      children: orderListCancel.map((e) {
                        return InkWell(
                            onTap: () {
                              appDataModel.orderIdSelected = e.orderId;
                              Navigator.pushNamed(context, "/orderShow-page");
                            },
                            child: Row(children: [
                              Expanded(
                                  child: ListTile(
                                title: Row(
                                  children: [
                                    Style().textSizeColor(
                                        e.startTime, 14, Style().textColor),
                                    Style().textSizeColor(
                                        " " +
                                            (int.parse(e.costDelivery) +
                                                    int.parse(e.amount))
                                                .toString() +
                                            '฿',
                                        18,
                                        Style().darkColor)
                                  ],
                                ),
                                subtitle: Style().textSizeColor(
                                    'Order No.' + e.orderId,
                                    12,
                                    Style().textColor),
                              )),
                              Container(
                                child: Column(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.times,
                                      color: Colors.orange,
                                    ),
                                    Style().textSizeColor(
                                        'ยกเลิก', 12, Style().textColor)
                                  ],
                                ),
                              )
                            ]));
                      }).toList(),
                    )
                  ],
                ),
              )
            : Container(
                child: Center(
                  child: Style()
                      .textSizeColor('ไม่มีรายการ', 14, Style().textColor),
                ),
              )
        : Container();
  }
}
