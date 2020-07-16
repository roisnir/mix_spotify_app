import 'package:spotify/spotify.dart';
import 'package:flutter/material.dart';
import 'package:spotify_manager/common/project_manager/projects_db.dart';
import 'package:spotify_manager/common/utils.dart';
import 'package:spotify_manager/screens/new_playlist_dialog.dart';
import 'package:spotify_manager/screens/create_project/form_fields.dart';
import 'package:spotify_manager/common/project_manager/model/project.dart';

class EditProject extends StatefulWidget {
  final SpotifyApi api;
  final User currentUser;
  final ProjectConfiguration project;
  final Function(BuildContext context, ProjectConfiguration newProjectConf) onSave;
  final Function(BuildContext context) onCancel;

  EditProject(this.api, this.currentUser, this.project, {this.onSave, this.onCancel});

  @override
  _EditProjectState createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {
  Future<List<PlaylistSimple>> playlistsFuture;
  List<PlaylistSimple> playlists;
  List<bool> selected;
  bool isSaving = false;
  TextEditingController textCtr;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    playlistsFuture = widget.api.playlists.me.all().then(
            (value) {
              setState(() {
                playlists = value.where(
                        (playlist) => playlist.owner.id == widget.currentUser.id).toList();
                selected = List<bool>.generate(playlists.length, (i) => widget.project.playlistIds.contains(playlists[i].id));
              });
              return playlists;
            });
    textCtr = TextEditingController(text: widget.project.name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Poject"),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: (){
            if (widget.onCancel != null) {
              widget.onCancel(context);
            }
            else {
            Navigator.of(context).pop();
            }
          },
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("SAVE"),
            onPressed: () async {
              if (!formKey.currentState.validate())
                return;
              setState(() {
                isSaving = true;
              });
              await updateProject().catchError((error){
                setState(() {
                  isSaving = false;
                  showDialog(context: context, child: AlertDialog(
                    title: Text('Error'),
                    content: Text('Something went wrong, try again later or report this bug'),
                    actions: <Widget>[FlatButton(child: Text("OK"), onPressed: ()=>Navigator.of(context).pop(),)],
                  ));
                });
              });
              if (widget.onSave != null) {
                widget.onSave(context, widget.project);
              }
              else{
                Navigator.of(context).pop(widget.project);
              }
            },
          )
        ],
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0),
      body: isSaving ? Center(child: CircularProgressIndicator(),)
          : DefaultFutureBuilder(
        future: playlistsFuture,
        builder: (context, snapshot){
          return Form(
            autovalidate: true,
            key: formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  child: TextFormField(
                    controller: textCtr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headline4.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                    validator: (value)=>value.isEmpty ? "name can't be empty" : null,
                    ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(icon: Icon(Icons.add), onPressed: () async {
                    Playlist playlist = await showDialog(context: context, child: NewPlaylistDialog(widget.api, widget.currentUser.id));
                    if (playlist != null) {
                      setState(() {
                        playlists.add(playlist);
                        selected.add(true);
                      });
                    }
                  },),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 5, bottom: 20),
                    color: theme.backgroundColor,
                    child: PlaylistsSelection(
                      playlists: playlists,
                      theme: Theme.of(context),
                      validator: (v) =>
                      v.any((e) => e) ? null : "select at least one playlist",
                      initialValue: selected,
                      autoValidate: true,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> updateProject() async {
    final selectedPlaylists = selected.asMap().entries
        .where((entry) => entry.value)
        .map((e) => playlists[e.key].id).toList();
    final project = widget.project;
    await ProjectsDB().updateProject(widget.project.uuid,
        newName: project.name == textCtr.text ? null : textCtr.text,
        newPlaylistIds: project.playlistIds == selectedPlaylists ? null : selectedPlaylists);
    project.name = textCtr.text;
    project.playlistIds = selectedPlaylists;
    return project;
  }
}
