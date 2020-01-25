import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:spotify_manager/main.dart';
import 'package:spotify_manager/common/project_manager/project.dart';
import 'package:spotify_manager/screens/create_project/create_project.dart';

import 'project_screen.dart';

class ProjectsScreenState extends State<ProjectsScreen> {
  final _projects = <Project>[];

  @override
  void initState() {
    super.initState();
  }

  Widget _buildRow(Project project) {
    return ListTile(
      title: Text(project.name),
      leading: Icon(Icons.album),
      trailing: SizedBox(
        width: 150,
        child: LinearPercentIndicator(
          lineHeight: 20.0,
          center: Text("${(project.curIndex / project.totalTracks * 100).toStringAsFixed(1)}%"),
          percent: project.curIndex / project.totalTracks,
          backgroundColor: Colors.grey,
          progressColor: Colors.green,
        ),
      )
      ,
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext subContext) {
          return ProjectScreen(
            project: project,
            client: SpotifyContainer.of(context).client,
            me: SpotifyContainer.of(context).myDetails,
          );
        }));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final spotifyClient = SpotifyContainer.of(context).client;
    final myDetails = SpotifyContainer.of(context).myDetails;
    var projectsWidgets = (_projects.map<Widget>((p) => _buildRow(p))).toList();
    projectsWidgets.insert(
      0,
      ListTile(
        title: Text("Start a New Project"),
        leading: Icon(Icons.add),
        onTap: () async {
          Project newProject = await
          Navigator.of(context)
              .push(MaterialPageRoute(builder:
              (BuildContext context) => CreateProject(spotifyClient, myDetails)));
          if (newProject != null)
            _projects.add(newProject);
        },
      ),
    );
    return new ListView(
      padding: const EdgeInsets.only(top: 8),
      children: ListTile.divideTiles(context: context, tiles: projectsWidgets)
          .toList(),
    );
  }
}

class ProjectsScreen extends StatefulWidget {
  @override
  ProjectsScreenState createState() => ProjectsScreenState();
}
