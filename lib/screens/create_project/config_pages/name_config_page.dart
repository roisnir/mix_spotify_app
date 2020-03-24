import 'package:flutter/material.dart';
import 'package:spotify_manager/common/project_manager/model/project.dart';
import 'config_page.dart';


class NameConfigPage extends ConfigPage {
  void Function(String) onSaved;
  Future<ProjectConfiguration> Function() onSubmit;

  NameConfigPage({
    GlobalKey<FormState> key,
    @required this.onSaved,
    @required this.onSubmit}):super(key);

  @override
  Widget buildPage(BuildContext context) {
    return NameConfigPageWidget(onSaved: onSaved, onSubmit: onSubmit,);
  }
}


class NameConfigPageWidget extends StatefulWidget {
  final void Function(String) onSaved;
  final Future<ProjectConfiguration> Function() onSubmit;

  NameConfigPageWidget({
    @required this.onSaved,
    @required this.onSubmit});

  @override
  _NameConfigPageWidgetState createState() => _NameConfigPageWidgetState();
}

class _NameConfigPageWidgetState extends State<NameConfigPageWidget> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, top: 200),
            child: TextFormField(
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: "Project's Name",
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onSaved: widget.onSaved,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 200, bottom: 40),
            child: RaisedButton(
              child: isLoading ?
              CircularProgressIndicator():
              Text(
                "Let's Start!",
                style: Theme.of(context).textTheme.headline6,
              ),
              onPressed: isLoading ?(){}:() async {
                setState(() => isLoading = true);
                final projectConf = await widget.onSubmit();
                Navigator.of(context).pop(projectConf);
              },
              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
            ),
          ),
          Text(isLoading ? "This may take a while..." : "", style: Theme.of(context).textTheme.subtitle1)
        ],
      ),
    );
  }
}
