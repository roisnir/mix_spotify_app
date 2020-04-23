import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_manager/main.dart';
import 'package:spotify_manager/screens/home_screen.dart';
import 'package:spotify_manager/screens/projects_screen.dart';

class HomeNav extends StatefulWidget {
  @override
  State createState() => HomeNavState();
}

class HomeNavState extends State<HomeNav> {
  int _selectedIndex = 0;
  List<Widget> _screens(BuildContext context) {
    final global = SpotifyContainer.of(context);
    return <Widget>[
    HomeScreen(global.client, global.myDetails),
    ProjectsScreen(global.myDetails)
  ];
  }


  static const _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home")),
    BottomNavigationBarItem(icon: Icon(Icons.reorder), title: Text("Projects"))
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: <Widget>[
          Padding(padding: EdgeInsets.only(bottom: 30),),
          Expanded(child: _screens(context).elementAt(_selectedIndex),)
        ],),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(top: 15),
        color: Theme.of(context).bottomAppBarColor,
        child: BottomNavigationBar(
            unselectedItemColor: Colors.white54,
            backgroundColor: Theme.of(context).bottomAppBarColor,
            items: _navItems,
            onTap: _onItemTapped,
            currentIndex: _selectedIndex
        ),
      ),
    );
  }
}
