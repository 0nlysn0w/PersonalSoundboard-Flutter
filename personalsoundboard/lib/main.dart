import 'dart:async';

import 'package:flutter/material.dart';
import 'audioplayer.dart';
import 'audiorecord.dart';
import 'sqflite_connection.dart';

import 'package:simple_permissions/simple_permissions.dart';

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
    // buttonsRows();
    gridviewthing();
    SimplePermissions.requestPermission(Permission.RecordAudio);
  }
  
  Widget row;
  

  //Dialog
  Future<Null> _soundOptions(String id) async {
    var db = new SQFLiteConnect();
    await showDialog<Department>(
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
          contentPadding: new EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 50.0),
          title: const Text('What would you like to do with this sound?', textAlign: TextAlign.center,),
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
            children: <Widget>[
            new Container(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              child: new SimpleDialogOption(
                onPressed: () {
                  //db.deleteSound(id);
                },
                child: const Icon(Icons.delete, size: 80.0, color: Colors.black54,),
              ),
            ),
            new Container(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              child: new SimpleDialogOption(
                onPressed: () {

                },
                child: const Icon(Icons.reply, size: 80.0, color: Colors.green,),
              ),
              )],
            )
          ],
        );
      }
    );
    setState(() { });

  }

  void gridviewthing() async {
    SQFLiteConnect _db = new SQFLiteConnect();
    // _db.deletedatabase();
    List<Map<String, dynamic>> sounds = await _db.getSounds();
    row = new GridView.builder(
      itemCount: sounds.length,
      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (BuildContext builder, int index){
        return new Card(
          child: new GridTile(
            child: 
            new InkResponse(
              child:new Text(sounds[index]["title"]),
              onTap: () {
                  AudioplayerRamon.localPath(sounds[index]["sound"]);
                },
              onLongPress: () {
                _soundOptions(sounds[index]["id"]);
               // _db.deleteSound(sounds[index]["id"]);
                // gridviewthing();
              },
            ),
          ),
        );
      },
    );
    setState(() {});
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
      body: row,
      // new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        // child: new Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: <Widget>[
              // new RaisedButton(
              //   child: new Text('1', textAlign: TextAlign.center),
              //   onPressed: () {
              //     // AudioplayerRamon.getSound("http://www.rxlabz.com/labz/audio.mp3");
              //     AudioplayerRamon.localPath();
              //   },
              // ),
              // new RaisedButton(
              //   child: new Text('2', textAlign: TextAlign.center),
              //   onPressed: () {
              //     // _getSound("http://www.rxlabz.com/labz/audio.mp3");
              //     AudioplayerRamon.localPathTheo();
              //   },
              // ),
              // new Expanded(
              //   child: new FittedBox(
              //     fit: BoxFit.contain, // otherwise the logo will be tiny
              //     child: const FlutterLogo(),
              //   ),
              // ),
        //     ],
        // child: row

      // ),
      // ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          // _addTitle();
        },
        tooltip: 'Increment',
        child: new Icon(Icons.add_box),
      ), // This trailing comma makes auto-formatting nicer for build methods.

    );
  }
}

