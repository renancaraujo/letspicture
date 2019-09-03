import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:letspicture/config/application.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:letspicture/storage/managers/projects.dart';
import 'package:letspicture/storage/observables/loading.dart';
import 'package:letspicture/storage/observables/project_collection.dart';
import 'package:letspicture/view/ui/gradients.dart';

import 'imagethumb.dart';

class SummaryRoute extends RouteWidget {
  SummaryRoute() : super("/");

  @override
  Widget build(BuildContext context, Map<String, List<String>> parameters) {
    return _SummaryScreen();
  }
}

class _SummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: _SummaryCreateButton(),
        body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: <Widget>[
              _SummaryAppbarSliver(),
              const SliverPadding(padding: const EdgeInsets.all(20)),
              _SliverSummaryTextProjects(),
              _SummaryListSliver(),
              const SliverPadding(padding: const EdgeInsets.all(100)),
            ]));
  }
}

class _SliverSummaryTextProjects extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: math.min(constraints.maxWidth - 20, 300),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: const Text("Projects"),
        );
      })),
    );
  }
}

class _SummaryAppbarSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
        expandedHeight: 70.0,
        backgroundColor: Theme.of(context).canvasColor,
        floating: true,
        flexibleSpace: _SummaryLoadingWrapper(),
        title: Container(
          padding: const EdgeInsets.only(top: 20),
          child: Image.asset("assets/images/tiny_logo.png"),
        ));
  }
}

class _SummaryListSliver extends StatefulWidget {
  @override
  __SummaryListSliverState createState() => __SummaryListSliverState();
}

class __SummaryListSliverState extends State<_SummaryListSliver> {
  int expandedItem;

  void onPrompt(int id) {
    setState(() {
      expandedItem = id;
    });
  }

  void onCancelPrompt() {
    setState(() {
      expandedItem = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) {
        final ProjectCollectionObservableState state =
            projectCollectionObservable.state;
        if (state == ProjectCollectionObservableState.ready) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              _buildChildren,
              childCount: projectCollectionObservable.listProjects.length,
            ),
          );
        }
        return SliverToBoxAdapter(child: Container());
      },
    );
  }

  Widget _buildChildren(BuildContext context, int index) {
    final projectObservable = projectCollectionObservable.listProjects[index];

    return SummaryImageThumb(
      projectObservable,
      key: ObjectKey(projectObservable.id),
      onPrompt: onPrompt,
      onCancelPrompt: onCancelPrompt,
      showDeletePrompt: expandedItem == projectObservable.id,
    );
  }
}

class _SummaryCreateButton extends StatelessWidget {
  void onPressed() async {
    ProjectsManager.importProject();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: const ObjectKey("Hello"),
      child: DecoratedBox(
          decoration: ShapeDecoration(
            gradient: creatingGradient,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
          ),
          child: MaterialButton(
            minWidth: 0,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: Text(
              "Import image",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w200),
            ),
            // backgroundColor: loading ? Colors.black12 : Theme.of(context).accentColor,
            onPressed: onPressed,
          )),
    );
  }
}

class _SummaryLoadingWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) {
        final bool loading = loadingObservable.loadingSummaryAppbar.isNotEmpty;
        return loading ? _SummaryLoadingBar() : Container();
      },
    );
  }
}

class _SummaryLoadingBar extends StatefulWidget {
  @override
  __SummaryLoadingBarState createState() => __SummaryLoadingBarState();
}

class __SummaryLoadingBarState extends State<_SummaryLoadingBar>
    with SingleTickerProviderStateMixin<_SummaryLoadingBar> {
  AnimationController controller;
  Animation<double> offsetAnimation;

  double offset = 0.0;

  @override
  void initState() {
    super.initState();
    offset = 0.0;
    controller = AnimationController(vsync: this)
      ..addListener(handleOffsetAnimation)
      ..addStatusListener(handleAnimationEnd);
    startAnimation();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void handleOffsetAnimation() {
    setState(() {
      offset = offsetAnimation.value;
    });
  }

  void handleAnimationEnd(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      startAnimation();
    }
  }

  void startAnimation() {
    offsetAnimation = Tween(begin: 0.0, end: 2.0).animate(controller);

    controller
      ..duration = const Duration(milliseconds: 1000)
      ..value = 0.0
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints layout) {
      return Align(
        alignment: Alignment.bottomLeft,
        child: Container(
            width: layout.maxWidth,
            height: 5,
            child: CustomPaint(
              painter: HorizontalGradientPainter(2 - offset, layout.maxWidth),
            )),
      );
    });
  }
}
