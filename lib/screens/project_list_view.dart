import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' hide Image;
import 'package:spotify_manager/common/project_manager/model/project.dart';
import 'package:spotify_manager/common/project_manager/project.dart';
import 'package:spotify_manager/common/project_manager/track_analysis.dart';
import 'package:spotify_manager/common/project_manager/projects_db.dart';
import 'package:spotify_manager/common/project_manager/track_analysis_cache.dart';
import 'package:spotify_manager/screens/project_screen.dart';
import 'package:spotify_manager/widgets/floating_bar_list_view.dart';
import 'package:spotify_manager/widgets/search.dart';

class ProjectListView extends StatefulWidget {
  final ProjectConfiguration projectConfig;
  final SpotifyApi api;
  final User me;
  final ProjectsDB db;
  final Project project;

  ProjectListView({@required this.projectConfig,
    @required this.api,
    @required  this.me,
    this.project}) : db = ProjectsDB();

  @override
  _ProjectListViewState createState() => _ProjectListViewState();
}

class _ProjectListViewState extends State<ProjectListView> {
  Future<Project> projectFuture;
  Project project;
  Stream<List<Track>> tracksRevisions;
  TrackAnalysisCache trackAnalysisCache;
  ScrollController scrollController;
  AudioPlayer player = new AudioPlayer();
  Queue<String> upNext;
  int nowPlaying;
  
  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.project == null)
        projectFuture = Project.fromConfiguration(widget.projectConfig, widget.api);
      else
        projectFuture = Future.value(widget.project);
      projectFuture.then((project) {
        setState(() {
          scrollController = ScrollController();
          print("creating revisions stream");
          trackAnalysisCache = TrackAnalysisCache(project.playlists, widget.api, onUpdate: ()=>setState((){}));
          tracksRevisions = streamRevisions(project.tracks, 50);
          this.project = project;
        });
        return projectFuture;
      });
    });
    player.onPlayerStateChanged.listen((var audioState) {
      if (audioState != AudioPlayerState.COMPLETED || upNext.length <= 0)
        return;
      play(upNext, nowPlaying + 1);
    });
  }

  @override
  void dispose() {
    upNext = Queue<String>();
    player.stop();
    super.dispose();
  }

  play(Iterable<String> _upNext, int index) async {
    upNext = Queue.from(_upNext);
    final track = upNext.removeFirst();
    if (track == null)
      pause();
    if (player.state != AudioPlayerState.STOPPED)
      await player.stop();
    await player.play(track);
    setState(() {
      project.curIndex = index;
      nowPlaying = index;
    });
  }

  pause() async {
    await player.pause();
    setState(() {
      nowPlaying = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop((await projectFuture).curIndex);
        return false;
      },
      child: Scaffold(
        body: StreamBuilder<List<Track>>(
          stream: tracksRevisions,
          builder: (context, snapshot) {
            if(snapshot.hasError)
              return Center(
                child: Column(children: <Widget>[
                  Padding(padding: EdgeInsets.only(bottom: 10), child: Icon(Icons.error),),
                  Text("An error occured, try again later"),
                  Text(snapshot.error.toString()),
                ],),
              );
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            final tracks = snapshot.data;
            final theme = Theme.of(context);
            final conf = widget.projectConfig;
            return FloatingBarListView(
              controller: scrollController,
              appBar: SliverAppBar(
                actions: <Widget>[IconButton(icon: Icon(Icons.subscriptions),onPressed: ()async{
                  await player.stop();
                  final newCurIndex = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (BuildContext subContext) {
                        return ProjectScreen(
                          projectConfig: widget.projectConfig..curIndex = project.curIndex,
                          client: widget.api,
                          me: widget.me,
                          project: project,
                        );
                      })
                  );
                  Navigator.of(context).pop(newCurIndex);
                },)],
                floating: true,
                backgroundColor: Theme.of(context).backgroundColor,
                expandedHeight: 150,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  title: Text(project.name, style: theme.textTheme.headline5),
                  centerTitle: true,
                  background: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 70),
                      child: Text("Sorting ${conf.trackIds.length} tracks to ${conf.playlistIds.length} playlists", style: theme.textTheme.bodyText1,),
                    ),
                  ),
                ),
              ),
              itemCount: tracks.length + 1,
              itemBuilder: (c, i) {
                if (i == tracks.length)
                  return i == widget.projectConfig.trackIds.length ? Container():
                    Center(child: CircularProgressIndicator());
                final track = tracks[i];
                final analysis = trackAnalysisCache[track];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TrackTile(
                      track,
                      onTap: (track)async{
                        if (nowPlaying == i)
                          await pause();
                        else
                          await play(tracks.sublist(i).map((t) => t.previewUrl), i);
                        },
                      trailing: nowPlaying == i ? Icon(Icons.pause):null,
                      genres: (analysis.genres == null || analysis.genres.length == 0) ? null
                          : analysis.genres
                          .sublist(0, min(analysis.genres.length, 2))
                          .join(', ')
                          .splitMapJoin(' ', onNonMatch: (m)=>m[0].toUpperCase() + m.substring(1)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Wrap(
                        spacing: 5,
                        children: project.playlists.map<Widget>((playlist) {
                          final selected = playlist.contains(track);
                          return ChoiceChip(
                            elevation: 3,
                              // genre recommended
                            shape: analysis.similarGenrePlaylists.contains(playlist.id) ? RoundedRectangleBorder(side: BorderSide(color: Colors.lightBlueAccent), borderRadius: BorderRadius.circular(30)) : null,
                            shadowColor: analysis.similarGenrePlaylists.contains(playlist.id) ? Colors.pinkAccent : null,
                            // audio features recommended
                            avatar: analysis.recommendedPlaylists.contains(playlist.id) ? Icon(Icons.star, size: 18, color: Colors.lightBlueAccent,) : null ,
                            selectedColor: theme.buttonColor,
                            onSelected: (value) async {
                              if (value)
                                await playlist.addTrack(widget.api, track);
                              else
                                await playlist.removeTrack(widget.api, track);
                              setState(() {
                              });
                              project.curIndex = i;
                              },
                            selected: selected,
                            label: Text(playlist.name, style: selected?
                              TextStyle(color: theme.textTheme.button.color, fontWeight: FontWeight.w500):TextStyle(color: Colors.white70)),
                          );
                        }).toList(),),
                    )
                  ],
                );
              },
              dividerBuilder: (c, i) => Divider(),);
          },
        ),
      ),
    );
  }
}
