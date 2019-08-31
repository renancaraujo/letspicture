import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:letspicture_app/config/application.dart';
import 'package:letspicture_app/view/root_widget.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  runApp(RootWidget(application: Application.instance));
}
