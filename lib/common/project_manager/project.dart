import 'dart:async';
import 'package:spotify/spotify.dart';
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
    print("created project");
  }

  Future<ProjectConfiguration> getConfig([List<String> trackIds]) async {
    trackIds = trackIds != null?trackIds:
      await tracks.map((t)=>t.id).toList();
    return ProjectConfiguration(name, uuid, curIndex, trackIds, playlists.map((pp)=>pp.playlist.id).toList());
  }

  static Future<Project> fromConfiguration(
      ProjectConfiguration config, SpotifyApi spotify) async {
    final playlists = await Future.wait<ProjectPlaylist>(
        config.playlistIds.map<Future<ProjectPlaylist>>((playlistId) async =>
            ProjectPlaylist.fromPlaylist(
                await spotify.playlists.get(playlistId), spotify))
    );
    final s = () => spotify.tracks.tracksStream(config.trackIds);
    return Project(
        config.name,
        config.trackIds.length,
        s,
        playlists,
        config.curIndex,
        config.uuid
    );
  }
}

Stream<List<T>> streamRevisions<T>(Stream<T> trackStream, [batchSize=10]) async* {
  final tracks = <T>[];
  final tracksIt = StreamIterator(trackStream);
  while (await tracksIt.moveNext()) {
    tracks.add(tracksIt.current);
    if (tracks.length % batchSize == 0)
      yield tracks;
  }
  yield tracks;
}
