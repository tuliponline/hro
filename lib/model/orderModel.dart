// To parse this JSON data, do
//
//     final orderdetail = orderdetailFromJson(jsonString);

import 'dart:convert';



List<OrderList> orderListFromJson(String str) => List<OrderList>.from(json.decode(str).map((x) => OrderList.fromJson(x)));

String orderListToJson(List<OrderList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrderList {
  OrderList({
    this.finishTime,
    this.amount,
    this.distance,
    this.orderId,
    this.costDelivery,
    this.inTime,
    this.driver,
    this.customerId,
    this.comment,
    this.startTime,
    this.location,
    this.shopId,
    this.status,
  });

  String finishTime;
  String amount;
  String distance;
  String orderId;
  String costDelivery;
  String inTime;
  String driver;
  String customerId;
  String comment;
  String startTime;
  String location;
  String shopId;
  String status;

  factory OrderList.fromJson(Map<String, dynamic> json) => OrderList(
    finishTime: json["finishTime"],
    amount: json["amount"],
    distance: json["distance"],
    orderId: json["orderId"],
    costDelivery: json["costDelivery"],
    inTime: json["inTime"],
    driver: json["driver"],
    customerId: json["customerId"],
    comment: json["comment"],
    startTime: json["startTime"],
    location: json["location"],
    shopId: json["shopId"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "finishTime": finishTime,
    "amount": amount,
    "distance": distance,
    "orderId": orderId,
    "costDelivery": costDelivery,
    "inTime": inTime,
    "driver": driver,
    "customerId": customerId,
    "comment": comment,
    "startTime": startTime,
    "location": location,
    "shopId": shopId,
    "status": status,
  };
}


// To parse this JSON data, do
//
//     final orderDetail = orderDetailFromJson(jsonString);



OrderDetail orderDetailFromJson(String str) => OrderDetail.fromJson(json.decode(str));

String orderDetailToJson(OrderDetail data) => json.encode(data.toJson());

class OrderDetail {
  OrderDetail({
    this.finishTime,
    this.amount,
    this.distance,
    this.orderId,
    this.costDelivery,
    this.inTime,
    this.driver,
    this.customerId,
    this.comment,
    this.startTime,
    this.location,
    this.shopId,
    this.status,
  });

  String finishTime;
  String amount;
  String distance;
  String orderId;
  String costDelivery;
  String inTime;
  String driver;
  String customerId;
  String comment;
  String startTime;
  String location;
  String shopId;
  String status;

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
    finishTime: json["finishTime"],
    amount: json["amount"],
    distance: json["distance"],
    orderId: json["orderId"],
    costDelivery: json["costDelivery"],
    inTime: json["inTime"],
    driver: json["driver"],
    customerId: json["customerId"],
    comment: json["comment"],
    startTime: json["startTime"],
    location: json["location"],
    shopId: json["shopId"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "finishTime": finishTime,
    "amount": amount,
    "distance": distance,
    "orderId": orderId,
    "costDelivery": costDelivery,
    "inTime": inTime,
    "driver": driver,
    "customerId": customerId,
    "comment": comment,
    "startTime": startTime,
    "location": location,
    "shopId": shopId,
    "status": status,
  };
}



List<OrderProduct> orderProductFromJson(String str) => List<OrderProduct>.from(json.decode(str).map((x) => OrderProduct.fromJson(x)));

String orderProductToJson(List<OrderProduct> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrderProduct {
  OrderProduct({
    this.pcs,
    this.productId,
    this.price,
    this.name,
    this.comment,
    this.time,
  });

  String pcs;
  String productId;
  String price;
  String name;
  String comment;
  String time;

  factory OrderProduct.fromJson(Map<String, dynamic> json) => OrderProduct(
    pcs: json["pcs"],
    productId: json["productId"],
    price: json["price"],
    name: json["name"],
    comment: json["comment"],
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "pcs": pcs,
    "productId": productId,
    "price": price,
    "name": name,
    "comment": comment,
    "time": time,
  };
}

