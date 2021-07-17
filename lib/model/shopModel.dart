// To parse this JSON data, do
//
//     final shopModel = shopModelFromJson(jsonString);

import 'dart:convert';

ShopModel shopModelFromJson(String str) => ShopModel.fromJson(json.decode(str));

String shopModelToJson(ShopModel data) => json.encode(data.toJson());

class ShopModel {
  ShopModel({
    this.shopUid,
    this.shopName,
    this.shopPhotoUrl,
    this.shopType,
    this.shopPhone,
    this.shopAddress,
    this.shopLocation,
    this.shopTime,
    this.shopStatus,
    this.token,
  });

  String shopUid;
  String shopName;
  String shopPhotoUrl;
  String shopType;
  String shopPhone;
  String shopAddress;
  String shopLocation;
  String shopTime;
  String shopStatus;
  String token;

  factory ShopModel.fromJson(Map<String, dynamic> json) => ShopModel(
    shopUid: json["shop_uid"],
    shopName: json["shop_name"],
    shopPhotoUrl: json["shop_photo_Url"],
    shopType: json["shop_type"],
    shopPhone: json["shop_phone"],
    shopAddress: json["shop_address"],
    shopLocation: json["shop_location"],
    shopTime: json["shop_time"],
    shopStatus: json["shop_status"],
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "shop_uid": shopUid,
    "shop_name": shopName,
    "shop_photo_Url": shopPhotoUrl,
    "shop_type": shopType,
    "shop_phone": shopPhone,
    "shop_address": shopAddress,
    "shop_location": shopLocation,
    "shop_time": shopTime,
    "shop_status": shopStatus,
    "token": token,
  };
}
