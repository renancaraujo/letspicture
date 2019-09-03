import 'package:flutter/material.dart';
import 'package:letspicture/config/application.dart';

class RootWidget extends StatelessWidget {
  const RootWidget({Key key, @required this.application}) : super(key: key);

  final Application application;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: "LetsPicture",
        onGenerateRoute: application.router.generator,
        initialRoute: "/loading",
        debugShowCheckedModeBanner: false,
        theme: application.themeData,
      );
}
