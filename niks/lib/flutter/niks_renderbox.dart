import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../niks.dart';

class NiksRenderWidget extends LeafRenderObjectWidget {
  final Niks skin;

  NiksRenderWidget(this.skin);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderConstrainedBox(
      child: NiksRenderBox(skin),
      additionalConstraints: BoxConstraints.tight(skin.options.size),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderConstrainedBox constrainedBox) {
    constrainedBox
      ..child = NiksRenderBox(skin)
      ..additionalConstraints = BoxConstraints.tight(skin.options.size);
  }
}

class NiksRenderBox extends RenderBox {
  Niks skin;

  NiksRenderBox(this.skin);

  @override
  bool get sizedByParent => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _bindNiksListener();
  }

  @override
  void detach() {
    _unbindNiksListener();
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    Canvas canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    skin.state.paint(canvas, offset);
    canvas.restore();
  }

  void _bindNiksListener() {
    skin.state.addListener(this.markNeedsPaint);
  }

  void _unbindNiksListener() {
    skin.state.removeListener(this.markNeedsPaint);
  }
}
