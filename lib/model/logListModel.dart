// To parse this JSON data, do
//
//     final logsListModel = logsListModelFromJson(jsonString);

import 'dart:convert';

List<LogsListModel> logsListModelFromJson(String str) => List<LogsListModel>.from(json.decode(str).map((x) => LogsListModel.fromJson(x)));

String logsListModelToJson(List<LogsListModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LogsListModel {
  LogsListModel({
    this.orderId,
    this.setId,
    this.logId,
    this.time,
    this.setBy,
    this.status,
    this.comment,
  });

  String orderId;
  String setId;
  String logId;
  String time;
  String setBy;
  String status;
  String comment;

  factory LogsListModel.fromJson(Map<String, dynamic> json) => LogsListModel(
    orderId: json["orderId"],
    setId: json["setId"],
    logId: json["logId"],
    time: json["time"],
    setBy: json["setBy"],
    status: json["status"],
    comment: json["comment"],
  );

  Map<String, dynamic> toJson() => {
    "orderId": orderId,
    "setId": setId,
    "logId": logId,
    "time": time,
    "setBy": setBy,
    "status": status,
    "comment": comment,
  };
}
