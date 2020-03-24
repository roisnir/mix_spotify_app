import 'package:spotify/spotify_io.dart';

class ProjectPlaylist {
  List<String> trackIds;
  Playlist playlist;

  ProjectPlaylist(this.playlist, this.trackIds);

  get name => playlist.name;
  get id => playlist.id;

  static Future<ProjectPlaylist> fromPlaylist(Playlist playlist, SpotifyApi api) async {
    final trackIds = (await Pages<Track>.fromPaging(api,
        playlist.tracks, (json) => Track.fromJson(json['track'])).all())
        .map((t)=>t.id).toList();
    return ProjectPlaylist(playlist, trackIds);
  }

  static Future<ProjectPlaylist> fromSimplePlaylist(PlaylistSimple playlist, SpotifyApi api) async {
    final trackIds = (await api.playlists.getTracksByPlaylistId(playlist.id).all()).toList()
        .map((t)=>t.id).toList();
    return ProjectPlaylist(await api.playlists.get(playlist.id), trackIds);
  }

  bool includes(Track track) => this.trackIds.contains(track.id);
  bool contains(Track track) => this.includes(track);
}