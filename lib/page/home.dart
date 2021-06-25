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
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/allShopModel.dart';
import 'package:hro/model/cartModel.dart';
import 'package:hro/model/orderModel.dart';
import 'package:hro/model/productsModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/page/orderDetail.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/dialog.dart';
import 'package:hro/utility/style.dart';
import 'package:hro/widget/myDrawer.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
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

  static final FacebookLogin facebookSignIn = new FacebookLogin();
  static final GoogleSignIn googleSignIn = new GoogleSignIn();

  bool getAllShopStatus = false;
  int orderNew = 0;
  int pcs = 0;
  int orderActiveCount = 0;
  List<OrderList> orderList;

  _getAllShop(AppDataModel appDataModel) async {
    //get Notification token
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String token = await firebaseMessaging.getToken();
    print('NotiToken = ' + token.toString());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(appDataModel.profileUid)
        .update({'token': token});
    appDataModel.token = token;

    CollectionReference shops = FirebaseFirestore.instance.collection('shops');
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
    }).catchError((onError) {
      appDataModel.allShopData = null;
      print(onError.toString());
    });
  }

  _getAllProduct(AppDataModel appDataModel) async {
    CollectionReference products =
        FirebaseFirestore.instance.collection('products');
    await products
        .where('product_status', isEqualTo: '1')
        .limit(10)
        .get()
        .then((value) {
      List<DocumentSnapshot> templist;
      List list = new List();
      templist = value.docs;
      list = templist.map((DocumentSnapshot docSnapshot) {
        return docSnapshot.data();
      }).toList();
      var jsonData = jsonEncode(list);
      //print('allProductJsonData' + jsonData.toString());
      appDataModel.allProductsData = productsModelFromJson(jsonData);
      print(appDataModel.allProductsData.length);
    }).catchError((onError) {
      appDataModel.allProductsData = null;
      print(onError.toString());
    });
    await _getOrder(context.read<AppDataModel>());
    // getOrder

    setState(() {
      // print('AllProduct = ' + appDataModel.allProductsData.length.toString());
      getAllShopStatus = true;
    });
  }

  Future<Null> _getOrder(AppDataModel appDataModel) async {
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
            element.status == '4') {
          orderActiveCount += 1;
        }
      });

      print('orderList' + orderList.length.toString());
    }).catchError((onError) {
      print('GetOrder = ' + onError.toString());
    });
    print('EndgrtOrder');
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

  _loadData() {
    // CollectionReference reference = FirebaseFirestore.instance.collection('orders');
    // reference.snapshots().listen((querySnapshot) {
    //   querySnapshot.docChanges.forEach((e) {
    //     print('data = ' + e.doc.id);
    //   });
    //
    //   // print('changData'+querySnapshot.docChanges.toString());
    // });
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
        var result = await dialogs.confirm(context, message.notification.title,
            message.notification.body, Icon(FontAwesomeIcons.question));
        print("nowPage = " + ModalRoute.of(context).settings.name);
      }
    });
  }

  void initState() {
    super.initState();
    _Notififation();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    _loadData();
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
                    ? IconButton(
                        icon: Icon(
                          FontAwesomeIcons.receipt,
                          color: Style().darkColor,
                        ),
                        onPressed: () {
                          setState(() {
                            pcs += 1;
                          });
                        })
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
                      Icons.search,
                      color: Style().darkColor,
                    ),
                    onPressed: () {}),
              ],
            ),
            drawer: Drawer(
              child: MyDrawer(),
            ),
            body: Container(
              color: Colors.grey.shade200,
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
                          buildPopularProduct(),
                          buildPopularShop((context.read<AppDataModel>())),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }

  Row buildMainMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: 100,
          decoration: new BoxDecoration(
              color: Style().darkColor,
              borderRadius: new BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.fastfood,
                  color: Colors.white,
                  size: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Style().textWhiteSize('อาหาร/เครื่องดื่ม', 12),
                )
              ],
            ),
          ),
        ),
        Container(
          width: 100,
          decoration: new BoxDecoration(
              color: Style().darkColor,
              borderRadius: new BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  FontAwesomeIcons.toolbox,
                  color: Colors.white,
                  size: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Style().textWhiteSize('บริการ/ซ่อม', 12),
                )
              ],
            ),
          ),
        ),
        Container(
          width: 100,
          decoration: new BoxDecoration(
              color: Style().darkColor,
              borderRadius: new BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.local_taxi,
                  color: Colors.white,
                  size: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Style().textWhiteSize('รถรับจ้าง', 12),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Container buildPopularProduct() => Container(
        margin: EdgeInsets.only(top: 10),
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 15, right: 10, top: 8, bottom: 8),
              child: Row(
                children: [
                  Style().textBlackSize('ยอดนิยม', 18),
                  Icon(
                    Icons.star,
                    size: 15,
                    color: Colors.orange,
                  ),
                  Icon(
                    Icons.star,
                    size: 15,
                    color: Colors.orange,
                  ),
                  Icon(
                    Icons.star,
                    size: 15,
                    color: Colors.orange,
                  )
                ],
              ),
            ),
            Container(
              height: 230,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [_setPopularProduct(context.read<AppDataModel>())],
              ),
            )
          ],
        ),
      );

  _setPopularProduct(AppDataModel appDataModel) {
    List<ProductsModel> productsModel = appDataModel.allProductsData;

    return (productsModel == null)
        ? Container(
            width: appDataModel.screenW,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Style().circularProgressIndicator(Style().darkColor)],
            ),
          )
        : Row(
            children: productsModel.map((e) {
              int i = productsModel.indexOf(e);

              ShopModel shopModel;
              for (var shop in appDataModel.allFullShopData) {
                if (shop.shopUid == e.shopUid) {
                  shopModel = shopModelFromJson(jsonEncode(shop));
                }
              }
              return InkWell(
                onTap: () async {
                  appDataModel.productSelectId = e.productId;
                  Navigator.pushNamed(context, "/showProduct-page");
                  // setState(() {
                  //   appDataModel.allPcs = 0;
                  //   appDataModel.allPrice = 0;
                  //   for (CartModel orderItem in appDataModel.currentOrder) {
                  //     int sumPrice =
                  //         int.parse(orderItem.pcs) * int.parse(orderItem.price);
                  //
                  //     appDataModel.allPcs += int.parse(orderItem.pcs);
                  //     appDataModel.allPrice += sumPrice;
                  //   }
                  // }
                  // );
                },
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  height: 230,
                  width: 150,
                  // color: (i.isEven) ? Colors.redAccent: Colors.green,
                  child: Column(
                    children: [
                      Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          image: DecorationImage(
                            fit: BoxFit.fitHeight,
                            image: (productsModel[i].productPhotoUrl == null)
                                ? AssetImage("assets/images/food_icon.png")
                                : NetworkImage(
                                    productsModel[i].productPhotoUrl),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Style().textBlackSize(
                                productsModel[i].productName +
                                    " - " +
                                    shopModel.shopName,
                                14),
                            Row(
                              children: [
                                Style().textSizeColor(
                                    productsModel[i].productPrice + ' ฿  ',
                                    14,
                                    Style().darkColor),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.motorcycle,
                                  size: 20,
                                ),
                                Style().textSizeColor(
                                    ' 20 ฿', 12, Style().shopPrimaryColor),
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
          );
  }

  Container buildPopularShop(AppDataModel appDataModel) => Container(
        margin: EdgeInsets.only(top: 5),
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 15, right: 10, top: 8, bottom: 8),
              child: Row(
                children: [
                  Style().textBlackSize('ร้านค้า แนะนำ ', 18),
                  Icon(
                    FontAwesomeIcons.mapPin,
                    size: 15,
                    color: Colors.pinkAccent,
                  ),
                  IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        getAllShopStatus = false;
                        _getAllShop(context.read<AppDataModel>());
                      })
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  _setPopularShop((context.read<AppDataModel>())),
                ],
              ),
            )
          ],
        ),
      );

  _setPopularShop(AppDataModel appDataModel) {
    return (appDataModel.allShopData != null)
        ? Column(
            children: [
              for (int i = 0; i < appDataModel.allShopData.length; i++)
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        appDataModel.storeSelectId =
                            appDataModel.allShopData[i].shopUid;
                        await Navigator.pushNamed(context, '/store-page');
                        appDataModel.currentOrder = [];
                        //appDataModel.currentOrder.clear();
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
                                  fit: BoxFit.fitHeight,
                                  image: NetworkImage(
                                      appDataModel.allShopData[i].shopPhotoUrl),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Style().textBlackSize(
                                      appDataModel.allShopData[i].shopName +
                                          "-" +
                                          appDataModel
                                              .allShopData[i].shopAddress,
                                      14),
                                  // Row(
                                  //   children: [
                                  //     Style().textBlackSize('1.5 กม. ', 10),
                                  //     Icon(
                                  //       Icons.star,
                                  //       size: 15,
                                  //       color: Colors.orange,
                                  //     ),
                                  //     Style().textBlackSize(' 3.4', 10)
                                  //   ],
                                  // ),
                                  Row(
                                    children: [
                                      Style().textBlackSize(
                                          appDataModel.allShopData[i].shopType,
                                          10),
                                    ],
                                  ),
                                  paddingShopOpen(
                                      appDataModel.allShopData[i].shopTime),
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

  Padding paddingShopOpen(String shopTime) {
    bool shopOpen = false;
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

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          (shopOpen == true)
              ? Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Style().darkColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Style().textSizeColor('เปิด', 12, Colors.white),
                )
              : Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Style().textSizeColor('ปิด', 12, Colors.white),
                ),
        ],
      ),
    );
  }
}
