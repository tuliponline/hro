import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class MyDrawer extends StatefulWidget {
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  static final GoogleSignIn googleSignIn = new GoogleSignIn();

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  Dialogs dialogs = Dialogs();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => SafeArea(
              child: Container(
                child: ListView(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          Container(
                            //color: Colors.orange,
                            margin: EdgeInsets.only(bottom: 5),
                            child: CircleAvatar(
                              backgroundColor: Style().primaryColor,
                              radius: 40,
                              child: CircleAvatar(
                                radius: 38,
                                backgroundColor: Colors.white,
                                child: (appDataModel.profilePhotoUrl?.isEmpty ??
                                        true)
                                    ? Container()
                                    : CircleAvatar(
                                        radius: 35,
                                        backgroundColor: Colors.white,
                                        backgroundImage: NetworkImage(
                                            appDataModel.profilePhotoUrl),
                                      ),
                              ),
                            ),
                          ),
                          (appDataModel.profileName?.isEmpty ?? true)
                              ? Container()
                              : Style().titleH3(appDataModel.profileName),
                          (appDataModel.profileName?.isEmpty ?? true)
                              ? Container()
                              : Style().textDark(appDataModel.profileEmail)
                        ],
                      ),
                    ),
                    Container(
                      // color: Colors.grey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: ListTile(
                            onTap: () async {
                              await Navigator.pushNamed(
                                  context, '/profile-page');
                              setState(() {});
                            },
                            leading: Icon(
                              FontAwesomeIcons.solidUserCircle,
                              color: Style().darkColor,
                              size: 30,
                            ),
                            title: Style().textBlack54('บัญชี'),
                          ))
                        ],
                      ),
                    ),
                    Container(
                      // color: Colors.grey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: ListTile(
                            leading: Icon(
                              FontAwesomeIcons.clipboardList,
                              color: Style().darkColor,
                              size: 30,
                            ),
                            title: Style().textBlack54('รายการ'),
                          ))
                        ],
                      ),
                    ),
                    Container(
                      // color: Colors.grey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: ListTile(
                            leading: Icon(
                              FontAwesomeIcons.wallet,
                              color: Style().darkColor,
                              size: 30,
                            ),
                            title: Style().textBlack54('ช่องทางชำระเงิน'),
                          ))
                        ],
                      ),
                    ),
                    Container(
                      // color: Colors.grey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: ListTile(
                            onTap: () {
                              _checkHaveShop(context.read<AppDataModel>());
                            },
                            leading: Icon(
                              FontAwesomeIcons.store,
                              color: Style().shopDarkColor,
                              size: 30,
                            ),
                            title: Style().textSizeColor(
                                'ร้านค้า', 14, Style().shopDarkColor),
                          ))
                        ],
                      ),
                    ),
                    Container(
                      // color: Colors.grey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: ListTile(
                            onTap: () {
                              Navigator.pushNamed(context, '/shop-page');
                            },
                            leading: Icon(
                              FontAwesomeIcons.motorcycle,
                              color: Style().drivePrimaryColor,
                              size: 30,
                            ),
                            title: Style().textSizeColor(
                                'บริการจัดส่ง', 14, Style().drivePrimaryColor),
                          ))
                        ],
                      ),
                    ),
                    Container(
                      // color: Colors.grey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () async {
                                await Firebase.initializeApp()
                                    .then((value) async {
                                  await FirebaseAuth.instance
                                      .signOut()
                                      .then((value) async {
                                    await MyDrawer.facebookSignIn.logOut();
                                    await MyDrawer.googleSignIn.signOut();
                                    Navigator.pushNamedAndRemoveUntil(context,
                                        '/first-page', (route) => false);
                                  });
                                });
                              },
                              child: Text(
                                "ออกจากระบบ",
                                style: TextStyle(
                                    fontFamily: 'Prompt',
                                    color: Colors.redAccent),
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
  }

  _checkHaveShop(AppDataModel appDataModel) async {
    var apiUrl = Uri.parse(appDataModel.server + '/shops/uid');
    print(apiUrl);
    var responseGetShopDetail = await http.post(
      (apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'shop_uid': appDataModel.profileUid,
      }),
    );
    if (responseGetShopDetail.statusCode == 204) {
      bool result = await dialogs.confirm(context, 'เปิดร้าน',
          'ต้องการเปิดร้านค้า ?', Icon(FontAwesomeIcons.store));
      if (result == true) {
        Navigator.pushNamed(context, "/shopSetup-page",arguments: 'NEW');
      }
    }else if(responseGetShopDetail.statusCode == 200){

      var rowData = utf8.decode(responseGetShopDetail.bodyBytes);
      var rowDataEdit = rowData.substring(1, rowData.length - 1);
      ShopModel shopModel = shopModelFromJson(rowDataEdit);
      appDataModel.shopName = shopModel.shopName;
      appDataModel.shopPhotoUrl = shopModel.shopPhotoUrl;
      appDataModel.shopType = shopModel.shopType;
      appDataModel.shopPhone = shopModel.shopPhone;
      appDataModel.shopAddress = shopModel.shopAddress;
      appDataModel.shopLocation = shopModel.shopLocation;
      appDataModel.shopTime = shopModel.shopTime;
      appDataModel.shopStatus = shopModel.shopStatus;


      Navigator.pushNamed(context,  '/shop-page',arguments: 'OLD');
    }
  }
}
