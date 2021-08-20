import 'package:crypto_app/models/assetbox.dart';
import 'package:crypto_app/models/pricemodel.dart';
import 'package:crypto_app/pages/assetpage.dart';
import 'package:crypto_app/service/api_service.dart';
import 'package:crypto_app/service/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:crypto_app/constants/constant.dart';
import 'dart:async';
import 'package:hive/hive.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<List<Pricemodel>> _prices; //price list
  ValueNotifier<double> _balance = ValueNotifier<double>(0); //Balance notifier
  List<Pricemodel> _transactionsForBalance = [];
  Timer reloadTimer; //timer for automatic 2min price refresh

  @override
  void initState() {
    loadList(false).then((value) {  //takes prices from Hive
      value.forEach((element) {
        _transactionsForBalance.add(element);
      });
      getBalance(_transactionsForBalance); //balance=Pricemodel
      return _transactionsForBalance;
    });
    _initializeTimer();
    super.initState();

    NotificationService().notificationPermission();
    NotificationService().initMessaging();
    NotificationService().getToken();
  }

  Future loadList(bool refresh) async {//Check if $ or € prices has to be requested
    final box = Hive.box('fetchingCurrency');
    if (box.isEmpty) {
      box.put('fetchingCurrency', 'USD');
      Constant.currentCurrency="\$";
    }
    else if(box.isNotEmpty){
      if(box.get('fetchingCurrency')=="USD"){
        Constant.currentCurrency="\$";
      }
      else{
        Constant.currentCurrency="€";
      }
    }
      _prices = ApiService().getprices(refresh); //refresh==true means from api
      setState(() {
        _prices = this._prices;
      });
      return _prices;
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
            onTap: changeCurrency,
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
              future: _prices,
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

  void changeCurrency() { //Changes currency when clicking on balance
    final box = Hive.box('fetchingCurrency');
    if (box.get('fetchingCurrency') == 'USD') {
      box.put('fetchingCurrency', 'EUR');
      Constant.currentCurrency="€";
    } else {
      box.put('fetchingCurrency', 'USD');
      Constant.currentCurrency="\$";
    }
    _transactionsForBalance = []; //Transactions to calculate balance
    _balance.value = 0.0;
    loadList(true).then((value) { //Loading new price data
      value.forEach((element) {
        _transactionsForBalance.add(element);
      });
      getBalance(_transactionsForBalance);
      return _transactionsForBalance;
    });
  }

  ValueNotifier<double> getBalance(List<Pricemodel> data) { //Calculates Balance
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
    reloadTimer=Timer.periodic(const Duration(minutes: 2), (_) => loadList(true));
  }

}

