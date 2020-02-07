import 'package:spotify/spotify_io.dart';
import 'package:spotify_manager/common/project_manager/project_playlist.dart';


class ProjectTrack {
  Track track;
  List<ProjectPlaylist> containingPlaylists;


  ProjectTrack(this.track, this.containingPlaylists);
}