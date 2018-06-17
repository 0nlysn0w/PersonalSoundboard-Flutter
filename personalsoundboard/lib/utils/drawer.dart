import 'package:flutter/material.dart';

import '../pages/group_page.dart';
import 'package:share/share.dart';

import '../main.dart';


class TestDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
        child: new Container(
          child: new ListView(
          children: <Widget>[
            new DrawerHeader(
              child: Text(""),
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: new AssetImage('icon/drawer_logo.png')
                ),
              ),
            ),
            new ListTile(
              title: new Container(
                alignment: Alignment.center,
                child: new Text("Personal"),
                ),
              trailing: new Icon(Icons.arrow_right),
              onTap: () {
                var route = Navigator.defaultRouteName;
                print(route);
                Navigator.of(context).popUntil(ModalRoute.withName(route));
                // Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new MyApp()));

              }
            ),
            new Divider(),
            new ListTile(
              title: new Container(
                alignment: Alignment.center,
                child: new Text("Groups"),
              ),
              trailing: new Icon(Icons.arrow_right),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new GroupPage()));
              }
            ),
          ],
        ),
        ),
      );
  }
}