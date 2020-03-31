import 'package:flutter/material.dart';
import 'package:spotify/spotify_io.dart';
import 'package:spotify_manager/common/project_manager/create_project.dart';
import 'package:spotify_manager/main.dart';
import 'create_project.dart';


class CreateMaintainProject extends StatefulWidget {
  final List<PlaylistSimple> playlists;

  CreateMaintainProject(this.playlists);

  @override
  _CreateMaintainProjectState createState() => _CreateMaintainProjectState();
}

class _CreateMaintainProjectState extends State<CreateMaintainProject> {
  String projectName;
  List<PlaylistSimple> selectedPlaylists;

  createProject(SpotifyApi api) {
    return createMaintainProject(
        api,
        widget.playlists,
        selectedPlaylists,
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
