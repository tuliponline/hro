import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/dialog.dart';
import 'package:hro/utility/getAddressName.dart';
import 'package:hro/utility/getLocationData.dart';
import 'package:hro/utility/notifySend.dart';
import 'package:hro/utility/style.dart';
import 'package:hro/utility/updateToken.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
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
    'จันทร์',
    'อังคาร',
    'พุธ',
    'พฤหัสบดี',
    'ศุกร์',
    'เสาร์',
    'อาทิตย์'
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

  double lat, lng;
  String addressName;

  Future<Null> _getLocation() async {
    LocationData locationData = await getLocationData();
    lat = locationData.latitude;
    lng = locationData.longitude;

    addressName = await getAddressName(lat, lng);
    shopLocation = '$lat,$lng';
    print('address = $addressName');
    setState(() {
      lat = locationData.latitude;
      lng = locationData.longitude;
      print('location = $lat,$lng');
    });
  }

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
    print('getshop' + shopTime);
    List<String> dateFull = shopTime.split(",");
    for (int i = 0; i < 7; i++) {
      List<String> statusTime = dateFull[i].split("/");
      (statusTime[0] == "open") ? days[i] = true : days[i] = false;
      List<String> openClose = statusTime[1].split('-');
      open[i] = openClose[0];
      close[i] = openClose[1];
    }
  }

  @override
  Widget build(BuildContext context) {

    cmdPage = ModalRoute.of(context).settings.arguments;
    if (lat == null || lng == null) _getLocation();

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
                            color: Style().darkColor,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      actions: [
                        Container(
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            width: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (shopTime?.isEmpty ?? true)
                                      shopTime =
                                      'open/8:0-21:20,open/8:00-20:00,open/8:00-20:00,open/8:00-20:00,open/8:00-20:00,open/8:00-20:00,open/8:0-6:45';
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
                                      primary: Style().darkColor,
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
              body: Container(
                child: ListView(
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 150,
                          width: appDataModel.screenW,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              fit: BoxFit.fitWidth,
                              image: (file == null)
                                  ? (shopPhotoUrl?.isEmpty ?? true)
                                      ? AssetImage(
                                          'assets/images/shop-icon.png')
                                      : NetworkImage(appDataModel.shopPhotoUrl)
                                  : FileImage(file),
                            ),
                          ),
                          child: InkWell(
                            onTap: () async {
                              var result = await dialogs.photoSelect(context);
                              if (result == false) {
                                chooseImage(ImageSource.camera);
                              } else if (result == true) {
                                chooseImage(ImageSource.gallery);
                              }
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
                        ),

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
        await _calTimeSave();
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
        if (shopTime?.isEmpty ?? true)
          shopTime =
              'open/8:0-21:20,open/8:00-20:00,open/8:00-20:00,open/8:00-20:00,open/8:00-20:00,open/8:00-20:00,open/8:0-6:45';
        if (shopPhotoUrl != null) {
          ShopModel model = ShopModel(
              shopUid: appDataModel.profileUid,
              shopName: shopName,
              shopPhotoUrl: shopPhotoUrl,
              shopType: shopType,
              shopPhone: shopPhone,
              shopAddress: shopAddress,
              shopLocation: '$lat,$lng',
              shopTime: shopTime,
              shopStatus: "3");
          Map<String, dynamic> data = model.toJson();
          await FirebaseFirestore.instance
              .collection('shops')
              .doc(appDataModel.profileUid)
              .set(data)
              .then((value) async {
            await updateToken(appDataModel.profileUid, appDataModel.token);
            print('addNewUser complete');
            await notifySend(appDataModel.notifyServer, appDataModel.adminToken, "ร้านค้าใหม่", "ร้าน " + shopName + " รอยืนยัน");
            await dialogs.information(
                context,
                Style().textSizeColor('สำเร็จ', 14, Style().textColor),
                Style().textSizeColor(
                    'เปิดร้านค้าเรียบร้อยแล้ว', 12, Style().textColor));

            Navigator.pushNamed(context, '/shop-page');
          }).catchError((onError) {
            normalDialog(context, 'ผิดพลาด', 'โปรดลองใหม่อีกครั้ง');
          });
        }
      } else {
        normalDialog(
            context, 'โปรดใส่รูปภาพหน้าปก', 'โปรดใส่รูปภาพหน้าปกของร้าน');
      }
    } else {
      if (file != null) {
        await FirebaseStorage.instance
            .refFromURL(shopPhotoUrl)
            .delete()
            .then((value) {
          print("deleteComplete");
        });

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
      }

      await _calTimeSave();
      print(shopTime);

      CollectionReference shops =
          FirebaseFirestore.instance.collection('shops');
      await shops.doc(appDataModel.profileUid).update({
        'shop_name': shopName,
        'shop_photo_Url': shopPhotoUrl,
        'shop_type': shopType,
        'shop_phone': shopPhone,
        'shop_address': shopAddress,
        'shop_location': '$lat,$lng',
        'shop_time': shopTime,
        'shop_status': shopStatus
      }).then((value)  async{
        await updateToken(appDataModel.profileUid, appDataModel.token);

        normalDialog(
            context, 'บันทึกสำเร็จ', 'ข้อมูลได้ถูกบันทึกเรียบร้อยแล้ว');
        setState(() {
          appDataModel.shopName = shopName;
          appDataModel.shopPhotoUrl = shopPhotoUrl;
          appDataModel.shopType = shopType;
          appDataModel.shopPhone = shopPhone;
          appDataModel.shopAddress = shopAddress;
          appDataModel.shopLocation = shopLocation;
          appDataModel.shopTime = shopTime;
          appDataModel.shopStatus = shopStatus;
          file = null;
          loading = false;
        });
      }).catchError((error) {
        print("Failed to update user: $error");
        normalDialog(context, 'ผิดพลาด', 'โปรดลองใหม่อีกครั้ง');
      });
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
                      var shopNewNameList = await dialogs.inputDialog(
                          context,
                          Style()
                              .textSizeColor('ชื่อร้าน', 14, Style().textColor),
                          'กรอกชื่อร้าน');
                      var shopNewName;
                      if (shopNewNameList[0] == true)
                        shopNewName = shopNewNameList[1].toString();

                      if (shopNewName != null && shopNewName != 'cancel') {
                        print('shopName ' + shopNewName);
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
                      var shopTypeNewList = await dialogs.inputDialog(
                          context,
                          Style().textSizeColor(
                              'ประเถทสินค้า', 14, Style().textColor),
                          'เช่น ตามสั่ง,ยำ,ก๋วยเตียว,เครื่องดื่ม');
                      var ShopTypeNew;
                      if (shopTypeNewList[0] == true)
                        ShopTypeNew = shopTypeNewList[1];
                      if (ShopTypeNew != null && ShopTypeNew != 'cancel') {
                        print('shopName ' + ShopTypeNew);
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
                      var ShopAddressNewList = await dialogs.inputDialog(
                          context,
                          Style().textSizeColor('ที่ตั้งร้าน *ระบุให้ชัดเจน',
                              14, Style().textColor),
                          'เช่น ข้างคิวรถฝั่งขวา,ตรงข้าม ธ.ออมสิน');
                      var ShopAddressNew;
                      if (ShopAddressNewList[0] == true)
                        ShopAddressNew = ShopAddressNewList[1];
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
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 5),
              child:
                  Style().textSizeColor('ตำแหน่งร้าน', 14, Style().textColor),
            ),
            (addressName == null)
                ? Container()
                : Container(
                    margin: EdgeInsets.only(left: 20, right: 20, bottom: 5),
                    child: Style()
                        .textSizeColor(addressName, 12, Style().textColor),
                  ),
            (lat == null || lng == null)
                ? Center(
                    child: Style().circularProgressIndicator(Style().darkColor),
                  )
                : showMap(),
          ],
        ));
  }

  Set<Marker> youMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId('youMarker'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: 'ตำแหน่งร้าน', snippet: addressName))
    ].toSet();
  }

  Container showMap() {
    LatLng firstLocation = LatLng(lat, lng);
    CameraPosition cameraPosition = CameraPosition(
      target: firstLocation,
      zoom: 16.0,
    );

    return Container(
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
        height: 200,
        child: GoogleMap(
          // myLocationEnabled: true,
          initialCameraPosition: cameraPosition,
          mapType: MapType.normal,
          onMapCreated: (controller) {},
          markers: youMarker(),
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
                                          disabledTime: TimeRange(
                                              startTime: TimeOfDay(
                                                  hour: 23, minute: 55),
                                              endTime: TimeOfDay(
                                                  hour: 00, minute: 5)),
                                          disabledColor:
                                              Colors.red.withOpacity(0.5),
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
