import 'package:spotify/spotify.dart';
import 'package:spotify_manager/common/utils.dart';
import 'dart:math' as math;

class ProjectPlaylist {
  List<Track> tracks;
  Playlist playlist;


  ProjectPlaylist(this.playlist, this.tracks);

  get name => playlist.name;
  get id => playlist.id;

  static Future<ProjectPlaylist> fromPlaylist(Playlist playlist, SpotifyApi api) async {
    final trackIds = (await Pages<Track>.fromPaging(api,
        playlist.tracks, (json) => Track.fromJson(json['track'])).all())
        .toList();
    return ProjectPlaylist(playlist, trackIds);
  }

  static Future<ProjectPlaylist> fromSimplePlaylist(PlaylistSimple playlist, SpotifyApi api) async {
    final trackIds = (await api.playlists.getTracksByPlaylistId(playlist.id).all()).toList();
    return ProjectPlaylist(await api.playlists.get(playlist.id), trackIds);
  }

  static Future<AudioFeature> avgAudioFutures(Iterable<Track> tracks, SpotifyApi api) async {
    final audioFeatures = AudioFeature();
    if (tracks.length == 0){
      // TODO: set all to default and return
    }
    final tracksAudioFeatures = await Future.wait(tracks.map((track) => api.audioFeatures.get(track.id)));
    audioFeatures.mode = avg(tracksAudioFeatures.map((e) => e.mode));
    // TODO: set more features
  }

  Future<void> addTrack(SpotifyApi api, Track track) async {
    await api.playlists.addTrack(track.uri, playlist.id);
    tracks.add(track);
  }

  Future<void> removeTrack(SpotifyApi api, Track track) async{
    await api.playlists.removeTrack(track.uri, playlist.id);
    tracks.removeAt(tracks.indexWhere((t) => t.id == track.id));
  }

  bool includes(Track track) => this.tracks.firstWhere((t)=>t.id == track.id, orElse: ()=>null) != null;
  bool contains(Track track) => this.includes(track);
}