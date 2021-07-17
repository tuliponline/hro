

import 'dart:convert';

List<RatingListModel> ratingListModelFromJson(String str) => List<RatingListModel>.from(json.decode(str).map((x) => RatingListModel.fromJson(x)));

String ratingListModelToJson(List<RatingListModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RatingListModel {
  RatingListModel({
    this.riderRate,
    this.riderId,
    this.customerComment,
    this.orderId,
    this.customerRate,
    this.customerId,
    this.riderComment,
    this.shopComment,
    this.shopId,
    this.shopRate,
  });

  String riderRate;
  String riderId;
  String customerComment;
  dynamic orderId;
  String customerRate;
  String customerId;
  String riderComment;
  String shopComment;
  String shopId;
  String shopRate;

  factory RatingListModel.fromJson(Map<String, dynamic> json) => RatingListModel(
    riderRate: json["riderRate"],
    riderId: json["riderId"],
    customerComment: json["customerComment"],
    orderId: json["orderId"],
    customerRate: json["customerRate"],
    customerId: json["customerId"],
    riderComment: json["riderComment"],
    shopComment: json["shopComment"],
    shopId: json["shopId"],
    shopRate: json["shopRate"],
  );

  Map<String, dynamic> toJson() => {
    "riderRate": riderRate,
    "riderId": riderId,
    "customerComment": customerComment,
    "orderId": orderId,
    "customerRate": customerRate,
    "customerId": customerId,
    "riderComment": riderComment,
    "shopComment": shopComment,
    "shopId": shopId,
    "shopRate": shopRate,
  };
}
// To parse this JSON data, do
//
//     final ratingModel = ratingModelFromJson(jsonString);



RatingModel ratingModelFromJson(String str) => RatingModel.fromJson(json.decode(str));

String ratingModelToJson(RatingModel data) => json.encode(data.toJson());

class RatingModel {
  RatingModel({
    this.riderRate,
    this.riderId,
    this.customerComment,
    this.orderId,
    this.customerRate,
    this.customerId,
    this.riderComment,
    this.shopComment,
    this.shopId,
    this.shopRate,
  });

  String riderRate;
  String riderId;
  String customerComment;
  dynamic orderId;
  String customerRate;
  String customerId;
  String riderComment;
  String shopComment;
  String shopId;
  String shopRate;

  factory RatingModel.fromJson(Map<String, dynamic> json) => RatingModel(
    riderRate: json["riderRate"],
    riderId: json["riderId"],
    customerComment: json["customerComment"],
    orderId: json["orderId"],
    customerRate: json["customerRate"],
    customerId: json["customerId"],
    riderComment: json["riderComment"],
    shopComment: json["shopComment"],
    shopId: json["shopId"],
    shopRate: json["shopRate"],
  );

  Map<String, dynamic> toJson() => {
    "riderRate": riderRate,
    "riderId": riderId,
    "customerComment": customerComment,
    "orderId": orderId,
    "customerRate": customerRate,
    "customerId": customerId,
    "riderComment": riderComment,
    "shopComment": shopComment,
    "shopId": shopId,
    "shopRate": shopRate,
  };
}

