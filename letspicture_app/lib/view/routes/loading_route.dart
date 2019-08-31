import 'dart:async';
import 'dart:math' as Math;
import 'dart:ui';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:letspicture_app/config/application.dart';
import 'package:letspicture_app/view/ui/gradients.dart';

class LoadingRoute extends RouteWidget {
  LoadingRoute()
      : super("/loading", transitionType: TransitionType.inFromBottom);

  @override
  Widget build(BuildContext context, Map<String, List<String>> parameters) =>
      LoadingScreen();
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin<LoadingScreen> {
  AnimationController controller;
  Animation<double> offsetAnimation;

  double offset = 0.0;

  Completer completer;

  @override
  void initState() {
    super.initState();
    Application.instance.setupFuture.then(onSetup);
    offset = 0.0;
    controller = AnimationController(vsync: this)
      ..addListener(handleOffsetAnimation)
      ..addStatusListener(handleAnimationEnd);
    startAnimation();
    completer = Completer<ImageInfo>();
    getImage();
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
      ..duration = Duration(milliseconds: 1000)
      ..value = 0.0
      ..forward();
  }

  void getImage() {
    ImageProvider provider = AssetImage("assets/images/loading_mask.png");
    final ImageStream stream = provider.resolve(const ImageConfiguration());

    final listener =
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
      if (!completer.isCompleted) {
        completer.complete(info);
      }
    });
    stream.addListener(listener);
    completer.future.then((_) {
      stream.removeListener(listener);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: FutureBuilder(
                future: completer.future,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) return Container();
                  return snapshot.connectionState == ConnectionState.done
                      ? Loading(offset: offset)
                      : Container();
                })));
  }

  FutureOr onSetup(_) {
    return Application.instance.router.navigateTo(
      context,
      "/",
      clearStack: true,
      transitionDuration: Duration(milliseconds: 500),
    );
  }
}

class Loading extends StatelessWidget {
  final double offset;

  const Loading({Key key, this.offset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child:
        LayoutBuilder(builder: (BuildContext context, BoxConstraints layout) {
      final double width = Math.min(layout.maxWidth - 40, 200);
      return SizedBox(
          width: width,
          height: width * 0.5,
          child: Stack(
            children: <Widget>[
              Positioned(
                  top: 2,
                  bottom: 2,
                  left: 2,
                  right: 2,
                  child: ClipRect(
                    child: CustomPaint(
                      painter: HorizontalGradientPainter(2 - offset, width),
                    ),
                  )),
              Image.asset("assets/images/loading_mask.png", fit: BoxFit.cover),
            ],
          ));
    })));
  }
}
