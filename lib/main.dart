import 'dart:io';
import 'package:crypto_app/models/assetbox.dart';
import 'package:crypto_app/models/notificationstate.dart';
import 'package:crypto_app/pages/navbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory document = await getApplicationDocumentsDirectory();
  Hive.registerAdapter(AssetBoxAdapter()); //Hive accepts model via adapter
  Hive.registerAdapter(NotificationStateAdapter()); //Hive accepts model via adapter
  Hive.init(document.path);//Hive saving path
  await Hive.openBox("assets"); //Transactions
  await Hive.openBox('fetchingCurrency'); //Dollar or Euro
  await Hive.openBox('homepageData'); //Cached prices for Homepage
  await Hive.openBox('notification'); //Notification states
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler); //Notification's handled in background
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        home: Navbar());
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}




