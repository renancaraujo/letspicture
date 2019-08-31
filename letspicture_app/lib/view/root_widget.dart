import 'package:flutter/material.dart';
import 'package:letspicture_app/config/application.dart';

class RootWidget extends StatelessWidget {
  final Application application;

  const RootWidget({Key key, @required this.application}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: "LetsPicture",
        onGenerateRoute: application.router.generator,
        initialRoute: "/loading",
        debugShowCheckedModeBanner: false,
        theme: application.themeData,
      );
}
