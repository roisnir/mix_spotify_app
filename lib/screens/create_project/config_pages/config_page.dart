library config_page;

import 'package:flutter/material.dart';


abstract class ConfigPage {
  final GlobalKey<FormState> key;

  ConfigPage([GlobalKey<FormState> key]):this.key = key ?? GlobalKey<FormState>();

  Widget buildPage(BuildContext context);

  Form build(BuildContext context){
    return Form(key: key, child: buildPage(context),);
  }
}