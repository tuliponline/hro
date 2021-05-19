import 'dart:convert';
import 'package:hro/model/allShopModel.dart';
import 'package:hro/model/productsModel.dart';
import 'package:hro/model/userModel.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';

import 'package:flutter/material.dart';

class AppDataModel {



  double _screenW;

  double get screenW => _screenW;

  set screenW(double screenW) {
    _screenW = screenW;
  }

  Color cols = Color.fromARGB(1, 34, 150, 243);

  String uid = '';
  String server = "http://58d7046b2892.sn.mynetname.net:3000";
  String basicAuth ="";





  String _port = "8000";

  String get port => _port;

  set port(String port) {
    _port = port;
  }

  String _user = "";

  String get user => _user;

  set user(String user) {
    _user = user;
  }

  String _password = "";

  String get password => _password;

  set password(String password) {
    _password = password;
  }



  //-----profile Data--------
  String profileEmail;
  String profileName;
  String profileUid;
  String profilePhotoUrl;
  String profilePhone;
  String profileProvider;
  String profileLocation;
  String profileStatus;

  bool profilePhoneVerify = false;
  bool profileEmailVerify = false;

  UserModel userDetail;

  //-----shop Data-------------
  String shopName;
  String shopType;
  String shopPhotoUrl;
  String shopPhone;
  String shopAddress;
  String shopLocation;
  String shopTime;
  String shopStatus;

  //-----allShop----
List<AllShopModel> allShopData;

//----product Model
List<ProductsModel> productsData;

  List<ProductsModel> allProductsData;



}
