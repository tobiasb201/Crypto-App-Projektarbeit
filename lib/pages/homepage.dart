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
  FirebaseMessaging messaging = FirebaseMessaging.instance; //Cloud Messaging

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<List<Pricemodel>> prices; //price list
  ValueNotifier<double> _balance = ValueNotifier<double>(0); //Balance notifier
  List<Pricemodel> balance = [];
  final homepageData= Hive.box('homepageData'); //Hive box for cached prices
  Timer timer; //timer for automatic 2min price refresh

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


  @override
  void initState() {
    loadList(false).then((value) {  //takes prices from Hive
      value.forEach((element) {
        balance.add(element);
      });
      getbalance(balance); //balance=Pricemodel
      return balance;
    });
    _initializeTimer();
    super.initState();

    notificationPermission();
    initMessaging();
    getToken();
  }

  Future loadList(bool refresh) async {//Check if $ or € prices has to be requested
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
      prices = Api_Service().getprices(refresh); //refresh==true means from api
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

  Future refresh() async { //For the pull down functionality
    Future.delayed(Duration(seconds: 1));//1sec duration to prevent spam
    loadList(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("UTDCrypto",style: TextStyle(color: Colors.grey[500]))),
        elevation: 1.0,
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
            child: ValueListenableBuilder( //Listens to _balance for updating in realtime
              valueListenable: _balance,
              builder: (context, double balance, _) {
                if (Hive.box('assets').isEmpty) {
                  return Center(
                    child: Text("Current Balance: 0"+Constant.currentCurrency
                    ),
                  );
                } else if (Hive.box('assets').isNotEmpty && _balance.value == 0.0){
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[900]),
                      backgroundColor: Colors.amber[600],
                    ),
                  );
                }
                else{
                  return Center(
                    child: Text("Current Balance:" +
                        _balance.value.toStringAsFixed(2) +
                        ""+Constant.currentCurrency
                    ),
                  );
                }
              }
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator( //pull down refresh functionality
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
                        return _getListItemUi(priceData, index); //Price list for each asset
                      });
                } else {
                  return Center(child: CircularProgressIndicator()); //preventing loading times
                }
              },
            ),
          ),
        ),
      ]),
      backgroundColor: Colors.grey[900],
    );
  }

  void changecurrency() { //Changes currency when clicking on balance
    final box = Hive.box('currency');
    if (box.get('currency') == 'USD') {
      box.put('currency', 'EUR');
      Constant.currentCurrency="€";
    } else {
      box.put('currency', 'USD');
      Constant.currentCurrency="\$";
    }
    balance = []; //Transactions to calculate balance
    _balance.value = 0.0;
    loadList(true).then((value) { //Loading new price data
      value.forEach((element) {
        balance.add(element);
      });
      getbalance(balance);
      return balance;
    });
  }

  ValueNotifier<double> getbalance(List<Pricemodel> data) { //Calculates Balance
    final box = Hive.box('assets');
    var temp;
    for (var i = 0; i < box.length; i++) { //each transaction
      final assetbox = box.getAt(i) as AssetBox;
      for (var y = 0; y < data.length; y++) { //each Pricemodel
        Pricemodel asset = data[y];
        if (asset.data.base == assetbox.asset) { //pricemodel Asset == transaction asset
          var amount = double.parse(assetbox.amount);
          var price = double.parse(asset.data.amount);
          temp = amount * price;
        }
      }
      _balance.value = _balance.value + temp; //balance addition
    }
    return _balance;
  }

  ListTile _getListItemUi(Pricemodel priceData, int index) { //Asset list
    String image = priceData.data.base;
    double holding = holdings(priceData.data.base);
    var amount = double.parse(priceData.data.amount);
    return ListTile(
      title: Text(
        priceData.data.base,
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        "Current Holdings:" + holding.toStringAsFixed(5),
        style: TextStyle(color: Colors.white54),
      ),
      trailing: Text(
        amount.toStringAsFixed(4) + ""+Constant.currentCurrency,
        style: TextStyle(color: Colors.white),
      ),
      leading: Image.asset('assets/$image.png'),
      onTap: () { //click on Asset to navigate to Asset page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssetPage(priceData, holding),
          ),
        );
      },
    );
  }

  double holdings(String assetId) { //Shows current Holdings of each asset
    final hivebox = Hive.box('assets'); //Transaction hive-box
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

  void _initializeTimer(){ //2min Timer for price update
    timer=Timer.periodic(const Duration(minutes: 2), (_) => loadList(true));
  }

}

