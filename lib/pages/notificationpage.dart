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

  final _timeOptions = ["15Min","1h"];
  // ignore: deprecated_member_use
  List<String> _checkTime = ["15Min","15Min","15Min","15Min","15Min","15Min","15Min","15Min","15Min"];
  List<bool> _switchActives =[false,false,false,false,false,false,false,false,false];
  FirebaseMessaging _fcm = FirebaseMessaging.instance;//Firebase Cloud Messaging

  List<int> _percentage = [3,3,3,3,3,3,3,3,3];
  final _percentageOptions=[3,4,5];
  NotificationState _notificationObject = new NotificationState(); //Object for notification variables
  Box _notificationBox; //Hive-box

  @override
  void initState() {
    _notificationBox = Hive.box("notification"); //Hive-box for notification states
    if(_notificationBox.isNotEmpty){
      for(var y=0;y<_switchActives.length;y++){
       _notificationObject= _notificationBox.get(y) as NotificationState;
       if(_notificationObject!=null){
         _switchActives[y]=_notificationObject.switchState; //turns switches on
         _checkTime[y]=_notificationObject.time; //right time saved by hive-box
         _percentage[y]=_notificationObject.percentage.toInt();//right percentage saved by hive-box
       }
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("UTDCrypto",style: TextStyle(color: Colors.grey[500]))),
        elevation: 1.0,
        backgroundColor: Colors.grey[900],
      ),
      body: SafeArea(
        child: ListView.builder(itemCount: Constant.currencies.length,itemBuilder: (context,index){
            return listOverlay(Constant.currencies[index],index);//Each list item for a notification
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
            Icon(Icons.access_alarm,color: Colors.grey),
            DropdownButton(
              dropdownColor: Colors.grey[700],
              value: _checkTime[index],
              underline: SizedBox(), //makes the underline go away and sets a empty SizedBox below the time
              onChanged: (newValue) {
                if(_switchActives[index]==false){
                  setState(() {
                    _checkTime[index] = newValue;
                  });
                }
              },
              items: _timeOptions.map((item) {
                return DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(color: Colors.white),
                    ));
              }).toList(),
            ),
            Container(
              margin: EdgeInsets.only(left: 38),
              child: DropdownButton(
                dropdownColor: Colors.grey[700],
                value: _percentage[index],
                underline: SizedBox(), //makes the underline go away and sets a empty SizedBox below the percentage
                onChanged: (newValue) {
                  if(_switchActives[index]==false){
                    setState(() {
                      _percentage[index] = newValue;
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
            Spacer(), //left space between dropdown menu and switch
            Switch(
              value: _switchActives[index],
              onChanged: (value) async {
                setState(() {
                  _switchActives[index]=value;
                });
                if(_switchActives[index]==true){
                  _fcm.subscribeToTopic(asset.toString()+_checkTime[index].toString()+_percentage[index].toString()+'%'); //subscribes to topic in firebase
                  final NotificationState newNotification = NotificationState( //creates new Notification model
                      time: _checkTime[index],
                      asset: asset,
                      percentage: _percentage[index].toDouble(),
                      switchState: _switchActives[index]);
                  _notificationBox.put(index,newNotification); //saves notification model in hive-box and the right index
                }
                else{
                  _fcm.unsubscribeFromTopic(asset.toString()+_checkTime[index].toString()+_percentage[index].toString()+'%'); //unsubscribes from topic
                  await _notificationBox.delete(index); //deletes the notification state at index
                }
              },
              activeTrackColor: Colors.yellow, //Background switch Color when active
              activeColor: Colors.amber[600], //switch circle color
            )
          ],
        ),
      ),
    );
  }
}
