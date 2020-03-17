import 'dart:async';

import 'package:spotify/spotify_io.dart';
import 'package:spotify_manager/common/project_manager/model/project.dart';
import 'package:spotify_manager/common/project_manager/project_playlist.dart';
import 'package:uuid/uuid.dart';

class Project {
  String name;
  String uuid;
  Stream<Track> Function() _getTracks;
  List<ProjectPlaylist> playlists;
  int totalTracks;
  int curIndex;

  Stream<Track> get tracks => _getTracks();

  Project(this.name, this.totalTracks, this._getTracks, this.playlists, [this.curIndex = 0, this.uuid]){
    uuid = uuid != null ? uuid : new Uuid().v4();
  }

  Future<ProjectConfiguration> getConfig([List<String> trackIds]) async {
    trackIds = trackIds != null?trackIds:
      await tracks.map((t)=>t.id).toList();
    return ProjectConfiguration(name, uuid, curIndex, trackIds, playlists.map((pp)=>pp.playlist.id).toList());
  }

  static Future<Project> fromConfiguration(
      ProjectConfiguration config, SpotifyApi spotify) async {
    return Project(
        config.name,
        config.trackIds.length,
        () => spotify.tracks.tracksStream(config.trackIds),
        await Future.wait<ProjectPlaylist>(
          config.playlistIds.map<Future<ProjectPlaylist>>((playlistId) async =>
              ProjectPlaylist.fromPlaylist(
                  await spotify.playlists.get(playlistId), spotify))
        ),
        config.curIndex,
        config.uuid
    );
  }
}
