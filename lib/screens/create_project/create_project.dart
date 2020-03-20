import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotify/spotify_io.dart';
import 'package:spotify_manager/common/utils.dart';
import 'package:spotify_manager/widgets/page_indicator.dart';
import 'package:spotify_manager/screens/create_project/config_pages/config_page.dart';


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




