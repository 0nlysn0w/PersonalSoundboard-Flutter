import 'package:flutter/material.dart';
import 'package:personalsoundboard/pages/content_page.dart';
import './pages/group_page.dart';

void main(){
  runApp(new MaterialApp(
    home: new GroupPage(),
    // routes: <String, WidgetBuilder> {
    //   "/ContentPage": (BuildContext context) => new ContentPage(),
    // }
  ));
}
