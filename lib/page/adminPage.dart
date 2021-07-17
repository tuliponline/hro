import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/allShopModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/productModel.dart';
import 'package:hro/model/productsModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/model/userModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AdminPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AdminState();
  }
}

class AdminState extends State<AdminPage> {
  Dialogs dialogs = Dialogs();

  int _selectedIndex = 0;
  FirebaseFirestore db = FirebaseFirestore.instance;

  List<AllUserModel> allUserDataRow;
  List<AllUserModel> allUserData;

  List<AllShopModel> allShopDataRow;
  List<AllShopModel> allShopData;

  List<DriversListModel> allDriverDataRow;
  List<DriversListModel> allDriverData;

  List<ProductsModel> allProductDataRow;
  List<ProductsModel> allProductData;

  List<bool> showDetail = [];

  String pageName = "customer";
  int showCount = 0;
  bool setData = false;

  double screenW = 0;

  _onItemTapped(int index) {
    print(index.toString());
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        pageName = "customer";
        _getCustomer();
      } else if (_selectedIndex == 1) {
        pageName = "shop";
        _getShop(context.read<AppDataModel>());
      } else if (_selectedIndex == 2) {
        _getDriver();
        pageName = "Rider";
      } else if (_selectedIndex == 3) {
        _getProduct();
        pageName = "Menu";
      }
    });
  }

  _getCustomer() async {
    showDetail = [];
    db.collection("users").get().then((value) async {
      var jsonData = await setList2Json(value);
      print(jsonData);
      allUserDataRow = allUserModelFromJson(jsonData);
      allUserData = allUserDataRow;
      await allUserData.forEach((element) {
        showDetail.add(false);
      });
      showCount = allUserData.length;
      print("showCustomerDetail = " + showDetail[0].toString());
      setState(() {
        print("setState");
        setData = true;
      });
    });
  }

  _getShop(AppDataModel appDataModel) async {
    showDetail = [];
    db.collection("shops").get().then((value) async {
      var jsonData = await setList2Json(value);
      print(jsonData);
      allShopDataRow = allShopModelFromJson(jsonData);
      allShopData = allShopDataRow;
      appDataModel.allShopAdminList = allShopData;
      allShopData.forEach((element) {
        showDetail.add(false);
      });
      showCount = allShopData.length;
      print("showShopDetail = " + showDetail[0].toString());
      setState(() {
        print("setState");
        setData = true;
      });
    });
  }

  _getDriver() async {
    showDetail = [];
    db.collection("drivers").get().then((value) async {
      var jsonData = await setList2Json(value);
      print(jsonData);
      allDriverDataRow = driversListModelFromJson(jsonData);
      allDriverData = allDriverDataRow;
      allDriverData.forEach((element) {
        showDetail.add(false);
      });
      showCount = allDriverData.length;
      setState(() {
        setData = true;
      });
    });
  }

  _getProduct() async {
    // await db.collection("products")
    //     .where('product_status', isEqualTo: 3)
    //     .get()
    //     .then((value) {
    //   value.docs.forEach((element) {
    //     print('element' + element.data().toString());
    //   });
    // });

    print("product");
    showDetail = [];
    await db.collection("products").get().then((value) async {
      var jsonData = await setList2Json(value);

      allProductDataRow = productsModelFromJson(jsonData);
      allProductData = allProductDataRow;
      print("allProductDataRow" + allProductDataRow.length.toString());
      allProductData.forEach((element) {
        showDetail.add(false);
      });
      showCount = allProductData.length;
      print("EndProduct");
      setState(() {
        setData = true;
      });
    });
  }

  _setScreenW(AppDataModel appDataModel) {
    screenW = appDataModel.screenW;
  }

  _productWaite() async {
    showDetail = [];
    allProductData = allProductDataRow
        .where((element) => (element.productStatus).contains('3'))
        .toList();
    allProductData.forEach((element) {
      showDetail.add(false);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _setScreenW(context.read<AppDataModel>());
    if (setData == false && _selectedIndex == 0) {
      _getCustomer();
    } else if (setData == false && _selectedIndex == 1) {
      _getShop(context.read<AppDataModel>());
    } else if (setData == false && _selectedIndex == 2) {
      _getDriver();
    } else if (setData == false && _selectedIndex == 3) {
      _getProduct();
    }
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              backgroundColor: Colors.grey.shade300,
              appBar: AppBar(
                iconTheme: IconThemeData(color: Style().darkColor),
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                title: Style()
                    .textDarkAppbar(pageName + " " + showCount.toString()),
                actions: [
                  (_selectedIndex == 0)
                      ? Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, "/adminOrder-page");
                                },
                                icon: Icon(FontAwesomeIcons.cartArrowDown)),
                            IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, "/adminSendNotify-page");
                                },
                                icon: Icon(FontAwesomeIcons.comment))
                          ],
                        )
                      : Container(
                          child: Container(
                            margin: EdgeInsets.only(right: 5),
                            padding: EdgeInsets.all(1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (_selectedIndex == 3) {
                                      _productWaite();
                                    }
                                  },
                                  child: Style().textSizeColor(
                                      'รอยืนยัน', 14, Colors.white),
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
                  IconButton(
                      onPressed: () {
                        setState(() {
                          setData = false;
                        });
                      },
                      icon: Icon(FontAwesomeIcons.sync))
                ],
              ),
              body: (allUserData == null && showDetail.length > 0)
                  ? Style().circularProgressIndicator(Style().darkColor)
                  : Container(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            (_selectedIndex == 0)
                                ? buildCustomerList()
                                : (_selectedIndex == 1)
                                    ? buildShopList()
                                    : (_selectedIndex == 2)
                                        ? buildDriverList()
                                        : buildProductList(
                                            context.read<AppDataModel>())
                          ],
                        ),
                      ),
                    ),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.supervised_user_circle_sharp),
                    title: Text(
                      'Customer',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.store),
                    title: Text(
                      'shop',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.motorcycle),
                    title: Text(
                      'Rider',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.fastfood),
                    title: Text(
                      'Menu',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
            ));
  }

  buildCustomerList() {
    return Container(
      // margin: EdgeInsets.all(8),
      child: (allUserData == null || showDetail.length != allUserData.length)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Style().circularProgressIndicator(Style().darkColor),
              ],
            )
          : Column(
              children: allUserData.mapIndexed((int index, e) {
                return Container(
                  color: Colors.white,
                  margin: EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          (showDetail[index] == true)
                              ? Container()
                              : Container(
                                  margin: EdgeInsets.only(right: 10, left: 10),
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                    image: DecorationImage(
                                      fit: BoxFit.fitHeight,
                                      image: NetworkImage(e.photoUrl),
                                    ),
                                  ),
                                ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Style().textBlackSize(e.name, 14),
                              (showDetail[index] == false)
                                  ? Container()
                                  : Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                                right: 10, left: 10),
                                            height: 180,
                                            width: 180,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.white,
                                              image: DecorationImage(
                                                fit: BoxFit.fitHeight,
                                                image: NetworkImage(e.photoUrl),
                                              ),
                                            ),
                                          ),
                                          Style().textBlackSize(
                                              "email : " + e.email, 14),
                                          (e.phone == null)
                                              ? Style()
                                                  .textBlackSize("tel : ", 14)
                                              : Style().textBlackSize(
                                                  "tel : " + e.phone, 14),
                                          (e.location == null)
                                              ? Style().textBlackSize(
                                                  "location : ", 14)
                                              : Style().textBlackSize(
                                                  "location : " + e.location,
                                                  14),
                                          (e.status == null)
                                              ? Style().textBlackSize(
                                                  "status : ", 14)
                                              : Style().textBlackSize(
                                                  "status : " + e.status, 14),
                                          (e.uid == null)
                                              ? Style()
                                                  .textBlackSize("uid : ", 14)
                                              : Style().textBlackSize(e.uid, 10)
                                        ],
                                      ),
                                    )
                            ],
                          )
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              print("index = " + index.toString());
                              (showDetail[index] == true)
                                  ? showDetail[index] = false
                                  : showDetail[index] = true;
                            });
                          },
                          icon: (showDetail[index] == false)
                              ? Icon(Icons.arrow_drop_down)
                              : Icon(Icons.arrow_drop_up))
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  buildShopList() {
    return Container(
      // margin: EdgeInsets.all(8),
      child: (allShopData == null || showDetail.length != allShopData.length)
          ? Style().circularProgressIndicator(Style().darkColor)
          : Column(
              children: allShopData.map((e) {
                int index = allShopData.indexOf(e);
                print(index);
                return Container(
                  color: Colors.white,
                  margin: EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          (showDetail[index] == true)
                              ? Container()
                              : Container(
                                  margin: EdgeInsets.only(
                                    left: 10,
                                  ),
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                    image: DecorationImage(
                                      fit: BoxFit.fitHeight,
                                      image: (e.shopPhotoUrl?.isEmpty ?? true)
                                          ? AssetImage(
                                              'assets/images/shop-icon.png')
                                          : NetworkImage(e.shopPhotoUrl),
                                    ),
                                  ),
                                ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (showDetail[index] == false)
                                    ? Container()
                                    : Container(
                                        margin: EdgeInsets.only(
                                          left: 10,
                                        ),
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.white,
                                          image: DecorationImage(
                                            fit: BoxFit.fitHeight,
                                            image: (e.shopPhotoUrl?.isEmpty ??
                                                    true)
                                                ? AssetImage(
                                                    'assets/images/shop-icon.png')
                                                : NetworkImage(e.shopPhotoUrl),
                                          ),
                                        ),
                                      ),
                                Row(
                                  children: [
                                    Style().textBlackSize(e.shopName, 14),
                                    (e.shopStatus == "3")
                                        ? Container(
                                            margin: EdgeInsets.only(left: 5),
                                            child: IconButton(
                                                onPressed: () async {
                                                  var result =
                                                      await dialogs.confirm(
                                                          context,
                                                          "ยืนยันร้านค้า",
                                                          "ยืนยันสถานะร้านค้า",
                                                          Icon(Icons.check));

                                                  if (result != null &&
                                                      result == true) {
                                                    await db
                                                        .collection("shops")
                                                        .doc(e.shopUid)
                                                        .update({
                                                      "shop_status": "1"
                                                    }).then((value) {
                                                      sendNotify(
                                                          context.read<
                                                              AppDataModel>(),
                                                          e.token,
                                                          "ยืนยันร้านค้า",
                                                          "ร้าน" +
                                                              e.shopName +
                                                              " ได้รับการยืนยันแล้ว");
                                                    });
                                                    setState(() {
                                                      setData = false;
                                                    });
                                                  }
                                                },
                                                icon: Icon(
                                                  Icons.warning_amber_sharp,
                                                  color:
                                                      Colors.deepOrangeAccent,
                                                )),
                                          )
                                        : (e.shopStatus == "2")
                                            ? Container(
                                                margin:
                                                    EdgeInsets.only(left: 5),
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            : (e.shopStatus == "1")
                                                ? Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5),
                                                    child: Icon(
                                                      Icons.check,
                                                      color: Style().darkColor,
                                                    ))
                                                : Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5),
                                                    child: Icon(
                                                      Icons.delete,
                                                      color:
                                                          Colors.orangeAccent,
                                                    ))
                                  ],
                                ),
                                (showDetail[index] == false)
                                    ? Container()
                                    : Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Style().textBlackSize(
                                                e.shopAddress, 14),
                                            (e.shopPhone == null)
                                                ? Style()
                                                    .textBlackSize("tel : ", 14)
                                                : Style().textBlackSize(
                                                    "tel : " + e.shopPhone, 14),
                                            (e.shopLocation == null)
                                                ? Style().textBlackSize(
                                                    "location : ", 14)
                                                : Style().textBlackSize(
                                                    "location : " +
                                                        e.shopLocation,
                                                    14),
                                            (e.shopType == null)
                                                ? Style().textBlackSize(
                                                    "type : ", 14)
                                                : Style().textBlackSize(
                                                    "status : " + e.shopStatus,
                                                    14),
                                            (e.shopUid == null)
                                                ? Style()
                                                    .textBlackSize("uid : ", 14)
                                                : Style().textBlackSize(
                                                    e.shopUid, 10)
                                          ],
                                        ),
                                      )
                              ],
                            ),
                          )
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              print("index = " + index.toString());
                              (showDetail[index] == true)
                                  ? showDetail[index] = false
                                  : showDetail[index] = true;
                            });
                          },
                          icon: (showDetail[index] == false)
                              ? Icon(Icons.arrow_drop_down)
                              : Icon(Icons.arrow_drop_up))
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  buildDriverList() {
    return Container(
      // margin: EdgeInsets.all(8),
      child: (allDriverData == null ||
              showDetail.length != allDriverData.length)
          ? Style().circularProgressIndicator(Style().darkColor)
          : Column(
              children: allDriverData.map((e) {
                int index = allDriverData.indexOf(e);
                print(index);
                return Container(
                  color: Colors.white,
                  margin: EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          (showDetail[index] == true)
                              ? Container()
                              : Container(
                                  margin: EdgeInsets.only(
                                    left: 10,
                                  ),
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                    image: DecorationImage(
                                      fit: BoxFit.fitHeight,
                                      image: (e.driverPhotoUrl?.isEmpty ?? true)
                                          ? AssetImage(
                                              'assets/images/shop-icon.png')
                                          : NetworkImage(e.driverPhotoUrl),
                                    ),
                                  ),
                                ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (showDetail[index] == false)
                                    ? Container()
                                    : Container(
                                        margin: EdgeInsets.only(
                                          left: 10,
                                        ),
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.white,
                                          image: DecorationImage(
                                            fit: BoxFit.fitHeight,
                                            image: (e.driverPhotoUrl?.isEmpty ??
                                                    true)
                                                ? AssetImage(
                                                    'assets/images/shop-icon.png')
                                                : NetworkImage(
                                                    e.driverPhotoUrl),
                                          ),
                                        ),
                                      ),
                                Row(
                                  children: [
                                    Style().textBlackSize(e.driverName, 14),
                                    (e.driverStatus == "3")
                                        ? Container(
                                            margin: EdgeInsets.only(left: 5),
                                            child: IconButton(
                                                onPressed: () async {
                                                  var result =
                                                      await dialogs.confirm(
                                                          context,
                                                          "ยืนยันRider",
                                                          "ยืนยันสถานะRider",
                                                          Icon(Icons.check));

                                                  if (result != null &&
                                                      result == true) {
                                                    await db
                                                        .collection("drivers")
                                                        .doc(e.driverId)
                                                        .update({
                                                      "driverStatus": "1"
                                                    }).then((value) {
                                                      sendNotify(
                                                          context.read<
                                                              AppDataModel>(),
                                                          e.token,
                                                          "สถานะ Rider",
                                                          "Rider " +
                                                              e.driverName +
                                                              " ได้รับการยืนยันแล้ว");
                                                    });
                                                    setState(() {
                                                      setData = false;
                                                    });
                                                  }
                                                },
                                                icon: Icon(
                                                  Icons.warning_amber_sharp,
                                                  color:
                                                      Colors.deepOrangeAccent,
                                                )),
                                          )
                                        : (e.driverStatus == "2")
                                            ? Container(
                                                margin:
                                                    EdgeInsets.only(left: 5),
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            : (e.driverStatus == "1")
                                                ? Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5),
                                                    child: Icon(
                                                      Icons.check,
                                                      color: Style().darkColor,
                                                    ))
                                                : Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5),
                                                    child: Icon(
                                                      Icons.delete,
                                                      color:
                                                          Colors.orangeAccent,
                                                    ))
                                  ],
                                ),
                                (showDetail[index] == false)
                                    ? Container()
                                    : Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Style().textBlackSize(
                                                "Status = " + e.driverStatus,
                                                14),
                                            Style().textBlackSize(
                                                e.driverAddress, 14),
                                            (e.driverPhone == null)
                                                ? Style()
                                                    .textBlackSize("tel : ", 14)
                                                : Style().textBlackSize(
                                                    "tel : " + e.driverPhone,
                                                    14),
                                            (e.driverLocation == null)
                                                ? Style().textBlackSize(
                                                    "location : ", 14)
                                                : Style().textBlackSize(
                                                    "location : " +
                                                        e.driverLocation,
                                                    14),
                                            (e.driverId == null)
                                                ? Style()
                                                    .textBlackSize("uid : ", 14)
                                                : Style().textBlackSize(
                                                    e.driverId, 10)
                                          ],
                                        ),
                                      )
                              ],
                            ),
                          )
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              print("index = " + index.toString());
                              (showDetail[index] == true)
                                  ? showDetail[index] = false
                                  : showDetail[index] = true;
                            });
                          },
                          icon: (showDetail[index] == false)
                              ? Icon(Icons.arrow_drop_down)
                              : Icon(Icons.arrow_drop_up))
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  buildProductList(AppDataModel appDataModel) {
    return Container(
      child: (allProductData == null ||
              showDetail.length != allProductData.length)
          ? Style().circularProgressIndicator(Style().darkColor)
          : Column(
              children: allProductData.map((e) {
                int index = allProductData.indexOf(e);
                String shopName = "";

                appDataModel.allShopAdminList.forEach((element) {
                  ShopModel shopModel = shopModelFromJson(jsonEncode(element));
                  if (shopModel.shopUid == e.shopUid) {
                    shopName = shopModel.shopName;
                  }
                });

                print(index);
                return Container(
                  color: Colors.white,
                  margin: EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          (showDetail[index] == true)
                              ? Container()
                              : Container(
                                  margin: EdgeInsets.only(
                                    left: 10,
                                  ),
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                    image: DecorationImage(
                                      fit: BoxFit.fitHeight,
                                      image:
                                          (e.productPhotoUrl?.isEmpty ?? true)
                                              ? AssetImage(
                                                  'assets/images/shop-icon.png')
                                              : NetworkImage(e.productPhotoUrl),
                                    ),
                                  ),
                                ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (showDetail[index] == false)
                                    ? Container()
                                    : Container(
                                        margin: EdgeInsets.only(
                                          left: 10,
                                        ),
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.white,
                                          image: DecorationImage(
                                            fit: BoxFit.fitHeight,
                                            image: (e.productPhotoUrl
                                                        ?.isEmpty ??
                                                    true)
                                                ? AssetImage(
                                                    'assets/images/shop-icon.png')
                                                : NetworkImage(
                                                    e.productPhotoUrl),
                                          ),
                                        ),
                                      ),
                                Row(
                                  children: [
                                    (e.productName == null)
                                        ? Container()
                                        : Style()
                                            .textBlackSize(e.productName, 14),
                                    (e.productStatus == "3")
                                        ? Container(
                                            margin: EdgeInsets.only(left: 5),
                                            child: IconButton(
                                                onPressed: () async {
                                                  var result =
                                                      await dialogs.confirm(
                                                          context,
                                                          "ยืนยันสินค้า",
                                                          "ยืนยันสถานะสินค้า",
                                                          Icon(Icons.check));

                                                  if (result != null &&
                                                      result == true) {
                                                    await db
                                                        .collection("products")
                                                        .doc(e.productId)
                                                        .update({
                                                      "product_status": "1"
                                                    }).then((value) {});
                                                    setState(() {
                                                      setData = false;
                                                    });
                                                  }
                                                },
                                                icon: Icon(
                                                  Icons.warning_amber_sharp,
                                                  color:
                                                      Colors.deepOrangeAccent,
                                                )),
                                          )
                                        : (e.productStatus == "2")
                                            ? Container(
                                                margin:
                                                    EdgeInsets.only(left: 5),
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            : (e.productStatus == "1")
                                                ? Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5),
                                                    child: Icon(
                                                      Icons.check,
                                                      color: Style().darkColor,
                                                    ))
                                                : Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5),
                                                    child: Icon(
                                                      Icons.delete,
                                                      color:
                                                          Colors.orangeAccent,
                                                    ))
                                  ],
                                ),
                                (showDetail[index] == false)
                                    ? Container()
                                    : Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Style().textBlackSize(
                                                e.productDetail, 14),
                                            (e.productPrice == null)
                                                ? Style().textBlackSize(
                                                    "ราคา : ", 14)
                                                : Style().textBlackSize(
                                                    "ราคา : " + e.productPrice,
                                                    14),
                                            (e.productTime == null)
                                                ? Style().textBlackSize(
                                                    "เวลา : ", 14)
                                                : Style().textBlackSize(
                                                    "เวลา : " + e.productTime,
                                                    14),
                                            Style().textBlackSize(shopName, 14),
                                            (e.productId == null)
                                                ? Style()
                                                    .textBlackSize("uid : ", 14)
                                                : Style().textBlackSize(
                                                    e.productId, 10)
                                          ],
                                        ),
                                      ),
                                (showDetail[index] == false)
                                    ? (Container())
                                    : Container(
                                        width: screenW * 0.8,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(right: 5),
                                              padding: EdgeInsets.all(1),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      var result = await Dialogs()
                                                          .confirm(
                                                              context,
                                                              "ลบสินค้า",
                                                              "ยืนยัน ลบสินค้า",
                                                              Icon(Icons
                                                                  .warning_sharp));
                                                      if (result != null &&
                                                          result == true) {
                                                        _deleteProduct(
                                                            2,
                                                            e.productId,
                                                            e.productPhotoUrl);
                                                      }
                                                    },
                                                    child: Style()
                                                        .textSizeColor('ลบถาวร',
                                                            14, Colors.white),
                                                    style: ElevatedButton.styleFrom(
                                                        primary: Colors.red,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5))),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(right: 5),
                                              padding: EdgeInsets.all(1),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      var result = await Dialogs()
                                                          .confirm(
                                                              context,
                                                              "ย้านสินค้า",
                                                              "ยืนยัน ย้านสินค้าไปถังขยะ",
                                                              Icon(Icons
                                                                  .warning_sharp));
                                                      if (result != null &&
                                                          result == true) {
                                                        _deleteProduct(
                                                            1,
                                                            e.productId,
                                                            e.productPhotoUrl);
                                                      }
                                                    },
                                                    child: Style()
                                                        .textSizeColor(
                                                            'ย้ายไปถังขยะ',
                                                            14,
                                                            Colors.white),
                                                    style: ElevatedButton.styleFrom(
                                                        primary: Colors.orange,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5))),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                              ],
                            ),
                          )
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              print("index = " + index.toString());
                              (showDetail[index] == true)
                                  ? showDetail[index] = false
                                  : showDetail[index] = true;
                            });
                          },
                          icon: (showDetail[index] == false)
                              ? Icon(Icons.arrow_drop_down)
                              : Icon(Icons.arrow_drop_up))
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  _deleteProduct(int cmd, String productID, String photoUrl) async {
    if (cmd == 1) {
      await db
          .collection("products")
          .doc(productID)
          .update({"product_status": "3"}).then((value) async {
        await Dialogs().information(
          context,
          Style().textBlackSize("สำเร็จ", 16),
          Style().textBlackSize("ย้านสินค้าไปถังขยะแล้ว", 14),
        );
      });
    } else if (cmd == 2) {
      await db
          .collection("products")
          .doc(productID)
          .delete()
          .then((value) async {
        await FirebaseStorage.instance
            .refFromURL(photoUrl)
            .delete()
            .then((value) async {
          await Dialogs().information(
            context,
            Style().textBlackSize("สำเร็จ", 16),
            Style().textBlackSize("ลบสินค้าแล้ว", 14),
          );
        });
      });
    }
    setState(() {
      setData = false;
    });
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
