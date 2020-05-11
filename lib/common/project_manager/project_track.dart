import 'package:spotify/spotify.dart';
import 'package:spotify_manager/common/project_manager/project_playlist.dart';


class ProjectTrack {
  Track track;
  Map<String, num> matchScores;
  List<String> genres;

  bool get isMatchScoresPopulated => matchScores != null;
  bool get isGenresPopulated => genres != null;


  ProjectTrack(this.track, List<ProjectPlaylist> projectPlaylists, SpotifyApi api){
    api.albums.get(track.album.id).then((album) => genres = album.genres);
    calcMatchScore(projectPlaylists, api).then((value) => matchScores = value);
  }

  Future<Map<String, num>> calcMatchScore(List<ProjectPlaylist> projectPlaylists, SpotifyApi api){
    final audioFeature = api.audioFeatures.get(track.id);

  }
}