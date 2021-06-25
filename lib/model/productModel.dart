// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';

ProductModel productModelFromJson(String str) => ProductModel.fromJson(json.decode(str));

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  ProductModel({
    this.productId,
    this.shopUid,
    this.productName,
    this.productPhotoUrl,
    this.productDetail,
    this.productPrice,
    this.productTime,
    this.productStatus,
  });

  dynamic productId;
  dynamic shopUid;
  dynamic productName;
  dynamic productPhotoUrl;
  dynamic productDetail;
  dynamic productPrice;
  dynamic productTime;
  dynamic productStatus;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    productId: json["product_id"],
    shopUid: json["shop_uid"],
    productName: json["product_name"],
    productPhotoUrl: json["product_photoUrl"],
    productDetail: json["product_detail"],
    productPrice: json["product_price"],
    productTime: json["product_time"],
    productStatus: json["product_status"],
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
  };
}
