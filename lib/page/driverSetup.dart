import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/dialog.dart';
import 'package:hro/utility/getAddressName.dart';
import 'package:hro/utility/getLocationData.dart';
import 'package:hro/utility/getTimeNow.dart';
import 'package:hro/utility/notifySend.dart';
import 'package:hro/utility/style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:time_range_picker/time_range_picker.dart';

class DriverSetupPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DriverSetupState();
  }
}

class DriverSetupState extends State<DriverSetupPage> {
  Dialogs dialogs = Dialogs();

  File file;
  final picker = ImagePicker();
  String cmdPage ;

  DriversModel driversModel;
  String uid;

  DriversModel driverData;
  ShopModel shopData;

  String name, phone, address, location, status, photoUrl;
  bool check = false;
  bool getDriverDataStatus = false;

  String addressName;
  double lat, lng;

  Future<Null> _getLocation() async {
    LocationData locationData = await getLocationData();
    lat = locationData.latitude;
    lng = locationData.longitude;
    addressName = await getAddressName(lat, lng);
    setState(() {
      lat = locationData.latitude;
      lng = locationData.longitude;
    });
  }

  _getShopData(AppDataModel appDataModel) async {
    uid = appDataModel.profileUid;
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(uid)
        .get()
        .then((value) {
      driversModel = driversModelFromJson(jsonEncode(value.data()));
      print('name= ' + driversModel.driverName);
      name = driversModel.driverName.toString();
      phone = driversModel.driverPhone.toString();
      address = driversModel.driverAddress.toString();
      location = driversModel.driverLocation.toString();
      status = driversModel.driverStatus.toString();
      photoUrl = driversModel.driverPhotoUrl.toString();
    });

    setState(() {
      getDriverDataStatus = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    status = "0";
     cmdPage = ModalRoute.of(context).settings.arguments;
   // cmdPage = "NEW";
    print('cmdPage = ' + cmdPage);
    if (lat == null && lng == null) _getLocation();
    if (cmdPage == "OLD" && getDriverDataStatus == false)
      _getShopData(context.read<AppDataModel>());

    print('test' + driversModel.toString());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: (cmdPage == 'NEW' || driversModel != null)
                  ? AppBar(
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
                          }),actions: [  Container(

                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  width: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if ((name?.isEmpty ?? true) ||
                              (phone?.isEmpty ?? true) ||
                              (address?.isEmpty ?? true) ||
                              (location?.isEmpty ?? true) ||
                              (status?.isEmpty ?? true)) {
                            normalDialog(
                                context,
                                'ข้อมูลไม่ครบ',
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
              )],
                    ):null,
              body: Container(
                child: (cmdPage == 'NEW' || driversModel != null)
                    ? ListView(
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
                                        backgroundColor:
                                            Style().drivePrimaryColor,
                                        child: CircleAvatar(
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
                                          radius: 38.0,
                                          backgroundColor: Colors.white,
                                          backgroundImage: (file == null)
                                              ? (photoUrl?.isEmpty ?? true)
                                                  ? AssetImage(
                                                      'assets/images/shop-icon.png')
                                                  : NetworkImage(photoUrl)
                                              : FileImage(file),
                                        ),
                                      ),
                                    )),
                              ]),
                              buildShopDetail(context.read<AppDataModel>()),

                            ],
                          ),
                        ],
                      ):Center(
                  child: Style().circularProgressIndicator(
                      Style().drivePrimaryColor),
                ),
              ),
            ));
  }

  _saveShopData(AppDataModel appDataModel) async {
    var onlineTime = await getTimeStampNow();
    if (cmdPage == "NEW") {
      if (file != null) {
        Random random = Random();
        int i = random.nextInt(100000);
        final _firebaseStorage = FirebaseStorage.instance;
        var snapshot = await _firebaseStorage
            .ref()
            .child('/driversPhoto/driver$i.jpg')
            .putFile(file);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        photoUrl = downloadUrl;

        if (photoUrl != null) {
          driverData = DriversModel(
            driverId: appDataModel.profileUid,
            driverName: name.toString(),
            driverPhone: phone,
            driverAddress: address,
            driverLocation: '$lat,$lng',
            driverStatus: '3',
            driverPhotoUrl: photoUrl,
            onlineTime: onlineTime,
          );
          Map<String, dynamic> data = driverData.toJson();
          await FirebaseFirestore.instance
              .collection('drivers')
              .doc(appDataModel.profileUid)
              .set(data)
              .then((value) async {
            print('addNewDriver complete');
            await notifySend(appDataModel.notifyServer, appDataModel.adminToken, "Riderใหม่", "Rider " + name + " รอยืนยัน");
            await dialogs.information(
                context,
                Style().textSizeColor('สำเร็จ', 14, Style().textColor),
                Style().textSizeColor(
                    'สมัครพนักงานขับรถเรียบร้อยแล้ว', 12, Style().textColor));
            getDriverDataStatus = false;
            appDataModel.driverData = driverData;
            Navigator.pushNamed(context, '/driver-page');
          }).catchError((onError) {
            print('error = ' + onError.toString());
            normalDialog(context, 'ผิดพลาด', 'โปรดลองใหม่อีกครั้ง');
          });
        }
      } else {
        normalDialog(context, 'โปรดใส่รูปภาพ', 'โปรดใส่รูปภาพของคุณ');
      }
    } else {
      if (file != null) {
        await FirebaseStorage.instance.refFromURL(photoUrl).delete().then((value){
          print('Delete PhotoComplete');
        });
        Random random = Random();
        int i = random.nextInt(100000);
        final _firebaseStorage = FirebaseStorage.instance;
        var snapshot = await _firebaseStorage
            .ref()
            .child('/driversPhoto/driver$i.jpg')
            .putFile(file);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        print('download = ' + downloadUrl);
        photoUrl = downloadUrl;
      }

      driverData = DriversModel(
          driverName: name.toString(),
          driverPhone: phone,
          driverAddress: address,
          driverLocation: '$lat,$lng',
          driverPhotoUrl: photoUrl,
          driverId: uid,
          driverStatus: driversModel.driverStatus,
          onlineTime: driversModel.onlineTime);
      Map<String, dynamic> data = driverData.toJson();

      CollectionReference drivers =
          FirebaseFirestore.instance.collection('drivers');
      await drivers.doc(appDataModel.profileUid).update(data).then((value) {
        normalDialog(
            context, 'บันทึกสำเร็จ', 'ข้อมูลได้ถูกบันทึกเรียบร้อยแล้ว');
        setState(() {
          getDriverDataStatus = false;
          appDataModel.driverData = driverData;
          file = null;
          getDriverDataStatus = false;
        });
      }).catchError((error) {
        print("Failed to update user: $error");
        normalDialog(context, 'ผิดพลาด', 'โปรดลองใหม่อีกครั้ง');
      });
    }
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
                    Style().textSizeColor('ชื่อ-สกุล', 12, Style().textColor),
                    (name == null)
                        ? Container()
                        : Style().textSizeColor(name, 16, Style().textColor)
                  ],
                ),
                IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () async {
                      var nameNewList = await dialogs.inputDialog(
                          context,
                          Style().textSizeColor(
                              'ชื่อ-สกุล', 14, Style().textColor),
                          'กรอกชื่อรและนามสกุลของคุณ');

                      var nameNew ;
                      if(nameNewList[0] == true) nameNew = nameNewList[1];
                      if (nameNew != null && nameNew != 'cancel') {
                        setState(() {
                          name = nameNew;
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
                    Style().textSizeColor(
                        'หมายเลขโทรศัพท์', 12, Style().textColor),
                    (phone == null)
                        ? Container()
                        : Style().textSizeColor(phone, 16, Style().textColor)
                  ],
                ),
                IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () async {
                      var phoneNew = await dialogs.inputPhoneDialog(
                          context,
                          Style().textSizeColor(
                              'หมายเลขโทรศัพท์', 14, Style().textColor),
                          'กรอกหมายเลขมือถือ 10หลัก');
                      //print('shopName ' + ShopTypeNew);
                      if (phoneNew != null && phoneNew != 'cancel') {
                        setState(() {
                          phone = phoneNew;
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
                    Style().textSizeColor('ที่อยู่', 12, Style().textColor),
                    (address == null)
                        ? Container()
                        : Style().textSizeColor(address, 16, Style().textColor)
                  ],
                ),
                IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () async {
                      var addressNewList = await dialogs.inputDialog(
                          context,
                          Style()
                              .textSizeColor('ที่อยู่', 14, Style().textColor),
                          'ที่อยู่ตามบัตรประชาชน');

                      var addressNew;
                      if( addressNewList[0] == true) addressNew = addressNewList[1];

                      if (addressNew != null && addressNew != 'cancel') {
                        setState(() {
                          address = addressNew;
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
                  Style().textSizeColor('ตำแหน่งของคุณ', 14, Style().textColor),
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

  Container showMap() {
    LatLng firstLocation = LatLng(lat, lng);
    CameraPosition cameraPosition = CameraPosition(
      target: firstLocation,
      zoom: 16.0,
    );
    if (lat != null && lng != null) location = "$lat,$lng";

    return Container(
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
        height: 200,
        child: GoogleMap(
          myLocationEnabled: true,
          initialCameraPosition: cameraPosition,
          mapType: MapType.normal,
          onMapCreated: (controller) {},
          //markers: youMarker(),
        ));
  }

  Future<void> chooseImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(
        source: imageSource, maxWidth: 600, maxHeight: 600);

    setState(() {
      if (pickedFile != null) {
        file = File(pickedFile.path);
        print('image = ' + file.path.toString());
      } else {
        print('No image selected.');
      }
    });
  }
}
