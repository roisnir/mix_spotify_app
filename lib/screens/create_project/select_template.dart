import 'package:flutter/material.dart';
import 'package:spotify_manager/common/project_manager/project_template.dart';
import 'package:spotify_manager/screens/create_project/form_fields.dart';

final templates = <ProjectTemplate>[
  ProjectTemplate(
      "Liked Songs",
      "Go through every song you have ever liked and sort them to your playlists",
      Icons.favorite),
  ProjectTemplate(
      "Discover",
      "Choose tracks you like, get recommendations based on them and sort them to your playlists",
      Icons.explore),
  ProjectTemplate(
      "Extend",
      "Choose existing playlists, get recommendations based on their tracks and sort them to your playlists",
      Icons.all_out),
  ProjectTemplate(
      "Maintain",
      "Work on tracks that not included in any of your playlists",
      Icons.build),
];

Widget pageTemplate(theme, Iterable<ProjectTemplate> templates, Function(int) onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text("Choose Template", style: theme.textTheme.headline4),
      Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 20),
        child: Text(
          "What kind of project would you like to start?",
          style: theme.textTheme.caption,
        ),
      ),
      Expanded(
        child: ProjectTemplateSelection(
          theme: theme,
          templates: templates,
          validator: (int i) => i == null ? "please select template" : null,
          onChanged: onChanged,
        ),
      ),
    ],
  );
}
