import 'package:hive/hive.dart';

part 'assetbox.g.dart';

@HiveType(typeId: 0)
class AssetBox{
  @HiveField(0)
  final String asset;
  @HiveField(1)
  final String action;
  @HiveField(2)
  final String price;
  @HiveField(3)
  final String amount;
  @HiveField(4)
  final String date;

  AssetBox({this.asset,this.action,this.price,this.amount,this.date});
}