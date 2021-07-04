import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/productModel.dart';
import 'package:hro/model/productsModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/dialog.dart';
import 'package:hro/utility/notifySend.dart';
import 'package:hro/utility/regexText.dart';
import 'package:hro/utility/style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class MenuPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MenuState();
  }
}

class MenuState extends State<MenuPage> {
  Dialogs dialogs = Dialogs();
  File file;
  final picker = ImagePicker();
  String photoUrl;
  bool popupSelect = false;

  var _nameFood = TextEditingController();
  var _detailFood = TextEditingController();
  var _priceFood = TextEditingController();

  int timeFood = 5;

  bool getProductsStatus = false;

  List<bool> productStatusList = [];

  bool updateTing = false;

  _getProduct(AppDataModel appDataModel) async {
    CollectionReference products =
        FirebaseFirestore.instance.collection('products');
    await products
        .where('shop_uid', isEqualTo: appDataModel.profileUid)
        .get()
        .then((value) {
      List<DocumentSnapshot> templist;
      List list = new List();
      templist = value.docs;
      list = templist.map((DocumentSnapshot docSnapshot) {
        return docSnapshot.data();
      }).toList();
      var jsobData = jsonEncode(list);
      appDataModel.productsData = productsModelFromJson(jsobData);

      productStatusList = [];
      appDataModel.productsData.forEach((element) {
        (element.productStatus == '2')
            ? productStatusList.add(false)
            : productStatusList.add(true);
      });
    }).catchError((onError) {
      appDataModel.productsData = null;
      print(onError.toString());
    });
    setState(() {
      print("productStatus = " + productStatusList.length.toString());
      print('productAll = ' + appDataModel.productsData.length.toString());
      getProductsStatus = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (getProductsStatus == false) _getProduct(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                iconTheme: IconThemeData(color: Style().darkColor),
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                title: Style()
                    .textSizeColor('สินค้าของคุณ', 18, Style().darkColor),
                actions: [
                  IconButton(
                      icon: Icon(
                        FontAwesomeIcons.sync,
                        color: Style().darkColor,
                      ),
                      onPressed: () {
                        getProductsStatus = false;
                        _getProduct(context.read<AppDataModel>());
                      }),

                  IconButton(
                      icon: Icon(
                        FontAwesomeIcons.plusCircle,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        var result = await Navigator.pushNamed(
                            context, "/addProduct-page");
                        if (result != null) {
                          setState(() {
                            getProductsStatus = false;
                          });
                        }
                      }),
                ],
              ),
              body: Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: ListView(
                    children: [
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 10),
                            child: buildProducts(context.read<AppDataModel>()),
                          ),
                          //buildPopularProduct(),
                          //buildPopularShop((context.read<AppDataModel>()))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  buildProducts(AppDataModel appDataModel) {
    List<ProductsModel> _productsData = appDataModel.productsData;
    return (_productsData != null)
        ? (_productsData.length == 0)
            ? Container(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Style().textBlackSize("กดเมนู ", 16),
                      IconButton(
                          onPressed: () async {
                            await _addMenuDialog(
                                Style().textSizeColor(
                                    'เพิ่มสินค้าใหม่', 16, Style().textColor),
                                context.read<AppDataModel>());

                            if (popupSelect == true) {
                              getProductsStatus = false;
                              _getProduct(context.read<AppDataModel>());
                            }
                          },
                          icon: Icon(
                            FontAwesomeIcons.plusCircle,
                            color: Style().darkColor,
                          )),
                      Style().textBlackSize("เพื่อเพิ่มสินค้า ", 16)
                    ],
                  ),
                ),
              )
            : Column(
                children: _productsData.map((e) {
                  int i = _productsData.indexOf(e);
                  print("i=" + i.toString());

                  return Column(
                    children: [
                      (e.productStatus == "0")
                          ? Container()
                          : Container(
                              width: appDataModel.screenW,
                              color: Colors.white,
                              margin: EdgeInsets.only(bottom: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin:
                                        EdgeInsets.only(left: 10, bottom: 8),
                                    height: 100,

                                    //color: Colors.green,
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.white,
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: NetworkImage(
                                                  _productsData[i]
                                                      .productPhotoUrl),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: appDataModel.screenW * 0.5,
                                          padding: EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Style().textBlackSize(
                                                  'สินค้า: ' +
                                                      _productsData[i]
                                                          .productName,
                                                  14),
                                              Style().textBlackSize(
                                                  'รายละเอียด : ' +
                                                      _productsData[i]
                                                          .productName,
                                                  12),
                                              Style().textBlackSize(
                                                  'ราคา : ' +
                                                      _productsData[i]
                                                          .productPrice +
                                                      " ฿",
                                                  14),
                                              Style().textBlackSize(
                                                  'เวลาเตรียม : ' +
                                                      _productsData[i]
                                                          .productTime +
                                                      ' นาที',
                                                  14),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                          icon: Icon(
                                            FontAwesomeIcons.edit,
                                            color: Colors.deepOrange,
                                          ),
                                          onPressed: () async {
                                           appDataModel.productEditId = e.productId;
                                            var result =
                                                await Navigator.pushNamed(
                                                    context,
                                                    "/editProduct-page");
                                            if (result != null || result == true) {
                                              setState(() {
                                                getProductsStatus = false;
                                              });
                                            }
                                          }),
                                      (e.productStatus == "3")
                                          ? Style().textSizeColor('รอตรวจสอบ',
                                              14, Colors.deepOrangeAccent)
                                          : (productStatusList.length == 0)
                                              ? Container()
                                              : Switch(
                                                  activeColor:
                                                      Style().darkColor,
                                                  value: productStatusList[i],
                                                  onChanged: (e.productStatus ==
                                                              '1' ||
                                                          e.productStatus ==
                                                              '2')
                                                      ? (value) async {
                                                          if (value == true) {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'products')
                                                                .doc(
                                                                    e.productId)
                                                                .update({
                                                              'product_status':
                                                                  '1'
                                                            });
                                                          } else {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'products')
                                                                .doc(
                                                                    e.productId)
                                                                .update({
                                                              'product_status':
                                                                  '2'
                                                            });
                                                          }
                                                          setState(() {
                                                            productStatusList[
                                                                i] = value;
                                                          });
                                                        }
                                                      : null)
                                    ],
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

  Future<void> _addMenuDialog(Text title, AppDataModel appDataModel) async {
    _nameFood.text = '';
    _detailFood.text = '';
    _priceFood.text = '';
    timeFood = 10;
    file = null;
    photoUrl = "";

    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return (updateTing == true)
                ? Style().circularProgressIndicator(Style().darkColor)
                : SingleChildScrollView(
                    child: AlertDialog(
                      title: title,
                      content: Container(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.red,
                                    image: DecorationImage(
                                      fit: BoxFit.fitHeight,
                                      image: (file != null)
                                          ? FileImage(file)
                                          : (photoUrl?.isEmpty ?? true)
                                              ? AssetImage(
                                                  'assets/images/food_icon.png')
                                              : NetworkImage(photoUrl),
                                    ),
                                  ),
                                ),
                                IconButton(
                                    icon: Icon(
                                      Icons.image,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      var result =
                                          await dialogs.photoSelect(context);
                                      if (result == false) {
                                        await chooseImage(ImageSource.camera);
                                      } else if (result == true) {
                                        await chooseImage(ImageSource.gallery);
                                      }
                                      setState(() {});
                                    })
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              width: appDataModel.screenW * 0.9,
                              height: 40,
                              child: TextField(
                                decoration: InputDecoration(
                                    hintText: 'Username',
                                    hintStyle: TextStyle(
                                        color: Color.fromRGBO(94, 101, 107, 1),
                                        letterSpacing: 0.1,
                                        fontWeight: FontWeight.w500),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                        borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                        borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                        borderSide: BorderSide.none),
                                    prefixIcon: Icon(Icons.person),
                                    filled: true,
                                    fillColor:
                                        Color.fromRGBO(243, 244, 247, 1)),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              width: appDataModel.screenW * 0.9,
                              height: 40,
                              child: TextField(
                                style: TextStyle(fontSize: 14),
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    suffixIcon: (textLengthRegex(
                                            _nameFood.text, 4))
                                        ? Icon(
                                            FontAwesomeIcons.solidCheckCircle,
                                            color: Colors.green,
                                          )
                                        : Icon(
                                            FontAwesomeIcons.solidTimesCircle,
                                            color: Colors.red,
                                          ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(
                                            color: Style().labelColor)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(
                                            color: Style().labelColor)),
                                    labelText: "ชื่อสินค้า",
                                    labelStyle: TextStyle(
                                        fontFamily: "prompt",
                                        fontSize: 14,
                                        color:
                                            (textLengthRegex(_nameFood.text, 4))
                                                ? Style().darkColor
                                                : Colors.red)),
                                controller: new TextEditingController.fromValue(
                                    new TextEditingValue(
                                        text: _nameFood.text,
                                        selection: new TextSelection.collapsed(
                                            offset: _nameFood.text.length))),
                                onChanged: (value) {
                                  setState(() {
                                    _nameFood.text = value;
                                  });
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              width: appDataModel.screenW * 0.9,
                              height: 40,
                              child: TextField(
                                style: TextStyle(fontSize: 14),
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    suffixIcon: (textLengthRegex(
                                                _detailFood.text, 8) ==
                                            true)
                                        ? Icon(
                                            FontAwesomeIcons.solidCheckCircle,
                                            color: Colors.green,
                                          )
                                        : Icon(
                                            FontAwesomeIcons.solidTimesCircle,
                                            color: Colors.red,
                                          ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(
                                            color: Style().labelColor)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(
                                            color: Style().labelColor)),
                                    labelText: "คำอธิบาย",
                                    labelStyle: TextStyle(
                                        fontFamily: "prompt",
                                        fontSize: 14,
                                        color: (textLengthRegex(
                                                    _detailFood.text, 8) ==
                                                true)
                                            ? Style().darkColor
                                            : Colors.red)),
                                controller: new TextEditingController.fromValue(
                                    new TextEditingValue(
                                        text: _detailFood.text,
                                        selection: new TextSelection.collapsed(
                                            offset: _detailFood.text.length))),
                                onChanged: (value) {
                                  setState(() {
                                    _detailFood.text = value;
                                  });
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              width: appDataModel.screenW * 0.9,
                              height: 40,
                              child: TextField(
                                style: TextStyle(fontSize: 14),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    suffixIcon: (onlyNumberRegex(
                                                _priceFood.text) ==
                                            true)
                                        ? Icon(
                                            FontAwesomeIcons.solidCheckCircle,
                                            color: Colors.green,
                                          )
                                        : Icon(
                                            FontAwesomeIcons.solidTimesCircle,
                                            color: Colors.red,
                                          ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(
                                            color: Style().labelColor)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(
                                            color: Style().labelColor)),
                                    labelText: "ราคา",
                                    labelStyle: TextStyle(
                                        fontFamily: "prompt",
                                        fontSize: 14,
                                        color:
                                            (onlyNumberRegex(_priceFood.text) ==
                                                    true)
                                                ? Style().darkColor
                                                : Colors.red)),
                                controller: new TextEditingController.fromValue(
                                    new TextEditingValue(
                                        text: _priceFood.text,
                                        selection: new TextSelection.collapsed(
                                            offset: _priceFood.text.length))),
                                onChanged: (value) {
                                  setState(() {
                                    _priceFood.text = value;
                                  });
                                },
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              width: appDataModel.screenW * 0.9,
                              height: 40,
                              child: Row(
                                children: [
                                  Style().textSizeColor(
                                      'เวลาเตรียม', 14, Style().darkColor),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => setState(() {
                                          final newValue = timeFood - 5;
                                          timeFood = newValue.clamp(5, 60);
                                        }),
                                      ),
                                      Text(timeFood.toString()),
                                      IconButton(
                                        icon: Icon(
                                          Icons.add_circle,
                                          color: Colors.green,
                                        ),
                                        onPressed: () => setState(() {
                                          final newValue = timeFood + 5;
                                          timeFood = newValue.clamp(5, 60);
                                        }),
                                      ),
                                    ],
                                  ),
                                  Style().textSizeColor(
                                      'นาที', 14, Style().darkColor),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        new FlatButton(
                          child: Style()
                              .textSizeColor('ยกเลิก', 14, Colors.blueAccent),
                          onPressed: () {
                            popupSelect = false;
                            Navigator.pop(context, false);
                          },
                        ),
                        new FlatButton(
                          child: Style()
                              .textSizeColor('เพิ่ม', 14, Style().darkColor),
                          onPressed: () {
                            _addProduct(context.read<AppDataModel>());
                          },
                        ),
                      ],
                    ),
                  );
          });
        });
  }

  Future<void> _updateMenuDialog(
      Text title, AppDataModel appDataModel, int i) async {
    ProductModel _productData =
        productModelFromJson(json.encode(appDataModel.productsData[i]));
    print(_productData.productName);

    _nameFood.text = _productData.productName;
    _detailFood.text = _productData.productDetail;
    _priceFood.text = _productData.productPrice;
    timeFood = int.parse(_productData.productTime);
    file = null;
    photoUrl = _productData.productPhotoUrl;

    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: title,
                content: Container(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.red,
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: (file != null)
                                    ? FileImage(file)
                                    : (photoUrl?.isEmpty ?? true)
                                        ? AssetImage(
                                            'assets/images/food_icon.png')
                                        : NetworkImage(photoUrl),
                              ),
                            ),
                          ),
                          IconButton(
                              icon: Icon(
                                Icons.image,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                await chooseImage(ImageSource.gallery);
                                setState(() {});
                              })
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
                              suffixIcon: (textLengthRegex(_nameFood.text, 4))
                                  ? Icon(
                                      FontAwesomeIcons.solidCheckCircle,
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      FontAwesomeIcons.solidTimesCircle,
                                      color: Colors.red,
                                    ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide:
                                      BorderSide(color: Style().labelColor)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide:
                                      BorderSide(color: Style().labelColor)),
                              labelText: "ชื่อสินค้า",
                              labelStyle: TextStyle(
                                  fontFamily: "prompt",
                                  fontSize: 14,
                                  color: (textLengthRegex(_nameFood.text, 4))
                                      ? Style().darkColor
                                      : Colors.red)),
                          controller: new TextEditingController.fromValue(
                              new TextEditingValue(
                                  text: _nameFood.text,
                                  selection: new TextSelection.collapsed(
                                      offset: _nameFood.text.length))),
                          onChanged: (value) {
                            setState(() {
                              _nameFood.text = value;
                            });
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        width: appDataModel.screenW * 0.9,
                        height: 40,
                        child: TextField(
                          style: TextStyle(fontSize: 14),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              suffixIcon:
                                  (textLengthRegex(_detailFood.text, 8) == true)
                                      ? Icon(
                                          FontAwesomeIcons.solidCheckCircle,
                                          color: Colors.green,
                                        )
                                      : Icon(
                                          FontAwesomeIcons.solidTimesCircle,
                                          color: Colors.red,
                                        ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide:
                                      BorderSide(color: Style().labelColor)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide:
                                      BorderSide(color: Style().labelColor)),
                              labelText: "คำอธิบาย",
                              labelStyle: TextStyle(
                                  fontFamily: "prompt",
                                  fontSize: 14,
                                  color:
                                      (textLengthRegex(_detailFood.text, 8) ==
                                              true)
                                          ? Style().darkColor
                                          : Colors.red)),
                          controller: new TextEditingController.fromValue(
                              new TextEditingValue(
                                  text: _detailFood.text,
                                  selection: new TextSelection.collapsed(
                                      offset: _detailFood.text.length))),
                          onChanged: (value) {
                            setState(() {
                              _detailFood.text = value;
                            });
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        width: appDataModel.screenW * 0.9,
                        height: 40,
                        child: TextField(
                          style: TextStyle(fontSize: 14),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              suffixIcon:
                                  (onlyNumberRegex(_priceFood.text) == true)
                                      ? Icon(
                                          FontAwesomeIcons.solidCheckCircle,
                                          color: Colors.green,
                                        )
                                      : Icon(
                                          FontAwesomeIcons.solidTimesCircle,
                                          color: Colors.red,
                                        ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide:
                                      BorderSide(color: Style().labelColor)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide:
                                      BorderSide(color: Style().labelColor)),
                              labelText: "ราคา",
                              labelStyle: TextStyle(
                                  fontFamily: "prompt",
                                  fontSize: 14,
                                  color:
                                      (onlyNumberRegex(_priceFood.text) == true)
                                          ? Style().darkColor
                                          : Colors.red)),
                          controller: new TextEditingController.fromValue(
                              new TextEditingValue(
                                  text: _priceFood.text,
                                  selection: new TextSelection.collapsed(
                                      offset: _priceFood.text.length))),
                          onChanged: (value) {
                            setState(() {
                              _priceFood.text = value;
                            });
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        width: appDataModel.screenW * 0.9,
                        height: 40,
                        child: Row(
                          children: [
                            Style().textSizeColor(
                                'เวลาเตรียม', 14, Style().darkColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => setState(() {
                                    final newValue = timeFood - 5;
                                    timeFood = newValue.clamp(5, 60);
                                  }),
                                ),
                                Text(timeFood.toString()),
                                IconButton(
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: Colors.green,
                                  ),
                                  onPressed: () => setState(() {
                                    final newValue = timeFood + 5;
                                    timeFood = newValue.clamp(5, 60);
                                  }),
                                ),
                              ],
                            ),
                            Style()
                                .textSizeColor('นาที', 14, Style().darkColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: Style().textSizeColor('ลบ', 14, Colors.deepOrange),
                    onPressed: () async {
                      var result = await Navigator.pushNamed(
                          context, "/editProduct-page");
                      if (result != null || result == true) {
                        print("editOK");
                      }

                      // await _updateProduct(
                      //     context.read<AppDataModel>(), 'delete', _productData);
                      // popupSelect = true;
                      // Navigator.pop(context);
                    },
                  ),
                  new FlatButton(
                    child:
                        Style().textSizeColor('ยกเลิก', 14, Colors.blueAccent),
                    onPressed: () {
                      popupSelect = false;
                      Navigator.pop(context, false);
                    },
                  ),
                  new FlatButton(
                    child:
                        Style().textSizeColor('บันทึก', 14, Style().darkColor),
                    onPressed: () async {
                      await _updateProduct(
                          context.read<AppDataModel>(), 'update', _productData);
                      popupSelect = true;
                    },
                  ),
                ],
              ),
            );
          });
        });
  }

  Future<void> chooseImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(
        source: imageSource, maxWidth: 800, maxHeight: 800);
    setState(() {
      if (pickedFile != null) {
        file = File(pickedFile.path);
        print("picket Images = " + file.toString());
      } else {
        print('No image selected.');
      }
    });
  }

  _updateProduct(
    AppDataModel appDataModel,
    String cmd,
    ProductModel productData,
  ) async {
    if (cmd == 'delete') {
      var bodyData;
      print("productid " + productData.productId.toString());

      CollectionReference products =
          FirebaseFirestore.instance.collection('products');
      await products
          .doc(productData.productId)
          .update({'product_status': '0'}).then((value) {
        popupSelect = true;
        Navigator.pop(context);
        print('delete OK');
      }).catchError((error) {
        print("Failed to update user: $error");
        normalDialog(context, 'ผิดพลาด', 'โปรดลองใหม่อีกครั้ง');
      });
    } else {
      if ((_nameFood.text?.isEmpty ?? true) ||
          (_detailFood.text?.isEmpty ?? true) ||
          (_priceFood.text?.isEmpty ?? true)) {
        normalDialog(context, 'ข้อมูลไม่ครบ', 'โปรดกรอกข้อมูลสินค้าให้ครบ');
      } else {
        if (file != null) {
          await FirebaseStorage.instance
              .refFromURL(photoUrl)
              .delete()
              .then((value) {
            print("deleteComplete");
          });
          Random random = Random();
          int i = random.nextInt(100000);
          final _firebaseStorage = FirebaseStorage.instance;
          var snapshot = await _firebaseStorage
              .ref()
              .child('productPhoto/phoduct$i.jpg')
              .putFile(file);
          var downloadUrl = await snapshot.ref.getDownloadURL();
          photoUrl = downloadUrl;
          print('newphotoUrl' + photoUrl);
        }
      }

      CollectionReference products =
          FirebaseFirestore.instance.collection('products');
      await products.doc(productData.productId).update({
        'product_name': _nameFood.text,
        'product_detail': _detailFood.text,
        'product_price': _priceFood.text,
        'product_time': timeFood.toString(),
        'product_photoUrl': photoUrl
      }).then((value) {
        print('update OK');
        popupSelect = true;
        Navigator.pop(context);
      }).catchError((error) {
        print("Failed to update user: $error");
        normalDialog(context, 'ผิดพลาด', 'โปรดลองใหม่อีกครั้ง');
      });
    }
  }

  _addProduct(AppDataModel appDataModel) async {
    if ((_nameFood.text?.isEmpty ?? true) ||
        (_detailFood.text?.isEmpty ?? true) ||
        (_priceFood.text?.isEmpty ?? true)) {
      normalDialog(context, 'ข้อมูลไม่ครบ', 'โปรดกรอกข้อมูลสินค้าให้ครบ');
    } else {
      if (file == null) {
        normalDialog(context, 'ไม่มีรูปภาพ', 'โปรดเลือกรูปภาพประกอบสินค้า');
      } else {
        Random random = Random();
        int i = random.nextInt(100000);
        final _firebaseStorage = FirebaseStorage.instance;
        var snapshot = await _firebaseStorage
            .ref()
            .child('productPhoto/phoduct$i.jpg')
            .putFile(file);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        photoUrl = downloadUrl;
        print('photoUrl' + photoUrl);

        ProductModel productModel = ProductModel(
            shopUid: appDataModel.profileUid,
            productName: _nameFood.text,
            productPhotoUrl: photoUrl,
            productDetail: _detailFood.text,
            productPrice: _priceFood.text.toString(),
            productTime: timeFood.toString(),
            productStatus: '3');
        Map<String, dynamic> data = productModel.toJson();

        String docId;
        CollectionReference products =
            FirebaseFirestore.instance.collection('products');
        await products.add(data).then((value) async {
          print('doc Id = ' + value.id);
          docId = value.id.toString();
          await notifySend(appDataModel.notifyServer, appDataModel.adminToken,
              "สินค้าใหม่", "สินค้า " + _nameFood.text + " รอยืนยัน");
          await products
              .doc(docId)
              .update({'product_id': docId}).then((value) async {
            // await  normalDialog(context, 'สำเร็จ', 'เพิ่มสินค้าเรียบร้อยแล้ว');
            popupSelect = true;
            Navigator.pop(context);
          }).catchError((error) {
            print("Failed to update user: $error");
            normalDialog(context, 'ผิดพลาด', 'โปรดลองใหม่อีกครั้ง');
          });
        }).catchError((error) {
          print("Failed to update user: $error");
          normalDialog(context, 'ผิดพลาด', 'โปรดลองใหม่อีกครั้ง');
        });
      }
    }
  }
}
