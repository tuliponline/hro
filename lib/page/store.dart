import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/cartModel.dart';

import 'package:hro/model/productsModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/utility/getAddressName.dart';
import 'package:hro/utility/getLocationData.dart';
import 'package:hro/utility/style.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class StorePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StoreState();
  }
}

class StoreState extends State<StorePage> {
  double lat1, lng1;
  bool getDataStatus = false;
  var _comment = TextEditingController();
  int pcs = 1;
  ShopModel storeData;
  String dayInNumber;
  bool shopOpen = false;
  String storeSelectId;
  _getShopData(AppDataModel appDataModel) async {
    storeSelectId = appDataModel.storeSelectId;
    //Get location
    LocationData locationData = await getLocationData();
    lat1 = locationData.latitude;
    lng1 = locationData.longitude;
    appDataModel.latYou = lat1;
    appDataModel.lngYou = lng1;
    await FirebaseFirestore.instance
        .collection('shops')
        .doc(storeSelectId)
        .get()
        .then((value) {
      var jsonData = jsonEncode(value.data());
      storeData = (shopModelFromJson(jsonData));
      print('storeData = ' + storeData.shopAddress.toString());
    }).catchError((onError) {
      print('onError = ' + onError.toString());
    });

    for (var shopData in appDataModel.allFullShopData) {
      if (shopData.shopUid == appDataModel.storeSelectId) {
        appDataModel.currentShopSelect =
            shopModelFromJson(jsonEncode(shopData));
        storeData = appDataModel.currentShopSelect;
        await _getShopOpen(storeData.shopTime);
        appDataModel.shopOpen = shopOpen;
        _getProduct(context.read<AppDataModel>());
      }
    }
  }
  _getProduct(AppDataModel appDataModel) async {
    CollectionReference products =
        FirebaseFirestore.instance.collection('products');
    await products
        .where('product_status', isEqualTo: '1')
        .where('shop_uid', isEqualTo: appDataModel.storeSelectId)
        .get()
        .then((value) {
      List<DocumentSnapshot> templist;
      List list = new List();
      templist = value.docs;
      list = templist.map((DocumentSnapshot docSnapshot) {
        return docSnapshot.data();
      }).toList();
      var jsobData = jsonEncode(list);
      appDataModel.storeProductsData = productsModelFromJson(jsobData);
    }).catchError((onError) {
      appDataModel.storeProductsData = null;
      print(onError.toString());
    });
    setState(() {
      getDataStatus = true;
    });
  }

