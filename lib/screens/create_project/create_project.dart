import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotify/spotify_io.dart';
import 'package:spotify_manager/common/project_manager/model/project.dart';
import 'package:spotify_manager/common/utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:spotify_manager/screens/create_project/config_pages/config_page.dart';
import 'package:spotify_manager/screens/create_project/config_pages/name_config_page.dart';
import 'package:spotify_manager/screens/create_project/config_pages/playlists_config_page.dart';


class CreateProject extends StatefulWidget {
  final SpotifyApi api;
  final User userDetails;
  final List<PlaylistSimple> playlists;
  final List<ConfigPage> configPages;
  final void Function(String) onNameSaved;
  final void Function(List<PlaylistSimple>) onPlaylistsSaved;
  final Future<ProjectConfiguration> Function() onSubmit;

  CreateProject({
    @required this.api,
    @required this.playlists,
    @required this.userDetails,
    List<ConfigPage> configPages,
    @required this.onNameSaved,
    @required this.onPlaylistsSaved,
    @required this.onSubmit,
  }): this.configPages = configPages ?? [];

  @override
  _CreateProjectState createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
  final controller = PageController();
  List<ConfigPage> configPages;
  int prevPage = 0;
  String projectName;

  @override
  void initState() {
    super.initState();
    final selectedPlaylists = List<bool>.generate(widget.playlists.length, (i) => false);
    configPages = widget.configPages..addAll([
      PlaylistsConfigPage(
        onSaved: (selected){
          widget.onPlaylistsSaved(widget.playlists
            .asMap()
            .entries
            .where((e) => selected[e.key])
            .map((entry)=>entry.value).toList());
        },
        playlists: widget.playlists,
        selectedPlaylists: selectedPlaylists,
      ),
      NameConfigPage(
          onSaved: widget.onNameSaved,
          onSubmit: (){
            configPages.last.key.currentState.save();
            return widget.onSubmit();
          })
    ]);
    controller.addListener(handlePageChange);
  }

  handlePageChange(){
    if (controller.page > prevPage) { // tried to move to the next page
      if (configPages[prevPage].key.currentState.validate())
        configPages[prevPage].key.currentState.save();
      else {
        controller.goToPage(prevPage, duration: Duration(milliseconds: 10));
        return;
      }
    }
    if (controller.page.isInt())
      prevPage = controller.page.toInt();
  }

  int get curPage => controller.hasClients ? controller.page.round() : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding:false,
      body: Column(children: <Widget>[
        Padding(padding: EdgeInsets.only(bottom: 20),),
        topBar(context),
        Expanded(
          child: pageView(context),
        )
      ]),
    );
  }

  Widget pageView(BuildContext context) {
    final theme = Theme.of(context);
    final column = Column(children: <Widget>[
      Expanded(child: PageView(
        children: configPages.map<Form>((e) => e.build(context)).toList(growable: false),
        controller: controller),)
    ]);
    final stack = Stack(
      children: <Widget>[
        Center(
          child: SmoothPageIndicator(
            controller: controller,
            count: configPages.length,
            effect: WormEffect(dotColor: Colors.green[200], activeDotColor: theme.primaryColor, spacing: 16),
          ),
        )],
    );
    if (curPage != configPages.length - 1)
      stack.children.add(nextButton());
    column.children.add(Container(
      color: theme.backgroundColor,
      height: 60,
      child: stack,));
    return column;
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

  Widget nextButton() => Padding(
    padding: const EdgeInsets.only(right: 10),
    child: Align(
      alignment: AlignmentDirectional.centerEnd,
      child: RaisedButton(
        padding: EdgeInsets.all(12),
        color: Theme.of(context).primaryColor,
        child: Text(
          "Next",
          style: Theme.of(context).textTheme.button,
        ),
        onPressed: () => controller.nextPageSimple(),
      ),
    ),
  );
}




