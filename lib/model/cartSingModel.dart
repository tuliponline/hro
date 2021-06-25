// To parse this JSON data, do
//
//     final cartSingleModel = cartSingleModelFromJson(jsonString);

import 'dart:convert';

CartSingleModel cartSingleModelFromJson(String str) => CartSingleModel.fromJson(json.decode(str));

String cartSingleModelToJson(CartSingleModel data) => json.encode(data.toJson());

class CartSingleModel {
  CartSingleModel({
    this.productId,
    this.pcs,
    this.price,
  });

  String productId;
  String pcs;
  String price;

  factory CartSingleModel.fromJson(Map<String, dynamic> json) => CartSingleModel(
    productId: json["productId"],
    pcs: json["pcs"],
    price: json["price"],
  );

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "pcs": pcs,
    "price": price,
  };
}
