import 'dart:async';
import 'dart:convert';

import 'dart:math';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/allShopModel.dart';
import 'package:hro/model/cartModel.dart';
import 'package:hro/model/locationSetupModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/model/productModel.dart';
import 'package:hro/model/productsModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/model/userModel.dart';
import 'package:hro/page/orderDetail.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/checkShopTimeOpen.dart';
import 'package:hro/utility/dialog.dart';
import 'package:hro/utility/fetcProduct.dart';
import 'package:hro/utility/getAddressName.dart';
import 'package:hro/utility/getAndSetLocation.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:hro/utility/updateToken.dart';
import 'package:hro/widget/myDrawer.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:loadmore/loadmore.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomeState();
  }
}

// _realtimeDB(){
//   FirebaseFirestore.instance.collection('orders').doc
// }

class HomeState extends State<HomePage> {
  Dialogs dialogs = Dialogs();
  FirebaseFirestore db = FirebaseFirestore.instance;

  static final FacebookLogin facebookSignIn = new FacebookLogin();
  static final GoogleSignIn googleSignIn = new GoogleSignIn();

  bool getAllShopStatus = false;
  int orderNew = 0;
  int pcs = 0;
  int orderActiveCount = 0;
  List<OrderList> orderList;

  List<ProductsModel> ranProductModel;
  List<AllShopModel> ranShopModel;

  List<AllShopModel> allShopModelFilter;
  List<ProductsModel> allProductModelFilter;

  int productLength;
  bool getData = false;

  int limitProduct = 30;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String goPage = "";
  String title = '';
  String body = "";

  // Triggers fecth() and then add new items or change _hasMore flag

