import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:spotify_manager/common/project_manager/model/project.dart';
import 'package:spotify_manager/main.dart';
import 'package:spotify_manager/common/project_manager/project.dart';
import 'package:spotify_manager/screens/create_project/create_project.dart';
import 'project_screen.dart';

const projectsFileName = 'projects.json';

class ProjectsScreenState extends State<ProjectsScreen> {
  List<Project>_projects;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProjects().then((projects)=>setState(() {
      _projects = projects;
      isLoading = false;
    }));
  }

  Future<List<Project>> loadProjects() async {
    final appDataDir = (await getApplicationDocumentsDirectory()).path;
    final file = File('$appDataDir/$projectsFileName');
    if (!await file.exists())
      return <Project>[];
    final json = jsonDecode(await file.readAsString());
    return Future.wait(
    json.map<Future<Project>>((pJson){
      final config = ProjectConfiguration.fromJson(pJson as Map<String, dynamic>);
      return Project.fromConfiguration(config, SpotifyContainer.of(context).client);
    }));
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
          Project newProject = await
          Navigator.of(context)
              .push(MaterialPageRoute(builder:
              (BuildContext context) => CreateProject(spotifyClient, myDetails)));
          if (newProject != null)
            _projects.add(newProject);
        },
      ),
    );
    return WillPopScope(
      child: ListView(
        padding: const EdgeInsets.only(top: 8),
        children: ListTile.divideTiles(context: context, tiles: projectsWidgets)
            .toList(),
      ),
      onWillPop: dumpProjectsConfigs,
    );
  }

  Future<bool> dumpProjectsConfigs() async {
    final getProjConf = () async =>
      jsonEncode(await Future.wait(_projects.map((p)async=>
          jsonDecode((await p.getConfig()).toJson())))
      );
    await showDialog(context: context, child: SaveProgress(getProjConf, projectsFileName));
    return true;
  }

}

class ProjectsScreen extends StatefulWidget {
  @override
  ProjectsScreenState createState() => ProjectsScreenState();
}

class SaveProgress extends StatefulWidget {
  final FutureOr<String> Function() _jsonData;
  final String fileName;

  SaveProgress(this._jsonData, [this.fileName = 'tmp']);

  @override
  _SaveProgressState createState() => _SaveProgressState();
}

class _SaveProgressState extends State<SaveProgress> {

  @override
  void initState() {
    super.initState();
    save().whenComplete(()=>Navigator.of(context).pop());
  }

  Future<void> save() async {
    final appDataDir = (await getApplicationDocumentsDirectory()).path;
    final file = File('$appDataDir/${widget.fileName}');
    file.writeAsString(await widget._jsonData());

  }

  @override
  Widget build(BuildContext context) {
    return Dialog(child: Column(mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(width: 50, height: 50,
            child: CircularProgressIndicator(backgroundColor: Colors.transparent,)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("saving..."),
        )
      ],
    ),
      backgroundColor: Colors.transparent,);
  }
}
