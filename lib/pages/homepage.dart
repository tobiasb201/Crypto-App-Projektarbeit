import 'package:crypto_app/models/assetbox.dart';
import 'package:crypto_app/models/pricemodel.dart';
import 'package:crypto_app/pages/assetpage.dart';
import 'package:crypto_app/service/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:crypto_app/constants/constant.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:hive/hive.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<List<Pricemodel>> prices;
  ValueNotifier<double> _balance = ValueNotifier<double>(0);
  List<Pricemodel> balance = [];
  final homepageData= Hive.box('homepageData');
  Timer timer;

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

    var iosInit = IOSInitializationSettings();

    var initSetting = InitializationSettings(android: androidInit, iOS: iosInit);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.initialize(initSetting);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message);
    });
  }

  void getToken() async{
    print(await messaging.getToken());
  }

  void showNotification(RemoteMessage message) async{
    RemoteNotification payload= message.notification;
    var androidDetails =
    AndroidNotificationDetails('1', 'channelName', 'channel Description');

    var iosDetails = IOSNotificationDetails();

    var generalNotificationDetails =
    NotificationDetails(android: androidDetails, iOS: iosDetails);

    await flutterLocalNotificationsPlugin.show(0,payload.title,payload.body, generalNotificationDetails,
        payload: 'Notification');
  }


  @override
  void initState() {
    loadList(false).then((value) {
      value.forEach((element) {
        balance.add(element);
      });
      getbalance(balance);
      return balance;
    });
    _initializeTimer();
    super.initState();

    notificationPermission();
    initMessaging();
    getToken();
  }

  Future loadList(bool refresh) async {
    final box = Hive.box('currency');
    if (box.isEmpty) {
      box.put('currency', 'USD');
      Constant.currentCurrency="\$";
    }
    else if(box.isNotEmpty){
      if(box.get('currency')=="USD"){
        Constant.currentCurrency="\$";
      }
      else{
        Constant.currentCurrency="€";
      }
    }
      prices = Api_Service().getprices(refresh);
      setState(() {
        prices = this.prices;
      });
      return prices;
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  Future refresh() async {
    Future.delayed(Duration(seconds: 1));
    loadList(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crypto App"),
        backgroundColor: Colors.grey[900],
      ),
      body: Column(children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.amber[600],
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 5),
          width: MediaQuery.of(context).size.width,
          height: 40,
          child: InkWell(
            onTap: changecurrency,
            splashColor: Colors.transparent,
            child: ValueListenableBuilder(
              valueListenable: _balance,
              builder: (context, double balance, _) {
                  return Center(
                    child: Text("Current Balance:" +
                        _balance.value.toStringAsFixed(2) +
                        ""+Constant.currentCurrency
                        ),
                  );
                }
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: refresh,
            child: FutureBuilder(
              future: prices,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data;
                  return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final priceData = data[index];
                        return _getListItemUi(priceData, index);
                      });
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
      ]),
      backgroundColor: Colors.grey[900],
    );
  }

  void changecurrency() {
    final box = Hive.box('currency');
    if (box.get('currency') == 'USD') {
      box.put('currency', 'EUR');
      Constant.currentCurrency="€";
    } else {
      box.put('currency', 'USD');
      Constant.currentCurrency="\$";
    }
    balance = [];
    _balance.value = 0.0;
    loadList(true).then((value) {
      value.forEach((element) {
        balance.add(element);
      });
      getbalance(balance);
      return balance;
    });
  }

  ValueNotifier<double> getbalance(List<Pricemodel> data) {
    final box = Hive.box('assets');
    var temp;
    for (var i = 0; i < box.length; i++) {
      final assetbox = box.getAt(i) as AssetBox;
      for (var y = 0; y < data.length; y++) {
        Pricemodel asset = data[y];
        if (asset.data.base == assetbox.asset) {
          var amount = double.parse(assetbox.amount);
          var price = double.parse(asset.data.amount);
          temp = amount * price;
        }
      }
      _balance.value = _balance.value + temp;
    }
    return _balance;
  }

  ListTile _getListItemUi(Pricemodel priceData, int index) {
    String image = priceData.data.base;
    double holding = holdings(priceData.data.base);
    var amount = double.parse(priceData.data.amount);
    return ListTile(
      title: Text(
        priceData.data.base,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        "Current Holdings:" + holding.toString(),
        style: TextStyle(color: Colors.white54),
      ),
      trailing: Text(
        amount.toStringAsFixed(4) + ""+Constant.currentCurrency,
        style: TextStyle(color: Colors.white),
      ),
      leading: Image.asset('assets/$image.png'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssetPage(priceData, holding),
          ),
        );
      },
    );
  }

  double holdings(String assetId) {
    final hivebox = Hive.box('assets');
    var holding = 0.0;
    for (var i = 0; i < hivebox.length; i++) {
      final assetbox = hivebox.getAt(i) as AssetBox;
      if (assetbox.asset == assetId) {
        var amount = double.parse(assetbox.amount);
        holding = holding + amount;
      }
    }
    return holding;
  }

  void _initializeTimer(){
    timer=Timer.periodic(const Duration(minutes: 2), (_) => loadList(true));
  }

}

