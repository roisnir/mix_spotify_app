import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_manager/widgets/draggable_scroll_bar.dart';

class FloatingBarListView extends StatelessWidget {
  final SliverAppBar appBar;
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Widget Function(BuildContext context, int index) dividerBuilder;
  final ScrollController controller;

  FloatingBarListView({
    @required this.appBar,
      @required this.itemCount, @required this.itemBuilder, this.dividerBuilder,
  this.controller});

  get _childCount => dividerBuilder == null ? itemCount : (itemCount * 2) - 1;

  @override
  Widget build(BuildContext context) {
    return CupertinoScrollbar(
      controller: controller,
      child: CustomScrollView(
        controller: controller,
        slivers: <Widget>[
          appBar,
          SliverList(
            delegate: SliverChildBuilderDelegate((c, i){
              if (dividerBuilder == null)
                return itemBuilder(c, i);
              if (i.isOdd)
                return dividerBuilder(c, i ~/ 2);
              return itemBuilder(c, i ~/ 2);
            },
              childCount: _childCount,
            ),
          ),
        ],
      ),
    );
  }
}
