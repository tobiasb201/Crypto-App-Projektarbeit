import 'package:crypto_app/pages/homepage.dart';
import 'package:crypto_app/pages/notificationpage.dart';
import 'package:crypto_app/pages/transactionpage.dart';
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Transactions',
          ),
        ],
        selectedItemColor: Colors.amber[600],
        unselectedItemColor: Colors.white38,
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}
