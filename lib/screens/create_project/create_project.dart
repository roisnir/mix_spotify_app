import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotify/spotify_io.dart';
import 'package:spotify_manager/common/utils.dart';
import 'package:spotify_manager/screens/create_project/config_page.dart';


class CreateProject extends StatefulWidget {
  final SpotifyApi api;
  final User userDetails;
  final List<PlaylistSimple> playlists;
  final List<ConfigPage> configPages;

  CreateProject({this.api, this.playlists, this.userDetails, this.configPages});

  @override
  _CreateProjectState createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
  final controller = PageController();
  List<ConfigPage> configPages;
  List<bool> selectedPlaylists;
  double prevPage = 0;
  String projectName;

  @override
  void initState() {
    super.initState();
    configPages = []..addAll(widget.configPages);
    configPages[0].current = true;
    controller.addListener(handlePageChange);
  }

  handlePageChange(){
    if (!(prevPage.isInt() && controller.page > prevPage)) {
      prevPage = controller.page;
      return;
    }
    int page = prevPage.toInt();
    if (configPages[page].key.currentState.validate())
      configPages[page].key.currentState.save();
    else
      controller.goToPage(page);
    prevPage = controller.page;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
        Padding(padding: EdgeInsets.only(bottom: 20),),
        topBar(context),
        Expanded(
          child: pageView(),
        )
      ]),
    );
  }

  Widget pageView() {
    return Column(children: [
      Expanded(child: PageView(
        children: configPages.map<Form>((e) => e.build()).toList(growable: false),
        controller: controller,
        onPageChanged: (pageIndex){
          setState(() {
//            configPages.forEach((page) => page.current = false);
            configPages[prevPage.toInt()].current = false;
            configPages[pageIndex].current = true;
          });
        },
      ),)
    ],);
  }

  Widget topBar(BuildContext context) => Row(
      children: <Widget>[
        IconButton(
            iconSize: 48,
            icon: Icon(
              Icons.keyboard_arrow_down,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }
        )
      ]);
}




