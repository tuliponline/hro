import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatefulWidget {
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  static final GoogleSignIn googleSignIn = new GoogleSignIn();

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  Dialogs dialogs = Dialogs();
  int orderShop = 0;
  int orderDriver = 0;
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<OrderList> orderList;
  bool getData = false;

  _checkOrderShop(AppDataModel appDataModel) {
    orderShop = 0;
    db
        .collection('orders')
        .where('shopId', isEqualTo: appDataModel.profileUid)
        .get()
        .then((value) async {
      var jsonData = await setList2Json(value);
      print(jsonData);
      orderList = orderListFromJson(jsonData);
      orderList.forEach((e) {
        if (e.status == '2' || e.status == '3') {
          orderShop += 1;
        }
      });

      _checkOrderDriver(context.read<AppDataModel>());
    });
  }

  _checkOrderDriver(AppDataModel appDataModel) {
    orderDriver = 0;
    db
        .collection('orders')
        .where('driver', isEqualTo: appDataModel.profileUid)
        .get()
        .then((value) async {
      var jsonData = await setList2Json(value);
      print(jsonData);
      orderList = orderListFromJson(jsonData);
      orderList.forEach((e) {
        if (e.status == '1' ||
            e.status == '2' ||
            e.status == '3' ||
            e.status == '4' ||
            e.status == '9') {
          orderDriver += 1;
        }
      });

      setState(() {
        getData = true;
        print("uid= " + appDataModel.profileUid);
        print("orderShop Count = " + orderShop.toString());
        print("orderDriver Count = " + orderDriver.toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (getData == false) _checkOrderShop(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => SafeArea(
              child: Container(
                child: ListView(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          Container(
                            //color: Colors.orange,
                            margin: EdgeInsets.only(bottom: 5),
                            child: CircleAvatar(
                              backgroundColor: Style().primaryColor,
                              radius: 40,
                              child: CircleAvatar(
                                radius: 38,
                                backgroundColor: Colors.white,
                                child: (appDataModel.profilePhotoUrl?.isEmpty ??
                                        true)
                                    ? Container()
                                    : CircleAvatar(
                                        radius: 35,
                                        backgroundColor: Colors.white,
                                        backgroundImage: NetworkImage(
                                            appDataModel.profilePhotoUrl),
                                      ),
                              ),
                            ),
                          ),
                          (appDataModel.profileName?.isEmpty ?? true)
                              ? Container()
                              : Style().titleH3(appDataModel.profileName),
                          (appDataModel.profileName?.isEmpty ?? true)
                              ? Container()
                              : Style().textDark(appDataModel.profileEmail)
                        ],
                      ),
                    ),
                    Container(
                      // color: Colors.grey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: ListTile(
                            onTap: () async {
                              await Navigator.pushNamed(
                                  context, '/profile-page');
                              setState(() {});
                            },
                            leading: Icon(
                              FontAwesomeIcons.solidUserCircle,
                              color: Style().darkColor,
                              size: 30,
                            ),
                            title: Style().textBlack54('บัญชี'),
                          ))
                        ],
                      ),
                    ),
                    Container(
                      // color: Colors.grey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: ListTile(
                            onTap: () async {
                              await Navigator.pushNamed(
                                  context, '/orderList-page');
                              setState(() {});
                            },
                            leading: Icon(
                              FontAwesomeIcons.clipboardList,
                              color: Style().darkColor,
                              size: 30,
                            ),
                            title: Style().textBlack54('รายการ Order'),
                          ))
                        ],
                      ),
                    ),

                    Container(
                      // color: Colors.grey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: ListTile(
                                  onTap: () {
                                    _checkHaveShop(
                                        context.read<AppDataModel>());
                                  },
                                  leading: Icon(
                                    FontAwesomeIcons.store,
                                    color: Style().shopDarkColor,
                                    size: 30,
                                  ),
                                  title: (orderShop == 0)
                                      ? Style().textSizeColor(
                                          'ร้านค้า', 14, Style().shopDarkColor)
                                      : Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(right: 5),
                                              child: Style().textSizeColor(
                                                  'ร้านค้า',
                                                  14,
                                                  Style().shopDarkColor),
                                            ),
                                            Badge(
                                              position: BadgePosition.topEnd(
                                                  top: 0, end: 3),
                                              animationDuration:
                                                  Duration(milliseconds: 300),
                                              animationType:
                                                  BadgeAnimationType.slide,
                                              badgeContent: Text(
                                                orderShop.toString(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10),
                                              ),
                                              // child: IconButton(
                                              //     icon: Icon(
                                              //       FontAwesomeIcons.receipt,
                                              //       color: Style().darkColor,
                                              //     ),
                                              //     onPressed: () {
                                              //       setState(() {
                                              //         Navigator.pushNamed(context,"/orderList-page");
                                              //       });
                                              //     }),
                                            ),
                                          ],
                                        )))
                        ],
                      ),
                    ),
                    Container(
                      // color: Colors.grey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: ListTile(
                            onTap: () {
                              _checkHaveDrivers(context.read<AppDataModel>());
                            },
                            leading: Icon(
                              FontAwesomeIcons.motorcycle,
                              color: Style().drivePrimaryColor,
                              size: 30,
                            ),
                            title: (orderDriver == 0)? Style().textSizeColor(
                                'Rider', 14, Style().drivePrimaryColor):Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 5),
                                  child: Style().textSizeColor(
                                      'Rider', 14, Style().drivePrimaryColor),
                                ),
                                Badge(
                                  position: BadgePosition.topEnd(
                                      top: 0, end: 3),
                                  animationDuration:
                                  Duration(milliseconds: 300),
                                  animationType:
                                  BadgeAnimationType.slide,
                                  badgeContent: Text(
                                    orderDriver.toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10),
                                  ),
                                  // child: IconButton(
                                  //     icon: Icon(
                                  //       FontAwesomeIcons.receipt,
                                  //       color: Style().darkColor,
                                  //     ),
                                  //     onPressed: () {
                                  //       setState(() {
                                  //         Navigator.pushNamed(context,"/orderList-page");
                                  //       });
                                  //     }),
                                ),
                              ],
                            )
                          ))
                        ],
                      ),
                    ),
                    Container(
                      // color: Colors.grey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () async {
                                await Firebase.initializeApp()
                                    .then((value) async {
                                  await FirebaseAuth.instance
                                      .signOut()
                                      .then((value) async {
                                    await MyDrawer.facebookSignIn.logOut();
                                    await MyDrawer.googleSignIn.signOut();
                                    Navigator.pushNamedAndRemoveUntil(context,
                                        '/first-page', (route) => false);
                                  });
                                });
                              },
                              child: Text(
                                "ออกจากระบบ",
                                style: TextStyle(
                                    fontFamily: 'Prompt',
                                    color: Colors.redAccent),
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  _checkHaveDrivers(AppDataModel appDataModel) async {
    CollectionReference drivers =
        FirebaseFirestore.instance.collection('drivers');
    await drivers.doc(appDataModel.profileUid).get().then((value) async {
      if (value.data() != null) {
        print('haveDriver = ' + jsonEncode(value.data()));
        Navigator.pushNamed(context, '/driver-page', arguments: 'OLD');
      } else {
        print('NorHaveShops');
        bool result = await dialogs.confirm(context, 'สมัคร Rider',
            'ต้องการสมัคร Rider ?', Icon(Icons.motorcycle));
        if (result == true) {
          Navigator.pushNamed(context, "/driverSetup-page", arguments: 'NEW');
        }
      }
    }).catchError((onError) async {
      print("error " + onError.toString());
      print('NotHaveDriver= addNew');
    });
  }

  _checkHaveShop(AppDataModel appDataModel) async {
    CollectionReference shops = FirebaseFirestore.instance.collection('shops');
    await shops.doc(appDataModel.profileUid).get().then((value) async {
      if (value.data() != null) {
        print('haveShops');
        ShopModel shopData = (shopModelFromJson(jsonEncode(value.data())));
        appDataModel.shopName = shopData.shopName;
        appDataModel.shopPhotoUrl = shopData.shopPhotoUrl;
        appDataModel.shopType = shopData.shopType;
        appDataModel.shopPhone = shopData.shopPhone;
        appDataModel.shopAddress = shopData.shopAddress;
        appDataModel.shopLocation = shopData.shopLocation;
        appDataModel.shopTime = shopData.shopTime;
        appDataModel.shopStatus = shopData.shopStatus;
        Navigator.pushNamed(context, '/shop-page', arguments: 'OLD');
      } else {
        print('NorHaveShops');
        bool result = await dialogs.confirm(context, 'เปิดร้าน',
            'ต้องการเปิดร้านค้า ?', Icon(FontAwesomeIcons.store));
        if (result == true) {
          Navigator.pushNamed(context, "/shopSetup-page", arguments: 'NEW');
        }
      }
    }).catchError((onError) async {
      print("error" + onError.toString());
      print('NotHaveUser = addNew');
    });
  }
}
