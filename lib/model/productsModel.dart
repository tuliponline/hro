// To parse this JSON data, do
//
//     final productsModel = productsModelFromJson(jsonString);

import 'dart:convert';

List<ProductsModel> productsModelFromJson(String str) => List<ProductsModel>.from(json.decode(str).map((x) => ProductsModel.fromJson(x)));

String productsModelToJson(List<ProductsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductsModel {
  ProductsModel({
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

  factory ProductsModel.fromJson(Map<String, dynamic> json) => ProductsModel(
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
