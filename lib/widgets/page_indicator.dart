import 'package:flutter/material.dart';

nullFunc(int i){}

class PageIndicator extends StatelessWidget {
  final List<int> pagesState;
  final void Function(int) onPressed;
  final Color primaryColor;
  final Color secondaryColor;
  final Color offColor;
  final Color backgroundColor;

  PageIndicator({@required this.pagesState,
    this.onPressed = nullFunc,
    this.primaryColor = Colors.green,
    this.secondaryColor = Colors.lightGreen,
    this.offColor = const Color(0xFFE0E0E0),
    this.backgroundColor = Colors.transparent
  });

  @override
  Widget build(BuildContext context) {
    Color(Colors.grey[300].value);
    return Container(
        color: backgroundColor,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            SizedBox(
              width: 100,
              child: Divider(
                thickness: 2.0,
                color: Colors.white70,
              ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: pagesState.map<Widget>((state) {
                  return ButtonTheme(
                  minWidth: state == 1 ? 15:10,
                  child: FlatButton(
                    color: state == -1
                        ? Colors.grey[300]
                        : state == 1
                        ? primaryColor
                        : secondaryColor,
                    shape: CircleBorder(
                        side: state == 1
                            ? BorderSide(color: Colors.white, width: 1)
                            : BorderSide(width: 0)),
                    padding: EdgeInsets.all(0),
                    onPressed: () {
//                      onPressed(i);
                    },
                    child: Container(
                      width: 0,
                      height: 0,
                      padding: EdgeInsets.all(0),
                      margin: EdgeInsets.all(0),
                    ),
                  ),
                );
                }).toList()),
          ],
        ));
  }
}
