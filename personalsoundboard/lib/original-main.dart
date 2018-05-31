import 'dart:async';

import 'package:flutter/material.dart';
import 'audioplayer.dart';
import 'sqflite_connection.dart';

enum PlayerState { stopped, playing, paused }
enum Department { title, image, audio }

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'PersonalSoundboard',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'PersonalSoundboard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    AudioplayerRamon.initAudioPlayer();
  }
  
  

//Dialog
Future<Null> _addSound() async {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var db = new SQFLiteConnect();
  String title = "";
  switch (
    await showDialog<Department>(
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
          title: const Text('Upload audio fragment'),
          children: <Widget>[
            new Form(
              key: _formKey,
              child:
              new TextFormField(
                decoration: new InputDecoration(
                  hintText: 'Title'
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter the title';
                  }
                  else {
                    title = value;
                  }
                },
              )
              ,
            ),
            new SimpleDialogOption(
              onPressed: () { if (_formKey.currentState.validate()) {
                Navigator.pop(context, Department.title);
                }
              },
              child: const Text('Next'),
            ),
          ],
        );
      }
    )
  ) {
    case Department.title:
    await db.insertIntoTable(title);
    break;
    case Department.image:
      // ...
    break;
    case Department.audio:
      // ...
    break;
  }
}

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              new RaisedButton(
                child: new Text('1', textAlign: TextAlign.center),
                onPressed: () {
                  AudioplayerRamon.getSound("http://www.rxlabz.com/labz/audio.mp3");
                },
              ),
              new RaisedButton(
                child: new Text('2', textAlign: TextAlign.center),
                onPressed: () {
                  // _getSound("http://www.rxlabz.com/labz/audio.mp3");
                  AudioplayerRamon.localPath();
                },
              ),
              new Expanded(
                child: new FittedBox(
                  fit: BoxFit.contain, // otherwise the logo will be tiny
                  child: const FlutterLogo(),
                ),
              ),
            ],

      ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          _addSound();
        },
        tooltip: 'Increment',
        child: new Icon(Icons.add_box),
      ), // This trailing comma makes auto-formatting nicer for build methods.

    );
  }
}