import 'package:spotify/spotify_io.dart';

class ProjectPlaylist {
  List<String> trackIds;
  Playlist playlist;

  ProjectPlaylist(this.playlist, this.trackIds);

  get name => playlist.name;
  get id => playlist.id;

  static Future<ProjectPlaylist> fromPlaylist(Playlist playlist, SpotifyApi api) async {
    final trackIds = (await Pages<Track>.fromPaging(api,
        playlist.tracksPaging, (json) => Track.fromJson(json['track'])).all())
        .map((t)=>t.id).toList();
    return ProjectPlaylist(playlist, trackIds);
  }

  bool includes(Track track) => this.trackIds.contains(track.id);
  bool contains(Track track) => this.includes(track);
}