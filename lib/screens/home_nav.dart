import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_manager/main.dart';
import 'package:spotify_manager/screens/projects_screen.dart';

class HomeNav extends StatefulWidget {
  @override
  State createState() => HomeNavState();
}

class HomeNavState extends State<HomeNav> {
  int _selectedIndex = 0;
  static List<Widget> _screens = <Widget>[
    ProjectsScreen(),
    HomeScreen()
  ];


  static const _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.reorder), title: Text("Projects")),
    BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home"))
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
          Padding(padding: EdgeInsets.only(bottom: 20),),
          Row(mainAxisAlignment: MainAxisAlignment.end,children: <Widget>[IconButton(icon: Icon(Icons.settings,),onPressed: (){},)],),
          Expanded(child: _screens.elementAt(_selectedIndex),)
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


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return
      Column(children: <Widget>[
    Text("Hello ${SpotifyContainer.of(context).myDetails.displayName}!")]);
  }
}
