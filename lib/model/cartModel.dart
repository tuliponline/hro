// To parse this JSON data, do
//
//     final cartModel = cartModelFromJson(jsonString);

import 'dart:convert';

List<CartModel> cartModelFromJson(String str) => List<CartModel>.from(json.decode(str).map((x) => CartModel.fromJson(x)));

String cartModelToJson(List<CartModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CartModel {
  CartModel({
    this.productId,
    this.productName,
    this.pcs,
    this.price,
    this.comment,
    this.time,
  });

  String productId;
  String productName;
  String pcs;
  String price;
  String comment;
  String time;

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
    productId: json["productId"],
    productName: json["productName"],
    pcs: json["pcs"],
    price: json["price"],
    comment: json["comment"],
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "productName": productName,
    "pcs": pcs,
    "price": price,
    "comment": comment,
    "time": time,
  };
}
