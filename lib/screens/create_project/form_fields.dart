import 'package:flutter/material.dart';
import 'package:spotify/spotify_io.dart' as spotify;
import 'package:spotify_manager/common/project_manager/project_template.dart';


class ProjectTemplateSelection extends FormField<int> {

  ProjectTemplateSelection({ThemeData theme,
                            List<ProjectTemplate> templates,
                             Function(int) onChanged,
                             FormFieldSetter<int> onSaved,
                           FormFieldValidator<int> validator,
                           int initialValue,
                           bool autoValidate=false}):
        super(onSaved:onSaved, validator:validator, initialValue: initialValue,
          autovalidate: autoValidate,
          builder:(FormFieldState<int> state) => build(state, theme, templates, onChanged));

  static Widget build(FormFieldState<int> state, ThemeData theme, List<ProjectTemplate> templates, Function(int) onChanged){
    List<Widget> templateButtons = <Widget>[];
    for (int i=0; i<templates.length; i++) {
      final template = templates[i];
      templateButtons.add(
      Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        height: 150,
        child: RaisedButton(
          padding: EdgeInsets.all(10),
          onPressed: (){
            state.didChange(i);
            onChanged(i);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(width: 3, color: state.value == i ? theme.accentColor : Colors.transparent)
          ),
          child: Row(children: <Widget>[
            Flexible(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(template.title, style: theme.textTheme.headline6,),
                  Text(template.description, style: theme.textTheme.caption,)
                ],
              ),
            ),
            Flexible(flex: 1,child: Center(child: Icon(template.icon),))]),
        ),
      ));
    }

    return Column(
      children: <Widget>[
        !state.hasError ? Container() :
        Row(children: <Widget>[
          Icon(Icons.error_outline,color: Colors.red,),
          Text(state.errorText, style: TextStyle(color: Colors.red),)
        ],),
        Expanded(
          child: Container(
            color: theme.backgroundColor,
            child: SingleChildScrollView(
              child: Column(children: templateButtons),
            ),
          ),
        ),
      ],
    );

  }
}

// TODO: add appearance on invalid value
class PlaylistsSelection extends FormField<List<bool>> {

  PlaylistsSelection({
    Key key,
                       ThemeData theme,
                            @required List<spotify.PlaylistSimple> playlists,
                             Function(List<bool>) onChanged,
                             FormFieldSetter<List<bool>> onSaved,
                           FormFieldValidator<List<bool>> validator,
                       List<bool> initialValue,
                           bool autoValidate=false}):
        super(key:key, onSaved:onSaved, validator:validator, initialValue: initialValue,
          autovalidate: autoValidate,
          builder:(FormFieldState<List<bool>> state) => build(state, theme, playlists, onChanged));

  static Widget build(FormFieldState<List<bool>> state, ThemeData theme, List<spotify.PlaylistSimple> playlists, Function(List<bool>) onChanged){
    final buttons = List<Widget>();
    final selectedPlaylists = state.value;
    for (int i = 0; i < playlists.length; i++) {
      var playlist = playlists[i];
      buttons.add(GridTile(
          child: Column(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: FlatButton(
                  clipBehavior: Clip.hardEdge,
                  padding: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(
                        color: selectedPlaylists[i]
                            ? Colors.green
                            : Colors.transparent,
                        width: 4.0,
                      )),
                  child: Ink(child: playlist.images.length > 0 ? FadeInImage.assetNetwork(placeholder: "assets/playlist.png", image: playlist.images[0].url): Image.asset("assets/playlist.png")),
                  color: Colors.black26,
                  onPressed: () {
                    selectedPlaylists[i] = !selectedPlaylists[i];
                    state.didChange(selectedPlaylists);
                    if (onChanged != null)
                      onChanged(selectedPlaylists);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 0),
                child: Text(playlist.name,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.subtitle2),
              )
            ],
          )));
    }
    return GridView.count(
      padding: EdgeInsets.all(30),
      crossAxisCount: 3,
      childAspectRatio: 0.75,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: buttons,
    );

  }
}




// FormFieldTemplate
//
//class PlaylistsSelection extends FormField<List<bool>> {
//
//  PlaylistsSelection({ThemeData theme,
//                       List<Playlist> playlists,
//                       Function(List<bool>) onChanged,
//                       FormFieldSetter<List<bool>> onSaved,
//                       FormFieldValidator<List<bool>> validator,
//                       List<bool> initialValue,
//                       bool autoValidate=false}):
//        super(onSaved:onSaved, validator:validator, initialValue: initialValue,
//          autovalidate: autoValidate,
//          builder:(FormFieldState<List<bool>> state) => build(state, theme, playlists, onChanged));
//
//  static Widget build(FormFieldState<List<bool>> state, ThemeData theme, List<Playlist> templates, Function(List<bool>) onChanged){
//
//  }
//}