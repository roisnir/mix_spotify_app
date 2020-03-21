import 'package:flutter/material.dart';
import 'package:spotify/spotify_io.dart';
import '../../new_playlist_dialog.dart';
import '../form_fields.dart';
import 'config_page.dart';


class PlaylistsConfigPage extends ConfigPage {
  void Function(List<bool>) onSaved;
  void Function(List<bool>) onPlaylistAdded;
  final List<PlaylistSimple> playlists;
  final List<bool> selectedPlaylists;
  final SpotifyApi client;
  final String userId;

  PlaylistsConfigPage({
    GlobalKey<FormState> key,
    @required this.onSaved,
    @required this.playlists,
    @required this.selectedPlaylists,
    this.onPlaylistAdded,
    @required this.client,
    @required this.userId}):super(key);

  @override
  Widget buildPage(BuildContext context) {
    final theme = Theme.of(context);
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
                  playlists.add(playlist);
                  onPlaylistAdded(selectedPlaylists); // TODO: do it better
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
              onSaved: onSaved,
              validator: (v) =>
              v.any((e) => e) ? null : "select at least one playlist",
              initialValue: List.generate(playlists.length, (i) => false),
            ),
          ),
        ),
      ],
    );
  }


}