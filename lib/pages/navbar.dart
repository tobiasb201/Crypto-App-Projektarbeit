import 'package:crypto_app/pages/homepage.dart';
import 'package:crypto_app/pages/notificationpage.dart';
import 'package:crypto_app/pages/transactionpage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 1;
  List<Widget> _widgetOptions = <Widget>[
    NotificationPage(),
    HomePage(),
    TransactionPage(),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.grey[700],
        backgroundColor: Colors.grey[900],
        buttonBackgroundColor: Colors.white,
        height: 50,
    items: <Widget>[
      Icon(Icons.notifications),
      Icon(Icons.home),
      Icon(Icons.business),
    ],
        onTap: _onTap,
        index: 1,
        animationDuration: Duration(milliseconds: 300),
    )
    );
  }
}
