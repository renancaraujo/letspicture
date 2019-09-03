import 'package:flutter/material.dart';
import 'package:letspicture/storage/project/project_model.dart';
import 'package:letspicture/view/routes/internal/studio/image/photoview_controller.dart';
import 'package:letspicture/view/routes/internal/studio/studio_route.dart';
import 'package:photo_view/photo_view.dart';

import 'inner_loading.dart';
import 'inner_niks.dart';

class ImageWrapper extends StatefulWidget {
  const ImageWrapper({
    Key key,
    this.project,
    this.isReady,
    this.screenMode,
    this.updateScreenMode,
  }) : super(key: key);

  final Project project;
  final bool isReady;
  final StudioScreenMode screenMode;
  final ValueChanged<StudioScreenMode> updateScreenMode;

  @override
  _ImageWrapperState createState() => _ImageWrapperState();
}

class _ImageWrapperState extends State<ImageWrapper>
    with TickerProviderStateMixin {
  MyPhotoViewController _photoViewController;
  PhotoViewScaleStateController _photoViewScaleStateController;

  AnimationController _verticalPositionAnimationController;
  Animation<double> _verticalPositionAnimation;
  double verticalPosition = 0;

  AnimationController _horizontalPositionAnimationController;
  Animation<double> _horizontalPositionAnimation;
  double horizontalPosition = 0;

  AnimationController _scaleAnimationController;
  Animation<double> _scaleAnimation;

  PhotoView photoView;
  ScaleBoundaries scaleBoundaries;

  bool get focusedMode => widget.screenMode == StudioScreenMode.focusedMode;

  void handleVerticalPositionAnimate() {
    setState(() {
      verticalPosition = _verticalPositionAnimation.value;
    });
  }

  void handleHorizontalPositionAnimate() {
    setState(() {
      horizontalPosition = _horizontalPositionAnimation.value;
    });
  }

  void handleScaleAnimation() {
    _photoViewController.scale = _scaleAnimation.value;
  }

  TickerFuture animateScale(double to) {
    final double from =
        _photoViewController.scale ?? scaleBoundaries.initialScale;
    _scaleAnimation = Tween(
      begin: from,
      end: to,
    ).animate(CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.easeOutExpo)); // todo: constant
    _scaleAnimationController
      ..duration = const Duration(milliseconds: 8350)
      ..value = 0.0;
    return _scaleAnimationController.forward();
  }

  void animateVerticalPosition(double to) {
    final from = verticalPosition;
    _verticalPositionAnimation = Tween(begin: from, end: to)
        .animate(_verticalPositionAnimationController);
    _verticalPositionAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void animateHorizontalPosition(double to) {
    final double from = horizontalPosition;
    _horizontalPositionAnimation = Tween(begin: from, end: to)
        .animate(_horizontalPositionAnimationController);
    _horizontalPositionAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void updatePositionAndScale() async {
    switch (widget.screenMode) {
      case StudioScreenMode.focusedMode:
        animateVerticalPosition(-30);
        animateHorizontalPosition(0);
        break;
      case StudioScreenMode.exporting:
        _photoViewScaleStateController.scaleState = PhotoViewScaleState.initial;
        animateVerticalPosition(0);
        animateHorizontalPosition(-(MediaQuery.of(context).size.width - 150));
        break;
      case StudioScreenMode.normal:
      default:
        animateVerticalPosition(0);
        animateHorizontalPosition(0);
    }
  }

  @override
  void initState() {
    super.initState();

    _photoViewController = MyPhotoViewController()..locked = !widget.isReady;
    _photoViewScaleStateController = PhotoViewScaleStateController();

    _verticalPositionAnimationController = AnimationController(vsync: this)
      ..addListener(handleVerticalPositionAnimate);

    _horizontalPositionAnimationController = AnimationController(vsync: this)
      ..addListener(handleHorizontalPositionAnimate);

    _scaleAnimationController = AnimationController(vsync: this)
      ..addListener(handleScaleAnimation);
  }

  @override
  void didUpdateWidget(ImageWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.screenMode != widget.screenMode) {
      updatePositionAndScale();
    }

    if (oldWidget.isReady != widget.isReady) {
      _photoViewController.locked = !widget.isReady;
    }
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    _verticalPositionAnimationController.dispose();
    _horizontalPositionAnimationController.dispose();
    _scaleAnimationController.dispose();
    _photoViewScaleStateController.dispose();

    super.dispose();
  }

  void onLayout(ScaleBoundaries boundaries) {
    scaleBoundaries = boundaries;
  }

  double get scale {
    if (widget.screenMode == StudioScreenMode.exporting) {
      return 0.85; // todo: constant
    }
    return widget.isReady ? 1.0 : 0.85;
  }

  @override
  Widget build(BuildContext context) {
    final double antiScale = 1 - scale;

    return Transform.translate(
      offset: Offset(horizontalPosition, verticalPosition),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        final double height =
            focusedMode ? constraints.maxHeight - 100 : constraints.maxHeight;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(constraints.maxWidth * antiScale / 2,
                constraints.maxHeight * antiScale / 2)
            ..scale(scale),
          height: height,
          child: PhotoView.customChild(
            onLayout: onLayout,
            customSize: Size(constraints.maxWidth, height),
            initialScale: PhotoViewComputedScale.contained,
            controller: _photoViewController,
            scaleStateController: _photoViewScaleStateController,
            backgroundDecoration: BoxDecoration(color: Colors.transparent),
            child: _buildPhotoInnerView(context),
            childSize: widget.project.imageSize,
          ),
        );
      }),
    );
  }

  Widget _buildPhotoInnerView(BuildContext context) {
    return Hero(
        tag: widget.project.id,
        child: widget.isReady
            ? InnerNiks(
                project: widget.project,
              )
            : InnerLoading(
                project: widget.project,
              ));
  }
}

const double paddingLoading = 20;
