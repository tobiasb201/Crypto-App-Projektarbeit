import 'dart:io';

import 'package:crypto_app/models/assetbox.dart';
import 'package:crypto_app/pages/navbar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Directory document= await getApplicationDocumentsDirectory();
  Hive.registerAdapter(AssetBoxAdapter());//Vor dem Hive init
  Hive.init(document.path);
  await Hive.openBox("assets");
  await Hive.openBox('currency');
  await Hive.openBox('homepageData');
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
      home: Navbar()
    );
  }
}
