import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/dialog.dart';
import 'package:hro/utility/style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:http/http.dart' as http;

class ShopSetupPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ShopSetupState();
  }
}

class ShopSetupState extends State<ShopSetupPage> {
  Dialogs dialogs = Dialogs();

  bool loading = true;
  File file;
  final picker = ImagePicker();
  String cmdPage = 'OLD';

  String shopName,
      shopType,
      shopPhone,
      shopAddress,
      shopLocation,
      shopTime,
      shopPhotoUrl,
      shopStatus;
  List<String> daysName = [
    'อาทิตย์',
    'จันทร์',
    'อังคาร',
    'พุธ',
    'พฤหัสบดี',
    'ศุกร์',
    'เสาร์'
  ];
  List<bool> days = [true, true, true, true, true, true, true];
  List<String> open = ['8:00', '8:00', '8:00', '8:00', '8:00', '8:00', '8:00'];
  List<String> close = [
    '20:00',
    '20:00',
    '20:00',
    '20:00',
    '20:00',
    '20:00',
    '20:00'
  ];

  bool check = false;

  bool getShopDataStatus = false;
  ShopModel shopData;

  _getShopData(AppDataModel appDataModel) async {
    shopName = appDataModel.shopName;
    shopPhotoUrl = appDataModel.shopPhotoUrl;
    shopType = appDataModel.shopType;
    shopPhone = appDataModel.shopPhone;
    shopAddress = appDataModel.shopAddress;
    shopLocation = appDataModel.shopLocation;
    shopTime = appDataModel.shopTime;
    shopStatus = appDataModel.shopStatus;
    getShopDataStatus = true;
   print('getshop'+shopTime);
    List<String> dateFull = shopTime.split(",");
    for (int i = 0; i < 7; i++) {
      List<String> statusTime = dateFull[i].split("/");
      (statusTime[0] == "open") ? days[i] = true:days[i] = false;
      List <String> openClose = statusTime[1].split('-');
      open[i] = openClose[0];
      close[i] = openClose[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    shopStatus = "1";
    cmdPage = ModalRoute.of(context).settings.arguments;

    if (cmdPage == null && getShopDataStatus == false)
      _getShopData(context.read<AppDataModel>());

    print(cmdPage);
    loading = false;
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: (loading == true)
                  ? null
                  : AppBar(
                      backgroundColor: Colors.white,
                      bottomOpacity: 0.0,
                      elevation: 0.0,
                      leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Style().shopPrimaryColor,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ),
              body: Container(
                child: ListView(
                  children: [
                    Column(
                      children: [
                        Stack(children: [
                          Container(
                            margin: EdgeInsets.only(top: 48),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          Align(
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                child: CircleAvatar(
                                  radius: 40.0,
                                  backgroundColor: Style().shopPrimaryColor,
                                  child: CircleAvatar(
                                    child: InkWell(
                                      onTap: () {
                                        chooseImage(ImageSource.gallery);
                                      },
                                      child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 12.0,
                                          child: Icon(
                                            Icons.edit,
                                            size: 15.0,
                                            color: Color(0xFF404040),
                                          ),
                                        ),
                                      ),
                                    ),
                                    radius: 38.0,
                                    backgroundColor: Colors.white,
                                    backgroundImage: (file == null)
                                        ? (appDataModel.shopPhotoUrl?.isEmpty ??
                                                true)
                                            ? AssetImage(
                                                'assets/images/shop-icon.png')
                                            : NetworkImage(
                                                appDataModel.shopPhotoUrl)
                                        : FileImage(file),
                                  ),
                                ),
                              )),
                        ]),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: (shopName == null)
                              ? Container()
                              : Style().textBlackSize(shopName, 14),
                        ),
                        buildShopDetail(context.read<AppDataModel>()),
                        // buildUser(context.read<AppDataModel>()),
                        // buildPhone(context.read<AppDataModel>()),
                        // buildEmail(context.read<AppDataModel>()),
                        Container(
                          width: appDataModel.screenW * 0.9,
                          child: Container(
                            width: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if ((shopName?.isEmpty ?? true) ||
                                        (shopType?.isEmpty ?? true) ||
                                        (shopPhone?.isEmpty ?? true) ||
                                        (shopAddress?.isEmpty ?? true) ||
                                        (shopLocation?.isEmpty ?? true) ||
                                        (shopTime?.isEmpty ?? true)) {
                                      normalDialog(context, 'ข้อมูลไม่ครบ',
                                          'โปรดกรอกข้อมูลให้ครบทุกช่อง');
                                    } else {
                                      _saveShopData(
                                          context.read<AppDataModel>());
                                    }
                                  },
                                  child: Style().textSizeColor(
                                      'บันทึก', 14, Colors.white),
                                  style: ElevatedButton.styleFrom(
                                      primary: Style().shopPrimaryColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5))),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ));
  }

  _saveShopData(AppDataModel appDataModel) async {
    if (cmdPage == "NEW") {
      if (file != null) {
        Random random = Random();
        int i = random.nextInt(100000);
        final _firebaseStorage = FirebaseStorage.instance;
        var snapshot = await _firebaseStorage
            .ref()
            .child('/shopPhoto/shop$i.jpg')
            .putFile(file);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        shopPhotoUrl = downloadUrl;
        print(shopPhotoUrl);
        if (shopPhotoUrl != null) {
          var responseAddShop = await http.post(
            (Uri.parse(appDataModel.server + '/shops/add')),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              "shop_uid": appDataModel.profileUid,
              "shop_name": shopName,
              "shop_photo_Url": shopPhotoUrl,
              "shop_type": shopType,
              "shop_phone": shopPhone,
              "shop_address": shopAddress,
              "shop_location": shopLocation,
              "shop_time": shopTime,
              "shop_status": shopStatus
            }),
          );
          print(responseAddShop.body.toString());
          if (responseAddShop.statusCode == 200) {
            appDataModel.shopName = shopName;
            appDataModel.shopPhotoUrl = shopPhotoUrl;
            appDataModel.shopType = shopType;
            appDataModel.shopPhone = shopPhone;
            appDataModel.shopAddress = shopAddress;
            appDataModel.shopLocation = shopLocation;
            appDataModel.shopTime = shopTime;
            appDataModel.shopStatus = shopStatus;

            await dialogs.information(
                context,
                Style().textSizeColor('สำเร็จ', 14, Style().textColor),
                Style().textSizeColor(
                    'ร้านค้าพร้อมใช้งานแล้ว', 12, Style().textColor));
            Navigator.pushNamed(context, '/shop-page');
          } else {
            normalDialog(context, 'ผิดพลาด', 'โปรดลองใหม่อีกครั้ง');
          }
        }
      }
      normalDialog(
          context, 'โปรดใส่รูปภาพหน้าปก', 'โปรดใส่รูปภาพหน้าปกของร้าน');
    } else {
      if (file != null) {
        Random random = Random();
        int i = random.nextInt(100000);
        final _firebaseStorage = FirebaseStorage.instance;
        var snapshot = await _firebaseStorage
            .ref()
            .child('/shopPhoto/shop$i.jpg')
            .child('/shopPhoto/shop$i.jpg')
            .putFile(file);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        shopPhotoUrl = downloadUrl;
        print(shopPhotoUrl);
      }

      await _calTimeSave();
      print(shopTime);
      var apiUrl = Uri.parse(appDataModel.server + '/shops/update');
      print('update url = ' + apiUrl.toString());
      print('shop_uid = ' + appDataModel.profileUid);
      var responseUpdateShop = await http.put(
        (apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'shop_uid': appDataModel.profileUid,
          'shop_name': shopName,
          'shop_photo_Url': shopPhotoUrl,
          'shop_type': shopType,
          'shop_phone': shopPhone,
          'shop_address': shopAddress,
          'shop_location': shopLocation,
          'shop_time': shopTime,
          'shop_status': shopStatus
        }),
      );
      print(responseUpdateShop.statusCode.toString());
      if (responseUpdateShop.statusCode == 200) {
        appDataModel.shopName = shopName;
        appDataModel.shopPhotoUrl = shopPhotoUrl;
        appDataModel.shopType = shopType;
        appDataModel.shopPhone = shopPhone;
        appDataModel.shopAddress = shopAddress;
        appDataModel.shopLocation = shopLocation;
        appDataModel.shopTime = shopTime;
        appDataModel.shopStatus = shopStatus;

        dialogs.information(
            context,
            Style().textSizeColor('สำเร็จ', 16, Style().textColor),
            Style().textSizeColor(
                'อัพเดทข้อมูลร้านค้าแล้ว', 14, Style().textColor));
      }
    }
  }

  _calTimeSave() {
    String timeSave = "";
    daysName.map((e) {
      int index = daysName.indexOf(e);

      String status = 'close';
      (days[index] == true) ? status = 'open' : status = 'close';
      timeSave += status + "/" + open[index] + "-" + close[index] + ',';
    }).toList();
    shopTime = timeSave;
  }

  Container buildShopDetail(AppDataModel appDataModel) {
    return Container(
        width: appDataModel.screenW * 0.9,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Style().textSizeColor('ชื่อร้าน', 12, Style().textColor),
                    (shopName == null)
                        ? Container()
                        : Style().textSizeColor(shopName, 16, Style().textColor)
                  ],
                ),
                IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () async {
                      var shopNewName = await dialogs.inputDialog(
                          context,
                          Style()
                              .textSizeColor('ชื่อร้าน', 14, Style().textColor),
                          'กรอกชื่อร้าน');
                      print('shopName ' + shopNewName);
                      if (shopNewName != null && shopNewName != 'cancel') {
                        setState(() {
                          shopName = shopNewName;
                        });
                      }
                    }),
              ],
            ),
            Container(
                margin: EdgeInsets.all(1),
                child: Divider(
                  color: Colors.grey,
                  height: 0,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Style()
                        .textSizeColor('ประเภทสินค้า', 12, Style().textColor),
                    (shopType == null)
                        ? Container()
                        : Style().textSizeColor(shopType, 16, Style().textColor)
                  ],
                ),
                IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () async {
                      var ShopTypeNew = await dialogs.inputDialog(
                          context,
                          Style().textSizeColor(
                              'ประเถทสินค้า', 14, Style().textColor),
                          'เช่น ตามสั่ง,ยำ,ก๋วยเตียว,เครื่องดื่ม');
                      print('shopName ' + ShopTypeNew);
                      if (ShopTypeNew != null && ShopTypeNew != 'cancel') {
                        setState(() {
                          shopType = ShopTypeNew;
                        });
                      }
                    }),
              ],
            ),
            Container(
                margin: EdgeInsets.all(1),
                child: Divider(
                  color: Colors.grey,
                  height: 0,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Style().textSizeColor('เบอร์โทร', 12, Style().textColor),
                    (shopPhone == null)
                        ? Container()
                        : Style()
                            .textSizeColor(shopPhone, 16, Style().textColor)
                  ],
                ),
                IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () async {
                      String shopNewPhone = await dialogs.inputPhoneDialog(
                          context,
                          Style().textSizeColor(
                              'หมายเลขโทรศัพท์', 14, Style().textColor),
                          'กรอกหมายเลขโทรศัพท 10หลัก');
                      if (shopNewPhone != null && shopNewPhone != 'cancel') {
                        setState(() {
                          shopPhone = shopNewPhone;
                        });
                      }
                    }),
              ],
            ),
            Container(
                margin: EdgeInsets.all(1),
                child: Divider(
                  color: Colors.grey,
                  height: 0,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Style().textSizeColor('ที่ตั้ง', 12, Style().textColor),
                    (shopAddress == null)
                        ? Container()
                        : Style()
                            .textSizeColor(shopAddress, 16, Style().textColor)
                  ],
                ),
                IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () async {
                      var ShopAddressNew = await dialogs.inputDialog(
                          context,
                          Style().textSizeColor('ที่ตั้งร้าน *ระบุให้ชัดเจน',
                              14, Style().textColor),
                          'เช่น ข้างคิวรถฝั่งขวา,ตรงข้าม ธ.ออมสิน');
                      print('shopName ' + ShopAddressNew);
                      if (ShopAddressNew != null &&
                          ShopAddressNew != 'cancel') {
                        setState(() {
                          shopAddress = ShopAddressNew;
                        });
                      }
                    }),
              ],
            ),
            Container(
                margin: EdgeInsets.all(1),
                child: Divider(
                  color: Colors.grey,
                  height: 0,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Style().textSizeColor('Location', 12, Style().textColor),
                    (shopLocation == null)
                        ? Container()
                        : Style()
                            .textSizeColor(shopLocation, 16, Style().textColor)
                  ],
                ),
                IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () async {
                      var shopLocationNew = await dialogs.inputDialog(
                          context,
                          Style().textSizeColor(
                              'ระบุ Location ร้าน', 14, Style().textColor),
                          'ปักหมุด location');
                      print('shopName ' + shopLocationNew);
                      if (shopLocationNew != null &&
                          shopLocationNew != 'cancel') {
                        setState(() {
                          shopLocation = shopLocationNew;
                        });
                      }
                    }),
              ],
            ),
            Container(
                margin: EdgeInsets.all(1),
                child: Divider(
                  color: Colors.grey,
                  height: 0,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Style()
                        .textSizeColor('เวลา เปิด-ปิด', 16, Style().textColor),
                  ],
                ),
                IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () {
                      _timeOpenDialog(Style().textSizeColor(
                          'ระบบเวลา เปิด-ปิด ร้าน', 14, Style().textColor));
                    }),
              ],
            ),
            Container(
                margin: EdgeInsets.all(1),
                child: Divider(
                  color: Colors.grey,
                  height: 0,
                )),
          ],
        ));
  }

  Future<void> chooseImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(
        source: imageSource, maxWidth: 800, maxHeight: 800);

    setState(() {
      if (pickedFile != null) {
        file = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _timeOpenDialog(Text title) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: title,
              content: Container(
                height: 350,
                child: Column(
                  children: daysName.map((e) {
                    int index = daysName.indexOf(e);
                    List<String> openList = open[index].split(":");
                    List<String> closeList = close[index].split(":");
                    return Row(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 45,
                              child: Style().textSizeColor(
                                  daysName[index], 12, Style().textColor),
                            ),
                            Checkbox(
                                value: days[index],
                                onChanged: (value) {
                                  setState(() {
                                    days[index] = value;
                                    print(days[index]);
                                  });
                                }),
                          ],
                        ),
                        (days[index] == true)
                            ? Row(
                                children: [
                                  Style().textSizeColor(
                                      'เปิด ', 12, Style().textColor),
                                  Style().textSizeColor(
                                      open[index], 12, Style().shopDarkColor),
                                  Style().textSizeColor(
                                      '/ ปิด ', 12, Style().textColor),
                                  Style().textSizeColor(
                                      close[index], 12, Style().shopDarkColor),
                                  IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        TimeRange result =
                                            await showTimeRangePicker(
                                          context: context,
                                          fromText: 'เวลาเปิด',
                                          toText: 'เวลาปิด',
                                          paintingStyle: PaintingStyle.fill,
                                          start: TimeOfDay(
                                              hour: (int.parse(openList[0])),
                                              minute: (int.parse(openList[1]))),
                                          end: TimeOfDay(
                                              hour: (int.parse(closeList[0])),
                                              minute:
                                                  (int.parse(closeList[1]))),
                                        );
                                        setState(() {
                                          open[index] =
                                              result.startTime.hour.toString() +
                                                  ":" +
                                                  result.startTime.minute
                                                      .toString();
                                          close[index] = result.endTime.hour
                                                  .toString() +
                                              ":" +
                                              result.endTime.minute.toString();
                                          shopTime =
                                              result.endTime.minute.toString();
                                        });
                                      })
                                ],
                              )
                            : Row(
                                children: [Text('')],
                              )
                      ],
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('ยกเลิก'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text('ตกลง'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
        });
  }
}
