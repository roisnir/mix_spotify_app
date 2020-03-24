import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:spotify_manager/common/project_manager/model/project.dart';
import 'package:spotify_manager/common/project_manager/projects_db.dart';
import 'package:spotify_manager/main.dart';
import 'package:spotify_manager/screens/create_project/select_template.dart';
import 'project_screen.dart';

const projectsFileName = 'projects.json';

class ProjectsScreenState extends State<ProjectsScreen> {
  List<ProjectConfiguration>_projects;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProjects().then((projects)=>setState(() {
      _projects = projects;
      isLoading = false;
    }));
  }

  Future<List<ProjectConfiguration>> loadProjects() async {
    final db = ProjectsDB();
    final projects = List<ProjectConfiguration>.from(await db.getProjectsConf());
    db.close();
    return projects;

  }

  Widget _buildRow(ProjectConfiguration project) {
    return ListTile(
      title: Text(project.name),
      leading: Icon(Icons.album,),
      trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
              LinearPercentIndicator(
                width: 80,
                padding: EdgeInsets.symmetric(horizontal: 3),
                lineHeight: 15.0,
                center: Text(
                    "${(project.curIndex / project.trackIds.length * 100).toStringAsFixed(1)}%", style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.bold),),
                percent: project.curIndex / project.trackIds.length,
                backgroundColor: Colors.green[200],
                progressColor: Colors.green[600],
              ),
            PopupMenuButton(itemBuilder: (c) => [PopupMenuItem(value: 1, child: Text('Delete'),)],onSelected: (v) async {
              setState(() {
                _projects.remove(project);
              });
              final db = ProjectsDB();
              await db.removeProject(project.uuid);
              db.close();
            }, )
          ]),
      onTap: () async => launchProject(context, project),
    );
  }

  launchProject(BuildContext context, ProjectConfiguration project) async {
    int index = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext subContext) {
      return ProjectScreen(
        projectConfig: project,
        client: SpotifyContainer.of(context).client,
        me: SpotifyContainer.of(context).myDetails,
      );
    }));
    setState(() {
      project.curIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 50, height: 50,
              child: CircularProgressIndicator()),
          Padding(padding: EdgeInsets.all(8.0),
          child: Text("loading..."),)
        ],
      );
    final spotifyClient = SpotifyContainer.of(context).client;
    final myDetails = SpotifyContainer.of(context).myDetails;
    var projectsWidgets = (_projects.map<Widget>((p) => _buildRow(p))).toList();
    projectsWidgets.insert(
      0,
      ListTile(
        title: Text("Start a New Project"),
        leading: Icon(Icons.add),
        onTap: () async {
          ProjectConfiguration newProject = await
          Navigator.of(context)
              .push(MaterialPageRoute(builder:
              (BuildContext context) => SelectTemplate(spotifyClient, myDetails)));
          if (newProject != null) {
            setState(() {
              _projects.add(newProject);
            });
            await launchProject(context, newProject);
          }
        },
      ),
    );
    return ListView(
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
