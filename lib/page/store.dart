import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/cartModel.dart';

import 'package:hro/model/productsModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/utility/checkShopTimeOpen.dart';
import 'package:hro/utility/fetcProduct.dart';
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
  int productCount = 0;

  bool listView = true;

  List<ProductsModel> allProductData;


  List<ProductsModel> _pairList = [];

  final _itemFetcher = fetchProduct;
  bool _isLoading = true;
  bool _hasMore = true;
  bool stopLoadProduct = false;
  int limitProduct = 30;

  void _loadMore(AppDataModel appDataModel) {
    if (_pairList.length <= limitProduct) {
      print("loadMore");
      _isLoading = true;
      _itemFetcher(allProductData).then((value) => {
        if (value.isEmpty)
          {
            setState(() {
              _isLoading = false;
              _hasMore = false;
              getDataStatus = true;
            })
          }
        else
          {
            setState(() {
              _isLoading = false;
              _pairList.addAll(value);
              getDataStatus = true;
            })
          }
      });
    } else {
      _isLoading = false;
    }
  }


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

    print("shopOpne = " + shopOpen.toString());
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
      allProductData = appDataModel.storeProductsData;
      productCount = appDataModel.storeProductsData.length;
      limitProduct = productCount;
    }).catchError((onError) {
      appDataModel.storeProductsData = null;
      print(onError.toString());
    });

    if (storeData.shopStatus == "2" || storeData.shopStatus == "3") {
      shopOpen = false;
    } else {
      await checkShopTimeOpen(storeData.shopTime)
          .then((value) => shopOpen = value);
    }

    _loadMore(context.read<AppDataModel>());
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
        builder: (context, appDataModel, child) =>
            Scaffold(
              body: Container(
                child: (storeData == null)
                    ? Style().circularProgressIndicator(Style().darkColor)
                    : SingleChildScrollView(
                  child: buildShowProduct(context.read<AppDataModel>()),
                ),
              ),
            ));
  }

  Column buildShowProduct(AppDataModel appDataModel) =>
      Column(
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
                                    Navigator.pop(context);
                                    // Navigator.pushNamedAndRemoveUntil(context,
                                    //     '/home-page', (route) => false);
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
                                    Style().textSizeColor(storeData.shopName,
                                        18, Style().textColor)
                                  ],
                                ),
                                Container(
                                  width: appDataModel.screenW * 0.8,
                                  child: Style().textSizeColor(
                                      storeData.shopAddress,
                                      14,
                                      Style().textColor),
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
                  padding: EdgeInsets.all(8),
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
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: SingleChildScrollView(
                          child: (listView == true)
                              ? _setProduct(context.read<AppDataModel>())
                              : _buildProductBars(context.read<AppDataModel>()),
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
        ? Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Style().textBlackSize('สินค้าสำหรับคุญ', 16),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, "/allProduct-page");
                  },
                  child: Row(
                    children: [
                      Style().textSizeColor(
                          'เลือกซื้อสินค้าต่อ', 14, Colors.blueAccent),
                      Icon(
                        Icons.navigate_next_sharp,
                        color: Colors.blueAccent,
                        size: 20,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          (allProductData == null)
              ? Style().circularProgressIndicator(Style().darkColor)
              : Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Wrap(
              runSpacing: 8,
              spacing: 8,
              children: allProductData.map((e) {
                int i = allProductData.indexOf(e);
                bool shopOpen = false;

                ShopModel shopModel;
                for (var shop in appDataModel.allFullShopData) {
                  if (shop.shopUid == e.shopUid) {
                    shopModel = shopModelFromJson(jsonEncode(shop));
                    var now = DateTime.now();
                    int dayNum = now.weekday;
                    List<String> statusTimeAll = shop.shopTime.split(",");
                    for (int i = 0; i < statusTimeAll.length - 1; i++) {
                      if (dayNum == i + 1) {
                        List<String> statusTime =
                        statusTimeAll[i].split("/");
                        if (statusTime[0] == "close") {
                          shopOpen = false;
                        } else {
                          List<String> openClose =
                          statusTime[1].split('-');
                          List<String> openHM = openClose[0].split(':');
                          List<String> closeHM = openClose[1].split(':');
                          final startTime = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              int.parse(openHM[0]),
                              int.parse(openHM[1]));
                          final endTime = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              int.parse(closeHM[0]),
                              int.parse(closeHM[1]));
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
                    appDataModel.productSelectId = e.productId;
                    Navigator.pushNamed(context, "/showProduct-page");
                  },
                  child: Container(
                    width: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                                height: 180,
                                width: 170,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(5.0),
                                  child: FadeInImage.assetNetwork(
                                    fit: BoxFit.fitHeight,
                                    placeholder:
                                    'assets/images/loading.gif',
                                    image: e.productPhotoUrl,
                                  ),
                                )),
                            // Container(height: 50,
                            //   width: 50,child:  paddingShopOpen(e.shopTime, e.shopStatus),)
                          ],
                        ),
                        Container(
                          width: 170,
                          margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                          child: Column(
                            children: [
                              Style().textFlexibleBackSize(
                                  e.productName +
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
                                  e.productDetail, 2, 12)
                            ],
                          ),
                        ),
                        Container(
                          width: 170,
                          margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Style().textSizeColor(e.productPrice + " ฿",
                                  16, Style().darkColor),
                              Row(
                                children: [
                                  Icon(
                                    Icons.motorcycle,
                                    size: 20,
                                  ),
                                  Style().textSizeColor(
                                      appDataModel.costDelivery
                                          .toString() +
                                          ' ฿',
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
              }).toList(),
            ),
          ),
        ],
      ),
    )
        : Container();
  }

  _setProductLoadMore(AppDataModel appDataModel) {
    return (appDataModel.allShopData != null)
        ? Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        children: [

          (allProductData == null)
              ? Style().circularProgressIndicator(Style().darkColor)
              : Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [


                StaggeredGridView.countBuilder(
                  shrinkWrap: true,
                  primary: false,
                  crossAxisCount: 4,
                  itemCount: _hasMore ? _pairList.length + 1 : _pairList.length,
                  staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemBuilder: (BuildContext context, int index) {
                    ShopModel shopModel;
                    for (var shop in appDataModel.allFullShopData) {
                      if (index < _pairList.length) {
                        if (shop.shopUid == _pairList[index].shopUid) {
                          shopModel = shopModelFromJson(jsonEncode(shop));
                        }
                      }
                    }

                    // Uncomment the following line to see in real time how ListView.builder works
                    // print('ListView.builder is building index $index');
                    if (index >= _pairList.length) {
                      print("index=" + index.toString());
                      print("_pairList.length=" + _pairList.length.toString());
                      // Don't trigger if one async loading is already under way
                      if (!_isLoading) {
                        _loadMore(context.read<AppDataModel>());
                      }
                      return Center(
                        child: (_pairList.length <= limitProduct)
                            ? Container(
                          width: 150,
                          height: 150,
                          child: Center(
                            child: CircularProgressIndicator(),

                          ),
                        )
                            : Container(),
                      );
                    }

                    return InkWell(
                      onTap: () async {
                        appDataModel.productSelectId = _pairList[index].productId;
                        Navigator.pushNamed(context, "/showProduct-page");
                      },
                      child: Container(
                        width: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
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
                                      child: FadeInImage.assetNetwork(
                                        fit: BoxFit.fitHeight,
                                        placeholder: 'assets/images/loading.gif',
                                        image: _pairList[index].productPhotoUrl,
                                      ),
                                    )),
                                // Container(height: 50,
                                //   width: 50,child:  paddingShopOpen(e.shopTime, e.shopStatus),)
                              ],
                            ),
                            Container(
                              width: 170,
                              margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                              child: Column(
                                children: [
                                  (shopModel == null || shopModel.shopName == null)
                                      ? Style().textFlexibleBackSize(
                                      _pairList[index].productName, 2, 14)
                                      : Style().textFlexibleBackSize(
                                      _pairList[index].productName +
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
                                      _pairList[index].productDetail, 2, 12)
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
                                      _pairList[index].productPrice + " ฿",
                                      16,
                                      Style().darkColor),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.motorcycle,
                                        size: 20,
                                      ),
                                      Style().textSizeColor(
                                          appDataModel.costDelivery.toString() + ' ฿',
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
                  },

                )
              ],
            ),
          ),
        ],
      ),
    )
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
                    await Navigator.pushNamed(context, "/showProduct-page");
                    setState(() {});
                  }, child: Row(
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
                            child: FadeInImage.assetNetwork(
                              fit: BoxFit.fitHeight,
                              placeholder: 'assets/images/loading.gif',
                              image: e.productPhotoUrl,
                            ),
                          ),
                        ),
                        Container(

                            width: appDataModel.screenW * 0.6,
                            margin: EdgeInsets.only(left: 10),
                            child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Style().textBlackSize(e.productName, 14),
                                Style().textBlackSize(e.productDetail, 10),
                              ],
                            )

                        )
                      ],
                    ),
                    Container(

                      child: Style().textSizeColor(
                          e.productPrice + " ฿", 14, Style().darkColor),
                    )
                  ],
                ),)
            ),);
        }).toList(),
      ),
    );
  }

  _changeView() {
    (listView == true) ? listView = false : listView = true;
    setState(() {});
  }
}
