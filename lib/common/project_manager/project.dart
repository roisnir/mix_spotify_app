import 'package:spotify/spotify_io.dart';
import 'package:spotify_manager/common/project_manager/project_playlist.dart';
import 'package:uuid/uuid.dart';

class Project
{
  String name;
  String uuid;
  Function() _getTracks;
  List<ProjectPlaylist> playlists;
  int totalTracks;
  int curIndex;


  Project(this.name, this.totalTracks, this._getTracks, this.playlists)
  {
    curIndex = 0;
    uuid = new Uuid().v4();
  }

  Stream<Track> get tracks => _getTracks();

  // TODO: implement fromJson
  Project.fromJson(Map<String, dynamic> json)
  {
    name = json["name"];
    uuid = json["uuid"];
  }
}
