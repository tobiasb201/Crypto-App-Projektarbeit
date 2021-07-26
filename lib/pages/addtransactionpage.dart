import 'package:crypto_app/constants/constant.dart';
import 'package:crypto_app/models/assetbox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends StatefulWidget {
  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  String asset = "BTC"; //Selected Asset
  final _assets = Constant.currencies; //All choosable Assets
  String action = "Buy"; //Selected Action
  final _actions = ["Buy", "Sell"];
  final formKey = GlobalKey<FormState>(); //
  String _price;
  String _amount;
  String _date;

  var textController = TextEditingController(); //Edit Textfield's

  Box assetBox; //TransactionBox(Hive)

  @override
  void initState() {
    super.initState();
    assetBox = Hive.box("assets"); //Box name
  }

  void buyorsell(){ //Adds + or - to the Tnputfield wether its a buy or sell action
    if(action=="Buy"){
      textController.value=textController.value.copyWith(text: "+");
    }
    if(action=="Sell"){
      textController.value=textController.value.copyWith(text: "-");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("UTDCrypto",style: TextStyle(color: Colors.grey[500])),
        backgroundColor: Colors.grey[900],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container( //Contrainer for Headline
                      width: MediaQuery.of(context).size.width/1.6, //Fixed width depending on device
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[700]),
                      borderRadius: BorderRadius.circular(23),
                      boxShadow: [
                    BoxShadow(
                      color: Colors.amber[50].withOpacity(0.1),
                      )
                      ]
                    ),
                      child: Center(
                        child: FittedBox(child: Text("New Transaction",style: TextStyle(fontSize: 20,color: Colors.amber[600])))
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50, right: 50, top: 10,bottom: 20),
                      child: Row(
                        children: <Widget>[
                          DropdownButton(
                            dropdownColor: Colors.grey[700],
                            value: asset,
                            onChanged: (newValue) {
                              setState(() {
                                asset = newValue;
                              });
                            },
                            items: _assets.map((item) {
                              return DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: TextStyle(color: Colors.white),
                                  ));
                            }).toList(),
                          ),
                          Spacer(),
                          DropdownButton(
                            dropdownColor: Colors.grey[700],
                            value: action,
                            onChanged: (newValue) {
                              setState(() {
                                action = newValue;
                              });
                              buyorsell(); //Checks option selected, to prefill textfield
                            },
                            items: _actions.map((item) {
                              return DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: TextStyle(color: Colors.white),
                                  ));
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _buildAmount(),
                    SizedBox(
                      height: 10,
                    ),
                    _buildPrice(),
                    SizedBox(
                      height: 10,
                    ),
                    _buildDate(),
                    SizedBox(
                      height: 30,
                    ),
                    TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.amber[600])),
                        onPressed: () {
                          if (formKey.currentState.validate()) { //Validates if textfields are filled
                            formKey.currentState.save(); //Saves state of textfields
                            final AssetBox newTransaction = AssetBox( //New Transaction
                                action: action,
                                amount: _amount,
                                asset: asset,
                                date: _date,
                                price: _price);
                            assetBox.add(newTransaction); //Adds data to hive-box
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Added new Transaction",style: TextStyle(color: Colors.amber[600]),), behavior: SnackBarBehavior.floating,)
                            );//Snackbar shows if transaction has been created
                          }
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Add Transaction",
                          style: TextStyle(color: Colors.black),
                        )),
                  ],
                ),
              )),
        ),
      ),
      backgroundColor: Colors.grey[900],
    );
  }

  Widget _buildPrice() {
    return Flexible(
        child: TextFormField(
      style: TextStyle(color: Colors.white54),
      decoration: InputDecoration(
        hintText: 'Price:',
        hintStyle: TextStyle(color: Colors.white38),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      // ignore: missing_return
      validator: (value) {
        if (value.trim().isEmpty) { //No Price input
          return "Price is Required";
        }
        if (value.length < 0) {
          return 'Price must be greater 0';
        }
      },
      onSaved: (value) {
        return _price = value;
      },
      maxLength: 20, //Max Price length
    ));
  }

  Widget _buildAmount() {
    return Flexible(
        child: TextFormField(
      style: TextStyle(color: Colors.white54),
      decoration: InputDecoration(
        hintText: 'Amount:',
        hintStyle: TextStyle(color: Colors.white38),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      controller: textController, //textcontroller variable for editing
      // ignore: missing_return
      validator: (value) {
        if (value.trim().isEmpty) {
          return "Amount is Required";
        }
        if (value.length < 0) {
          return 'Amount must be greater 0';
        }
      },
      onSaved: (value) {
        return _amount = value;
      },
    ));
  }

  Widget _buildDate() {
    final now = new DateTime.now();
    String formatter = DateFormat('yMd').format(now); //Only year,month,day
    return Flexible(
        child: TextFormField(
      style: TextStyle(color: Colors.white54),
      decoration: InputDecoration(
        labelText: "Date:",
        labelStyle: TextStyle(color: Colors.white38),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      initialValue: formatter.toString(),
      onSaved: (value) {
        return _date = formatter;
      },
    ));
  }
}
