import 'package:flutter/widgets.dart';

class StreamLineIcon extends StatelessWidget {
  const StreamLineIcon({Key key, this.name, this.size = const Size(48.0, 48.0)})
      : super(key: key);

  final String name;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/icons/streamline-icon-$name@48x48.png",
      width: size.width,
      height: size.height,
    );
  }
}
