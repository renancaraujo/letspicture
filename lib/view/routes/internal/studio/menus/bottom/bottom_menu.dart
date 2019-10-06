import 'package:flutter/material.dart';
import 'package:letspicture/editor/adjustments/adjustments_items.dart';
import 'package:letspicture/editor/editor.dart';
import 'package:letspicture/storage/project/project_model.dart';
import 'package:letspicture/view/ui/gradients.dart';

import '../../studio_route.dart';

class AdjustmentsMenu extends StatelessWidget {
  const AdjustmentsMenu({
    Key key,
    this.updateScreenMode,
    this.screenMode,
    this.isReady,
    this.project,
  }) : super(key: key);

  final StudioScreenMode screenMode;
  final ValueChanged<StudioScreenMode> updateScreenMode;
  final bool isReady;
  final Project project;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: <Widget>[
          MenuBackdrop(
            screenMode: screenMode,
            updateScreenMode: updateScreenMode,
            isReady: isReady,
          ),
          MenuIconsRow(
            screenMode: screenMode,
            updateScreenMode: updateScreenMode,
            isReady: isReady,
            project: project,
          ),
        ],
      ),
    );
  }
}

/// *** Menu gradient
class MenuBackdrop extends StatefulWidget {
  const MenuBackdrop({
    Key key,
    this.screenMode,
    this.updateScreenMode,
    this.isReady,
  }) : super(key: key);

  final StudioScreenMode screenMode;
  final ValueChanged<StudioScreenMode> updateScreenMode;
  final bool isReady;

  @override
  _MenuBackdropState createState() => _MenuBackdropState();
}

