import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/productModel.dart';
import 'package:hro/model/productsModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/dialog.dart';
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

  _getProduct(AppDataModel appDataModel) async {
    var apiUrl = Uri.parse(appDataModel.server + '/products/shop_uid');
    print('getProductURL ' + apiUrl.toString());
    var responseGetProducts = await http.post(
      (apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'shop_uid': appDataModel.profileUid,
      }),
    );
    if (responseGetProducts.statusCode == 200) {
      var rowData = utf8.decode(responseGetProducts.bodyBytes);
      appDataModel.productsData = productsModelFromJson(rowData);
    }else{
      appDataModel.productsData = null;
    }
    setState(() {
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
                iconTheme: IconThemeData(color: Style().shopPrimaryColor),
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                title: Style().textSizeColor(
                    'รายการสินค้า', 18, Style().shopPrimaryColor),
                actions: [
                  IconButton(
                      icon: Icon(
                        FontAwesomeIcons.sync,
                        color: Style().shopPrimaryColor,
                      ),
                      onPressed: () {
                        getProductsStatus = false;
                        _getProduct(context.read<AppDataModel>());
                      }),
                  IconButton(
                      icon: Icon(
                        FontAwesomeIcons.plusCircle,
                        color: Style().shopPrimaryColor,
                      ),
                      onPressed: () async {
                        await _addMenuDialog(
                            Style().textSizeColor(
                                'เพิ่มสินค้าใหม่', 16, Style().textColor),
                            context.read<AppDataModel>());

                        if (popupSelect == true) {
                          getProductsStatus = false;
                          _getProduct(context.read<AppDataModel>());
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
                            padding:
                                EdgeInsets.only(left: 10, right: 10, top: 10),
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
        ? Column(
            children: _productsData.map((e) {
              int i = _productsData.indexOf(e);
              return Container(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Style().textBlackSize(
                                    'สินค้า : ' + _productsData[i].productName,
                                    14),
                                Style().textBlackSize(
                                    'รายละเอียด : ' +
                                        _productsData[i].productName,
                                    12),
                                Style().textBlackSize(
                                    'ราคา : ' +
                                        _productsData[i].productPrice +
                                        " ฿",
                                    14),
                                Style().textBlackSize(
                                    'เวลาเตรียม : ' +
                                        _productsData[i].productTime +
                                        ' นาที',
                                    14),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    IconButton(
                        icon: Icon(
                          FontAwesomeIcons.edit,
                          color: Colors.deepOrange,
                        ),
                        onPressed: () async {
                          await _updateMenuDialog(
                              Style().textSizeColor(
                                  'แก้ไขสินค้า', 16, Style().textColor),
                              context.read<AppDataModel>(),
                              i);

                          if (popupSelect == true) {
                            getProductsStatus = false;
                            _getProduct(context.read<AppDataModel>());
                          }
                        })
                  ],
                ),
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
                    child:
                        Style().textSizeColor('ยกเลิก', 14, Colors.blueAccent),
                    onPressed: () {
                      popupSelect = false;
                      Navigator.pop(context, false);
                    },
                  ),
                  new FlatButton(
                    child:
                        Style().textSizeColor('เพิ่ม', 14, Style().darkColor),
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
                      await _updateProduct(
                          context.read<AppDataModel>(), 'delete', _productData);
                      popupSelect = true;
                      Navigator.pop(context);
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
        print(file.toString());
      } else {
        print('No image selected.');
      }
    });
  }

  _updateProduct(
      AppDataModel appDataModel, String cmd, ProductModel productData) async {
    if (cmd == 'delete') {
      var bodyData;
      print("productid " + productData.productId.toString());
      bodyData = jsonEncode(<String, dynamic>{
        'product_id': productData.productId.toString(),
        'product_status': "0"
      });
      var responseUpdateProduct = await http.put(
        (Uri.parse(appDataModel.server + '/products/update')),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: bodyData,
      );

      if (responseUpdateProduct.statusCode == 200) {
        await dialogs.information(
            context,
            Style().textSizeColor('สำเร็จ', 16, Style().textColor),
            Style().textSizeColor(
                'แก้ไขสินค้าเรียบร้อยแล้ว', 14, Style().textColor));
        popupSelect = true;
      } else {
        print(responseUpdateProduct.statusCode.toString());
        await dialogs.information(
            context,
            Style().textSizeColor('ผิดพลาด', 16, Style().textColor),
            Style()
                .textSizeColor('โปลดลองใหม่อีกครั้ง', 14, Style().textColor));
        popupSelect = true;
        // Navigator.pop(context);
      }
    } else {
      if ((_nameFood.text?.isEmpty ?? true) ||
          (_detailFood.text?.isEmpty ?? true) ||
          (_priceFood.text?.isEmpty ?? true)) {
        normalDialog(context, 'ข้อมูลไม่ครบ', 'โปรดกรอกข้อมูลสินค้าให้ครบ');
      } else {
        if (file != null) {
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

      var responseUpdateProduct =
          await http.put((Uri.parse(appDataModel.server + '/products/update')),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(
                <String, String>{
                  "product_id": productData.productId.toString(),
                  "product_name": _nameFood.text,
                  "product_photoUrl": photoUrl,
                  "product_detail": _detailFood.text,
                  "product_price": _priceFood.text,
                  "product_time": timeFood.toString()
                },
              ));
      if (responseUpdateProduct.statusCode == 200) {
        await dialogs.information(
            context,
            Style().textSizeColor('สำเร็จ', 16, Style().textColor),
            Style().textSizeColor(
                'แก้ไขสินค้าเรียบร้อยแล้ว', 14, Style().textColor));
        popupSelect = true;
        Navigator.pop(context);
      } else {
        print(responseUpdateProduct.body.toString());
        await dialogs.information(
            context,
            Style().textSizeColor('ผิดพลาด', 16, Style().textColor),
            Style().textSizeColor(
                'เกิดข้อผิดพลาดโปรดลองใหม่อีกครั้ง', 14, Style().textColor));
      }
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

        var responseAddProduct = await http.post(
          (Uri.parse(appDataModel.server + '/products/add')),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            "shop_uid": appDataModel.profileUid,
            "product_name": _nameFood.text,
            "product_photoUrl": photoUrl,
            "product_detail": _detailFood.text,
            "product_price": _priceFood.text,
            "product_time": timeFood.toString(),
            "product_status": "1"
          }),
        );
        if (responseAddProduct.statusCode == 200) {
          await dialogs.information(
              context,
              Style().textSizeColor('สำเร็จ', 16, Style().textColor),
              Style().textSizeColor(
                  'เพิ่มสินค้าเรียบร้อยแล้ว', 14, Style().textColor));
          popupSelect = true;
          Navigator.pop(context);
        } else {
          await dialogs.information(
              context,
              Style().textSizeColor('ผิดพลาด', 16, Style().textColor),
              Style().textSizeColor(
                  'เกิดข้อผิดพลาดโปรดลองใหม่อีกครั้ง', 14, Style().textColor));
        }
      }
    }
  }
}
