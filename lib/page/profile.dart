import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/dialog.dart';
import 'package:hro/utility/getAddressName.dart';
import 'package:hro/utility/getLocationData.dart';
import 'package:hro/utility/regexText.dart';
import 'package:hro/utility/style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ProfileState();
  }
}

class ProfileState extends State<ProfilePage> {
  var _nameController = TextEditingController();
  var _phoneController = TextEditingController();
  var _emailController = TextEditingController();
  FocusNode myFocusNode = new FocusNode();
  bool checkNameRegX = false;
  bool checkEmailRegX = false;
  bool checkPhoneRegX = false;
  bool setDataStatus = false;
  File file;

  bool loading = true;

  final picker = ImagePicker();

  String photoUrl;

  double lat, lng;
  String addressName;

  Dialogs dialogs = Dialogs();

  _setDataProfile(AppDataModel appDataModel) {
    _nameController.text = appDataModel.profileName;
    _phoneController.text = appDataModel.profilePhone;
    _emailController.text = appDataModel.profileEmail;

    checkNameRegX = textLengthRegex(_nameController.text, 8);
    checkPhoneRegX = phoneRegex(_phoneController.text);
    checkEmailRegX = emailRegex(_emailController.text);

    setDataStatus = true;
    loading = false;
  }

  Future<Null> findLocation() async {
    LocationData locationData = await getLocationData();
    lat = locationData.latitude;
    lng = locationData.longitude;

    addressName = await getAddressName(lat, lng);
    print('address = $addressName');
    setState(() {
      lat = locationData.latitude;
      lng = locationData.longitude;
      print('location = $lat,$lng');
    });
  }

