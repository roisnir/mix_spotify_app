import 'package:spotify/spotify.dart';
import 'package:spotify_manager/common/project_manager/model/project.dart';
import 'package:spotify_manager/common/project_manager/project_playlist.dart';
import 'package:spotify_manager/common/project_manager/projects_db.dart';
import 'package:spotify_manager/common/utils.dart';

Future<List<ProjectConfiguration>> loadProjects(String userId) async {
  final db = ProjectsDB();
  final projects = List<ProjectConfiguration>.from(await db.getProjectsConf(userId));
  db.close();
  return projects;
}

Future<List<PlaylistSimple>> userPlaylists(SpotifyApi api, String userId) async {
  return api.playlists.me.all().then(
          (playlists) => playlists.where(
              (playlist) => playlist.owner.id == userId).toList());
}

Future<List<TrackSaved>> unsortedTracks(SpotifyApi api, String userId, List<PlaylistSimple> allPlaylists, List<TrackSaved> allTracks) async {
  final playlists = await Future.wait(
      allPlaylists.map((p) => ProjectPlaylist.fromSimplePlaylist(p, api)));
  return allTracks.where((
      track) => playlists.all(
          (playlist) => !playlist.contains(track.track))).toList();
}