import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/userModel.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  String _message = 'Log in/out by pressing the buttons below.';

  //google login//
  Future<Null> signInWithGoogle(AppDataModel appDataModel) async {
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    await FirebaseAuth.instance.signInWithCredential(credential).then((value)  async{
      appDataModel.profileEmail = value.user.email;
      appDataModel.profileName = value.user.displayName;
      appDataModel.profileUid = value.user.uid;
      appDataModel.profilePhotoUrl = value.user.photoURL;
      appDataModel.profilePhone = value.user.phoneNumber;
      appDataModel.profileEmailVerify = value.user.emailVerified;
       _checkHaveUser(context.read<AppDataModel>());

    }
    );
  }

// facebook login
  Future<Null> signInWithFacebook(AppDataModel appDataModel) async {
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

          // Navigator.pushNamedAndRemoveUntil(
          //     context, '/home-page', (route) => false);
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

  _setScreen(AppDataModel appDataModel) {
    appDataModel.screenW = MediaQuery.of(context).size.width;
  }

  _checkLogin(AppDataModel appDataModel) async {
    await FirebaseAuth.instance.authStateChanges().listen((event) async{
      if (event != null) {
        appDataModel.profileUid = event.uid;
        appDataModel.profileEmail = event.email;
        appDataModel.profileName = event.displayName;
        appDataModel.profilePhotoUrl = event.photoURL;
        appDataModel.profilePhone = event.phoneNumber;
        appDataModel.profileEmailVerify = event.emailVerified;

       _checkHaveUser(context.read<AppDataModel>());

        // Navigator.pushNamedAndRemoveUntil(
        //     context, '/home-page', (route) => false);

      } else {
        print("non Login");
        setState(() {
          checkLogin = true;
        });
      }
    });
  }

  _checkHaveUser(AppDataModel appDataModel) async {
    var apiUrl = Uri.parse(appDataModel.server + '/users/uid');
    print(apiUrl);
    var responseGetUserDetail = await http.post(
      (apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'uid': appDataModel.profileUid,
      }),
    );
    print(
        'CheckUserDB StatusCode' + responseGetUserDetail.statusCode.toString());
    if (responseGetUserDetail.statusCode == 204) {
      print(appDataModel.profileUid);
      var responseAddUser = await http.post(
        (Uri.parse(appDataModel.server + '/users/add')),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "uid": appDataModel.profileUid.toString(),
          "name": appDataModel.profileName,
          "phone": appDataModel.profilePhone,
          "email": appDataModel.profileEmail,
          "photo_url": appDataModel.profilePhotoUrl,
          "location": "1234565",
          "status": '1'
        }),
      );
      print('addUser ' + responseAddUser.body.toString());
      if (responseAddUser.statusCode == 200){
        Navigator.pushNamedAndRemoveUntil(
            context, '/home-page', (route) => false);
      }else{
        checkLogin = true;
      }

    } else if (responseGetUserDetail.statusCode == 200) {
      print('getUserData' + responseGetUserDetail.body.toString());
      var rowData = utf8.decode(responseGetUserDetail.bodyBytes);
      var rowDataEdit = rowData.substring(1, rowData.length - 1);
      UserModel _userDetail = userModelFromJson(rowDataEdit);
     appDataModel.profileUid = _userDetail.uid;
      appDataModel.profileName = _userDetail.name;
      appDataModel.profilePhone = _userDetail.phone;
      appDataModel.profileEmail = _userDetail.email;
      appDataModel.profilePhotoUrl = _userDetail.photoUrl;
      appDataModel.profileLocation = _userDetail.location;
      appDataModel.profileStatus = _userDetail.status;

      Navigator.pushNamedAndRemoveUntil(
          context, '/home-page', (route) => false);

    }
  }

  @override
  Widget build(BuildContext context) {
    _setScreen(context.read<AppDataModel>());
    if (checkLogin == false) _checkLogin(context.read<AppDataModel>());

    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              backgroundColor: Colors.white,
              body: (checkLogin == true)
                  ? Container(
                      color: Colors.white,
                      // color: Style().primaryColor,
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Style().titleH0("เฮาะ"),
                          Style().textDark("อากาศเดลิเวอรี่"),
                          Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 50),
                                width: appDataModel.screenW * 0.9,
                                child: ElevatedButton(
                                    onPressed: () {
                                      signInWithFacebook(
                                          context.read<AppDataModel>());
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          //   color: Colors.redAccent,
                                          width: (appDataModel.screenW * 0.9) *
                                              0.1,
                                          child: Icon(
                                            FontAwesomeIcons.facebook,
                                            color: Colors.white,
                                            size: 20,
                                          ),
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
                                                Style().textWhite(
                                                    'เข้าใช้งานด้วย Facebook'),
                                              ],
                                            ))
                                      ],
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        primary: Style().facebookColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)))),
                              ),
                              Container(
                                width: appDataModel.screenW * 0.9,
                                child: ElevatedButton(
                                    onPressed: () {
                                      signInWithGoogle(
                                          context.read<AppDataModel>());
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          //color: Colors.redAccent,
                                          width: (appDataModel.screenW * 0.9) *
                                              0.1,
                                          child: Image.asset(
                                            'assets/images/googleLogo.png',
                                            height: 20,
                                          ),
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
                                                    'เข้าใช้งานด้วย Google'),
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
                              Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            height: 10),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            height: 1,
                                            color: Colors.grey),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            height: 10),
                                      ]),
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    child: Center(
                                        child: Style().textBlackSmall('หรือ')),
                                  ),
                                ],
                              ),
                              Container(
                                width: appDataModel.screenW * 0.9,
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/login-page');
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          //   color: Colors.redAccent,
                                          width: (appDataModel.screenW * 0.9) *
                                              0.1,
                                          child: Icon(
                                            Icons.email,
                                            color: Colors.white,
                                            size: 20,
                                          ),
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
                                                Style().textWhite(
                                                    'เข้าใช้งานด้วย Email'),
                                              ],
                                            ))
                                      ],
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        primary: Style().emailColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)))),
                              ),
                            ],
                          )
                        ],
                      )),
                    )
                  : Center(child: Style().circularProgressIndicator(Style().darkColor)),
            ));
  }

  Future<Null> registerFirebase() async {
    await Firebase.initializeApp().then((value) {
      print('Connect Firebase Success');
    });
  }
}
