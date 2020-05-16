import 'package:spotify/spotify.dart';
import 'package:spotify_manager/common/project_manager/project_playlist.dart';
import 'package:spotify_manager/common/project_manager/track_analysis.dart';

class TrackAnalysisCache {
  Map<String, TrackAnalysis> cache = {};
  List<ProjectPlaylist> projectPlaylists;
  Function() onUpdate;
  SpotifyApi api;

  TrackAnalysisCache(this.projectPlaylists, this.api, {this.onUpdate});

  TrackAnalysis operator [](Track track){
    if (cache.containsKey(track.id)){
      return cache[track.id];
    }
    cache[track.id] = TrackAnalysis(track, projectPlaylists, api, onUpdate: onUpdate);
    return cache[track.id];
  }
}