import 'package:hive/hive.dart';

part 'hivenotification.g.dart';

@HiveType(typeId: 3)
class HiveNotification{
  @HiveField(0)
  final String asset;
  @HiveField(1)
  final String time;
  @HiveField(2)
  final int percent;


  HiveNotification({this.asset,this.time,this.percent});
}