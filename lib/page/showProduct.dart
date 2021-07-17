import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/cartModel.dart';
import 'package:hro/model/cartSingModel.dart';
import 'package:hro/model/productModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/utility/checkShopTimeOpen.dart';
import 'package:hro/utility/checkUserDetail.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class ShowProductPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ShowProductState();
  }
}

class ShowProductState extends State<ShowProductPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  ProductModel productModel;
  bool getDataStatus = false;
  var _comment = TextEditingController();
  int pcs = 1;

  String shopStatus = '1';
  bool shopOpen = true;

  ShopModel shopModel;

  bool userDetail;

  _getProductData(AppDataModel appDataModel) async {
    for (var product in appDataModel.allProductsData) {
      print('productSelectId= ' + appDataModel.productSelectId);
      print('productSId= ' + product.productId);
      if (product.productId == appDataModel.productSelectId) {
        productModel = productModelFromJson(jsonEncode(product));
        print('product URL= ' + productModel.productPhotoUrl);
      }
    }

    await db
        .collection("shops")
        .doc(productModel.shopUid)
        .get()
        .then((value) async {
      shopModel = shopModelFromJson(jsonEncode(value.data()));
      shopStatus = shopModel.shopStatus;
      await checkShopTimeOpen(shopModel.shopTime)
          .then((value) => shopOpen = value);
    });

    print('ShopStatus= ' + shopStatus);
    print('ShopOpen= ' + shopOpen.toString());

    await checkUserDetail(appDataModel.profileUid)
        .then((value) => userDetail = value);
    print("userDetail =" + userDetail.toString());

    setState(() {
      getDataStatus = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (getDataStatus == false) _getProductData(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                title: (shopModel == null)
                    ? Text("")
                    : Style().textSizeColor(
                        shopModel.shopName, 16, Style().darkColor),
                leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Style().darkColor,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              body: Container(
                child: SingleChildScrollView(
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
                      height: 230,
                      width: appDataModel.screenW,
                      //color: Colors.amber,
                      // color: (i.isEven) ? Colors.redAccent: Colors.green,
                      child: Column(
                        children: [
                          Container(
                            height: 230,
                            width: appDataModel.screenW * 0.9,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                image: (productModel.productPhotoUrl == null)
                                    ? AssetImage("assets/images/food_icon.png")
                                    : NetworkImage(
                                        productModel.productPhotoUrl),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: appDataModel.screenW * 0.7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Style().textFlexibleBackSize(
                                productModel.productName, 4, 18),
                            Style().textFlexibleBackSize(
                                productModel.productDetail, 4, 14)
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Style().textSizeColor(
                              productModel.productPrice.toString() + ' ฿',
                              20,
                              Style().darkColor),
                          Style().textSizeColor(
                              (int.parse(productModel.productTime) * pcs)
                                      .toString() +
                                  ' นาที',
                              12,
                              Style().textColor)
                        ],
                      )
                    ],
                  ),
                ),
                (userDetail == false)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Style().textSizeColor(
                                'ท่านกรอกข้อมูลบัญชีไม่ครบ',
                                16,
                                Colors.redAccent),
                          ),
                        ],
                      )
                    : (shopStatus == "2" ||
                            shopStatus == "3" ||
                            shopOpen == false )
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Style().textSizeColor(
                                    'ร้านปิด', 16, Colors.redAccent),
                              ),
                            ],
                          )
                        : (
                    userDetail == null)? Container() :Container(
                            margin: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Style().textSizeColor('ข้อความถึงร้านค้า',
                                        16, Style().textColor),
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  width: appDataModel.screenW * 0.9,
                                  height: 40,
                                  child: TextField(
                                    style: TextStyle(fontSize: 14),
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: BorderSide(
                                                color: Style().labelColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: BorderSide(
                                                color: Style().labelColor)),
                                        hintText: 'ไม่ระบุก็ได้',
                                        hintStyle: TextStyle(
                                            fontSize: 10,
                                            fontFamily: "prompt")),
                                    controller: _comment,
                                  ),
                                )
                              ],
                            ),
                          )
              ],
            ),
          ),
          (shopStatus == "2" ||
                  shopStatus == "3" ||
                  shopOpen == false ||
                  userDetail == false ||
              userDetail == null)
              ? Container()
              : Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () => setState(() {
                          final newValue = pcs - 1;
                          pcs = newValue.clamp(0, 50);
                        }),
                      ),
                      Style()
                          .textSizeColor(pcs.toString(), 18, Style().textColor),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle,
                          color: Colors.green,
                        ),
                        onPressed: () => setState(() {
                          final newValue = pcs + 1;
                          pcs = newValue.clamp(0, 50);
                        }),
                      ),
                    ],
                  ),
                ),
          (shopStatus == "2" ||
                  shopStatus == "3" ||
                  shopOpen == false ||
                  userDetail == false ||
                  userDetail == null)
              ? Container()
              : Container(
                  width: appDataModel.screenW * 0.9,
                  child: ElevatedButton(
                    onPressed: () {
                      _addOrder(context.read<AppDataModel>());
                      appDataModel.allPcs = 0;
                      appDataModel.allPrice = 0;
                      for (CartModel orderItem in appDataModel.currentOrder) {
                        int sumPrice = int.parse(orderItem.pcs) *
                            int.parse(orderItem.price);

                        appDataModel.allPcs += int.parse(orderItem.pcs);
                        appDataModel.allPrice += sumPrice;
                      }
                    },
                    child: Style().titleH3('เพิ่มใส่รถเข็น - ' +
                        (int.parse(productModel.productPrice) * pcs)
                            .toString() +
                        ' ฿'),
                    style: ElevatedButton.styleFrom(
                        primary: Style().primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                  ),
                )
        ],
      );

  _addOrder(AppDataModel appDataModel) async {
    print('listLength = ' + appDataModel.currentOrder.length.toString());
    int length = appDataModel.currentOrder.length;

    if (length != 0) {
      bool haveItem = false;
      for (int i = 0; i < length; i++) {
        if (appDataModel.currentOrder[i].productId == productModel.productId) {
          haveItem = true;
          print('have');
          int newPcs = int.parse(appDataModel.currentOrder[i].pcs) + pcs;
          if (_comment.text?.isEmpty ?? true) {
          } else {
            appDataModel.currentOrder[i].comment = _comment.text;
          }
          appDataModel.currentOrder[i].pcs = newPcs.toString();
          print(
              'newPcs ' + jsonEncode(appDataModel.currentOrder[i]).toString());
        }
      }
      if (haveItem == false) {
        print('notHave1');
        CartModel newItem = CartModel(
            productId: productModel.productId,
            productName: productModel.productName,
            pcs: pcs.toString(),
            price: productModel.productPrice,
            comment: _comment.text,
            time: productModel.productTime);
        var roeData = jsonEncode(newItem);
        print(roeData);
        appDataModel.currentOrder.add(newItem);
      }
    } else {
      print('notHave');
      CartModel newItem = CartModel(
          productId: productModel.productId,
          productName: productModel.productName,
          pcs: pcs.toString(),
          price: productModel.productPrice,
          comment: _comment.text,
          time: productModel.productTime);
      var roeData = jsonEncode(newItem);
      print(roeData);

      appDataModel.currentOrder.add(newItem);
    }
    appDataModel.storeSelectId = productModel.shopUid;
    Navigator.pushNamedAndRemoveUntil(context, '/store-page', (route) => false);
  }
}
