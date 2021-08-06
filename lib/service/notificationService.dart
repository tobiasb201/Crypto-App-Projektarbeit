
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



class NotificationService {

  FirebaseMessaging messaging = FirebaseMessaging.instance; //Cloud Messaging
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  void notificationPermission() async{
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  void initMessaging(){
    var androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    final IOSInitializationSettings iosInit = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    var initSetting = InitializationSettings(android: androidInit, iOS: iosInit);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.initialize(initSetting);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message);//Notification message gets passed
    });
  }


  void showNotification(RemoteMessage message) async{
    RemoteNotification payload= message.notification;//notification data
    var androidDetails =
    AndroidNotificationDetails('1', 'channelName', 'channel Description');

    var iosDetails = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    var generalNotificationDetails =
    NotificationDetails(android: androidDetails, iOS: iosDetails);

    //Visible data from the Notification
    await flutterLocalNotificationsPlugin.show(0,payload.title,payload.body, generalNotificationDetails,
        payload: 'Notification');
  }

  void getToken() async{
    print(await messaging.getToken());
  }
}