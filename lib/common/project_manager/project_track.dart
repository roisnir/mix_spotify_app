import 'package:spotify/spotify_io.dart';


class ProjectTrack {
  Track track;
  List<Playlist> containingPlaylists;


  ProjectTrack(this.track, this.containingPlaylists);
}