import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/allShopModel.dart';
import 'package:hro/model/cartModel.dart';
import 'package:hro/model/locationSetupModel.dart';

import 'package:hro/model/productsModel.dart';
import 'package:hro/model/ratingModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/utility/checkShopTimeOpen.dart';
import 'package:hro/utility/fetcProduct.dart';
import 'package:hro/utility/getAddressName.dart';
import 'package:hro/utility/getLocationData.dart';
import 'package:hro/utility/snapshot2list.dart';
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
  int productCount = 0;

  bool listView = true;
  List<ProductsModel> allProductData;
  bool stopLoadProduct = false;
  int limitProduct = 30;

  FirebaseFirestore db = FirebaseFirestore.instance;
  List<RatingListModel> ratingListModel;

  double rating = 0.0;

  LocationSetupModel locationSetup;
  double distanceFinal;
  String distanceString;
  int costDelivery;

  _getShopData(AppDataModel appDataModel) async {
    storeSelectId = appDataModel.storeSelectId;
    var rating00 = [];
    await db
        .collection("rating")
        .where("shopId", isEqualTo: storeSelectId)
        .get()
        .then((value) {
      var jsonData = setList2Json(value);
      ratingListModel = ratingListModelFromJson(jsonData);
      ratingListModel.forEach((element) {
        rating00.add({'rating': double.parse(element.shopRate)});
      });
    });

    if (rating00.length > 0) {
      rating = rating00.map((m) => m['rating']).reduce((a, b) => a + b) /
          rating00.length;
    }
    print("rating = " + rating.toString());

    var shopData = await appDataModel.allShopData.where(
        (element) => (element.shopUid).contains(appDataModel.storeSelectId));
    shopData.forEach((element) async {
      String jsonData = jsonEncode(element);
      print("shopDataRow = " + jsonData);
      storeData = await shopModelFromJson(jsonData);
      print("shopData00 = " + storeData.shopName);
    });

    await _getLocationSetup(context.read<AppDataModel>());
    await _calData(context.read<AppDataModel>());

    //Get location
    LocationData locationData = await getLocationData();
    lat1 = locationData.latitude;
    lng1 = locationData.longitude;
    appDataModel.latYou = lat1;
    appDataModel.lngYou = lng1;

    print("shopOpne = " + shopOpen.toString());
    for (var shopData in appDataModel.allFullShopData) {
      if (shopData.shopUid == appDataModel.storeSelectId) {
        appDataModel.currentShopSelect =
            shopModelFromJson(jsonEncode(shopData));
        storeData = appDataModel.currentShopSelect;
        if (storeData.shopStatus == "1") {
          await _getShopOpen(storeData.shopTime);
        } else {
          shopOpen = false;
        }

        appDataModel.shopOpen = shopOpen;
        _getProduct(context.read<AppDataModel>());
      }
    }
  }

  _getProduct(AppDataModel appDataModel) async {
    allProductData = await appDataModel.allProductsData
        .where((e) => (e.shopUid).contains(appDataModel.storeSelectId))
        .toList();
    appDataModel.storeProductsData = await allProductData;
    productCount = await appDataModel.storeProductsData.length;
    limitProduct = await productCount;
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

  _getLocationSetup(AppDataModel appDataModel) async {
    await db.collection('appstatus').doc('locationSetup').get().then((value) {
      print("locationSetup" + jsonEncode(value.data()));
      var jsonData = jsonEncode(value.data());
      appDataModel.locationSetupModel = locationSetupModelFromJson(jsonData);
      List<String> locationLatLng =
          appDataModel.locationSetupModel.centerLocation.split(",");
      appDataModel.latStart = double.parse(locationLatLng[0]);
      appDataModel.lngStart = double.parse(locationLatLng[1]);
      appDataModel.distanceLimit =
          double.parse(appDataModel.locationSetupModel.distanceMax);
      locationSetup = appDataModel.locationSetupModel;
    });
  }

  Future<Null> _calData(AppDataModel appDataModel) async {
    List<String> locationLatLng = storeData.shopLocation.split(",");
    appDataModel.latShop = double.parse(locationLatLng[0]);
    appDataModel.lngShop = double.parse(locationLatLng[1]);

    await _getLocationSetup(context.read<AppDataModel>());
    LocationData locationData = await getLocationData();
    double latYou = locationData.latitude;
    double lngSou = locationData.longitude;
    int costPerKm;
    List<String> distanceAndCost = await calDistanceAndCostDelivery(
        appDataModel.latShop,
        appDataModel.lngShop,
        latYou,
        lngSou,
        int.parse(locationSetup.distanceStart),
        int.parse(locationSetup.costDeliveryMin),
        int.parse(locationSetup.costDeliveryPerKm));
    distanceFinal = double.parse(distanceAndCost[0]);
    costPerKm = int.parse(distanceAndCost[1]);
    var distanceFormat = NumberFormat('#0.0#', 'en_US');
    distanceString = distanceFormat.format(distanceFinal);
    costDelivery = costPerKm;
  }

  @override
  Widget build(BuildContext context) {
    if (getDataStatus == false) _getShopData(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              body: Container(
                child: (storeData == null)
                    ? Style().circularProgressIndicator(Style().darkColor)
                    : SingleChildScrollView(
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Stack(
                              children: [
                                Container(
                                  height: 150,
                                  width: appDataModel.screenW,
                                  child: CachedNetworkImage(
                                    key: UniqueKey(),
                                    imageUrl: storeData.shopPhotoUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.black12,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.black12,
                                      child: (Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      )),
                                    ),
                                  ),
                                ),SafeArea(
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: InkWell(
                                        onTap: () async {
                                          if (appDataModel.currentOrder.length == 0) {
                                            appDataModel.currentOrder = [];
                                            Navigator.pop(context);
                                          } else {
                                            appDataModel.currentOrder = [];
                                            Navigator.pushNamedAndRemoveUntil(context,
                                                '/home-page', (route) => false);
                                          }
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
                                )))
                              ],
                            ),

                            // FadeInImage.assetNetwork(
                            //   fit: BoxFit.fitHeight,
                            //   placeholder:
                            //       'assets/images/loading.gif',
                            //   image: ranProductModel[index]
                            //       .productPhotoUrl,
                            // ),
                          ),

                          // child: SafeArea(
                          //   child: InkWell(
                          //     onTap: () async {
                          //       if (appDataModel.currentOrder.length == 0) {
                          //         appDataModel.currentOrder = [];
                          //         Navigator.pop(context);
                          //       } else {
                          //         appDataModel.currentOrder = [];
                          //         Navigator.pushNamedAndRemoveUntil(context,
                          //             '/home-page', (route) => false);
                          //       }
                          //     },
                          //     child: Container(
                          //       child: Row(
                          //         crossAxisAlignment:
                          //             CrossAxisAlignment.start,
                          //         children: [
                          //           Container(
                          //             margin: EdgeInsets.all(10),
                          //             padding: EdgeInsets.all(5),
                          //             decoration: BoxDecoration(
                          //                 color: Colors.black87
                          //                     .withOpacity(0.4),
                          //                 shape: BoxShape.circle),
                          //             child: Icon(
                          //               Icons.close,
                          //               color: Colors.white,
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // )),
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
                                    Style().textSizeColor(storeData.shopName,
                                        18, Style().textColor)
                                  ],
                                ),
                                Container(
                                  width: appDataModel.screenW * 0.8,
                                  child: Style().textFlexibleBackSize(
                                      storeData.shopAddress, 2, 14),
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
                        ? (shopOpen == false || storeData.shopStatus != "1")
                            ? Container()
                            : Container(
                                width: appDataModel.screenW * 0.9,
                                child: ElevatedButton(
                                  onPressed: () {
                                    for (CartModel orderItem
                                        in appDataModel.currentOrder) {
                                      print(
                                          'delete = ' + jsonEncode(orderItem));
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
                                          appDataModel.allPrice.toString() +
                                              ' ฿'),
                                    ],
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      primary: Style().primaryColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5))),
                                ),
                              )
                        : Container()
                    : Container(),
                Container(
                  color: Colors.white,
                  margin: EdgeInsets.only(top: 3),
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Style().textSizeColor(
                              'สินค้า ' + productCount.toString() + " รายการ",
                              16,
                              Style().textColor),
                          (listView == true)
                              ? IconButton(
                                  onPressed: () => _changeView(),
                                  icon: Icon(FontAwesomeIcons.bars),
                                )
                              : IconButton(
                                  onPressed: () => _changeView(),
                                  icon: Icon(FontAwesomeIcons.list))
                        ],
                      ),
                      (listView == true)
                          ? _setProduct(context.read<AppDataModel>())
                          : _buildProductBars(context.read<AppDataModel>())
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      );

  buildDistance(String location, AppDataModel appDataModel) {
    appDataModel.distanceDelivery = distanceString;

    double ratingForShow = double.parse((rating).toStringAsFixed(0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.motorcycle),
            Style().textSizeColor(
                ' $distanceString กิโลเมตร', 14, Style().textColor),
          ],
        ),
        (rating == 0.0)
            ? Style().textBlackSize('ยังไม่มีคะแนน', 10)
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RatingBar.builder(
                    ignoreGestures: true,
                    itemSize: 15,
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 0.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {},
                  ),
                  Style().textBlackSize(" $ratingForShow/5.0", 12),
                  InkWell(
                    onTap: () {
                      print("Show Review");
                      appDataModel.shopRatingList = ratingListModel;
                      Navigator.pushNamed(context, "/shopReview-page");
                    },
                    child: Style()
                        .textSizeColor(' ดูรีวิว', 12, Colors.blueAccent),
                  )
                ],
              )
      ],
    );
  }

  _setProduct(AppDataModel appDataModel) {
    return (appDataModel.allShopData != null)
        ? StaggeredGridView.countBuilder(
            shrinkWrap: true,
            primary: false,
            crossAxisCount: 2,
            staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: EdgeInsets.only(top: 0),
            itemCount: allProductData.length,
            itemBuilder: (BuildContext context, int index) {
              ShopModel shopModel;
              for (var shop in appDataModel.allFullShopData) {
                if (shop.shopUid == allProductData[index].shopUid) {
                  shopModel = shopModelFromJson(jsonEncode(shop));
                  var now = DateTime.now();
                  int dayNum = now.weekday;
                  List<String> statusTimeAll = shop.shopTime.split(",");
                  for (int i = 0; i < statusTimeAll.length - 1; i++) {
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
                        (currentTime.isAfter(startTime) &&
                                currentTime.isBefore(endTime))
                            ? shopOpen = true
                            : shopOpen = false;
                      }
                    }
                  }
                }
              }

              return InkWell(
                onTap: () async {
                  appDataModel.productSelectId =
                      allProductData[index].productId;
                  Navigator.pushNamed(context, "/showProduct-page");
                },
                child: Container(
                  width: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey.shade200,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                              height: 180,
                              width: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: CachedNetworkImage(
                                    key: UniqueKey(),
                                    imageUrl:
                                        allProductData[index].productPhotoUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.black12,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.black12,
                                      child: (Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      )),
                                    ),
                                  )
                                  // FadeInImage.assetNetwork(
                                  //   fit: BoxFit.fitHeight,
                                  //   placeholder: 'assets/images/loading.gif',
                                  //   image: allProductData[index].productPhotoUrl,
                                  // ),
                                  )),
                        ],
                      ),
                      Container(
                        width: 170,
                        margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                        child: Column(
                          children: [
                            (shopModel == null || shopModel.shopName == null)
                                ? Style().textFlexibleBackSize(
                                    allProductData[index].productName, 2, 14)
                                : Style().textFlexibleBackSize(
                                    allProductData[index].productName +
                                        " - " +
                                        shopModel.shopName,
                                    2,
                                    14)
                          ],
                        ),
                      ),
                      Container(
                        width: 170,
                        margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                        child: Column(
                          children: [
                            Style().textFlexibleBackSize(
                                allProductData[index].productDetail, 2, 12)
                          ],
                        ),
                      ),
                      Container(
                        width: 170,
                        margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Style().textSizeColor(
                                allProductData[index].productPrice + " ฿",
                                16,
                                Style().darkColor),
                            Row(
                              children: [
                                Icon(
                                  Icons.motorcycle,
                                  size: 20,
                                ),
                                Style().textSizeColor(
                                    costDelivery.toString() + ' ฿',
                                    14,
                                    Style().shopPrimaryColor),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            })
        : Container();
  }

  _buildProductBars(AppDataModel appDataModel) {
    return Container(
      // margin: EdgeInsets.all(8),
      child: (allProductData == null)
          ? Style().circularProgressIndicator(Style().darkColor)
          : Column(
              children: allProductData.map((e) {
                int i = allProductData.indexOf(e);

                return Container(
                  width: appDataModel.screenW,
                  color: Colors.white,
                  child: Container(
                      margin: EdgeInsets.only(top: 5),
                      child: InkWell(
                        onTap: () async {
                          appDataModel.productSelectId =
                              appDataModel.storeProductsData[i].productId;
                          await Navigator.pushNamed(
                              context, "/showProduct-page");
                          setState(() {});
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                    left: 10,
                                  ),
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                    // image: DecorationImage(
                                    //   fit: BoxFit.fitHeight,
                                    //   image: (e.productPhotoUrl?.isEmpty ?? true)
                                    //       ? AssetImage('assets/images/shop-icon.png')
                                    //       : NetworkImage(e.productPhotoUrl),
                                    // ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: CachedNetworkImage(
                                      key: UniqueKey(),
                                      imageUrl: e.productPhotoUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.black12,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.black12,
                                        child: (Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        )),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                    width: appDataModel.screenW * 0.6,
                                    margin: EdgeInsets.only(left: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Style()
                                            .textBlackSize(e.productName, 14),
                                        Style().textFlexibleBackSize(
                                            e.productDetail, 4, 10),
                                      ],
                                    ))
                              ],
                            ),
                            Container(
                              child: Style().textSizeColor(
                                  e.productPrice + " ฿", 14, Style().darkColor),
                            )
                          ],
                        ),
                      )),
                );
              }).toList(),
            ),
    );
  }

  _changeView() {
    (listView == true) ? listView = false : listView = true;
    setState(() {});
  }
}