  _getShopOpen(String shopTime) async {
    var now = DateTime.now();
    int dayNum = now.weekday;
    print('dayNow = ' + dayNum.toString());
    List<String> statusTimeAll = shopTime.split(",");
    print('stpLeng = ' + statusTimeAll.length.toString());
    for (int i = 0; i < statusTimeAll.length - 1; i++) {
      print('i=' + i.toString() + " " + statusTimeAll[i]);
      if (dayNum == i + 1) {
        List<String> statusTime = statusTimeAll[i].split("/");
        if (statusTime[0] == "close") {
          shopOpen = false;
        } else {
          List<String> openClose = statusTime[1].split('-');
          List<String> openHM = openClose[0].split(':');
          List<String> closeHM = openClose[1].split(':');
          final startTime = DateTime(now.year, now.month, now.day,
              int.parse(openHM[0]), int.parse(openHM[1]));
          final endTime = DateTime(now.year, now.month, now.day,
              int.parse(closeHM[0]), int.parse(closeHM[1]));
          // final startTime = DateTime(now.year, now.month, now.day, 01, 0);
          // final endTime = DateTime(now.year, now.month, now.day, 23,0);
          final currentTime = DateTime.now();
          (currentTime.isAfter(startTime) && currentTime.isBefore(endTime))
              ? shopOpen = true
              : shopOpen = false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (getDataStatus == false) _getShopData(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              body: Container(
                child:  (storeData == null) ? Style().circularProgressIndicator(Style().darkColor) :SingleChildScrollView(
                  child: buildShowProduct(context.read<AppDataModel>()),
                ),
              ),
            ));
  }
  Column buildShowProduct(AppDataModel appDataModel) => Column(
        children: [
          Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 150,
                      width: appDataModel.screenW,
                      child: Column(
                        children: [
                          Container(
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  image: (storeData.shopPhotoUrl == null)
                                      ? AssetImage(
                                          "assets/images/food_icon.png")
                                      : NetworkImage(storeData.shopPhotoUrl),
                                ),
                              ),
                              child: SafeArea(
                                child: InkWell(
                                  onTap: () {
                                    appDataModel.currentOrder = [];
                                    Navigator.pushNamedAndRemoveUntil(context,
                                        '/home-page', (route) => false);
                                  },
                                  child: Container(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.all(10),
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: Colors.black87
                                                  .withOpacity(0.4),
                                              shape: BoxShape.circle),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          (shopOpen == true)
                              ? Container(
                                  margin: EdgeInsets.only(top: 8, left: 8),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Style().darkColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Style()
                                      .textSizeColor('เปิด', 12, Colors.white),
                                )
                              : Container(
                                  margin: EdgeInsets.all(8),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Style()
                                      .textSizeColor('ปิด', 12, Colors.white),
                                ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Style().textSizeColor(
                                        storeData.shopName +
                                            ' - ' +
                                            storeData.shopAddress,
                                        18,
                                        Style().textColor)
                                  ],
                                ),
                                Container(
                                  child: buildDistance(storeData.shopLocation,
                                      context.read<AppDataModel>()),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                (appDataModel.currentOrder != null)
                    ? (appDataModel.currentOrder.length != 0)
                        ? Container(
                            width: appDataModel.screenW * 0.9,
                            child: ElevatedButton(
                              onPressed: () {
                                for (CartModel orderItem
                                    in appDataModel.currentOrder) {
                                  print('delete = ' + jsonEncode(orderItem));
                                }

                                Navigator.pushNamed(
                                    context, "/orderDetail-page");
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Style().titleH3('รถเข็น - ' +
                                      appDataModel.allPcs.toString() +
                                      ' รายการ'),
                                  Style().titleH3(
                                      appDataModel.allPrice.toString() + ' ฿'),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Style().primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5))),
                            ),
                          )
                        : Container()
                    : Container(),
                Container(
                  color: Colors.white,
                  margin: EdgeInsets.only(top: 3),
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Style().textSizeColor(
                              'รายการ เมนู', 16, Style().textColor)
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: SingleChildScrollView(
                          child: _setProduct(context.read<AppDataModel>()),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      );

  Row buildDistance(String location, AppDataModel appDataModel) {
    List<String> locationLatLng = location.split(",");
    double lat = double.parse(locationLatLng[0]);
    double lng = double.parse(locationLatLng[1]);

    double distance = calculateDistance(lat1, lng1, lat, lng);
    var distanceFormat = NumberFormat('#0.0#', 'en_US');
    String distanceString = distanceFormat.format(distance);
    appDataModel.distanceDelivery = distanceString;

    return Row(
      children: [
        Icon(Icons.motorcycle),
        Style()
            .textSizeColor(' $distanceString กิโลเมตร', 14, Style().textColor),
      ],
    );
  }

  _setProduct(AppDataModel appDataModel) {
    return (appDataModel.allShopData != null)
        ? Column(
            children: [
              for (int i = 0; i < appDataModel.storeProductsData.length; i++)
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        appDataModel.productSelectId =
                            appDataModel.storeProductsData[i].productId;
                        await Navigator.pushNamed(context, "/showProduct-page");
                        setState(() {});
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 10, bottom: 8),
                        height: 100,

                        //color: Colors.green,
                        child: Row(
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(appDataModel
                                      .storeProductsData[i].productPhotoUrl),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Style().textBlackSize(
                                      appDataModel
                                          .storeProductsData[i].productName,
                                      14),
                                  Row(
                                    children: [
                                      Style().textBlackSize(
                                          appDataModel.storeProductsData[i]
                                              .productDetail,
                                          12),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Style().textDark(appDataModel
                                                .storeProductsData[i]
                                                .productPrice +
                                            ' ฿')
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )
            ],
          )
        : Container();
  }
}
