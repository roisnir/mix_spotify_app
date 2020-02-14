import 'package:spotify/spotify_io.dart';

class ProjectPlaylist {
  PlaylistSimple playlist;
  List<String> trackIds;

  ProjectPlaylist(this.playlist, this.trackIds);

  ProjectPlaylist.fromJson(Map<String, dynamic> json) {
    playlist = PlaylistSimple.fromJson(json['playlist']);
    trackIds = json['trackIds'];
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'playlist': playlist.toJson(),
      'trackIds': trackIds
    };
  }

  bool includes(Track track) => trackIds.contains(track.id);
  bool contains(Track track) => trackIds.contains(track.id);
}

getProjectPlaylist(PlaylistSimple playlist, SpotifyApi client) async {
  final tracks = (await client.playlists.getTracksByPlaylistId(playlist.id).all()).map((t)=>t.id).toList();
  return ProjectPlaylist(playlist, tracks);
}