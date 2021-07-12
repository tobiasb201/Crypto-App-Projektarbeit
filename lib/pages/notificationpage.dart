import 'package:crypto_app/models/notificationstate.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
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
  FirebaseMessaging fcm = FirebaseMessaging.instance;

  List<int> percentage = [3,3,3,3,3,3,3,3,3];
  final _percentageOptions=[3,4,5];
  NotificationState state = new NotificationState();
  Box notificationBox;

  @override
  void initState() {
    notificationBox = Hive.box("notification");
    if(notificationBox.isNotEmpty){
      for(var y=0;y<_switch.length;y++){
       state= notificationBox.get(y) as NotificationState;
       if(state!=null){
         _switch[y]=state.switchState;
         checkTime[y]=state.time;
         percentage[y]=state.percentage.toInt();
       }
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("UTDCrypto")),
        elevation: 1.0,
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 70,
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.amber[50].withOpacity(0.1),
              )
            ]
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 7,left: 7),
              child: Image.asset('assets/$asset.png'),
            ),
            Text(""+asset,style: TextStyle(color: Colors.amber[600],fontSize: 18),),
            Spacer(),
            DropdownButton(
              dropdownColor: Colors.grey[700],
              value: checkTime[index],
              onChanged: (newValue) {
                if(_switch[index]==false){
                  setState(() {
                    checkTime[index] = newValue;
                  });
                }
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
                  if(_switch[index]==false){
                    setState(() {
                      percentage[index] = newValue;
                    });
                  }
                },
                items: _percentageOptions.map((item) {
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
              onChanged: (value) async {
                setState(() {
                  _switch[index]=value;
                });
                if(_switch[index]==true){
                  fcm.subscribeToTopic(asset.toString()+checkTime[index].toString()+percentage[index].toString()+'%');
                  final NotificationState newNotification = NotificationState(
                      time: checkTime[index],
                      asset: asset,
                      percentage: percentage[index].toDouble(),
                      switchState: _switch[index]);
                  notificationBox.put(index,newNotification);
                }
                else{
                  fcm.unsubscribeFromTopic(asset.toString()+checkTime[index].toString()+percentage[index].toString()+'%');
                  await notificationBox.delete(index);
                }
              },
              activeTrackColor: Colors.yellow,
              activeColor: Colors.amber[600],
            )
          ],
        ),
      ),
    );
  }
}
