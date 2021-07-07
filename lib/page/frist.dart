import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/userModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/checkLocationService.dart';
import 'package:hro/utility/fireStore.dart';
import 'package:hro/utility/getAddressName.dart';
import 'package:hro/utility/getLocationData.dart';
import 'package:hro/utility/style.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' as Foundation;

import 'package:http/http.dart' as http;

class FirstPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FirstState();
  }
}

class FirstState extends State<FirstPage> {
  bool checkLogin = false;
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool checkLocation = false;
  bool inService = true;

  double distance, lat, lng;
  String distanceString;

  bool locationPermission = false;
  bool checkLocationSuccess = false;

  bool loginIn = false;

  double distanceLimit = 2.0;

  Future<Null> _getLocation(AppDataModel appDataModel) async {
    if (Foundation.kDebugMode) {
      print("App in debug mode");
    } else {
      print("App in release. mode");
    }
    LocationData locationData = await getLocationData();
    lat = locationData.latitude;
    lng = locationData.longitude;
    distance = calculateDistance(
        appDataModel.latStart, appDataModel.lngStart, lat, lng);
    var distanceFormat = NumberFormat('#0.0#', 'en_US');
    distanceString = distanceFormat.format(distance);
    print('ระยะ = $distanceString');
    checkLocation = true;
    if (distance > distanceLimit) {
      inService = false;
    } else {
      inService = true;
    }
    setState(() {
      checkLocationSuccess = true;
      print("inService = " + inService.toString());
    });
  }

