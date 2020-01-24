import 'dart:async';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:spotify_manager/common/project_manager/project.dart';
import 'package:spotify_manager/flutter_spotify/model/track.dart';
import 'package:spotify_manager/screens/create_project/form_fields.dart';
import 'package:spotify_manager/common/utils.dart';
import 'package:marquee/marquee.dart';

class ProjectScreenState extends State<ProjectScreen>
{
  Project project;
  List<Track> trackQueue = List<Track>();
  StreamSubscription trackSubscription;
  AudioPlayer player = new AudioPlayer();
  AudioPlayerState playerState = AudioPlayerState.PLAYING;
  String curTrackUrl;
  PageController pageController;


  @override
  void initState() {
    super.initState();
    project = widget.project;
    pageController = PageController(initialPage: project.curIndex);
    player.onPlayerStateChanged.listen((var audioState){
//      print("player -> $audioState widget -> $playerState");
      if (audioState == AudioPlayerState.COMPLETED)
        player.play(curTrackUrl);
      else if (audioState == AudioPlayerState.PLAYING && playerState == AudioPlayerState.PAUSED)
        player.pause();
    });
    trackSubscription = project.tracks.listen((t) async {
      trackQueue.add(t);
    });
    getProjectTrack(project.curIndex).then((track){
      curTrackUrl = track.previewUrl;
      player.stop();
      player.play(curTrackUrl);
      return track;
    });
  }

  Future<Track> getProjectTrack(int index) async {
    while (trackQueue.length <= index)
      await Future.delayed(Duration(milliseconds: 250));
    return trackQueue[index];
  }

  @override
  Widget build(BuildContext context)
  {
    final _project = project;

  return Scaffold(body: Column(children: <Widget>[
      Padding(padding: EdgeInsets.only(bottom: 20),),
      Row(children: <Widget>[
        IconButton(iconSize: 48, icon: Icon(Icons.keyboard_arrow_down,),onPressed: (){Navigator.of(context).pop();},),
        IconButton(iconSize: 48, icon: Icon(playerState!=AudioPlayerState.PAUSED?Icons.pause:Icons.play_arrow,),
          onPressed: () async {
            if (curTrackUrl == null)
              return;
            if (playerState == AudioPlayerState.PAUSED){
              setState(() => playerState = AudioPlayerState.PLAYING);
              await player.play(curTrackUrl);
            }
            else {
              setState(() => playerState = AudioPlayerState.PAUSED);
              await player.pause();
            }
          },),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,),
      Expanded(
        child: PageView.builder(
          controller: pageController,
          itemCount: project.totalTracks,
          onPageChanged: (index) {
            project.curIndex = index;
            getProjectTrack(index).then((track){
              curTrackUrl = track.previewUrl;
              player.stop();
              player.play(curTrackUrl);
              return track;
            });

          },
          itemBuilder: (context, index) {
            return SimpleFutureBuilder(getProjectTrack(index), (context, Track track){
              final a = TextPainter(text:TextSpan(text:track.name, style: Theme.of(context).textTheme.headline), maxLines: 1, textDirection: TextDirection.ltr);
              a.layout(maxWidth: MediaQuery.of(context).size.width * 0.8);
            return Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: 200,
                height: 200,
                child: Image.network(track.album.images[0].url, height: 300,
                loadingBuilder: (c,Widget w,ice)=> ice == null?w:Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: CircularProgressIndicator(value: ice.cumulativeBytesLoaded / ice.expectedTotalBytes,),
                ) ,),
              ),
            ),
            a.didExceedMaxLines ?
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height:50,
              child: Marquee(
                text: track.name,
                style: Theme.of(context).textTheme.headline,
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                blankSpace: 100.0,
                velocity: 40.0,
                pauseAfterRound: Duration(milliseconds: 1500),
              ),
//              child: Text(track.name, style: Theme.of(context).textTheme.headline, overflow: TextOverflow.fade, softWrap: false,),
            ):
            Text(track.name, style: Theme.of(context).textTheme.headline, overflow: TextOverflow.fade, softWrap: false,) ,
            Text(track.artists[0].name, style: Theme.of(context).textTheme.subhead.copyWith(color: Theme.of(context).textTheme.caption.color),),
            Expanded(
              child: PlaylistsSelection(
                key: GlobalKey<FormFieldState>(),
                theme: Theme.of(context),
                playlists: _project.playlists.map((p)=>p.playlist).toList(),
                initialValue: _project.playlists.map((p)=>p.contains(track)).toList(),
                onSaved: (v){},
                onChanged: (v){},
                validator: (v)=> null,

              ),
            )
          ]);
          });
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
          IconButton(padding:EdgeInsets.all(0), iconSize:48, icon: Icon(Icons.skip_previous),onPressed: (){pageController.prevPageSimple();},),
          IconButton(padding:EdgeInsets.all(0), iconSize:48, icon: Icon(Icons.skip_next),onPressed: (){pageController.nextPageSimple();},),
        ],),
      ),
      new LinearPercentIndicator(padding: EdgeInsets.symmetric(horizontal: 20),
        lineHeight: 30.0,
        center: Text("${(project.curIndex / project.totalTracks * 100).toStringAsFixed(1)}%"),
        percent: project.curIndex / project.totalTracks,
        backgroundColor: Colors.grey,
        progressColor: Colors.green,
      )
    ],));
  }
  @override
  void dispose() {
    player.stop();
    trackSubscription.cancel();
    super.dispose();
  }
}

class ProjectScreen extends StatefulWidget
{
  final Project project;

  ProjectScreen({Key key, @required this.project}) : super(key: key);

  @override
  ProjectScreenState createState() => ProjectScreenState();
}
