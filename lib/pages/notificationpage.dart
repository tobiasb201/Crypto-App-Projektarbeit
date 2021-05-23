import 'package:crypto_app/models/hivenotification.dart';
import 'package:flutter/material.dart';
import 'package:crypto_app/constants/constant.dart';
import 'package:hive/hive.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  final _action = ["15Min","1h"];
  // ignore: deprecated_member_use
  List<String> checkTime = ["15Min","15Min","15Min","15Min","15Min","15Min","15Min","15Min","15Min"];
  List<bool> _switch =[false,false,false,false,false,false,false,false,false];
  bool isSwitched= false;

  List<int> percentage = [3,3,3,3,3,3,3,3,3];
  final _percentage=[3,4,5];

  Box notificationBox;

  @override
  void initState() {
    super.initState();
    notificationBox = Hive.box("notification");
    if(notificationBox.isNotEmpty){
      for(var y=0;y<notificationBox.length;y++){
       HiveNotification test= notificationBox.getAt(y);
       print(test.asset);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crypto App"),
        backgroundColor: Colors.grey[900],
      ),
      body: SafeArea(
        child: ListView.builder(itemCount: Constant.currencies.length,itemBuilder: (context,index){
          return listOverlay(Constant.currencies[index],index);
        }),
      ),
      backgroundColor: Colors.grey[900],
    );
  }

  Widget listOverlay(String asset,int index){
    return Container(
      height: 60,
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black)
      ),
      child: Row(
        children: <Widget>[
          Text(""+asset,style: TextStyle(color: Colors.amber[600],fontSize: 18),),
          Spacer(),
          DropdownButton(
            dropdownColor: Colors.grey[700],
            value: checkTime[index],
            onChanged: (newValue) {
              setState(() {
                checkTime[index] = newValue;
              });
            },
            items: _action.map((item) {
              return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(color: Colors.white),
                  ));
            }).toList(),
          ),
          Container(
            margin: EdgeInsets.only(left: 25),
            child: DropdownButton(
              dropdownColor: Colors.grey[700],
              value: percentage[index],
              onChanged: (newValue) {
                setState(() {
                  percentage[index] = newValue;
                });
              },
              items: _percentage.map((item) {
                return DropdownMenuItem(
                    value: item,
                    child: Text(
                      item.toString()+"%",
                      style: TextStyle(color: Colors.white),
                    ));
              }).toList(),
            ),
          ),
          Spacer(),
          Switch(
            value: _switch[index],
            onChanged: (value){
              setState(() {
                _switch[index]=value;
              });
              if(_switch[index]==true){
                final HiveNotification newNotification = HiveNotification(asset: asset,time: checkTime[index],percent: percentage[index]);
                notificationBox.add(newNotification);
              }
              else{
                notificationBox.deleteAt(index);
              }
            },
            activeTrackColor: Colors.yellow,
            activeColor: Colors.amber[600],
          )
        ],
      ),
    );
  }


}
