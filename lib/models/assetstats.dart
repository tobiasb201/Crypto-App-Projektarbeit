import 'dart:convert';

AssetStats assetStatsFromJson(String str) => AssetStats.fromJson(json.decode(str));

class AssetStats {
  AssetStats({
    this.open,
    this.high,
    this.low,
    this.volume,
    this.last,
    this.volume30Day,
  });

  String open;
  String high;
  String low;
  String volume;
  String last;
  String volume30Day;

  factory AssetStats.fromJson(Map<String, dynamic> json) => AssetStats(
    open: json["open"],
    high: json["high"],
    low: json["low"],
    volume: json["volume"],
    last: json["last"],
    volume30Day: json["volume_30day"],
  );

}