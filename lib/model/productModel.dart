// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';

ProductModel productModelFromJson(String str) => ProductModel.fromJson(json.decode(str));

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  ProductModel({
    this.productPhotoUrl,
    this.productTime,
    this.productDetail,
    this.productId,
    this.shopUid,
    this.productStatus,
    this.productPrice,
    this.productName,
  });

  String productPhotoUrl;
  String productTime;
  String productDetail;
  String productId;
  String shopUid;
  String productStatus;
  String productPrice;
  String productName;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    productPhotoUrl: json["product_photoUrl"],
    productTime: json["product_time"],
    productDetail: json["product_detail"],
    productId: json["product_id"],
    shopUid: json["shop_uid"],
    productStatus: json["product_status"],
    productPrice: json["product_price"],
    productName: json["product_name"],
  );

  Map<String, dynamic> toJson() => {
    "product_photoUrl": productPhotoUrl,
    "product_time": productTime,
    "product_detail": productDetail,
    "product_id": productId,
    "shop_uid": shopUid,
    "product_status": productStatus,
    "product_price": productPrice,
    "product_name": productName,
  };
}
