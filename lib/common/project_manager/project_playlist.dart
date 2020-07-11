import 'package:spotify/spotify.dart';
import 'package:spotify_manager/common/project_manager/track_analysis.dart';
import 'package:spotify_manager/common/utils.dart';
import 'dart:math' as math;

class ProjectPlaylist {
  List<Track> tracks;
  Playlist playlist;
  SpotifyApi api;
  Future<AudioFeature> _audioFeature;
  Future<AudioFeature> get audioFeature{
    if (_audioFeature == null){
      _audioFeature = avgAudioFutures(tracks, api);
    }
    return _audioFeature;
  }
  Future<Map<String, int>> _genres;
  Future<Map<String, int>> get genres {
    if (_genres == null){
      _genres = genresCounts(tracks, api);
    }
    return _genres;
  }


  ProjectPlaylist(this.playlist, this.tracks, this.api);
  get name => playlist.name;
  get id => playlist.id;

  Future<num> fitScore(AudioFeature trackAF) async {
    if (audioFeature == null || tracks.length == 0){
       // TODO: maybe throw an errors
      return null;
    }
    final af = await audioFeature.catchError((e){
      return null;
    });
    if (af == null){
      return null;
    }
    num distance = 0;
//    distance += af.mode - trackAF.mode;
    distance += (af.acousticness - trackAF.acousticness).abs();
    distance += (af.danceability - trackAF.danceability).abs();
    distance += (af.energy - trackAF.energy).abs();
    distance += (af.instrumentalness - trackAF.instrumentalness).abs();
//    distance += af.loudness;
//    distance += af.tempo - trackAF.tempo;
    distance += (af.valence - trackAF.valence).abs();
    return distance;
  }

  static Future<ProjectPlaylist> fromPlaylist(Playlist playlist, SpotifyApi api) async {
    final trackIds = (await Pages<Track>.fromPaging(api,
        playlist.tracks, (json) => Track.fromJson(json['track'])).all())
        .toList();
    return ProjectPlaylist(playlist, trackIds, api);
  }

  static Future<ProjectPlaylist> fromSimplePlaylist(PlaylistSimple playlist, SpotifyApi api) async {
    final trackIds = (await api.playlists.getTracksByPlaylistId(playlist.id).all()).toList();
    return ProjectPlaylist(await api.playlists.get(playlist.id), trackIds, api);
  }

  Future<void> addTrack(SpotifyApi api, Track track) async {
    // TODO: handle audioFeatures and genre
    await api.playlists.addTrack(track.uri, playlist.id);
    tracks.add(track);
  }

  Future<void> removeTrack(SpotifyApi api, Track track) async{
    // TODO: handle audioFeatures and genre
    await api.playlists.removeTrack(track.uri, playlist.id);
    tracks.removeAt(tracks.indexWhere((t) => t.id == track.id));
  }

  bool includes(Track track) => this.tracks.firstWhere((t)=>t.id == track.id, orElse: ()=>null) != null;
  bool contains(Track track) => this.includes(track);

  static Future<AudioFeature> avgAudioFutures(Iterable<Track> tracks, SpotifyApi api) async {
    tracks = tracks.where((track) => track.id != null);
    final audioFeatures = AudioFeature();
    if (tracks.length == 0) {
      return null;
    }
    final tracksAudioFeatures = await Future.wait(
        tracks.where((track) => track.id != null).map((track) {
          return api.audioFeatures.get(track.id);
        }));
//      audioFeatures.mode = avg(tracksAudioFeatures.map((af) => af.mode));
    audioFeatures.acousticness = avg(tracksAudioFeatures.map((af) => af.acousticness));
    audioFeatures.danceability = avg(tracksAudioFeatures.map((af) => af.danceability));
    audioFeatures.energy = avg(tracksAudioFeatures.map((af) => af.energy));
    audioFeatures.instrumentalness = avg(tracksAudioFeatures.map((af) => af.instrumentalness));
    audioFeatures.loudness = avg(tracksAudioFeatures.map((af) => af.loudness));
    audioFeatures.tempo = avg(tracksAudioFeatures.map((af) => af.tempo));
    audioFeatures.valence = avg(tracksAudioFeatures.map((af) => af.valence));
    return audioFeatures;
  }

  static Future<Map<String, int>> genresCounts(Iterable<Track> tracks, SpotifyApi api) async {
    Map<String, int> genres = {};
    for (var track in tracks){
      final trackGenres = track.artists[0].id != null ? await api.artists.get(track.artists[0].id).then((artist)=>artist.genres) : [];
      trackGenres.forEach((genre) {
        genres[genre] = (genres[genre] ?? 0) + 1;
      });
    }
    return genres;
  }
}