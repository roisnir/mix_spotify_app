import 'package:flutter/material.dart';

class Error extends StatelessWidget {
  final String errorMsg;
  final double vSpace;
  final TextStyle textStyle;
  final double iconSize;


  Error(this.errorMsg, {this.vSpace = 16, this.textStyle, this.iconSize = 60});

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Icon(
        Icons.error_outline,
        color: Colors.red,
        size: iconSize,
      ),
      Padding(
        padding: EdgeInsets.only(top: vSpace),
        child: Text('Error: $errorMsg', style: textStyle,),
      )
    ],);
  }
}