class _MenuBackdropState extends State<MenuBackdrop>
    with SingleTickerProviderStateMixin<MenuBackdrop> {
  AnimationController _animationController;

  Animation<double> _fadeLengthAnimation;
  double fadeLength = 150;

  Animation<double> _radiusAnimation;
  double radius = 1;

  Animation<double> _centerAnimation;
  double center = 1.0;

  void handleAnimate() {
    setState(() {
      fadeLength = _fadeLengthAnimation.value;
      radius = _radiusAnimation.value;
      center = _centerAnimation.value;
    });
  }

  void updateFadeLength() {
    switch (widget.screenMode) {
      case StudioScreenMode.focusedMode:
        animate(fadeLength: 250, radius: 0.97, center: 1.1);
        break;
      default:
        animate(fadeLength: 150, radius: 1, center: 1);
    }
  }

  void animate({double fadeLength, double radius, double center}) {
    if (fadeLength != null) {
      final double fromFadeLength = fadeLength;
      _fadeLengthAnimation = Tween(begin: fromFadeLength, end: fadeLength)
          .animate(_animationController);
    }

    if (radius != null) {
      final double fromRadius = radius;
      _radiusAnimation =
          Tween(begin: fromRadius, end: radius).animate(_animationController);
    }

    if (center != null) {
      final double fromCenter = center;
      _centerAnimation =
          Tween(begin: fromCenter, end: center).animate(_animationController);
    }

    _animationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this)
      ..addListener(handleAnimate);
  }

  @override
  void didUpdateWidget(MenuBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.screenMode != widget.screenMode) {
      updateFadeLength();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get opacity {
    if (widget.screenMode == StudioScreenMode.exporting) {
      return 0.0;
    }
    return widget.isReady ? 1.0 : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: widget.isReady ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 350),
        child: Container(
          child: CustomPaint(
            painter: MenuGradientPainter(
              fadeLength: fadeLength,
              radiusMultiplier: radius,
              center: Alignment(
                0.0,
                -(1.0 * center),
              ),
            ),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

/// *** Menu Icons row
class MenuIconsRow extends StatefulWidget {
  const MenuIconsRow({
    Key key,
    this.screenMode,
    this.updateScreenMode,
    this.isReady,
    this.project,
  }) : super(key: key);

  final StudioScreenMode screenMode;
  final ValueChanged<StudioScreenMode> updateScreenMode;
  final bool isReady;
  final Project project;

  @override
  State<StatefulWidget> createState() {
    return _MenuIconsRowState();
  }
}

const int duration = 700;

class _MenuIconsRowState extends State<MenuIconsRow>
    with TickerProviderStateMixin<MenuIconsRow> {
  AnimationController _opacityController;
  Animation<double> _animationOpacity;

  Animation<double> _animationTranslation;

  AdjustmentsMenuItemWidget pickedItem;

  @override
  void initState() {
    super.initState();
    _prepareStartAnimations();
  }

  @override
  void didUpdateWidget(MenuIconsRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isReady != widget.isReady) {
      if (widget.isReady) {
        _opacityController.forward();
      } else {
        _opacityController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _opacityController.dispose();
    super.dispose();
  }

  void _prepareStartAnimations() {
    _opacityController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    final CurvedAnimation curve =
        CurvedAnimation(parent: _opacityController, curve: Curves.easeOutExpo);
    _animationOpacity = Tween(begin: 0.0, end: 1.0).animate(curve);
    _animationTranslation = Tween(begin: 20.0, end: 0.0).animate(curve);
  }

  void onPick(AdjustmentsMenuItemWidget option) {
    if (option == pickedItem) {
      onUnpick();
    } else {
      widget.updateScreenMode(StudioScreenMode.focusedMode);
      setState(() {
        pickedItem = option;
      });
    }
  }

  void onUnpick() {
    widget.updateScreenMode(StudioScreenMode.normal);

    Editor.instance.commitAndSave("Chanegd ${pickedItem.title}");

    setState(() {
      pickedItem = null;
    });
  }

  bool get hasPicked {
    return pickedItem != null;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      child: IgnorePointer(
          ignoring: !widget.isReady,
          child: AnimatedBuilder(
              animation: _opacityController,
              builder: (BuildContext context, Widget child) {
                return Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.none,
                  child: Opacity(
                      opacity: _animationOpacity.value,
                      child: Transform.translate(
                          offset: Offset(0, _animationTranslation.value),
                          child: _buildScopeWillPop(context))),
                );
              })),
    );
  }

  Future<bool> onWillPop() async {
    if (hasPicked) {
      onUnpick();
      return false;
    }
    return true;
  }

  Widget _buildScopeWillPop(BuildContext context) {
    return WillPopScope(
        child: Stack(
          children: <Widget>[
            _buildOptionsContainer(context),
            _buildOptionsContent(context)
          ],
        ),
        onWillPop: onWillPop);
  }

  double get opacity {
    if (widget.screenMode == StudioScreenMode.exporting) {
      return 0.0;
    }
    return hasPicked ? 0.09 : 1;
  }

  Widget _buildOptionsContainer(BuildContext context) {
    return AnimatedContainer(
      height: hasPicked ? 210.0 : 140.0, // todo: constant
      duration: const Duration(milliseconds: duration), // todo: constant
      padding: const EdgeInsets.only(bottom: 30, top: 30), // todo: constant
      curve: Curves.easeOutExpo, // todo: constant
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: duration), // todo: constant
        opacity: opacity,
        curve: Curves.easeOutExpo, // todo: constant
        child: Center(
          child: ListView.builder(
            itemBuilder: buildMenuIconItem,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: adjustmentsMenuItems.length,
            physics: const BouncingScrollPhysics(),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsContent(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !hasPicked,
        child: AnimatedContainer(
          transform: Matrix4.translationValues(
            0,
            hasPicked ? 0.0 : 100.0,
            0,
          ), // todo: constant
          duration: const Duration(milliseconds: duration), // todo: constant
          decoration: BoxDecoration(
            color: Colors.blueAccent.withAlpha(1),
          ), // todo: constant
          curve: Curves.easeOutExpo, // todo: constant
          child: AnimatedOpacity(
            opacity: hasPicked ? 1 : 0, // todo: constant
            duration: hasPicked
                ? const Duration(milliseconds: duration)
                : const Duration(milliseconds: 100), // todo: constant
            child: hasPicked && widget.isReady
                ? OptionEditor(
                    option: pickedItem,
                    onBack: onUnpick,
                  )
                : Container(),
          ),
        ),
      ),
    );
  }

  _MenuIconItem buildMenuIconItem(BuildContext context, int index) =>
      _MenuIconItem(adjustmentsMenuItems[index], onPick);
}

class _MenuIconItem extends StatelessWidget {
  _MenuIconItem(this.item, this.onPick) : super();

  final AdjustmentsMenuItemWidget item;
  final ValueChanged<AdjustmentsMenuItemWidget> onPick;

  void onTap() => onPick(item);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: InkResponse(
        highlightColor: Colors.transparent,
        radius: 40,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: onTap,
        child: Container(
            width: 75.0,
            decoration: BoxDecoration(color: Colors.transparent),
            padding: const EdgeInsets.symmetric(
              horizontal: 5.0,
              vertical: 15.0,
            ),
            child: Opacity(
              opacity: 1.0,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 20.0,
                      height: 20.0,
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: Center(
                        child: item.icon,
                      ),
                    ),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 12.0,
                      ),
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
