import 'package:flutter/material.dart';
import 'package:spotify/spotify_io.dart';
import 'package:spotify_manager/common/project_manager/create_project.dart';
import 'package:spotify_manager/main.dart';
import 'create_project.dart';


class CreateSavedSongsProject extends StatefulWidget {
  final List<PlaylistSimple> playlists;

  CreateSavedSongsProject(this.playlists);

  @override
  _CreateSavedSongsProjectState createState() => _CreateSavedSongsProjectState();
}

class _CreateSavedSongsProjectState extends State<CreateSavedSongsProject> {
  String projectName;
  List<PlaylistSimple> selectedPlaylists;

  createProject(SpotifyApi api){
    return createSavedSongsProject(
        api,
        selectedPlaylists.map<String>((p) => p.id),
        projectName);
  }

  @override
  Widget build(BuildContext context) {
    final spotifyContainer = SpotifyContainer.of(context);
    return CreateProject(
      api: spotifyContainer.client,
      playlists: widget.playlists,
      userDetails: spotifyContainer.myDetails,
      onNameSaved: (name)=>projectName = name,
      onPlaylistsSaved: (playlists) => selectedPlaylists = playlists,
      onSubmit: ()=>createProject(spotifyContainer.client));
  }
}
