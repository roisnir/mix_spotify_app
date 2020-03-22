import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_manager/main.dart';

class HomeScreen extends StatelessWidget{
  final int totalProjects;

  HomeScreen(this.totalProjects);

  @override
  Widget build(BuildContext context) => Column(children: <Widget>[
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
      child: Text("Hello ${SpotifyContainer.of(context).myDetails.displayName}!",
      style: Theme.of(context).textTheme.headline4,),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
      child: Text("You have $totalProjects active projects",
      style: Theme.of(context).textTheme.caption,),
    )
  ],);

}