import 'package:flutter/material.dart';
import 'package:spotify/spotify_io.dart';
import 'package:spotify_manager/main.dart';
import 'package:spotify_manager/screens/create_project/create_discover_project.dart';
import 'package:spotify_manager/screens/create_project/create_maintain_project.dart';
import 'package:spotify_manager/screens/create_project/form_fields.dart';
import 'package:spotify_manager/common/project_manager/project_template.dart';
import 'package:spotify_manager/screens/create_project/create_saved_songs_project.dart';

final templates = <ProjectTemplate>[
  ProjectTemplate(
      "Liked Songs",
      "Go through every song you have ever liked and sort them to your playlists",
      Icons.favorite,
      builder: (playlists)=>CreateSavedSongsProject(playlists)),
  ProjectTemplate(
      "Discover",
      "Choose tracks you like, get recommendations based on them and sort them to your playlists",
      Icons.explore,
      builder: (playlist)=>CreateDiscoverProject(playlist)),
  ProjectTemplate(
      "Extend",
      "Choose existing playlists, get recommendations based on their tracks and sort them to your playlists",
      Icons.all_out),
  ProjectTemplate(
      "Maintain",
      "Work on tracks that not included in any of your playlists",
      Icons.build,
      builder: (playlists)=>CreateMaintainProject(playlists)),
];

class SelectTemplate extends StatefulWidget {
  final SpotifyApi api;
  final User currentUser;

  SelectTemplate(this.api, this.currentUser);

  @override
  _SelectTemplateState createState() => _SelectTemplateState();
}

class _SelectTemplateState extends State<SelectTemplate> {
  Future<List<PlaylistSimple>> playlistsFuture;

  @override
  void initState() {
    super.initState();
    playlistsFuture = widget.api.playlists.me.all().then(
            (playlists) => playlists.where(
                    (playlist) => playlist.owner.id == widget.currentUser.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 50),),
        Text("Choose Template", style: theme.textTheme.headline4),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 20),
          child: Text(
            "What kind of project would you like to start?",
            style: theme.textTheme.caption,
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: playlistsFuture,
            builder: (context, snapshot)=>snapshot.hasData?buildTemplates(context, snapshot.data, theme):Center(child:CircularProgressIndicator()),
          ),
        ),
      ],
    );
  }

  buildTemplates(BuildContext context, List<PlaylistSimple> playlists, ThemeData theme)=> ProjectTemplateSelection(
    theme: theme,
    templates: templates,
    validator: (int i) => i == null ? "please select template" : null,
    onChanged: (i){
      final builder = templates[i].builder;
      if (builder == null){
        showDialog(context: context, builder: (context)=>AlertDialog(
          title:Text("Coming Soon!"), content: Text("This project template is not supported yet."),actions: <Widget>[FlatButton(child:Text("OK"), onPressed: (){Navigator.of(context).pop();},)],));
        return;
      }
      Navigator.of(context).push(MaterialPageRoute(builder: (c)=>
          SpotifyContainer(client: widget.api, myDetails: widget.currentUser, child:
          builder(playlists),))).then((project) {
            if (project != null)
              return Navigator.of(context).pop(project);
          });
    },
  );
}
