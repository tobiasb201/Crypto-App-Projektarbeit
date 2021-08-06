import 'package:crypto_app/models/assetstats.dart';
import 'package:crypto_app/models/pricemodel.dart';
import 'package:crypto_app/service/apiService.dart';
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
  Future<AssetStats> _stats; //statistics from api
  List _filteredTransactions; //Transactions from Hive
  var _icon;
  String _currency;

  @override
  void initState() {
    _stats = ApiService().getstats(widget.asset.data.base); //Selected asset stats
    Box transactions = Hive.box('assets');//Transaction hive-box
    _currency=Constant.currentCurrency; //gets current selected currency
    _filteredTransactions=transactions.values.where((element) => element.asset==widget.asset.data.base).toList(); //selected asset transactions
    _icon=widget.asset.data.base; //IconName
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("UTDCrypto",style: TextStyle(color: Colors.grey[500])),
        backgroundColor: Colors.grey[900],
      ),
      body: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 5,left: 0,right: 0,top: 20),
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            Spacer(),
                            Image.asset('assets/$_icon.png'),
                            Text(widget.asset.data.base, //Selected name from homepage
                              textAlign: TextAlign.center,
                              style: TextStyle(height: 1, fontSize: 50,color: Colors.white),),
                            Spacer(),
                          ],
                        ),
                        Text("("+Constant.assetNameMap[widget.asset.data.base]+")",style: TextStyle(color: Colors.white)),//Gets full name from constant Class
                      ],
                    ),
                  )
                ),
              ),
              Container(
                  child: FutureBuilder<AssetStats>( //FutureBuilder for statistics
                      future: _stats,
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          AssetStats info = snapshot.data;
                          return _gridView(info); //function displays multiple stats
                        }
                        else {
                          return Center(child: CircularProgressIndicator()); //No internet connection
                        }
                      }
                  )
              ),
              Center(child: FittedBox(child: Text("Transactions:",style: TextStyle(color: Colors.amber[600], fontSize: 20)))),
              transactionLength(_filteredTransactions),//Checks transaction length
              Expanded(
                child: ListView.builder(itemCount:_filteredTransactions.length,shrinkWrap:true,itemBuilder: (context,index) {
                  final transaction = _filteredTransactions[index] as AssetBox; //Each Transactions going trough the function
                  return transactionList(transaction);
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
        crossAxisCount: 2, //2 Cards pro Row
        childAspectRatio: 1.8, //Größe der Card
        padding: EdgeInsets.all(20),
        children: <Widget>[
          Card(
            elevation: 0,
            color: Colors.black45,
              child: Column(
                children: <Widget>[
                  Text("24h Volumen:",style: TextStyle(color: Colors.white),),
                  SizedBox(height: 10),
                  Center( //FittedBox is responsive
                    child: FittedBox(child: Text(getvolume(info)+""+_currency,textAlign: TextAlign.center, style: TextStyle(color:Colors.white,fontSize: 30),))
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
                      child: FittedBox(child: Text(info.last+""+_currency, textAlign: TextAlign.center, style: TextStyle(color:Colors.white,fontSize: 30),))
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
                      child: FittedBox(child: Text(balance(info.last).toStringAsFixed(2)+""+_currency, style: TextStyle(fontSize: 30, color:Colors.white),))
                  )
                ],
              )
          ),
        ]
    );
  }
  double balance(String price){ //returns Balance specific to the asset
    var balance=0.0;
    var amount= double.parse(price);
    balance=widget.holding*amount;
    return balance;
  }

  ListTile transactionList(AssetBox transaction){
    return ListTile(
      title: Text(
        transaction.asset,
        style: TextStyle(color: Colors.amber[400]),
      ),
      subtitle: Text("Price:" +
          transaction.price.toString() +Constant.currentCurrency
          +"\nAmount:" +
          transaction.amount.toString(),style: TextStyle(color:Colors.amber[400]),),
      trailing: FittedBox(
        child: Column(
          children: [
            actionColor(transaction.action),
            SizedBox(height: 10),
            calculatePriceDifference(transaction.price, widget.asset.data.amount)
          ],
        ),
      ),
      leading: Text(transaction.date.toString(),style: TextStyle(color: Colors.white60),),
      isThreeLine: true,
    );
  }

  Align transactionLength(List transactionList){
    if(transactionList.length<1){ //If no transactions listed
      return Align(alignment: Alignment.center,child: Text("....",style: TextStyle(fontSize: 18)));
    }
    return Align();
  }


  Text actionColor(String action) { //Selects Color for each transaction
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


  String getvolume(AssetStats info){//Get Volume (volume is amount of coins and not price)
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

  Text calculatePriceDifference(String transactionPrice,String assetPrice){
    var currentPrice= double.parse(assetPrice);
    var boughtPrice = double.parse(transactionPrice);

    if(boughtPrice<currentPrice){
      var one= boughtPrice/100;
      var two=currentPrice/one;
      var result =two-100;
      return Text("+"+result.toStringAsFixed(2)+"%", style: TextStyle(fontSize:15,color:Colors.green));
    }
    else{
      var one = boughtPrice/100;
      var two= currentPrice/one;
      var result= two-100;
      return Text("-"+result.toStringAsFixed(2)+"%", style: TextStyle(fontSize:15,color:Colors.red));
    }
  }
}
