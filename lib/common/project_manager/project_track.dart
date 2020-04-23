import 'package:spotify/spotify.dart';


class ProjectTrack {
  Track track;
  List<Playlist> containingPlaylists;


  ProjectTrack(this.track, this.containingPlaylists);
}