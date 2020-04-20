import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_manager/main.dart';
import '../../new_playlist_dialog.dart';
import '../form_fields.dart';
import 'config_page.dart';


class PlaylistsConfigPage extends ConfigPage {
  final void Function(List<bool>) onSaved;
  final List<PlaylistSimple> playlists;
  final List<bool> selectedPlaylists;

  PlaylistsConfigPage({
    GlobalKey<FormState> key,
    @required this.onSaved,
    @required this.playlists,
    @required this.selectedPlaylists}):super(key);

  @override
  Widget buildPage(BuildContext context) => PlaylistsConfigWidget(playlists, selectedPlaylists, onSaved);
}

class PlaylistsConfigWidget extends StatefulWidget {
  final List<PlaylistSimple> playlists;
  final List<bool> selectedPlaylists;
  final void Function(List<bool>) onSaved;

  PlaylistsConfigWidget(this.playlists, this.selectedPlaylists, this.onSaved);

  @override
  _PlaylistsConfigWidgetState createState() => _PlaylistsConfigWidgetState();
}

class _PlaylistsConfigWidgetState extends State<PlaylistsConfigWidget> {
  List<PlaylistSimple> playlists;
  List<bool> selectedPlaylists;

  @override
  void initState() {
    super.initState();
    playlists = widget.playlists;
    selectedPlaylists = widget.selectedPlaylists;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spotifyContainer = SpotifyContainer.of(context);
    final client = spotifyContainer.client;
    final userId = spotifyContainer.myDetails.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Choose Playlists", style: theme.textTheme.headline4),
        Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "You will add songs to those playlists trough the project",
                style: theme.textTheme.caption,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(icon: Icon(Icons.add), onPressed: () async {
                Playlist playlist = await showDialog(context: context, child: NewPlaylistDialog(client, userId));
                if (playlist != null) {
                  setState(() {
                    playlists.add(playlist);
                    selectedPlaylists.add(true);
                  });
                }
              },),
            )
          ],
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 5, bottom: 20),
            color: theme.backgroundColor,
            child: PlaylistsSelection(
              playlists: playlists,
              theme: Theme.of(context),
              onSaved: widget.onSaved,
              validator: (v) =>
              v.any((e) => e) ? null : "select at least one playlist",
              initialValue: selectedPlaylists,
            ),
          ),
        ),
      ],
    );

  }
}
