// To parse this JSON data, do
//
//     final productsModel = productsModelFromJson(jsonString);

import 'dart:convert';

List<ProductsModel> productsModelFromJson(String str) => List<ProductsModel>.from(json.decode(str).map((x) => ProductsModel.fromJson(x)));

String productsModelToJson(List<ProductsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductsModel {
  ProductsModel({
    this.productId,
    this.shopUid,
    this.productName,
    this.productPhotoUrl,
    this.productDetail,
    this.productPrice,
    this.productTime,
    this.productStatus,
    this.shopName,
    this.shopLocation,
  });

  String productId;
  String shopUid;
  String productName;
  String productPhotoUrl;
  String productDetail;
  String productPrice;
  String productTime;
  String productStatus;
  String shopName;
  String shopLocation;

  factory ProductsModel.fromJson(Map<String, dynamic> json) => ProductsModel(
    productId: json["product_id"],
    shopUid: json["shop_uid"],
    productName: json["product_name"],
    productPhotoUrl: json["product_photoUrl"],
    productDetail: json["product_detail"],
    productPrice: json["product_price"],
    productTime: json["product_time"],
    productStatus: json["product_status"],
    shopName: json["shop_name"] == null ? null : json["shop_name"],
    shopLocation: json["shop_location"] == null ? null : json["shop_location"],
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "shop_uid": shopUid,
    "product_name": productName,
    "product_photoUrl": productPhotoUrl,
    "product_detail": productDetail,
    "product_price": productPrice,
    "product_time": productTime,
    "product_status": productStatus,
    "shop_name": shopName == null ? null : shopName,
    "shop_location": shopLocation == null ? null : shopLocation,
  };
}
