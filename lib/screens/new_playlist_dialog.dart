import 'package:flutter/material.dart';
import 'package:spotify/spotify_io.dart';

class NewPlaylistDialog extends StatefulWidget {
  final SpotifyApi client;
  final String userId;

  NewPlaylistDialog(this.client, this.userId);

  @override
  _NewPlaylistDialogState createState() => _NewPlaylistDialogState();
}

class _NewPlaylistDialogState extends State<NewPlaylistDialog> {
  String playlistName;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text("Create Playlist"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Form(
          key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextFormField(onSaved: (v)=>playlistName=v, decoration: const InputDecoration(hintText: "Playlist Name"),),
        ),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: isLoading?
            CircularProgressIndicator():
            RaisedButton(
                child: Text("Submit"),
                onPressed: () async {
                  if (!_formKey.currentState.validate())
                    return;
                  _formKey.currentState.save();
                  widget.client.playlists.createPlaylist(widget.userId, playlistName).then((playlist){
                    Navigator.of(context).pop(playlist);
                  }, onError: (e){
                    setState(() {
                      isLoading = false;
                    });
                  });
                  setState(() {
                    isLoading = true;
                  });
                }))
      ])));
  }
}
