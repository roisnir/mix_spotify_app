import 'package:spotify/spotify_io.dart';
import 'package:spotify_manager/common/project_manager/projects_db.dart';
import 'package:spotify_manager/common/project_manager/model/project.dart';

Future<ProjectConfiguration> createSavedSongsProject(SpotifyApi client, Iterable<String> playlistIds, String projectName) async {
  final tracksIds = (await client.tracks.me.saved.all()).map((t)=>t.track.id).toList();
  final project = ProjectConfiguration.init(projectName, tracksIds, playlistIds.toList());
  await ProjectsDB().insertProject(project);
  return project;
}