import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleFutureBuilder<T> extends StatelessWidget{
  final Future<T> future;
  final Function(BuildContext, T data) builder;

  SimpleFutureBuilder(this.future, this.builder);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        List<Widget> children;

        if (snapshot.hasData)
          return builder(context, snapshot.data);
        else if (snapshot.hasError) {
          children = <Widget>[
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: ${snapshot.error}'),
            )
          ];
        } else {
          children = <Widget>[
            SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Awaiting result...'),
            )
          ];
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        );
      },
    );
  }

}


extension PageViewNavigation on PageController {
  void goToPage(int pageIndex, {duration:const Duration(milliseconds: 300), curve: Curves.easeInOutCubic}) {
    this.animateToPage(pageIndex, duration: duration, curve: curve);
  }
  void nextPageSimple({duration:const Duration(milliseconds: 240), curve: Curves.easeIn}){
    final curPage = this.page.toInt();
//  this.nextPage(duration: duration, curve: curve);
    this.animateToPage(curPage + 1, duration: duration, curve: curve);
  }
  void prevPageSimple({duration:const Duration(milliseconds: 240), curve: Curves.easeIn}){
    this.previousPage(duration: duration, curve: curve);
  }
}

extension IterTools<T> on Iterable<T> {
//  Iterable<> enumerate(){
//
//  }
}

extension DictTools<T1, T2> on Map<T1,T2> {
  Iterable<T> dMap<T>(Function(T1, T2) func) sync* {
    for (var entry in this.entries){
      yield func(entry.key, entry.value);
    }
  }
}

extension DoubleTools on double {
  bool isInt() => this == this.roundToDouble();
}



