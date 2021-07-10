import 'package:crypto_app/constants/constant.dart';
import 'package:crypto_app/models/assetbox.dart';
import 'package:crypto_app/pages/addtransactionpage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:hive_flutter/hive_flutter.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crypto App"),
        backgroundColor: Colors.grey[900],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(height: 5),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.amber[600])),
                child: Text(
                  "Add Transaction",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTransactionPage(),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: _buildListView(),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[900],
    );
  }

  Widget _buildListView() {
    // ignore: deprecated_member_use
    return WatchBoxBuilder(
      box: Hive.box('assets'),
      builder: (context, assetbox) {
        return ListView.separated(
          separatorBuilder: (context,index)=>Divider(color: Colors.grey[700],),
            shrinkWrap: true,
            itemCount: assetbox.length,
            itemBuilder: (context, index) {
              final asset = assetbox.getAt(index) as AssetBox;
              return Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber[50].withOpacity(0.1),
                      )
                    ]
                ),
                child: ListTile(
                  title: Text(
                    asset.asset,
                    style: TextStyle(color: Colors.amber[400]),
                  ),
                  subtitle: Text("Price: " +
                      asset.price.toString() +
                      ""+Constant.currentCurrency+"\n""Amount: " +
                      asset.amount.toString(),style: TextStyle(color:Colors.amber[400]),),
                  trailing:
                      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    actioncolor(asset.action),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await assetbox.deleteAt(index);
                      },
                    )
                  ]),
                  leading: Container(
                    decoration: BoxDecoration(
                      border: new Border(
                        right: new BorderSide(width: 2, color: Colors.white24)
                      )
                    ),
                      child: Text(asset.date.toString(),style: TextStyle(color: Colors.white60))
                  ),
                  isThreeLine: true,
                ),
              );
            });
      },
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
}
