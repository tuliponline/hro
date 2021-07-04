// To parse this JSON data, do
//
//     final appStatusModel = appStatusModelFromJson(jsonString);

import 'dart:convert';

AppStatusModel appStatusModelFromJson(String str) => AppStatusModel.fromJson(json.decode(str));

String appStatusModelToJson(AppStatusModel data) => json.encode(data.toJson());

class AppStatusModel {
  AppStatusModel({
    this.customerOpen,
    this.dateopen,
    this.status,
  });

  String customerOpen;
  String dateopen;
  String status;

  factory AppStatusModel.fromJson(Map<String, dynamic> json) => AppStatusModel(
    customerOpen: json["customerOpen"],
    dateopen: json["dateopen"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "customerOpen": customerOpen,
    "dateopen": dateopen,
    "status": status,
  };
}