  //google login//
  Future<Null> signInWithGoogle(AppDataModel appDataModel) async {
    print("googleLogin Start");
    await _getLocation(context.read<AppDataModel>());
    if (inService == false) {
      setState(() {
        checkLocationSuccess = true;
      });
    } else {
      final GoogleSignInAccount googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((value) async {
        appDataModel.profileEmail = value.user.email;
        appDataModel.profileName = value.user.displayName;
        appDataModel.profileUid = value.user.uid;
        appDataModel.profilePhotoUrl = value.user.photoURL;
        appDataModel.profilePhone = value.user.phoneNumber;
        appDataModel.profileEmailVerify = value.user.emailVerified;
        appDataModel.loginProvider = credential.providerId;
        _checkHaveUser(context.read<AppDataModel>());
      });
    }
  }

// facebook login
  Future<Null> signInWithFacebook(AppDataModel appDataModel) async {
    await _getLocation(context.read<AppDataModel>());
    if (inService == false) {
      setState(() {});
    } else {
      final FacebookLoginResult result = await facebookSignIn.logIn(['email']);
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final FacebookAccessToken accessToken = result.accessToken;
          String token = result.accessToken.token.toString();
          final facebookAuthCredential = FacebookAuthProvider.credential(token);
          await FirebaseAuth.instance
              .signInWithCredential(facebookAuthCredential)
              .then((value) async {
            appDataModel.profileEmail = value.user.email;
            appDataModel.profileName = value.user.displayName;
            appDataModel.profileUid = value.user.uid;
            appDataModel.profilePhotoUrl = value.user.photoURL;
            appDataModel.profilePhone = value.user.phoneNumber;
            appDataModel.profileEmailVerify = value.user.emailVerified;
            _checkHaveUser(context.read<AppDataModel>());
          });
          break;
        case FacebookLoginStatus.cancelledByUser:
          print('Login cancelled by the user.');
          break;
        case FacebookLoginStatus.error:
          print('Something went wrong with the login process.\n'
              'Here\'s the error Facebook gave us: ${result.errorMessage}');
          break;
      }
    }
  }

  _setScreen(AppDataModel appDataModel) {
    appDataModel.screenW = MediaQuery.of(context).size.width;
  }

  _checkLogin(AppDataModel appDataModel) async {
    var permission = await LocationPermissions().requestPermissions();
    print('location permission = ' + permission.toString());
    if (permission.toString() == "PermissionStatus.denied") {
      setState(() {
        locationPermission = false;
        checkLocationSuccess = true;
      });
    } else {
      locationPermission = true;
      await _getLocation(context.read<AppDataModel>());
      if (inService == false) {
        setState(() {
          checkLogin = true;
        });
      } else {
        final FirebaseAuth auth = await FirebaseAuth.instance;
        final User user = auth.currentUser;
        if (user != null) {
          appDataModel.profileUid = user.uid;
          CollectionReference users =
              FirebaseFirestore.instance.collection('users');
          await users.doc(appDataModel.profileUid).get().then((value) {
            print('checkLogin = ' + value['email']);
            UserModel userDataFinal =
                userModelFromJson(jsonEncode(value.data()));

            appDataModel.profileEmail = userDataFinal.email;
            appDataModel.profileName = userDataFinal.name;
            appDataModel.profilePhotoUrl = userDataFinal.photoUrl;
            appDataModel.profilePhone = userDataFinal.phone;
            appDataModel.profileStatus = userDataFinal.status;
            appDataModel.profileLocation = userDataFinal.location;
          }).catchError((error) {
            print('CheckLogin error = ' + error.toString());
          });

          Navigator.pushNamedAndRemoveUntil(
              context, '/home-page', (route) => false);
        } else {
          print("non login");
          setState(() {
            checkLocationSuccess = true;
            checkLogin = true;
          });
        }
      }
    }
  }

  _checkHaveUser(AppDataModel appDataModel) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users.doc(appDataModel.profileUid).get().then((value) {
      print('have User = ' + value['email']);
      UserModel userDataFinal = userModelFromJson(jsonEncode(value.data()));
      appDataModel.profileUid = userDataFinal.uid;
      appDataModel.profileEmail = userDataFinal.email;
      appDataModel.profileName = userDataFinal.name;
      appDataModel.profilePhotoUrl = userDataFinal.photoUrl;
      appDataModel.profilePhone = userDataFinal.phone;
      appDataModel.profileStatus = userDataFinal.status;
      appDataModel.profileLocation = userDataFinal.location;

      Navigator.pushNamedAndRemoveUntil(
          context, '/home-page', (route) => false);
    }).catchError((onError) async {
      print("error" + onError.toString());
      print('NotHaveUser = addNew');
      UserModel model = UserModel(
          uid: appDataModel.profileUid,
          name: appDataModel.profileName,
          phone: appDataModel.profilePhone,
          email: appDataModel.profileEmail,
          photoUrl: appDataModel.profilePhotoUrl,
          location: '0',
          status: '2');
      Map<String, dynamic> data = model.toJson();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(appDataModel.profileUid)
          .set(data)
          .then((value) {
        print('addNewUser complete');
        Navigator.pushNamedAndRemoveUntil(
            context, '/home-page', (route) => false);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    findLocation();
  }

  Future<Null> findLocation() async {
    bool locationService = await checkLocationService();
    if (locationService) {
      print("LocationService Open");
    } else {
      print("LocationService Close");
      Dialogs().alertLocationService(context);
    }
  }

  Widget build(BuildContext context) {
    _setScreen(context.read<AppDataModel>());

    if (checkLogin == false) _checkLogin(context.read<AppDataModel>());

    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              backgroundColor: Colors.white,
              body: (checkLocationSuccess == false)
                  ? Style().circularProgressIndicator(Style().darkColor)
                  : (locationPermission == false)
                      ? Container(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Style().titleH0("เฮาะ"),
                                Style().textDark("อากาศเดลิเวอรี่"),
                                Style().textSizeColor(
                                    "ไม่สามารถเข้าถึงตำแหน่งของคุณได้",
                                    16,
                                    Colors.deepOrange),
                                Image.asset("assets/images/map.png"),
                                Container(
                                  width: appDataModel.screenW * 0.9,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          checkLogin = false;
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            //color: Colors.redAccent,
                                            width:
                                                (appDataModel.screenW * 0.9) *
                                                    0.1,
                                          ),
                                          Container(
                                              //color: Colors.green,
                                              width:
                                                  (appDataModel.screenW * 0.9) *
                                                      0.8,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Style().textBlack54(
                                                      'อนุญาตให้เข้าถึงตำแหน่งมือถือ'),
                                                ],
                                              )),
                                        ],
                                      ),
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5)))),
                                ),
                              ],
                            ),
                          ),
                        )
                      : (checkLogin == true)
                          ? Container(
                              color: Colors.white,
                              // color: Style().primaryColor,
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Style().titleH0("เฮาะ"),
                                  Style().textDark("อากาศเดลิเวอรี่"),
                                  (inService == false)
                                      ? Column(
                                          children: [
                                            Container(
                                                child: Style().textSizeColor(
                                                    'คุณอยู่นอกพื้นที่ให้บริการ !!',
                                                    16,
                                                    Colors.deepOrange)),
                                            Container(
                                                child: Style().textSizeColor(
                                                    'ไม่เกิน $distanceLimit กิโลเมตรจากตัวอากาศ',
                                                    14,
                                                    Style().textColor))
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            // Container(
                                            //   margin: EdgeInsets.only(top: 50),
                                            //   width: appDataModel.screenW * 0.9,
                                            //   child: ElevatedButton(
                                            //       onPressed: () {
                                            //         signInWithFacebook(
                                            //             context.read<AppDataModel>());
                                            //       },
                                            //       child: Row(
                                            //         mainAxisAlignment:
                                            //             MainAxisAlignment.spaceEvenly,
                                            //         children: [
                                            //           Container(
                                            //             //   color: Colors.redAccent,
                                            //             width: (appDataModel.screenW *
                                            //                     0.9) *
                                            //                 0.1,
                                            //             child: Icon(
                                            //               FontAwesomeIcons.facebook,
                                            //               color: Colors.white,
                                            //               size: 20,
                                            //             ),
                                            //           ),
                                            //           Container(
                                            //               //color: Colors.green,
                                            //               width: (appDataModel.screenW *
                                            //                       0.9) *
                                            //                   0.8,
                                            //               child: Row(
                                            //                 mainAxisAlignment:
                                            //                     MainAxisAlignment
                                            //                         .center,
                                            //                 children: [
                                            //                   Style().textWhite(
                                            //                       'เข้าใช้งานด้วย Facebook'),
                                            //                 ],
                                            //               ))
                                            //         ],
                                            //       ),
                                            //       style: ElevatedButton.styleFrom(
                                            //           primary: Style().facebookColor,
                                            //           shape: RoundedRectangleBorder(
                                            //               borderRadius:
                                            //                   BorderRadius.circular(
                                            //                       5)))),
                                            // ),
                                            Container(
                                              width: appDataModel.screenW * 0.9,
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      loginIn = true;
                                                    });

                                                    signInWithGoogle(context
                                                        .read<AppDataModel>());
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      (loginIn == true)
                                                          ? Container()
                                                          : Container(
                                                              //color: Colors.redAccent,
                                                              width: (appDataModel
                                                                          .screenW *
                                                                      0.9) *
                                                                  0.1,
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/googleLogo.png',
                                                                height: 20,
                                                              ),
                                                            ),
                                                      Container(
                                                          //color: Colors.green,
                                                          width: (appDataModel
                                                                      .screenW *
                                                                  0.9) *
                                                              0.8,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              (loginIn == true)
                                                                  ? Style().circularProgressIndicator(
                                                                      Style()
                                                                          .darkColor)
                                                                  : Style()
                                                                      .textBlack54(
                                                                          'เข้าใช้งานด้วย Google'),
                                                            ],
                                                          )),
                                                    ],
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                      primary: Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)))),
                                            ),
                                            // Stack(
                                            //   alignment: Alignment.center,
                                            //   children: <Widget>[
                                            //     Column(
                                            //         mainAxisAlignment:
                                            //             MainAxisAlignment.center,
                                            //         children: <Widget>[
                                            //           Container(
                                            //               width: MediaQuery.of(context)
                                            //                       .size
                                            //                       .width *
                                            //                   0.9,
                                            //               height: 10),
                                            //           Container(
                                            //               width: MediaQuery.of(context)
                                            //                       .size
                                            //                       .width *
                                            //                   0.9,
                                            //               height: 1,
                                            //               color: Colors.grey),
                                            //           Container(
                                            //               width: MediaQuery.of(context)
                                            //                       .size
                                            //                       .width *
                                            //                   0.9,
                                            //               height: 10),
                                            //         ]),
                                            //     Container(
                                            //       width: 50,
                                            //       height: 50,
                                            //       decoration: BoxDecoration(
                                            //           color: Colors.white,
                                            //           shape: BoxShape.circle),
                                            //       child: Center(
                                            //           child: Style()
                                            //               .textBlackSmall('หรือ')),
                                            //     ),
                                            //   ],
                                            // ),
                                            // Container(
                                            //   width: appDataModel.screenW * 0.9,
                                            //   child: ElevatedButton(
                                            //       onPressed: () {
                                            //         Navigator.pushNamed(
                                            //             context, '/login-page');
                                            //       },
                                            //       child: Row(
                                            //         mainAxisAlignment:
                                            //             MainAxisAlignment.spaceEvenly,
                                            //         children: [
                                            //           Container(
                                            //             //   color: Colors.redAccent,
                                            //             width: (appDataModel.screenW *
                                            //                     0.9) *
                                            //                 0.1,
                                            //             child: Icon(
                                            //               Icons.email,
                                            //               color: Colors.white,
                                            //               size: 20,
                                            //             ),
                                            //           ),
                                            //           Container(
                                            //               //color: Colors.green,
                                            //               width: (appDataModel.screenW *
                                            //                       0.9) *
                                            //                   0.8,
                                            //               child: Row(
                                            //                 mainAxisAlignment:
                                            //                     MainAxisAlignment
                                            //                         .center,
                                            //                 children: [
                                            //                   Style().textWhite(
                                            //                       'เข้าใช้งานด้วย Email'),
                                            //                 ],
                                            //               ))
                                            //         ],
                                            //       ),
                                            //       style: ElevatedButton.styleFrom(
                                            //           primary: Style().emailColor,
                                            //           shape: RoundedRectangleBorder(
                                            //               borderRadius:
                                            //                   BorderRadius.circular(
                                            //                       5)))),
                                            // ),
                                          ],
                                        )
                                ],
                              )),
                            )
                          : Center(
                              child: Style().circularProgressIndicator(
                                  Style().darkColor)),
            ));
  }

  Future<Null> registerFirebase() async {
    await Firebase.initializeApp().then((value) {
      print('Connect Firebase Success');
    });
  }
}
