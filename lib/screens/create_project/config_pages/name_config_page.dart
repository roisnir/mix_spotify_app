import 'package:flutter/material.dart';
import 'config_page.dart';


class NameConfigPage extends ConfigPage {
  final BuildContext context;
  void Function(String) onSaved;
  void Function() onSubmit;

  NameConfigPage({
    GlobalKey<FormState> key,
    @required this.context,
    @required this.onSaved,
    @required this.onSubmit}):super(key);

  @override
  Widget buildPage() {
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
              onSaved: onSaved,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 200, bottom: 40),
            child: RaisedButton(
              child: Text(
                "Let's Start!",
                style: Theme.of(context).textTheme.headline6,
              ),
              onPressed: onSubmit,
              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
            ),
          )
        ],
      ),
    );
  }


}