import 'dart:convert';
import 'package:hro/model/allShopModel.dart';
import 'package:hro/model/driverModel.dart';
import 'package:hro/model/productsModel.dart';
import 'package:hro/model/ratingModel.dart';
import 'package:hro/model/shopModel.dart';
import 'package:hro/model/userModel.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'cartModel.dart';
import 'locationSetupModel.dart';

class AppDataModel {
  double _screenW;

  double get screenW => _screenW;

  set screenW(double screenW) {
    _screenW = screenW;
  }

  Color cols = Color.fromARGB(1, 34, 150, 243);

  String uid = '';
  String server = "http://58d7046b2892.sn.mynetname.net:3000";
  String basicAuth = "";
  String _port = "8000";
  String get port => _port;
  set port(String port) {
    _port = port;
  }

  double distanceLimit = 2.0;

  int costDelivery = 20;
  int allProductCurrentPage = 1;
  String ratingOrderId,ratingShopId,ratingRiderId,ratingCustomerId;
  String noTiServer = 'https://us-central1-hro-authen.cloudfunctions.net/hello';
  String notifyServer = "https://us-central1-hro-authen.cloudfunctions.net/hello/notify";

  //location and costDelivery Setup
  LocationSetupModel locationSetupModel;


  List<AllShopModel> allShopAdminList;


  String adminToken ="";

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

  List<RatingListModel> shopRatingList;

  String productEditId;

  //-----profile Data--------
  String profileEmail;
  String profileName;
  String profileUid;
  String profilePhotoUrl;
  String profilePhone;
  String profileProvider;
  String profileLocation;
  String profileStatus;

  String loginProvider;
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
  List<AllShopModel> allFullShopData;

//----product Model
  List<ProductsModel> productsData;
  List<ProductsModel> allProductsData;

//----driVers Data
  DriversModel driverData;

//-----productSelect
  String productSelectId;

  List<CartModel> currentOrder = [];
  int allPcs = 0;
  int allPrice = 0;

  String orderAddressComment = "";

  //---storeData
  String storeSelectId;
  ShopModel currentShopSelect;
  List<ProductsModel> storeProductsData;

  bool shopOpen;

  //----Order
  String _orderIdSelected;

  String get orderIdSelected => _orderIdSelected;

  set orderIdSelected(String orderIdSelected) {
    _orderIdSelected = orderIdSelected;
  }

  //---location
  double latStart = 17.591244;
  double lngStart = 103.979989;
  double latYou;
  double lngYou;

  double latOrder;
  double lngOrder;

  String _distanceDelivery;

  String get distanceDelivery => _distanceDelivery;

  set distanceDelivery(String distanceDelivery) {
    _distanceDelivery = distanceDelivery;
  }

  //Notification
String _token;
  String get token => _token;

  set token(String token) {
    _token = token;
  }

}
