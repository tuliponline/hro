import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/allShopModel.dart';
import 'package:hro/model/productsModel.dart';
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

class HomeState extends State<HomePage> {
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  static final GoogleSignIn googleSignIn = new GoogleSignIn();

  bool getAllShopStatus = false;

  _getAllShop(AppDataModel appDataModel) async {
    if (getAllShopStatus == false) {
      var apiUrl = Uri.parse(appDataModel.server + '/shops/all');
      print(apiUrl);
      var responseGetShopAll = await http.post(
        (apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int>{
          'limit': 20,
        }),
      );
      if (responseGetShopAll.statusCode == 200) {
        var rowData = utf8.decode(responseGetShopAll.bodyBytes);
        appDataModel.allShopData = await allShopModelFromJson(rowData);
        print('allshop ' + appDataModel.allShopData.length.toString());
        _getAllProduct(context.read<AppDataModel>());
      }
    }
  }

  _getAllProduct(AppDataModel appDataModel) async {
    var apiUrl = Uri.parse(appDataModel.server + '/productShop/all');
    print(apiUrl);
    var responseGetProductAll = await http.post(
      (apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'limit': 20,
      }),
    );
    if (responseGetProductAll.statusCode == 200) {
      var rowData = utf8.decode(responseGetProductAll.bodyBytes);
      appDataModel.allProductsData = await productsModelFromJson(rowData);
      print('allshop ' + appDataModel.allShopData.length.toString());
      setState(() {
        getAllShopStatus = true;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    _getAllShop(context.read<AppDataModel>());
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
                  IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Style().darkColor,
                      ),
                      onPressed: () {}),
                  IconButton(
                      icon: Icon(
                        Icons.message,
                        color: Style().darkColor,
                      ),
                      onPressed: () {}),
                  IconButton(
                      icon: Icon(
                        Icons.shopping_cart,
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
                            Container(
                              padding:
                                  EdgeInsets.only(left: 10, right: 10, top: 10),
                              child: buildMainMenu(),
                            ),
                            buildPopularProduct(),
                            buildPopularShop((context.read<AppDataModel>()))
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
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
                  Style().textBlackSize('สิ้นค้าและบริการ ยอดนิยม', 18),
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
        ? Row(
            children: [Style().circularProgressIndicator(Style().darkColor)],
          )
        : Row(
            children: productsModel.map((e) {
              int i = productsModel.indexOf(e);
              return Container(
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
                          fit: BoxFit.fill,
                          image: (productsModel[i].productPhotoUrl == null)
                              ? AssetImage("assets/images/food_icon.png")
                              : NetworkImage(productsModel[i].productPhotoUrl),
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
                                  productsModel[i].shopName,
                              14),
                          Row(
                            children: [
                              Style().textBlackSize(
                                  productsModel[i].productPrice + ' ฿  ', 12),
                              Style().textBlackSize(
                                  '20 นาที / 1.2 กม.', 10)
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.motorcycle,
                                size: 20,
                              ),
                              Style().textBlackSize(' 20 ฿', 12),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
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
                    Container(
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
                                        appDataModel.allShopData[i].shopAddress,
                                    14),
                                Row(
                                  children: [
                                    Style().textBlackSize('1.5 กม. ', 10),
                                    Icon(
                                      Icons.star,
                                      size: 15,
                                      color: Colors.orange,
                                    ),
                                    Style().textBlackSize(' 3.4', 10)
                                  ],
                                ),
                                Row(
                                  children: [
                                    Style().textBlackSize(
                                        appDataModel.allShopData[i].shopType,
                                        10),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      (i.isEven)
                                          ? Style().textDark('เปิด')
                                          : Style().textSizeColor(
                                              'ปิด', 14, Colors.redAccent),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )
            ],
          )
        : Container();
  }
}
