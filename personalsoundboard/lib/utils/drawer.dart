import 'package:flutter/material.dart';

import '../pages/group_page.dart';
import '../main.dart';

class TestDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
        child: new ListView(
          children: <Widget>[
            new DrawerHeader(
              child: Text(""),
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: new NetworkImage("https://c.wallhere.com/photos/e1/9f/1920x1080_px_landscape_Low_Poly_render-1106972.jpg!d")
                ),
              ),
            ),
            new ListTile(
              title: new Text("Personal"),
              trailing: new Icon(Icons.arrow_right),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new MyApp()));
              }
            ),
            new Divider(),
            new ListTile(
              title: new Text("Groups"),
              trailing: new Icon(Icons.arrow_right),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new GroupPage()));
              }
            ),
            new Divider(),
            new ListTile(
              title: new Text("Group Page"),
              trailing: new Icon(Icons.add_circle),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new GroupPage()));
              }
            ),
          ],
        ),
      );
  }
}