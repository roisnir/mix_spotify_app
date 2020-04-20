import 'package:spotify/spotify.dart';
import 'package:spotify_manager/common/project_manager/project_playlist.dart';
import 'package:spotify_manager/common/project_manager/projects_db.dart';
import 'package:spotify_manager/common/project_manager/model/project.dart';
import 'package:spotify_manager/common/utils.dart';

Future<ProjectConfiguration> createSavedSongsProject(SpotifyApi client,
    Iterable<String> playlistIds, String projectName) async {
  final tracksIds = (await client.tracks.me.saved.all())
      .map((t) => t.track.id)
      .toList();
  final project = ProjectConfiguration.init(
      projectName, tracksIds, playlistIds.toList(), "SavedSongs");
  await ProjectsDB().insertProject(project);
  return project;
}

Future<ProjectConfiguration> createMaintainProject(SpotifyApi api,
    List<PlaylistSimple> allPlaylists,
    Iterable<PlaylistSimple> selectedPlaylists, String projectName) async {
  final playlists = await Future.wait(
      allPlaylists.map((p) => ProjectPlaylist.fromSimplePlaylist(p, api)));
  final List<String> tracksIds = (await api.tracks.me.saved.all())
      .where((track) =>
      playlists.all((playlist) => !playlist.contains(track.track)))
      .map<String>((t) => t.track.id)
      .toList();
  final project = ProjectConfiguration.init(projectName, tracksIds,
      selectedPlaylists.map((playlist) => playlist.id).toList(), "Maintain");
  await ProjectsDB().insertProject(project);
  return project;
}


Future<ProjectConfiguration> createDiscoverProject(SpotifyApi api,
    List<String> seedArtists, List<String> seedTracks,
    Iterable<PlaylistSimple> selectedPlaylists, String projectName,
    [int limit = 100]) async {
  final trackIds = await api.recommendations.get(
      seedArtists: seedArtists,
      seedTracks: seedTracks,
      limit: limit).then((recommendations) =>
      recommendations.tracks.map((track) => track.id).toList(growable: false));
  final project = ProjectConfiguration.init(projectName, trackIds, selectedPlaylists.map((playlist) => playlist.id).toList(), "Discover");
  await ProjectsDB().insertProject(project);
  return project;
}


Future<ProjectConfiguration> createExtendProject(SpotifyApi api,
    List<PlaylistSimple> allPlaylists,
    Iterable<PlaylistSimple> selectedPlaylists, String projectName) async {
  // TODO: implement extend
  throw UnimplementedError();
}
