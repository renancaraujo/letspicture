import 'package:flutter/material.dart';

class ExportingLoader extends StatefulWidget {
  @override
  _ExportingLoaderState createState() => _ExportingLoaderState();
}

class _ExportingLoaderState extends State<ExportingLoader>
    with SingleTickerProviderStateMixin<ExportingLoader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("Loading"),
      ),
    );
  }
}
