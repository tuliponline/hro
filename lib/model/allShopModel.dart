// To parse this JSON data, do
//
//     final allShopModel = allShopModelFromJson(jsonString);

import 'dart:convert';

List<AllShopModel> allShopModelFromJson(String str) => List<AllShopModel>.from(json.decode(str).map((x) => AllShopModel.fromJson(x)));

String allShopModelToJson(List<AllShopModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AllShopModel {
  AllShopModel({
    this.shopUid,
    this.shopName,
    this.shopPhotoUrl,
    this.shopType,
    this.shopPhone,
    this.shopAddress,
    this.shopLocation,
    this.shopTime,
    this.shopStatus,
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

  factory AllShopModel.fromJson(Map<String, dynamic> json) => AllShopModel(
    shopUid: json["shop_uid"],
    shopName: json["shop_name"],
    shopPhotoUrl: json["shop_photo_Url"],
    shopType: json["shop_type"],
    shopPhone: json["shop_phone"],
    shopAddress: json["shop_address"],
    shopLocation: json["shop_location"],
    shopTime: json["shop_time"],
    shopStatus: json["shop_status"],
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
  };
}
