import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_manager/main.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Widget Function()> builders;

  @override
  void initState() {
    super.initState();
    builders = [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildTextTile("Stats", theme),
          buildStats(theme),
          buildTextTile("Library Status", theme),
          buildLibraryStatus(theme),
          buildTextTile("Action", theme),
          buildCreateProject(theme),
          buildLogo()
        ],
      ),
    );
  }

  Widget buildTextTile(String text, ThemeData theme) => Padding(
      padding: const EdgeInsets.only(top: 15, left: 20),
      child: Text(
        text,
        style: theme.textTheme.headline5,
      ),
    );

  Widget buildStats(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15, top: 15),
          child: Card(
            color: theme.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 90,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.show_chart,
                          size: 96,
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Active Projects: 3", style: theme.textTheme.headline6,),
                          Text("Archived Project: 5", style: theme.textTheme.headline6),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
  }

  Widget buildCreateProject(ThemeData theme) {
    return Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
          child: Card(
            color: theme.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 90,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.add_box,
                          size: 96,
                          color: theme.primaryColor,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Start A New Project!", style: theme.textTheme.headline6,),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
  }

  Widget buildLibraryStatus(ThemeData theme) {
    return Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
          child: Card(
            color: theme.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 90,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.library_music,
                          size: 96,
                          color: Colors.pinkAccent,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("What a mess!", style: theme.textTheme.headline6,),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
  }

  Widget buildLogo()=>Padding(
    padding: EdgeInsets.only(top: 60, bottom: 40),
    child: Center(child: Image.asset("assets/mix_app5.png", height: 128,),),
  );
}
