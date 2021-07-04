import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/allShopModel.dart';
import 'package:hro/model/productsModel.dart';
import 'package:hro/utility/snapshot2list.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class AllProductsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AllProductState();
  }
}

class AllProductState extends State<AllProductsPage> {
  int currentPage = 1;
  double screenW;
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool setData = false;

  List<ProductsModel> _productsDataRow;
  List<ProductsModel> _productsData;
  int productCount = 0;

  List<AllShopModel> _shopsDataRow;
  List<AllShopModel> _shopsDataRow2;
  List<AllShopModel> _shopsData;
  int shopCount = 0;

  TextEditingController  textController = TextEditingController();

  _getDataAll(AppDataModel appDataModel) async {
    screenW = appDataModel.screenW;
    await db.collection("products").where('product_status',isEqualTo: "1").get().then((value) async {
      var jsonData = await setList2Json(value);
      _productsDataRow = productsModelFromJson(jsonData);
      _productsData = _productsDataRow;
      print("productDataCount = " + _productsData.length.toString());
      productCount =_productsData.length;

    });

    await db.collection("shops").get().then((value) async{
      var jsonData = await setList2Json(value);
      _shopsDataRow = allShopModelFromJson(jsonData);
      _shopsDataRow2 = _shopsDataRow
          .where((element) => (element.shopStatus).contains("1") || (element.shopStatus).contains("2"))
          .toList();
      shopCount = _shopsDataRow2.length;
      _shopsData = _shopsDataRow2;
    });

    setState(() {
      setData = true;
    });

  }

  @override
  Widget build(BuildContext context) {
    if (setData == false) _getDataAll(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: AppBar(
                iconTheme: IconThemeData(color: Style().darkColor),
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                title: Style().textDarkAppbar('สินค้า/ร้านค้า'),
                leading: Text(""),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey,
                          ))
                    ],
                  )
                ],
              ),
              body:(_productsData == null)? Style().circularProgressIndicator(Style().darkColor) : Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildMenu(context.read<AppDataModel>()),
                      searchBar(),
                      (currentPage == 1)? buildListProduct(context.read<AppDataModel>()) : _setPopularShop(context.read<AppDataModel>())
                    ],
                  ),
                ),
              ),
            ));
  }

  Container buildMenu(AppDataModel appDataModel) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: (appDataModel.screenW * 0.9) / 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
              child: Style().textBlackSize('สินค้า ' + productCount.toString(), 16),
              onPressed: () {
                setState(() {
                  currentPage = 1;
                  setData = false;
                });
              },
            ),
          ),
          Container(
            width: (appDataModel.screenW * 0.9) / 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
              child: Style().textBlackSize('ร้านค้า ' + shopCount.toString(), 16),
              onPressed: () {
                setState(() {

                  currentPage = 2;
                  setData = false;
                });


              },
            ),
          ),
        ],
      ),
    );
  }

  searchBar() {
    return Container(
      margin: EdgeInsets.only(left: 20,bottom:10  ),
      height: 50,
      color: Colors.white,
      child: AnimSearchBar(
        autoFocus: false,
        width: (screenW) * 0.9,
        helpText: "ค้นหา",
        style:
            TextStyle(fontSize: 16, fontFamily: 'Prompt', color: Colors.grey),
       textController: textController,
        suffixIcon: Icon(Icons.search),

        onSuffixTap: () {
          setState(() {
            startSearch();
          });
        },
      ),
    );
  }

  startSearch() async {
    if(currentPage == 1) {
     _productsData = _productsDataRow
          .where((element) => (element.productName).contains(textController.text) || (element.productDetail).contains(textController.text))
          .toList();
     productCount = _productsData.length;

    }else{
      _shopsData = _shopsDataRow2
          .where((element) => (element.shopName).contains(textController.text) )
          .toList();
      shopCount = _shopsData.length;
    }

  }

  buildListProduct(AppDataModel appDataModel) {
    return (_productsData != null)
        ? Column(
            children: _productsData.map((e) {
              int i = _productsData.indexOf(e);
              print("i=" + i.toString());

              return Column(
                children: [
                  (e.productStatus == "0")
                      ? Container()
                      : Container(
                          color: Colors.white,
                          margin: EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                              _productsData[i].productPhotoUrl),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Style().textBlackSize(

                                                  _productsData[i].productName,
                                              14),
                                          Style().textBlackSize(
                                              'รายละเอียด : ' +
                                                  _productsData[i].productName,
                                              12),
                                          Style().textSizeColor(
                                              'ราคา : ' +
                                                  _productsData[i]
                                                      .productPrice +
                                                  " ฿",
                                              14,
                                              Style().darkColor),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              );
            }).toList(),
          )
        : Container();
  }

  _setPopularShop(AppDataModel appDataModel) {
    return (_shopsData != null)
        ? Column(
      children: [
        for (int i = 0; i < _shopsData.length; i++)
          Row(
            children: [
              InkWell(
                onTap: () async {
                  appDataModel.storeSelectId = _shopsData[i].shopUid;
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
                                _shopsData[i].shopPhotoUrl),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Style().textBlackSize(
                                _shopsData[i].shopName +
                                    "-" +
                                    _shopsData[i].shopAddress,
                                14),
                            Row(
                              children: [
                                Style().textBlackSize(
                                    _shopsData[i].shopType, 10),
                              ],
                            ),
                            paddingShopOpen(_shopsData[i].shopTime),
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
  paddingShopOpen(String shopTime) {
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
    print("shopOpen = " + shopOpen.toString());
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
