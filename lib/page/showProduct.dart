import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/cartModel.dart';
import 'package:hro/model/cartSingModel.dart';
import 'package:hro/model/productModel.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class ShowProductPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ShowProductState();
  }
}

class ShowProductState extends State<ShowProductPage> {
  ProductModel productModel;

  bool getDataStatus = false;

  var _comment = TextEditingController();

  int pcs = 1;

  _getProductData(AppDataModel appDataModel) {
    for (var product in appDataModel.allProductsData) {
      if (product.productId == appDataModel.productSelectId) {
        productModel = productModelFromJson(jsonEncode(product));
      }
    }
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Style().textSizeColor(
                              productModel.productName, 18, Style().textColor),
                          Style().textSizeColor(
                              productModel.productDetail, 14, Colors.black87)
                        ],
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
                Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Style().textSizeColor(
                              'ข้อความถึงร้านค้า', 16, Style().textColor),
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
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide:
                                      BorderSide(color: Style().labelColor)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide:
                                      BorderSide(color: Style().labelColor)),
                              hintText: 'ไม่ระบุก็ได้',
                              hintStyle: TextStyle(
                                  fontSize: 10, fontFamily: "prompt")),
                          controller: _comment
                         ,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
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
                Style().textSizeColor(pcs.toString(), 18, Style().textColor),
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
          Container(
            width: appDataModel.screenW * 0.9,
            child: ElevatedButton(
              onPressed: () {
                _addOrder(context.read<AppDataModel>());
                appDataModel.allPcs = 0;
                  appDataModel.allPrice = 0;
                  for (CartModel orderItem in appDataModel.currentOrder) {
                    int sumPrice =
                        int.parse(orderItem.pcs) * int.parse(orderItem.price);

                    appDataModel.allPcs += int.parse(orderItem.pcs);
                    appDataModel.allPrice += sumPrice;
                  }

              },
              child: Style().titleH3('เพิ่มใส่รถเข็น - ' +
                  (int.parse(productModel.productPrice) * pcs).toString() +
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

    if (length  != 0){
      bool haveItem =false;
      for (int i = 0; i < length ; i++)  {
        if (appDataModel.currentOrder[i].productId == productModel.productId) {
          haveItem =true;
          print('have');
          int newPcs = int.parse(appDataModel.currentOrder[i].pcs) + pcs;
          if  (_comment.text?.isEmpty ?? true){

          }else{
            appDataModel.currentOrder[i].comment = _comment.text;
          }
          appDataModel.currentOrder[i].pcs = newPcs.toString();
          print('newPcs ' + jsonEncode(appDataModel.currentOrder[i]).toString());
        }
      }
      if (haveItem == false){
        print('notHave1');
        CartModel newItem = CartModel(
            productId: productModel.productId,productName: productModel.productName,
            pcs: pcs.toString(),
            price: productModel.productPrice,comment: _comment.text,time:productModel.productTime );
        var roeData = jsonEncode(newItem);
        print(roeData);
        appDataModel.currentOrder.add(newItem);

      }

    } else {
      print('notHave');
      CartModel newItem = CartModel(
          productId: productModel.productId,productName: productModel.productName,
          pcs: pcs.toString(),
          price: productModel.productPrice,comment: _comment.text,time: productModel.productTime);
      var roeData = jsonEncode(newItem);
      print(roeData);

      appDataModel.currentOrder.add(newItem);
    }
     appDataModel.storeSelectId =productModel.shopUid;
   Navigator.pushNamedAndRemoveUntil(context, '/store-page', (route) => false);
  }
}