  Widget build(BuildContext context) {
    if (lat == null || lng == null) findLocation();
    if (setDataStatus == false) _setDataProfile(context.read<AppDataModel>());
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
                                    (checkEmailRegX &&
                                            checkNameRegX &&
                                            checkPhoneRegX)
                                        ? updateProfile(
                                            context.read<AppDataModel>())
                                        : normalDialog(
                                            context,
                                            'ข้อมูลไม่ถูกต้อง',
                                            'โปรดตรวจสอบข้อมูล');
                                  },
                                  child: Style().titleH3('บันทึก'),
                                  style: ElevatedButton.styleFrom(
                                      primary: Style().primaryColor,
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
              body: (loading == true)
                  ? Style().circularProgressIndicator(Style().darkColor)
                  : Container(
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
                                        backgroundColor: Style().primaryColor,
                                        child: CircleAvatar(
                                          child: InkWell(
                                            onTap: () {
                                              chooseImage(ImageSource.camera);
                                            },
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: CircleAvatar(
                                                backgroundColor: Colors.white,
                                                radius: 12.0,
                                                child: Icon(
                                                  Icons.camera_alt,
                                                  size: 15.0,
                                                  color: Color(0xFF404040),
                                                ),
                                              ),
                                            ),
                                          ),
                                          radius: 38.0,
                                          backgroundColor: Colors.white,
                                          backgroundImage: (file == null)
                                              ? (appDataModel.profilePhotoUrl
                                                          ?.isEmpty ??
                                                      true)
                                                  ? AssetImage(
                                                      'assets/images/person-icon.png')
                                                  : NetworkImage(appDataModel
                                                      .profilePhotoUrl)
                                              : FileImage(file),
                                        ),
                                      ),
                                    )),
                              ]),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Style().textBlackSize(
                                    appDataModel.profileName, 14),
                              ),
                              buildUser(context.read<AppDataModel>()),
                              buildPhone(context.read<AppDataModel>()),
                              buildEmail(context.read<AppDataModel>()),
                              Container(
                                margin: EdgeInsets.only(top: 10, bottom: 5),
                                child: Style().textSizeColor(
                                    'ตําแหน่งของคุณ', 14, Style().textColor),
                              ),
                              (addressName == null)
                                  ? Container()
                                  : Container(
                                      margin: EdgeInsets.only(
                                          left: 20, right: 20, bottom: 5),
                                      child: Style().textSizeColor(
                                          addressName, 12, Style().textColor),
                                    ),
                              (lat == null || lng == null)
                                  ? Center(
                                      child: Style().circularProgressIndicator(
                                          Style().darkColor),
                                    )
                                  : showMap(),
                              (lat != null || lng != null)
                                  ? Container()
                                  : Container()
                            ],
                          ),
                        ],
                      ),
                    ),
            ));
  }

  Set<Marker> youMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId('youMarker'),
          position: LatLng(lat, lng),
          infoWindow:
              InfoWindow(title: 'ตําแหน่งของคุณ', snippet: 'TestDetail'))
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
          myLocationEnabled: true,
          initialCameraPosition: cameraPosition,
          mapType: MapType.normal,
          onMapCreated: (controller) {},
          // markers: youMarker(),
        ));
  }

  Container buildUser(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: appDataModel.screenW * 0.9,
      height: 40,
      child: TextField(
        style: TextStyle(fontSize: 14),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            suffixIcon: (checkNameRegX == true)
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
                borderSide: BorderSide(color: Style().labelColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            labelText: "ชื่อ",
            labelStyle: TextStyle(
                fontFamily: "prompt",
                fontSize: 14,
                color:
                    (checkNameRegX == true) ? Style().darkColor : Colors.red)),
        controller: new TextEditingController.fromValue(new TextEditingValue(
            text: _nameController.text,
            selection: new TextSelection.collapsed(
                offset: _nameController.text.length))),
        onChanged: (value) {
          setState(() {
            _nameController.text = value;
            checkNameRegX = textLengthRegex(_nameController.text, 8);
          });
        },
      ),
    );
  }

  Container buildPhone(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: appDataModel.screenW * 0.9,
      height: 40,
      child: TextField(
        style: TextStyle(fontSize: 14),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            suffixIcon: (checkPhoneRegX == true)
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
                borderSide: BorderSide(color: Style().labelColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            labelText: "หมายเลขโทรศัพท์",
            labelStyle: TextStyle(
                fontFamily: "prompt",
                fontSize: 14,
                color:
                    (checkPhoneRegX == true) ? Style().darkColor : Colors.red)),
        controller: new TextEditingController.fromValue(new TextEditingValue(
            text: _phoneController.text,
            selection: new TextSelection.collapsed(
                offset: _phoneController.text.length))),
        onChanged: (value) {
          setState(() {
            _phoneController.text = value;
            checkPhoneRegX = phoneRegex(_phoneController.text);
          });
        },
      ),
    );
  }

  Container buildEmail(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: appDataModel.screenW * 0.9,
      height: 40,
      child: TextField(
        style: TextStyle(fontSize: 14),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            suffixIcon: (checkEmailRegX == true)
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
                borderSide: BorderSide(color: Style().labelColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            labelText: "Email",
            labelStyle: TextStyle(
                fontFamily: "prompt",
                fontSize: 14,
                color:
                    (checkEmailRegX == true) ? Style().darkColor : Colors.red)),
        controller: new TextEditingController.fromValue(new TextEditingValue(
            text: _emailController.text,
            selection: new TextSelection.collapsed(
                offset: _emailController.text.length))),
        onChanged: (value) {
          setState(() {
            _emailController.text = value;
            emailRegex(_emailController.text);
          });
        },
      ),
    );
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

  Future<Null> updateProfile(AppDataModel appDataModel) async {
    var result = await dialogs.confirm(context, "แก้ไขข้อมูล",
        "บันทึกข้อมูลบัญชี ?", Icon(FontAwesomeIcons.question));

    if (result != null && result == true) {
      photoUrl = appDataModel.profilePhotoUrl;
      print('photoUrl = ' + photoUrl);
      if (file != null) {
        if (photoUrl != null) {
          if (photoUrl.contains("firebasestorage")) {
            await FirebaseStorage.instance
                .refFromURL(photoUrl)
                .delete()
                .then((value) {
              print("deleteComplete");
            });
          } else {
            print("Not delete");
          }
        }

        Random random = Random();
        int i = random.nextInt(100000);
        final _firebaseStorage = FirebaseStorage.instance;
        var snapshot = await _firebaseStorage
            .ref()
            .child('profile_picture/profile$i.jpg')
            .putFile(file);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        photoUrl = downloadUrl;
        appDataModel.profilePhotoUrl = photoUrl;
      }

      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      await users.doc(appDataModel.profileUid).update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'photo_url': photoUrl,
        'location': '$lat,$lng'
      }).then((value) {
        normalDialog(
            context, 'บันทึกสำเร็จ', 'ข้อมูลได้ถูกบันทึกเรียบร้อยแล้ว');
        setState(() {
          appDataModel.profileName = _nameController.text;
          appDataModel.profilePhone = _phoneController.text;
          appDataModel.profilePhotoUrl = photoUrl;
          appDataModel.profileEmail = _emailController.text;
          file = null;
          loading = false;
        });
      }).catchError((error) {
        print("Failed to update user: $error");
        normalDialog(context, 'ผิดพลาด', 'โปรดลองใหม่อีกครั้ง');
      });
    }
  }
}