  _getAllShop(AppDataModel appDataModel) async {
    print("getShop");
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String token = await firebaseMessaging.getToken();
    print('NotiToken = ' + token.toString());
    await updateToken(appDataModel.profileUid, token);
    appDataModel.token = token;
    CollectionReference shops = FirebaseFirestore.instance.collection('shops');

    await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: "overtechth@gmail.com")
        .limit(1)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        var jsonData = jsonEncode(element.data());
        UserModel userModel = userModelFromJson(jsonData);
        print('Admintoken = ' + userModel.token);
        appDataModel.adminToken = userModel.token;
      });
    });

    await getAndSetLocation(appDataModel.profileUid);

    await shops.get().then((value) {
      List<DocumentSnapshot> templist;
      List list = new List();
      templist = value.docs;
      list = templist.map((DocumentSnapshot docSnapshot) {
        return docSnapshot.data();
      }).toList();
      var jsonData = jsonEncode(list);
      //print('allShopJsonData' + jsonData.toString());
      appDataModel.allShopData = allShopModelFromJson(jsonData);
      appDataModel.allFullShopData = allShopModelFromJson(jsonData);
      print(appDataModel.allShopData.length);
      _getAllProduct(context.read<AppDataModel>());
      int shopLength = 0;
      allShopModelFilter = appDataModel.allShopData;
      // allShopModelFilter = appDataModel.allShopData
      //     .where((element) => (element.shopStatus).contains("1"))
      //     .toList();
      print("allShopModelFilter = " + allShopModelFilter.length.toString());
      (allShopModelFilter.length < 10)
          ? shopLength = allShopModelFilter.length
          : shopLength = 10;
      List<String> ranShop = [];
      for (int i = 0; i < shopLength;) {
        var randomItem = (allShopModelFilter..shuffle()).first;
        bool sameData = false;
        ranShop.forEach((element) {
          if (element == jsonEncode(randomItem)) sameData = true;
        });
        if (sameData == false) {
          ranShop.add(jsonEncode(randomItem));
          i++;
        }
      }
      String rowData = ranShop.toString();
      ranShopModel = allShopModelFromJson(rowData);
      print("randomShopCount" + ranShopModel.length.toString());
      ranShopModel.forEach((element) {
        print("name = " + element.shopName);
      });
    }).catchError((onError) {
      appDataModel.allShopData = null;
      print(onError.toString());
    });
  }

  _getAllProduct(AppDataModel appDataModel) async {
    print('getAllProduct');
    CollectionReference products =
        FirebaseFirestore.instance.collection('products');
    await products
        .where('product_status', isEqualTo: '1')
        .get()
        .then((value) async {
      List<DocumentSnapshot> templist;
      List list = new List();
      templist = value.docs;
      list = templist.map((DocumentSnapshot docSnapshot) {
        return docSnapshot.data();
      }).toList();
      var jsonData = jsonEncode(list);
      //print('allProductJsonData' + jsonData.toString());
      appDataModel.allProductsData = productsModelFromJson(jsonData);
      print('allProduct = ' + appDataModel.allProductsData.length.toString());

      productLength = 0;

      allProductModelFilter = appDataModel.allProductsData
          .where((element) => (element.productStatus).contains("1"))
          .toList();
      print("allProductFilter = " + allProductModelFilter.length.toString());

      (allProductModelFilter.length < limitProduct)
          ? productLength = allProductModelFilter.length
          : productLength = limitProduct;
      List<String> ranProductList = [];
      for (int i = 0; i < productLength;) {
        var randomItem = (allProductModelFilter..shuffle()).first;
        bool sameData = false;
        ranProductList.forEach((element) {
          if (element == jsonEncode(randomItem)) sameData = true;
        });
        if (sameData == false) {
          ranProductList.add(jsonEncode(randomItem));
          i++;
        }
      }

      String rowData = ranProductList.toString();
      ranProductModel = productsModelFromJson(rowData);
      print("randomCount" + ranProductModel.length.toString());

      ranProductModel.forEach((element) {
        print("name = " + element.productName);
      });
    }).catchError((onError) {
      appDataModel.allProductsData = null;
      print(onError.toString());
    });
    await _getOrder(context.read<AppDataModel>());
    // getOrder

    setState(() {
      getAllShopStatus = true;
    });
  }

  _reRandomData(AppDataModel appDataModel) async {
    setState(() {
      ranProductModel = null;
      ranShopModel = null;
    });

    productLength = 0;
    allProductModelFilter = null;
    allProductModelFilter = appDataModel.allProductsData
        .where((element) => (element.productStatus).contains("1"))
        .toList();

    (allProductModelFilter.length < limitProduct)
        ? productLength = allProductModelFilter.length
        : productLength = limitProduct;
    List<String> ranProductList = [];
    for (int i = 0; i < productLength;) {
      var randomItem = (allProductModelFilter..shuffle()).first;
      bool sameData = false;
      ranProductList.forEach((element) async {
        if (element == jsonEncode(randomItem)) sameData = true;
      });
      if (sameData == false) {
        ranProductList.add(jsonEncode(randomItem));
        i++;
      }
    }

    String rowData = ranProductList.toString();
    ranProductModel = productsModelFromJson(rowData);
    print("Re-randomProduct" + ranProductModel.length.toString());

    int shopLength = 0;
    allShopModelFilter = null;
    allShopModelFilter = appDataModel.allShopData;
    print("Re-random Shop = " + allShopModelFilter.length.toString());
    (allShopModelFilter.length < 10)
        ? shopLength = allShopModelFilter.length
        : shopLength = 10;
    List<String> ranShop = [];
    for (int i = 0; i < shopLength;) {
      var randomItem = (allShopModelFilter..shuffle()).first;
      bool sameData = false;
      ranShop.forEach((element) {
        if (element == jsonEncode(randomItem)) sameData = true;
      });
      if (sameData == false) {
        ranShop.add(jsonEncode(randomItem));
        i++;
      }
    }
    String rowData2 = ranShop.toString();
    ranShopModel = allShopModelFromJson(rowData2);

    setState(() {
      print("re-random Complete");
    });
  }

  getRandomElement<T>(List<T> list) {
    final random = new Random();
    var i = random.nextInt(list.length);
    return list[i];
  }

  Future<Null> _getOrder(AppDataModel appDataModel) async {
    await _getLocationSetup(context.read<AppDataModel>());
    print('grtOrder');
    orderActiveCount = 0;
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
      orderList = orderListFromJson(jsonData);
      orderList.forEach((element) {
        if (element.status == '1' ||
            element.status == '2' ||
            element.status == '3' ||
            element.status == '4' ||
            element.status == '9') {
          orderActiveCount += 1;
        }
      });

      print('orderList' + orderList.length.toString());
    }).catchError((onError) {
      print('GetOrder = ' + onError.toString());
    });
    print('endGetOrder');
  }

  _getLocationSetup(AppDataModel appDataModel) async {
    await db.collection('appstatus').doc('locationSetup').get().then((value) {
      print("locationSetup" + jsonEncode(value.data()));
      var jsonData = jsonEncode(value.data());
      appDataModel.locationSetupModel = locationSetupModelFromJson(jsonData);
    });
  }

  static int refreshNum = 10; // number that changes when refreshed
  Stream<int> counterStream =
      Stream<int>.periodic(Duration(seconds: 3), (x) => refreshNum);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _handleRefresh() {
    final Completer<void> completer = Completer<void>();
    Timer(const Duration(seconds: 3), () {
      completer.complete();
    });
    setState(() {
      refreshNum = new Random().nextInt(100);
    });
    return completer.future.then<void>((_) {
      getAllShopStatus = false;
      _getAllShop(context.read<AppDataModel>());
    });
  }

  _Notififation() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        print(message.notification.title);

        title = message.notification.title;
        body = message.notification.body;

        goPage = "";
        if (message.notification.title.contains("Rider")) {
          goPage = "/driver-page";
        } else if (message.notification.title.contains("Shop")) {
          goPage = '/shop-page';
        }

        showNotification(title, body, goPage);

        // var result = await dialogs.confirm(context, message.notification.title,
        //     message.notification.body, Icon(FontAwesomeIcons.question));
        // print("nowPage = " + ModalRoute.of(context).settings.name);
      }
    });
  }

  void initState() {
    super.initState();
    _Notififation();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/launcher_icon');
    var iOS = new IOSInitializationSettings();
    var initSetttings = InitializationSettings(iOS: iOS, android: android);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: SelectNotification);
  }

  Future SelectNotification(String payload) {
    debugPrint("payload : $payload");
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: Style().textBlackSize(title, 14),
        content: Style().textFlexibleBackSize(body, 5, 14),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Style().textSizeColor('ออก', 14, Colors.black)),
          (goPage?.isEmpty ?? true)
              ? (Container())
              : TextButton(
                  onPressed: () async {
                    if (goPage == "/driver-page" || goPage == "/shop-page") {
                      print(goPage);
                      Navigator.pop(context);
                      await Navigator.pushNamed(context, goPage);
                    }
                  },
                  child:
                      Style().textSizeColor('ดูOrder', 14, Colors.blueAccent))
        ],
      ),
    );
  }

  showNotification(String title, String body, String goPage) async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.high, importance: Importance.max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(0, title, body, platform,
        payload: 'Nitish Kumar Singh is part time Youtuber');
  }

  // _getDataForReview(AppDataModel appDataModel)async {
  //
  //
  //   appDataModel.ratingOrderId = e.orderId;
  //   appDataModel.ratingShopId = e.shopId;
  //   appDataModel.ratingRiderId = e.driver;
  //
  //   var result =  await   Navigator.pushNamed(
  //       context,  "/Rating4Customer-page");
  //   if (result != null && result == true){
  //     setState(() {
  //       getOrderStatus = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (getAllShopStatus == false) _getAllShop(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
            key: _scaffoldKey,
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
              title: Style().textDarkAppbar('เฮาะ อากาศเดลิเวอรี่'),
              actions: [
                (orderActiveCount == 0)
                    ? Container()
                    : Badge(
                        position: BadgePosition.topEnd(top: 0, end: 3),
                        animationDuration: Duration(milliseconds: 300),
                        animationType: BadgeAnimationType.slide,
                        badgeContent: Text(
                          orderActiveCount.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        child: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.receipt,
                              color: Style().darkColor,
                            ),
                            onPressed: () {
                              setState(() {
                                Navigator.pushNamed(context, "/orderList-page");
                              });
                            }),
                      ),
                IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Style().darkColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _handleRefresh();
                      });
                    }),
              ],
            ),
            drawer: Drawer(
              child: MyDrawer(),
            ),
            body: Container(
              color: Colors.grey.shade100,
              child: Center(
                child: LiquidPullToRefresh(
                  // key if you want to add
                  color: Colors.white,
                  backgroundColor: Style().darkColor,
                  springAnimationDurationInMilliseconds: 3,
                  showChildOpacityTransition: false,
                  onRefresh: _handleRefresh,
                  height: 50,
                  child: ListView(
                    children: [
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Container(
                          //   padding:
                          //       EdgeInsets.only(left: 10, right: 10, top: 10),
                          //   child: buildMainMenu(),
                          // ),
                          // buildMainMenu(),
                          showShop((context.read<AppDataModel>())),
                          showProduct((context.read<AppDataModel>())),
                          // showProductLoadMore(
                          //     (context.read<AppDataModel>())),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }

  buildMainMenu() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              // Navigator.pushNamed(context, "/loadMore-page");
            },
            child: Container(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Image.asset("assets/images/foodIcon.png"),
                  ),
                  Style().textBlackSize("อาหาร/เครื่องดื่ม", 12)
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Dialogs().information(
                  context,
                  Style().textBlackSize('ยังไม่ให้บริการ', 16),
                  Style()
                      .textBlackSize('เรียกช่าง จะเปิดให้บริการเร็วๆนี้', 14));
            },
            child: Container(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Image.asset("assets/images/serviceIcon.png"),
                  ),
                  Style().textBlackSize("เรียกช่าง", 12)
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Dialogs().information(
                  context,
                  Style().textBlackSize('ยังไม่ให้บริการ', 16),
                  Style()
                      .textBlackSize('รถรับจ้าง จะเปิดให้บริการเร็วๆนี้', 14));
            },
            child: Container(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Image.asset("assets/images/taxiIcon.png"),
                  ),
                  Style().textBlackSize("รถรับจ้าง", 12)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  showProduct(AppDataModel appDataModel) {
    return Container(
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
                    appDataModel.allProductCurrentPage = 1;
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
          (ranProductModel == null)
              ? Container(
                  height: 150,
                  child: Style().circularProgressIndicator(Style().darkColor))
              : StaggeredGridView.countBuilder(
                  shrinkWrap: true,
                  primary: false,
                  crossAxisCount: 2,
                  staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: ranProductModel.length,
                  itemBuilder: (BuildContext context, int index) {
                    print("taggeredGridView $index");
                    ShopModel shopModel;
                    for (var shop in appDataModel.allFullShopData) {
                      if (shop.shopUid == ranProductModel[index].shopUid) {
                        shopModel = shopModelFromJson(jsonEncode(shop));
                      }
                    }
                    return InkWell(
                      onTap: () async {
                        appDataModel.productSelectId =
                            ranProductModel[index].productId;
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
                                        placeholder:
                                            'assets/images/loading.gif',
                                        image: ranProductModel[index]
                                            .productPhotoUrl,
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
                                  (shopModel == null ||
                                          shopModel.shopName == null)
                                      ? Style().textFlexibleBackSize(
                                          ranProductModel[index].productName,
                                          2,
                                          14)
                                      : Style().textFlexibleBackSize(
                                          ranProductModel[index].productName +
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
                                      ranProductModel[index].productDetail,
                                      2,
                                      12)
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
                                  Style().textSizeColor(
                                      ranProductModel[index].productPrice +
                                          " ฿",
                                      16,
                                      Style().darkColor),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.motorcycle,
                                        size: 20,
                                      ),
                                      Style().textSizeColor(
                                          appDataModel.costDelivery.toString() +
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
                  })
        ],
      ),
    );
  }

  showShop(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Style().textBlackSize('ร้านค้าแนะนำ', 16),
                InkWell(
                  onTap: () {
                    appDataModel.allProductCurrentPage = 2;
                    Navigator.pushNamed(context, "/allProduct-page");
                  },
                  child: Row(
                    children: [
                      Style().textSizeColor(
                          'ร้านค้าทั้งหมด', 14, Colors.blueAccent),
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
          (ranShopModel == null)
              ? Container(
                  height: 150,
                  child: Style().circularProgressIndicator(Style().darkColor))
              : StaggeredGridView.countBuilder(
                  shrinkWrap: true,
                  primary: false,
                  crossAxisCount: 5,
                  staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  itemCount: 10,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () async {
                        print("goto StorePage");
                        appDataModel.storeSelectId =
                            ranShopModel[index].shopUid;
                        await Navigator.pushNamed(context, '/store-page');
                        appDataModel.currentOrder = [];
                        _reRandomData(context.read<AppDataModel>());
                      },
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.shade100,
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: FadeInImage.assetNetwork(
                                        fit: BoxFit.fitHeight,
                                        placeholder:
                                            'assets/images/loading.gif',
                                        image: ranShopModel[index].shopPhotoUrl,
                                      ),
                                    )),
                                Container(
                                  height: 50,
                                  width: 50,
                                  child: paddingShopOpen(
                                      ranShopModel[index].shopTime,
                                      ranShopModel[index].shopStatus),
                                )
                              ],
                            ),
                            Container(
                              width: 60,
                              margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                              child: Column(
                                children: [
                                  Style().textFlexibleBackSize(
                                      ranShopModel[index].shopName, 2, 10)
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  })
        ],
      ),
    );
  }

  paddingShopOpen(String shopTime, String shopStatus) {
    bool shopOpen = false;

    if (shopStatus == "1") {
      var now = DateTime.now();
      int dayNum = now.weekday;
      List<String> statusTimeAll = shopTime.split(",");
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
            (currentTime.isAfter(startTime) && currentTime.isBefore(endTime))
                ? shopOpen = true
                : shopOpen = false;
          }
        }
      }
    } else {
      shopOpen = false;
    }

    print("shopOpen = " + shopOpen.toString());
    return Container(
      width: 10,
      child: Padding(
        padding: const EdgeInsets.only(top: 1),
        child: (shopOpen == true)
            ? Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Style().darkColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Style().textSizeColor('เปิด', 10, Colors.white),
                ),
              )
            : Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Style().textSizeColor('ปิด', 10, Colors.white),
                ),
              ),
      ),
    );
  }
}
