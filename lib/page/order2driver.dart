import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/model/userModel.dart';
import 'package:hro/utility/getAddressName.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class Order2DriverPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Order2DriverState();
  }
}

class Order2DriverState extends State<Order2DriverPage> {
  bool loadData = false;
  OrderDetail orderDetail;
  List<OrderProduct> orderProduct;
  FirebaseFirestore db = FirebaseFirestore.instance;
  String orderIdSelect;
  String shopAddressName, customerAddress;

  double shopLat, shopLng, customerLat, customerLng;

  bool showAddress = false;

  _getData(AppDataModel appDataModel) async {
    orderIdSelect = appDataModel.orderIdSelected;
    db.collection('orders').doc(orderIdSelect).get().then((value) async {
      orderDetail = orderDetailFromJson(jsonEncode(value.data()));
      db
          .collection('orders')
          .doc(orderIdSelect)
          .collection('product')
          .get()
          .then((value) async {
        var jsonData = await setList2Json(value);
        orderProduct = orderProductFromJson(jsonData);

        await db
            .collection('shops')
            .doc(orderDetail.shopId)
            .get()
            .then((shopValue) async {
          ShopModel shopModel = shopModelFromJson(jsonEncode(shopValue.data()));
          List<String> locationLatLng = shopModel.shopLocation.split(',');
          shopLat = double.parse(locationLatLng[0]);
          shopLng = double.parse(locationLatLng[1]);
          shopAddressName = await getAddressName(shopLat, shopLng);
          print('shopAddress = ' + shopAddressName);
        });

        await db
            .collection('users')
            .doc(orderDetail.customerId)
            .get()
            .then((userValue) async {
          UserModel userModel = userModelFromJson(jsonEncode(userValue.data()));
          List<String> locationLatLng = userModel.location.split(',');
          customerLat = double.parse(locationLatLng[0]);
          customerLng = double.parse(locationLatLng[1]);
          customerAddress = await getAddressName(customerLat, customerLng);
          print('CustomerAddress = ' + customerAddress);
          setState(() {
            loadData = true;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loadData == false) _getData(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              backgroundColor: Colors.grey.shade200,
              appBar: (orderProduct == null)
                  ? null
                  : AppBar(
                      iconTheme:
                          IconThemeData(color: Style().darkColor),
                      backgroundColor: Colors.white,
                      bottomOpacity: 0.0,
                      elevation: 0.0,
                      title: Style().textSizeColor(
                          'รายการสินค้า', 18, Style().darkColor),
                    ),
              body: Container(
                child: (orderProduct == null)
                    ? Style()
                        .circularProgressIndicator(Style().drivePrimaryColor)
                    : SingleChildScrollView(
                      child: Column(
                          children: [
                            Container(
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Style().textSizeColor('Order No.$orderIdSelect',
                                      14, Style().textColor),
                                ],
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: ListTile(
                                        title: Style().textSizeColor(
                                            'ตำแหน่งร้านค้า และ สถานที่จัดส่ง',
                                            14,
                                            Style().textColor),
                                      )),
                                      IconButton(
                                        onPressed: () {
                                          (showAddress == true)
                                              ? showAddress = false
                                              : showAddress = true;
                                          setState(() {});
                                        },
                                        icon: Icon(
                                          (showAddress == false)
                                              ? FontAwesomeIcons.angleDown
                                              : FontAwesomeIcons.angleUp,
                                          color: Style().textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (showAddress == true)
                                    buildShopAddress(
                                        context.read<AppDataModel>()),
                                  if (showAddress == true)
                                    buildCustomerAddress(
                                        context.read<AppDataModel>()),
                                  buildProductDetail(),
                                  buildAmount()
                                ],
                              ),
                            ),
                          ],
                        ),
                    ),
              ),
            ));
  }

  buildAmount() {
    int amount = 0;
    orderProduct.forEach((e) {
      amount += (int.parse(e.price) * int.parse(e.pcs));
    });

    return Container(
      margin: EdgeInsets.all(5),
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
              Style().textSizeColor('รวมค่าสินค้า', 16, Style().textColor),
              Style().textSizeColor('$amount ฿', 16, Style().textColor)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Style().textSizeColor('ค่าส่ง', 16, Style().textColor),
              Style().textSizeColor(
                  orderDetail.costDelivery + ' ฿', 16, Style().textColor)
            ],
          )
        ],
      ),
    );
  }

  Container buildProductDetail() {
    return Container(
      margin: EdgeInsets.only(top: 5, right: 10),
      child: Column(
        children: [
          Container(
            child: Style().textSizeColor('รายการสินค้า', 14, Style().textColor),
          ),
          Container(
              margin: EdgeInsets.only(top: 1),
              child: Divider(
                color: Colors.grey,
                height: 0,
              )),
          Column(
            children: orderProduct.map((e) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: ListTile(
                    title: (e.name?.isEmpty ?? true)
                        ? Text('')
                        : Style().textSizeColor(e.name, 14, Style().textColor),
                    subtitle: (e.comment?.isEmpty ?? true)
                        ? Text('')
                        : Style()
                            .textSizeColor(e.comment, 12, Style().textColor),
                  )),
                  Column(
                    children: [
                      Style().textSizeColor(
                          (int.parse(e.pcs) * int.parse(e.price)).toString() +
                              ' ฿',
                          14,
                          Style().textColor),
                      Style().textSizeColor(
                          'จำนวน x ' + e.pcs, 12, Style().darkColor)
                    ],
                  )
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Container buildShopAddress(AppDataModel appDataModel) {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(top: 3),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Style().textSizeColor('ร้านค้า', 14, Style().textColor),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  FontAwesomeIcons.mapMarked,
                  color: Style().drivePrimaryColor,
                ),
              ),
              Expanded(
                  child: ListTile(
                title: (shopAddressName?.isEmpty ?? true)
                    ? Text('')
                    : Style()
                        .textSizeColor(shopAddressName, 14, Style().textColor),
              )),
              // IconButton(icon: Icon(Icons.navigate_next), onPressed: () {})
            ],
          ),
        ],
      ),
    );
  }

  Container buildCustomerAddress(AppDataModel appDataModel) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 3),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Style().textSizeColor('ลูกค้า', 14, Style().textColor),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  FontAwesomeIcons.mapMarked,
                  color: Style().darkColor,
                ),
              ),
              Expanded(
                  child: ListTile(
                title: (customerAddress?.isEmpty ?? true)
                    ? Text('')
                    : Style()
                        .textSizeColor(customerAddress, 14, Style().textColor),
                    subtitle: Text(appDataModel.orderAddressComment),
              )),
              // IconButton(icon: Icon(Icons.navigate_next), onPressed: () {})
            ],
          ),
        ],
      ),
    );
  }
}
