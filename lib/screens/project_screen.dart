import 'dart:async';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:spotify/spotify_io.dart' hide Image;
import 'package:spotify_manager/common/project_manager/model/project.dart';
import 'package:spotify_manager/common/project_manager/project.dart';
import 'package:spotify_manager/common/project_manager/projects_db.dart';
import 'package:spotify_manager/screens/create_project/form_fields.dart';
import 'package:spotify_manager/common/utils.dart';
import 'package:marquee/marquee.dart';

class ProjectScreenState extends State<ProjectScreen> {
  Future<Project> projectFuture;
  List<Track> trackQueue = List<Track>();
  StreamSubscription trackSubscription;
  AudioPlayer player = new AudioPlayer();
  AudioPlayerState playerState = AudioPlayerState.PLAYING;
  String curTrackUrl;
  ProjectsDB projectsDB;
  List<bool> selectedPlaylists;
  PageController pageController;

  @override
  void initState() {
    super.initState();
    projectsDB = ProjectsDB();
    projectFuture =
        Project.fromConfiguration(widget.projectConfig, widget.client);
    pageController = PageController(initialPage: widget.projectConfig.curIndex);
    player.onPlayerStateChanged.listen((var audioState) {
//      print("player -> $audioState widget -> $playerState");
      if (audioState == AudioPlayerState.COMPLETED)
        player.play(curTrackUrl);
      else if (audioState == AudioPlayerState.PLAYING &&
          playerState == AudioPlayerState.PAUSED) player.pause();
    });
    projectFuture.then((p) {
      trackSubscription = p.tracks.listen((t) async {
        trackQueue.add(t);
      });
      getProjectTrack(p.curIndex).then((track) {
        curTrackUrl = track.previewUrl;
        player.stop();
        player.play(curTrackUrl);
        return track;
      });
    });
  }

  Future<Track> getProjectTrack(int index) async {
    while (trackQueue.length <= index)
      await Future.delayed(Duration(milliseconds: 250));
    final track = trackQueue[index];
    return track;
  }

