import 'dart:convert';

List<NotificationData> notificationDataFromJson(String str) => List<NotificationData>.from(json.decode(str).map((x) => NotificationData.fromJson(x)));

class NotificationData {
  NotificationData({
    this.id,
    this.asset,
    this.currentprice,
    this.fifteen,
    this.hour,
  });

  int id;
  String asset;
  double currentprice;
  double fifteen;
  double hour;

  factory NotificationData.fromJson(Map<String, dynamic> json) => NotificationData(
    id: json["id"],
    asset: json["asset"],
    currentprice: json["currentprice"].toDouble(),
    fifteen: json["fifteen"].toDouble(),
    hour: json["hour"].toDouble(),
  );

}