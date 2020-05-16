import 'dart:async';
import 'package:spotify/spotify.dart';
import 'package:spotify_manager/common/project_manager/project_playlist.dart';


class TrackAnalysis {
  Track track;
  Map<String, num> matchScores;
  List<String> genres;
  List<ProjectPlaylist> projectPlaylists;

  bool get isMatchScoresPopulated => matchScores != null;
  bool get isGenresPopulated => genres != null;

  List<String >get recommendedPlaylists {
    if (!isMatchScoresPopulated)
      return [];
    final scores = matchScores.entries.toList()..sort((a, b)=> a.value.abs().compareTo(b.value.abs()));
//    return scores.sublist(0, (scores.length * 0.25).round()).map((e) => e.key).toList();
    final res =  scores.where((s) => s.value < 0.25).map((e) => e.key).toList();
    return res;
  }

  TrackAnalysis(this.track, this. projectPlaylists, SpotifyApi api, {Function() onUpdate}){
    api.artists.get(track.artists[0].id).then((artist) {
      genres = artist.genres;
      if (onUpdate != null)
        onUpdate();
    });
    calcMatchScore(projectPlaylists, api).then((value) {
      matchScores = value;
      if (onUpdate != null)
        onUpdate();
    });
  }

  Future<Map<String, num>> calcMatchScore(List<ProjectPlaylist> projectPlaylists, SpotifyApi api) async {
    final audioFeature = await api.audioFeatures.get(track.id);
    Map<String, num> matches = {};
    for (var playlist in projectPlaylists){
      matches[playlist.id] = await playlist.fitScore(audioFeature);
    }
    return matches;
  }
}