  void updatePlaylists(int itemIndex, List<bool> curSelectedPlaylists) async {
    final project = await projectFuture;
    final track = trackQueue[itemIndex];
    final playlists = project.playlists;
    final initialPlaylists =
        project.playlists.map((p) => p.contains(track)).toList();
    final client = widget.client;
    for (int i = 0; i < playlists.length; i++) {
      final playlist = playlists[i];
      if ((!initialPlaylists[i] && curSelectedPlaylists[i])) {
        print("adding ${track.name} -> ${playlist.name}");
        await client.playlists.addTrack(track.uri, playlist.id);
        playlist.trackIds.add(track.id);
      }
      if (initialPlaylists[i] && !curSelectedPlaylists[i]) {
        print("removing ${track.name} -> ${playlist.name}");
        await client.playlists.removeTrack(track.uri, playlist.id);
        playlist.trackIds.remove(track.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SimpleFutureBuilder(projectFuture,
          (context, project)=>WillPopScope(
            onWillPop: () async {
              Navigator.of(context).pop((await projectFuture).curIndex);
              return false;
            },
            child: Column(
      children: buildButtonsTopBar() + <Widget>[
        buildBody(project),
        Padding(
            padding: const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  padding: EdgeInsets.all(0),
                  iconSize: 56,
                  icon: Icon(Icons.skip_previous),
                  onPressed: () {
                    pageController.prevPageSimple();
                  },
                ),
                IconButton(
                  padding: EdgeInsets.all(0),
                  iconSize: 56,
                  icon: Icon(Icons.skip_next),
                  onPressed: () {
                    pageController.nextPageSimple();
                  },
                ),
              ],
            ),
        ),
        buildPercentIndicator(project)
      ],
    ),
          ),
        ));
  }

  List<Widget> buildButtonsTopBar() => [
    Padding(
    padding: EdgeInsets.only(bottom: 20),
  ),
    Row(
      children: <Widget>[
        IconButton(
          iconSize: 48,
          icon: Icon(
            Icons.keyboard_arrow_down,
          ),
          onPressed: () async {
            Navigator.of(context).pop((await projectFuture).curIndex);
          },
        ),
        IconButton(
          iconSize: 48,
          icon: Icon(
            playerState != AudioPlayerState.PAUSED
                ? Icons.pause
                : Icons.play_arrow,
          ),
          onPressed: () async {
            if (curTrackUrl == null) return;
            if (playerState == AudioPlayerState.PAUSED) {
              setState(() => playerState = AudioPlayerState.PLAYING);
              await player.play(curTrackUrl);
            } else {
              setState(() => playerState = AudioPlayerState.PAUSED);
              await player.pause();
            }
          },
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    )];

  buildBody(Project project) => Expanded(
    child: PageView.builder(
      controller: pageController,
      itemCount: project.totalTracks,
      onPageChanged: (index) {
        projectsDB.updateIndex(project.uuid, index).whenComplete(() => print("updated index"));
        if (selectedPlaylists != null)
          updatePlaylists(project.curIndex, selectedPlaylists);
        selectedPlaylists = null;
        setState(() {
          project.curIndex = index;
        });
        getProjectTrack(index).then((track) {
          selectedPlaylists =
              project.playlists.map((p) => p.contains(track)).toList();
          curTrackUrl = track.previewUrl;
          player.stop();
          player.play(curTrackUrl);
          return track;
        });
      },
      itemBuilder: (context, index) {
        return SimpleFutureBuilder(getProjectTrack(index),
                (context, Track track) {
              final a = TextPainter(
                  text: TextSpan(
                      text: track.name,
                      style: Theme.of(context).textTheme.headline5),
                  maxLines: 1,
                  textDirection: TextDirection.ltr);
              a.layout(maxWidth: MediaQuery.of(context).size.width * 0.8);
              return Column(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.network(
                      track.album.images[0].url,
                      height: 300,
                      loadingBuilder: (c, Widget w, ice) => ice == null
                          ? w
                          : Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: CircularProgressIndicator(
                          value: ice.cumulativeBytesLoaded /
                              ice.expectedTotalBytes,
                        ),
                      ),
                    ),
                  ),
                ),
                a.didExceedMaxLines
                    ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 50,
                  child: Marquee(
                    text: track.name,
                    style: Theme.of(context).textTheme.headline5,
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    blankSpace: 100.0,
                    velocity: 40.0,
                    pauseAfterRound: Duration(milliseconds: 1500),
                  ),
//              child: Text(track.name, style: Theme.of(context).textTheme.headline, overflow: TextOverflow.fade, softWrap: false,),
                )
                    : Text(
                  track.name,
                  style: Theme.of(context).textTheme.headline5,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                Text(
                  track.artists[0].name,
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color: Theme.of(context).textTheme.caption.color),
                ),
                Expanded(
                  child: PlaylistsSelection(
                    key: GlobalKey<FormFieldState>(),
                    theme: Theme.of(context),
                    playlists:
                    project.playlists.map((p)=>p.playlist).toList(),
                    initialValue: project.playlists
                        .map((p) => p.contains(track))
                        .toList(),
                    onSaved: (v) {},
                    onChanged: (v) {
                      selectedPlaylists = v;
                    },
                    validator: (v) => null,
                  ),
                )
              ]);
            });
      },
    ),
  );

  buildPercentIndicator(Project project) => new LinearPercentIndicator(
    padding: EdgeInsets.symmetric(horizontal: 20),
    lineHeight: 30.0,
    center: Text(
        "${(project.curIndex / project.totalTracks * 100).toStringAsFixed(1)}%"),
    percent: project.curIndex / project.totalTracks,
    backgroundColor: Colors.green[200],
    progressColor: Colors.green[600],
  );

  @override
  void dispose() {
    player.stop();
    trackSubscription.cancel();
    super.dispose();
  }
}

class ProjectScreen extends StatefulWidget {
  final ProjectConfiguration projectConfig;
  final SpotifyApi client;
  final User me;

  ProjectScreen(
      {Key key,
      @required this.projectConfig,
      @required this.client,
      @required this.me})
      : super(key: key);

  @override
  ProjectScreenState createState() => ProjectScreenState();
}
