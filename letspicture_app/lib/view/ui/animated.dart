import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'gradients.dart';

class BorderLoader extends StatefulWidget {
  final Size size;

  const BorderLoader({Key key, this.size}) : super(key: key);

  @override
  _BorderLoaderState createState() => _BorderLoaderState();
}

class _BorderLoaderState extends State<BorderLoader>
    with SingleTickerProviderStateMixin<BorderLoader> {
  AnimationController controller;
  Animation<double> offsetAnimation;

  double offset = 0.0;

  @override
  void initState() {
    super.initState();
    offset = 0.0;
    controller = AnimationController(vsync: this)
      ..addListener(handleAngleAnimation)
      ..addStatusListener(handleAnimationEnd);
    startAnimation();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void handleAngleAnimation() {
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

  @override
  Widget build(BuildContext context) {
    return ClipRect(
        child: Align(
            child: Container(
      constraints: BoxConstraints.expand(
          width: widget.size.width, height: widget.size.height),
      child: CustomPaint(
        size: widget.size,
        painter: HorizontalGradientPainter(2 - offset, widget.size.width),
      ),
    )));
  }
}
