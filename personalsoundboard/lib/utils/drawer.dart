import 'package:flutter/material.dart';

class TestDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: new Drawer(
        child: new ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            new DrawerHeader(
              child: new Text("Drawer Header"),
              decoration: new BoxDecoration(
                color: Colors.blue,
              ),
            )
          ],
        ),
      ),
    );
  }
}