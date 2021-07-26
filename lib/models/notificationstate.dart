import 'package:hive/hive.dart';
part 'notificationstate.g.dart';
//Used for saving Notification settings
@HiveType(typeId: 1)
class NotificationState {
  @HiveField(0)
  String asset;
  @HiveField(1)
  double percentage;
  @HiveField(2)
  String time;
  @HiveField(3)
  bool switchState;

  NotificationState({this.asset, this.percentage, this.time, this.switchState,});

}
