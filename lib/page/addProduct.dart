import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/productModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/dialog.dart';
import 'package:hro/utility/notifySend.dart';
import 'package:hro/utility/regexText.dart';
import 'package:hro/utility/style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddProductPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddProductState();
  }
}

class AddProductState extends State<AddProductPage> {
  var _nameFood = TextEditingController();
  var _detailFood = TextEditingController();
  var _priceFood = TextEditingController();
  bool _nameCheck = false;
  bool _detailCheck = false;
  bool _priceCheck = false;

  int timeFood = 10;
  File file;
  String photoUrl = "";
  Dialogs dialogs = Dialogs();
  final picker = ImagePicker();

  bool updating = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: AppBar(
                  iconTheme: IconThemeData(color: Style().darkColor),
                  backgroundColor: Colors.white,
                  bottomOpacity: 0.0,
                  elevation: 0.0,
                  title: Style()
                      .textSizeColor('เพิ่มสินค้า', 18, Style().darkColor)),
              body: (updating == true)
                  ? Style().circularProgressIndicator(Style().darkColor)
                  : buildFrom(context.read<AppDataModel>()),
            ));
  }

  buildFrom(AppDataModel appDataModel) {
    return Container(child: StatefulBuilder(builder: (context, setState) {
      return SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: InkWell(
                        onTap: () async {
                          var result = await dialogs.photoSelect(context);
                          if (result == false) {
                            await chooseImage(ImageSource.camera);
                          } else if (result == true) {
                            await chooseImage(ImageSource.gallery);
                          }
                          setState(() {});
                          print("EditPhoto");
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 12.0,
                          child: Icon(
                            Icons.edit,
                            size: 15.0,
                            color: Colors.deepOrangeAccent,
                          ),
                        ),
                      ),
                    ),
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: (file != null)
                            ? FileImage(file)
                            : (photoUrl?.isEmpty ?? true)
                                ? AssetImage('assets/images/food_icon.png')
                                : NetworkImage(photoUrl),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                width: appDataModel.screenW * 0.9,
                child: TextField(
                  style: TextStyle(
                      fontFamily: "prompt",
                      fontSize: 16,
                      color: Style().textColor),
                  decoration: InputDecoration(
                      hintText: 'ชื่อสินค้า',
                      hintStyle: TextStyle(
                          fontFamily: "prompt",
                          fontSize: 14,
                          color: (onlyNumberRegex(_nameFood.text) == true)
                              ? Style().darkColor
                              : Colors.red),
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
                      suffixIcon: (textLengthRegex(_nameFood.text, 4))
                          ? Icon(
                              FontAwesomeIcons.solidCheckCircle,
                              color: Colors.green,
                            )
                          : Icon(
                              FontAwesomeIcons.solidTimesCircle,
                              color: Colors.red,
                            ),
                      filled: true,
                      fillColor: Color.fromRGBO(243, 244, 247, 1)),
                  controller: new TextEditingController.fromValue(
                      new TextEditingValue(
                          text: _nameFood.text,
                          selection: new TextSelection.collapsed(
                              offset: _nameFood.text.length))),
                  onChanged: (value) {
                    setState(() {
                      _nameCheck = textLengthRegex(_nameFood.text, 4);
                      _nameFood.text = value;
                    });
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                width: appDataModel.screenW * 0.9,
                child: TextField(
                  style: TextStyle(
                      fontFamily: "prompt",
                      fontSize: 16,
                      color: Style().textColor),
                  decoration: InputDecoration(
                      hintText: 'คำอธิบาย',
                      hintStyle: TextStyle(
                          fontFamily: "prompt",
                          fontSize: 14,
                          color: (onlyNumberRegex(_detailFood.text) == true)
                              ? Style().darkColor
                              : Colors.red),
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
                      suffixIcon: (textLengthRegex(_detailFood.text, 8))
                          ? Icon(
                              FontAwesomeIcons.solidCheckCircle,
                              color: Colors.green,
                            )
                          : Icon(
                              FontAwesomeIcons.solidTimesCircle,
                              color: Colors.red,
                            ),
                      filled: true,
                      fillColor: Color.fromRGBO(243, 244, 247, 1)),
                  controller: new TextEditingController.fromValue(
                      new TextEditingValue(
                          text: _detailFood.text,
                          selection: new TextSelection.collapsed(
                              offset: _detailFood.text.length))),
                  onChanged: (value) {
                    setState(() {
                      _detailCheck = textLengthRegex(_detailFood.text, 8);
                      print("detailCheck = " + _detailCheck.toString());
                      _detailFood.text = value;
                    });
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                width: appDataModel.screenW * 0.9,
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                      fontFamily: "prompt",
                      fontSize: 16,
                      color: Style().textColor),
                  decoration: InputDecoration(
                      hintText: 'ราคา',
                      hintStyle: TextStyle(
                          fontFamily: "prompt",
                          fontSize: 14,
                          color: (onlyNumberRegex(_priceFood.text) == true)
                              ? Style().darkColor
                              : Colors.red),
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
                      suffixIcon: (onlyNumberRegex(_priceFood.text))
                          ? Icon(
                              FontAwesomeIcons.solidCheckCircle,
                              color: Colors.green,
                            )
                          : Icon(
                              FontAwesomeIcons.solidTimesCircle,
                              color: Colors.red,
                            ),
                      filled: true,
                      fillColor: Color.fromRGBO(243, 244, 247, 1)),
                  controller: new TextEditingController.fromValue(
                      new TextEditingValue(
                          text: _priceFood.text,
                          selection: new TextSelection.collapsed(
                              offset: _priceFood.text.length))),
                  onChanged: (value) {
                    setState(() {
                      _priceCheck = onlyNumberRegex(_priceFood.text);
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
                    Style().textSizeColor('เวลาเตรียม', 16, Style().darkColor),
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
                    Style().textSizeColor('นาที', 16, Style().darkColor),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 5),
                    padding: EdgeInsets.all(1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          child:
                              Style().textSizeColor('ยกเลิก', 14, Colors.white),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.orange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 5),
                    padding: EdgeInsets.all(1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            _addProduct(context.read<AppDataModel>());
                          },
                          child: Style()
                              .textSizeColor('เพิ่มสินค้า', 14, Colors.white),
                          style: ElevatedButton.styleFrom(
                              primary: Style().darkColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      );
    }));
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

  _addProduct(AppDataModel appDataModel) async {
    setState(() {
      updating = true;
    });
    if ((_nameFood.text?.isEmpty ?? true) ||
        (_detailFood.text?.isEmpty ?? true) ||
        (_priceFood.text?.isEmpty ?? true)) {
      normalDialog(context, 'ข้อมูลไม่ครบ', 'โปรดกรอกข้อมูลสินค้าให้ครบ');
    } else {
      if (_nameCheck && _detailCheck && _priceCheck) {
        if (file == null) {
          normalDialog(context, 'ไม่มีรูปภาพ', 'โปรดเลือกรูปภาพประกอบสินค้า');
        } else {
          var result = await Dialogs().confirm(
              context,
              "เพิ่มสิ้นค้า",
              "ต้องการเพิ่มสิ้นค้า " + _nameFood.text + " ?",
              Icon(
                FontAwesomeIcons.questionCircle,
                color: Style().darkColor,
              ));
          if (result) {
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
              await products
                  .doc(docId)
                  .update({'product_id': docId}).then((value) async {
                // await  normalDialog(context, 'สำเร็จ', 'เพิ่มสินค้าเรียบร้อยแล้ว');

                Navigator.pop(context, true);
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
      } else {
        normalDialog(context, 'ข้อมูลไม่ถูกต้อง', 'โปรดตรวจสอบข้อมูลสินค้า');
      }
    }
    updating = false;
  }
}
