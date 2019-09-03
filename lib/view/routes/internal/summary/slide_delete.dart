import 'package:flutter/material.dart';
import 'package:letspicture/config/application.dart';
import 'package:letspicture/config/typedefs.dart';
import 'package:letspicture/storage/project/project_model.dart';
import 'package:letspicture/view/ui/gradients.dart';

class SlideToDelete extends StatefulWidget {
  const SlideToDelete({
    Key key,
    @required this.size,
    @required this.project,
    @required this.onDelete,
    @required this.showDeletePrompt,
    @required this.onPrompt,
    @required this.onCancelPrompt,
    @required this.outBounds,
  }) : super(key: key);

  final Project project;
  final IntAsyncCallback onDelete;
  final IntCallback onPrompt;
  final VoidCallback onCancelPrompt;
  final Size size;
  final bool showDeletePrompt;
  final double outBounds;

  @override
  _SlideToDeleteState createState() => _SlideToDeleteState();
}

class _SlideToDeleteState extends State<SlideToDelete>
    with TickerProviderStateMixin<SlideToDelete> {
  double translateBefore;
  double translate = 0.0;

  AnimationController translateAnimationController;
  Animation<double> translateAnimation;

  double heightFactor = 1.0;
  AnimationController scaleAnimationController;
  Animation<double> scaleAnimation;

  double width = 1.0;

  void handleTranslateAnimation() {
    setState(() {
      translate = translateAnimation.value;
    });
  }

  void handleScaleAnimation() {
    setState(() {
      heightFactor = scaleAnimation.value;
    });
  }

  @override
  void initState() {
    super.initState();
    translateAnimationController = AnimationController(vsync: this)
      ..addListener(handleTranslateAnimation);

    scaleAnimationController = AnimationController(vsync: this)
      ..addListener(handleScaleAnimation);
  }

  @override
  void dispose() {
    translateAnimationController.dispose();
    scaleAnimationController.dispose();
    super.dispose();
  }

  void onHorizontalDragStart(DragStartDetails details) {
    translateBefore = translate;

    translateAnimationController.stop();
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      translate = translate + details.delta.dx;
    });
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    if (completion >= 0.9) {
      widget.onPrompt(widget.project.id);
    } else {
      animateTranslate(0.0, const Duration(milliseconds: 500));
    }
  }

  @override
  void didUpdateWidget(SlideToDelete oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.showDeletePrompt != widget.showDeletePrompt) {
      final double moveOut = width * 0.8;
      animateTranslate(
          widget.showDeletePrompt ? translate > 0 ? moveOut : -moveOut : 0.0,
          const Duration(milliseconds: 700));
    }
  }

  void onRemove() async {
    await widget.onDelete(widget.project.id);
    animateScale();
  }

  void onCancel() {
    widget.onCancelPrompt();
  }

  void animateTranslate(double to,
      [Duration duration = const Duration(milliseconds: 200)]) {
    translateAnimation = Tween(begin: translate, end: to).animate(
        CurvedAnimation(
            parent: translateAnimationController, curve: Curves.easeOutExpo));
    translateAnimationController
      ..duration = duration
      ..forward(from: 0.0);
  }

  void animateScale() {
    scaleAnimation = Tween<double>(begin: heightFactor, end: 0.0).animate(
        CurvedAnimation(
            parent: scaleAnimationController, curve: Curves.easeInOutCirc));
    scaleAnimationController
      ..duration = const Duration(milliseconds: 400)
      ..forward(from: 0.0);
  }

  double get completion => translate.abs() / (width / 2);

  double get clampedCompletion => completion.clamp(0, 1.0);
  double get finalHeight => widget.size.height * heightFactor;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    final Color background = Theme.of(context).canvasColor;
    return Container(
      margin: EdgeInsets.only(bottom: 20 * heightFactor),
      height: finalHeight,
      child: Stack(
        children: <Widget>[
          _buildDisplay(context),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: 250,
            child: IgnorePointer(
              child: Opacity(
                opacity: clampedCompletion,
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    background,
                    background.withAlpha(0),
                  ])),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: 250,
            child: IgnorePointer(
              child: Opacity(
                opacity: clampedCompletion,
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    background.withAlpha(0),
                    background,
                  ])),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: _buildConfirmation(context),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation(BuildContext context) {
    final finalHeightFactor =
        heightFactor < 0.2 ? 0.0 : (heightFactor - 0.5) / 0.5;
    final finalOpacityFactor =
        ((finalHeightFactor - 0.5) / 0.5).clamp(0.0, 1.0);
    final scale =
        ((0.8 + (0.2 * completion)) * finalHeightFactor).clamp(0.0, 1.0);
    final opacity =
        ((0.0 + completion) * 0.7 * finalOpacityFactor).clamp(0.0, 1.0);

    final Matrix4 transform = Matrix4.identity()..scale(scale);

    final Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Text("Remove project?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
              splashColor: Colors.white,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: negativeActionGradient,
                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                ),
                child: Container(
                  height: 40.0,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: FlatButton(
                    padding: const EdgeInsets.all(0),
                    child: Text(
                      "Remove",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: onRemove,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: positiveActionGradient,
                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                ),
                child: Container(
                  height: 40.0,
                  child: FlatButton(
                    padding: const EdgeInsets.all(0),
                    child: Text(
                      "Nope",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: onCancel,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return Opacity(
      opacity: opacity,
      child: Transform(
        transform: transform,
        alignment: Alignment.center,
        child: IgnorePointer(
          ignoring: completion < 1,
          child: content,
        ),
      ),
    );
  }

  Widget _buildDisplay(BuildContext context) {
    final Matrix4 transform = Matrix4.identity()..translate(translate);

    return GestureDetector(
      onHorizontalDragStart:
          widget.showDeletePrompt ? null : onHorizontalDragStart,
      onHorizontalDragUpdate:
          widget.showDeletePrompt ? null : onHorizontalDragUpdate,
      onHorizontalDragEnd: widget.showDeletePrompt ? null : onHorizontalDragEnd,
      child: Align(
        child: Transform(
          transform: transform,
          child:
              ProjectDisplay(project: widget.project, imageSize: widget.size),
        ),
      ),
    );
  }
}

// will be niks display maybe
class ProjectDisplay extends StatefulWidget {
  const ProjectDisplay({Key key, @required this.project, this.imageSize})
      : super(key: key);

  final Project project;
  final Size imageSize;

  @override
  _ProjectDisplayState createState() => _ProjectDisplayState();
}

class _ProjectDisplayState extends State<ProjectDisplay> {
  void onTap() {
    Application.instance.router.navigateTo(
      context,
      "/studio?projectId=${Uri.encodeComponent(widget.project.id.toString())}",
      transitionDuration: const Duration(milliseconds: 550),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: widget.imageSize.height,
        child: Hero(
            tag: widget.project.id,
            child: Image.memory(
              widget.project.thumbnailFile.thumbnailBitmap,
              width: widget.imageSize.width,
              height: widget.imageSize.height,
              fit: BoxFit.cover,
            )),
      ),
    );
    /*return ;*/
  }
}
