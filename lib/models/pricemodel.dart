import 'dart:convert';

Pricemodel pricemodelFromJson(String str) => Pricemodel.fromJson(json.decode(str));

class Pricemodel {
  Pricemodel({
    this.data,
  });
  Data data;

  factory Pricemodel.fromJson(Map<String, dynamic> json) => Pricemodel(
    data: Data.fromJson(json["data"]),
  );
}


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
