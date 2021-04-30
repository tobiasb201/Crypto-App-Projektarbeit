import 'package:crypto_app/models/assetstats.dart';
import 'package:crypto_app/models/pricemodel.dart';
import 'package:crypto_app/service/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:crypto_app/constants/constant.dart';
import 'package:hive/hive.dart';
import 'package:crypto_app/models/assetbox.dart';


class AssetPage extends StatefulWidget {
  final Pricemodel asset;
  final double holding;
  AssetPage(this.asset,this.holding);

  @override
  _AssetPageState createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  Future<AssetStats> stats;
  List filteredTransactions;
  var icon;
  String currency;

  @override
  void initState() {
    stats = Api_Service().getstats(widget.asset.data.base);
    Box transactions = Hive.box('assets');
    currency=Constant.currentCurrency;
    filteredTransactions=transactions.values.where((element) => element.asset==widget.asset.data.base).toList();
    icon=widget.asset.data.base;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crypto App"),
      ),
      body: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 5,left: 0,right: 0,top: 20),
                    child: Row(
                      children: <Widget>[
                        Spacer(),
                        Image.asset('assets/$icon.png'),
                        Text(widget.asset.data.base,
                          textAlign: TextAlign.center,
                          style: TextStyle(height: 1, fontSize: 50,color: Colors.white),),
                        Spacer(),
                      ],
                    ),
                  )
                ),
              ),
              Container(
                  child: FutureBuilder<AssetStats>(
                      future: stats,
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          AssetStats info = snapshot.data;
                          return _gridView(info);
                        }
                        else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }
                  )
              ),
              Expanded(
                child: ListView.builder(itemCount:filteredTransactions.length,shrinkWrap:true,itemBuilder: (context,index) {
                  final transaction = filteredTransactions[index] as AssetBox;
                  return transactionlist(transaction);
                }),
              ),
            ],
          ),
      ),
      backgroundColor: Colors.grey[900],
    );
  }

  GridView _gridView(AssetStats info) {
    return GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: 1.7,
        padding: EdgeInsets.all(20),
        children: <Widget>[
          Card(
            elevation: 0,
            color: Colors.black45,
              child: Column(
                children: <Widget>[
                  Text("24h Volumen:",style: TextStyle(color: Colors.white),),
                  SizedBox(height: 10),
                  Center(
                    child: Text(getvolume(info)+""+currency,textAlign: TextAlign.center, style: TextStyle(color:Colors.white,fontSize: 30),)
                  ),
                ],
              )
          ),
          Card(
              elevation: 0,
              color: Colors.black45,
              child: Column(
                children: <Widget>[
                  Text("Price:",style: TextStyle(color: Colors.white),),
                  SizedBox(height: 10),
                  Center(
                      child: Text(info.last+""+currency, textAlign: TextAlign.center, style: TextStyle(color:Colors.white,fontSize: 30),)
                  ),
                ],
              )
          ),
          Card(
              elevation: 0,
              color: Colors.black45,
              child: Column(
                children: <Widget>[
                  Text("24hour Change:",style: TextStyle(color: Colors.white),),
                  SizedBox(height: 10),
                  Center(
                    child:get24hchange(info)
                  ),
                ],
              )
          ),
          Card(
              elevation: 0,
              color: Colors.black45,
              child: Column(
                children: <Widget>[
                  Text("Balance:",style: TextStyle(color: Colors.white),),
                  SizedBox(height: 10),
                  Center(
                      child: Text(balance(info.last).toStringAsFixed(2)+""+currency, style: TextStyle(fontSize: 30, color:Colors.white),)
                  )
                ],
              )
          ),
        ]
    );
  }
  double balance(String price){
    var balance=0.0;
    var amount= double.parse(price);
    balance=widget.holding*amount;
    return balance;
  }

  ListTile transactionlist(AssetBox transaction){
    return ListTile(
      title: Text(
        transaction.asset,
        style: TextStyle(color: Colors.amber[400]),
      ),
      subtitle: Text("Price:" +
          transaction.price.toString() +Constant.currentCurrency
          +"\nAmount:" +
          transaction.amount.toString(),style: TextStyle(color:Colors.amber[400]),),
      trailing: actioncolor(transaction.action),
      leading: Text(transaction.date.toString(),style: TextStyle(color: Colors.white60),),
      isThreeLine: true,
    );
  }

  Text actioncolor(String action) {
    if (action == "Buy") {
      return Text(
        action,
        style: TextStyle(color: Colors.green[400]),
      );
    } else {
      return Text(
        action,
        style: TextStyle(color: Colors.red[400]),
      );
    }
  }

  String getvolume(AssetStats info){
    var volume = double.parse(info.volume);
    var price = double.parse(info.last);
    var t2= price*volume;
    return t2.toStringAsFixed(0);
  }
  Text get24hchange(AssetStats info){
    var openprice= double.parse(info.open);
    var lastprice= double.parse(info.last);

    if(openprice<lastprice){
      var one = openprice/100;
      var two= lastprice/one;
      var result= two-100;
      return Text("+"+result.toStringAsFixed(2)+"%", style: TextStyle(fontSize:30,color:Colors.green));
    }
    else{
      var one= openprice/100;
      var two=lastprice/one;
      var result =100-two;
      return Text("-"+result.toStringAsFixed(2)+"%", style: TextStyle(fontSize:30,color:Colors.red));
    }

  }
}