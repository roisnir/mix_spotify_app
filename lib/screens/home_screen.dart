import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' hide Image;
import 'package:spotify_manager/common/project_manager/model/project.dart';
import 'package:spotify_manager/common/project_manager/projects_db.dart';
import 'package:spotify_manager/common/project_manager/projects_endpoint.dart';
import 'package:spotify_manager/main.dart';
import 'package:spotify_manager/screens/create_project/select_template.dart';
import 'package:spotify_manager/screens/project_list_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  final SpotifyApi api;
  final User user;

  HomeScreen(this.api, this.user);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<ProjectConfiguration>> _projects;
  Future<List<PlaylistSimple>> _playlists;
  Future<List<TrackSaved>> _unsortedTracks;
  List<TrackSaved> _allTracks;

  @override
  void initState() {
    super.initState();
    final api = widget.api;
    final user = widget.user;
    setState(() {
    _projects = loadProjects();
    final _allTracksF = api.tracks.me.saved.all().then((value) => value.toList());
    _playlists = userPlaylists(api, user.id);
    _playlists.then(
            (playlists) => _allTracksF.then(
                    (tracks) {
                      setState(() {
                        _allTracks = tracks;
                      });
                      return _unsortedTracks = unsortedTracks(
                        api, user.id, playlists, tracks);
                    }));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[],
    );
    bodyColumn.children.add(buildTextTile("Stats", theme));
    bodyColumn.children.add(buildStats(theme));
    bodyColumn.children.add(buildTextTile("Library Status", theme));
    bodyColumn.children.add(buildLibraryStatus(theme));
    bodyColumn.children.add(buildTextTile("Action", theme));
    bodyColumn.children.add(buildCreateProject(theme));
    bodyColumn.children.add(buildContinueProject(context));
    bodyColumn.children.add(buildLogo());
    return Stack(children: <Widget>[
      SingleChildScrollView(child: bodyColumn,),
      Align(alignment: Alignment.topRight, child: PopupMenuButton(
        icon: Icon(Icons.settings),
        itemBuilder: (c)=>[PopupMenuItem(value: 0, child: Row(
          children: <Widget>[
            Icon(Icons.exit_to_app),
            Text("Logout")
          ],),)],
        onSelected: (v){
          CookieManager().clearCookies();
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (ctx)=>WelcomeScreen()
          ), (route) => route.isFirst);
        },
      ),)]);
  }

  Widget buildTextTile(String text, ThemeData theme) => Padding(
      padding: const EdgeInsets.only(top: 15, left: 20),
      child: Text(
        text,
        style: theme.textTheme.headline5,
      ),
    );

  Widget buildStats(ThemeData theme) {
    return buildRowCard(
        icon: Icon(
          Icons.show_chart,
          size: 88,
          color: Colors.lightBlueAccent,
        ),
        child: FutureBuilder<List<ProjectConfiguration>>(
            future: _projects,
            builder: (c, snapshot){
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator(),);
              final projects = snapshot.data;
              final activeNum = projects.where((project) => !project.isArchived).length;
              final archivedNum = projects.where((project) => project.isArchived).length;
              return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Active Projects: $activeNum", style: theme.textTheme.headline6,),
                Text("Archived Project: $archivedNum", style: theme.textTheme.headline6),
              ],
            );
            }),
        theme: theme);
  }

  Widget buildLibraryStatus(ThemeData theme) {
    return buildRowCard(
        icon: Icon(
          Icons.library_music,
          size: 88,
          color: Colors.pinkAccent,
        ),
        child: FutureBuilder<List<TrackSaved>>(
          future: _unsortedTracks,
          builder: (c, snapshot){
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator(),);
            List<TrackSaved> unsortedTracks = snapshot.data;
            final now = DateTime.now();
            final addedThisMonth = _allTracks.where(
                    (track) => track.addedAt.isAfter(DateTime(now.year, now.month))).length;
            String msg;
            if (unsortedTracks.length >= 0.2 * _allTracks.length)
              msg = "What a mess!";
            else if (unsortedTracks.length <= 0.05 * _allTracks.length)
              msg = "Nice Work!";
            else
              msg = "Keep Going!";
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Tracks Liked This Month: $addedThisMonth", style: theme.textTheme.subtitle1,),
                Text("Unsorted Liked Songs: ${unsortedTracks.length}", style: theme.textTheme.subtitle1,),
                Text("$msg", style: theme.textTheme.subtitle1, overflow: TextOverflow.fade,),
              ],
            );
          }
          ,
        ),
        theme: theme);
  }

  launchProjectListView(BuildContext context, ProjectConfiguration project) async {
    int index = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext subContext) {
      return ProjectListView(
        projectConfig: project,
        api: widget.api,
        me: widget.user,
      );
    }));
    final db = ProjectsDB();
    await db.updateIndex(project.uuid, index);
    db.close();
  }

  createProject() async {
    ProjectConfiguration project = await
    Navigator.of(context)
        .push(MaterialPageRoute(builder:
        (BuildContext context) => SelectTemplate(widget.api, widget.user)));
    if (project == null)
      return;
    _projects.then((projects) {
      final updatedProjects = Future.value(projects..add(project));
      setState(()=>_projects=updatedProjects);
    });
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext subContext) {
      return ProjectListView(
          projectConfig: project,
          api: widget.api,
          me: widget.user);
    }));
  }

  Widget buildCreateProject(ThemeData theme) {
    return buildRowCard(
        onPressed: createProject,
        icon: Icon(
          Icons.add_box,
          size: 88,
          color: theme.primaryColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Start A New Project!", style: theme.textTheme.headline6,),
          ],
        ),
        theme: theme);
  }

  Widget buildContinueProject(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<ProjectConfiguration>>(
      future: _projects,
      builder: (c, snapshot){
        if (!snapshot.hasData || snapshot.hasError || snapshot.data.length == 0)
          return Container();
        final project = snapshot.data.reduce(
                (a, b) => a.lastModified.isAfter(b.lastModified) ? a : b);
        return buildRowCard(
          onPressed: (){
            launchProjectListView(context, project);
          },
            icon: Icon(
              Icons.arrow_forward,
              size: 88,
              color: Colors.deepPurple,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Continue: ${project.name}", style: theme.textTheme.headline6,),
              ],),
            theme: theme);
      },
    );
  }

  Widget buildRowCard({
    double height=90,
    @required Widget icon,
    @required Widget child,
    @required ThemeData theme,
    Function() onPressed
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
      child: InkWell(
        onTap: onPressed ?? (){},
        child: Card(
          color: theme.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                height: height,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SizedBox(child: icon, width: 88,),
                    ),
                    Expanded(child: child)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLoadingCard({
    double height=90,
    @required ThemeData theme}) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
      child: Card(
        color: theme.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: height,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }


  Widget buildLogo()=>Padding(
    padding: EdgeInsets.only(top: 60, bottom: 40),
    child: Center(child: Image.asset("assets/mix_app7.png", height: 128,),),
  );
}
