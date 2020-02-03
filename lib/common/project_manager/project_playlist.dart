import 'package:spotify_manager/flutter_spotify/api/spotify_client.dart';
import 'package:spotify_manager/flutter_spotify/api/tracks.dart';
import 'package:spotify_manager/flutter_spotify/model/playlist.dart';
import 'package:spotify_manager/flutter_spotify/model/track.dart';

class ProjectPlaylist {
  Playlist playlist;
  List<String> trackIds;

  ProjectPlaylist(this.playlist, this.trackIds);

  ProjectPlaylist.fromJson(Map<String, dynamic> json) {
    playlist = Playlist.fromJson(json['playlist']);
    trackIds = json['trackIds'].map<String>((t)=>t as String);
  }

  toJson(Map<String, dynamic> json) {
    playlist = Playlist.fromJson(json['playlist']);
    trackIds = json['trackIds'].map<String>((t)=>t as String);
  }

  bool includes(Track track) => trackIds.contains(track.id);
  bool contains(Track track) => trackIds.contains(track.id);
}

getProjectPlaylist(Playlist playlist, SpotifyClient client) async {
  final paging = await client.getPaging(playlist.tracksHref);
  final tracksStream = TracksPagination(client, paging).stream;

  final temp = await tracksStream.toList();
  final trackIds = temp.map((t)=>t.id).toList();
//  final trackIds = await tracksStream.map((t)=>t.id).toList();
  return ProjectPlaylist(playlist, trackIds);
}