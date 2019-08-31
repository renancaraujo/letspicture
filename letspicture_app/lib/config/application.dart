import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:letspicture_app/storage/config/database_manager.dart';
import 'package:letspicture_app/storage/config/file_manager.dart';
import 'package:letspicture_app/storage/observables/project_collection.dart';
import 'package:letspicture_app/view/routes/internal/studio/studio_route.dart';
import 'package:letspicture_app/view/routes/internal/summary/route.dart';
import 'package:letspicture_app/view/routes/loading_route.dart';

List<RouteWidget> routes = [SummaryRoute(), LoadingRoute(), StudioRoute()];

class Application {
  Application._internal() : router = Router() {
    _prepareRoutes();
    setupFuture = _prepareKicksStartConfig();
  }

  static Application _instance;

  static Application get instance {
    if (_instance == null) {
      _instance = Application._internal();
    }
    return _instance;
  }

  final Router router;
  final ThemeData themeData = ThemeData(
      brightness: Brightness.dark,
      accentColor: Color(0xFFE94227),
      canvasColor: Color(0xFF080808),
      appBarTheme: AppBarTheme(color: Color(0xFF080808)),
      textTheme: TextTheme(
          body1: TextStyle(fontSize: 20, fontWeight: FontWeight.w200)),
      fontFamily: "Exo");
  Future<void> setupFuture;

  Future<void> _prepareKicksStartConfig() async {
    await DatabaseManager.instance.init();
    await FileUtils.instance.init();

    await projectCollectionObservable.init();

    return Future.delayed(Duration(milliseconds: 900));
  }

  void _prepareRoutes() {
    routes.forEach((RouteWidget route) {
      router.define(route.routePath,
          handler: route.handler, transitionType: route.transitionType);
    });
  }
}

abstract class RouteWidget {
  RouteWidget(
    this.routePath, {
    this.transitionType = TransitionType.fadeIn,
  }) {
    this.handler = Handler(handlerFunc: this.build);
  }

  Handler handler;
  final String routePath;
  final TransitionType transitionType;

  Widget build(BuildContext context, Map<String, List<String>> parameters);
}
