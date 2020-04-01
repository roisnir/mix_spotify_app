import 'package:flutter/material.dart';
import 'package:spotify/spotify_io.dart';
import 'package:spotify_manager/common/project_manager/create_project.dart';
import 'package:spotify_manager/common/project_manager/model/spotify_items.dart';
import 'package:spotify_manager/main.dart';
import 'package:spotify_manager/screens/create_project/config_pages/search_config_page.dart';
import 'create_project.dart';


class CreateDiscoverProject extends StatefulWidget {
  final List<PlaylistSimple> playlists;

  CreateDiscoverProject(this.playlists);

  @override
  _CreateDiscoverProjectState createState() => _CreateDiscoverProjectState();
}

class _CreateDiscoverProjectState extends State<CreateDiscoverProject> {
  String projectName;
  List<PlaylistSimple> selectedPlaylists;
  SpotifyItems selectedItems;

  createProject(SpotifyApi api) {
    return createDiscoverProject(
        api,
        selectedItems.artists.map((artist) => artist.id).toList(),
        selectedItems.tracks.map((track) => track.id).toList(),
        widget.playlists,
        projectName);
  }

  @override
  Widget build(BuildContext context) {
    final spotifyContainer = SpotifyContainer.of(context);

    return CreateProject(
        api: spotifyContainer.client,
        playlists: widget.playlists,
        userDetails: spotifyContainer.myDetails,
        configPages: [SearchConfigPage(onSaved: (value)=>selectedItems = value),],
        onNameSaved: (name)=>projectName = name,
        onPlaylistsSaved: (playlists) => selectedPlaylists = playlists,
        onSubmit: ()=>createProject(spotifyContainer.client));
  }
}
