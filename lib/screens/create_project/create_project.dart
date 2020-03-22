import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotify/spotify_io.dart';
import 'package:spotify_manager/common/project_manager/model/project.dart';
import 'package:spotify_manager/common/utils.dart';
import 'package:spotify_manager/widgets/page_indicator.dart';
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
    configPages[0].current = true;
    controller.addListener(handlePageChange);
  }

  handlePageChange(){
    if (controller.page > prevPage) { // tried to move to the next page
      if (configPages[prevPage].key.currentState.validate())
        configPages[prevPage].key.currentState.save();
      else {
        controller.goToPage(prevPage);
        return;
      }
    }
    if (controller.page.round() != prevPage)
      setState(() {
        configPages[prevPage].current = false;
        configPages[controller.page.round()].current = true;
      });
    final page = controller.page.toInt();
    if ((!(controller.page.isInt())) || page == prevPage)
      return;
    prevPage = page;
  }

  int get curPage => controller.hasClients ? controller.page.round() : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    if (curPage != configPages.length - 1)
      column.children.add(bottomBar());
    final pagesState = configPages.map<PageState>((p) =>
      p.current ? PageState.current : p.seen ? PageState.seen : PageState.none).toList(growable: false);
    column.children.add(PageIndicator(
      pagesState: pagesState,
      onPressed: (i)=>controller.goToPage(i),
      primaryColor: theme.primaryColor,
      secondaryColor: theme.secondaryHeaderColor,
      backgroundColor: theme.backgroundColor,
    ));
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

  Widget bottomBar() => Padding(
    padding: const EdgeInsets.all(20),
    child: Align(
      alignment: AlignmentDirectional.bottomEnd,
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




