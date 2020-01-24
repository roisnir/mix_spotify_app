import 'package:spotify_manager/common/project_manager/project_playlist.dart';
import 'package:spotify_manager/flutter_spotify/model/track.dart';


class ProjectTrack {
  Track track;
  List<ProjectPlaylist> containingPlaylists;


  ProjectTrack(this.track, this.containingPlaylists);
}