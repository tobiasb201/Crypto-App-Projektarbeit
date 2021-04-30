import 'dart:convert';
import 'package:hive/hive.dart';

Pricemodel pricemodelFromJson(String str) => Pricemodel.fromJson(json.decode(str));

@HiveType(typeId: 1)
class Pricemodel {
  Pricemodel({
    this.data,
  });
  @HiveField(0)
  Data data;

  factory Pricemodel.fromJson(Map<String, dynamic> json) => Pricemodel(
    data: Data.fromJson(json["data"]),
  );
}

@HiveType(typeId: 2)
class Data {
  Data({
    this.base,
    this.currency,
    this.amount,
  });

  String base;
  String currency;
  String amount;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    base: json["base"],
    currency: json["currency"],
    amount: json["amount"],
  );
}
