import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/application.dart';
import 'view/root_widget.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(
    RootWidget(application: Application.instance),
  );
}
