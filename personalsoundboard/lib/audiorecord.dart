import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_recorder/audio_recorder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';

import 'main.dart';
import 'sqflite_connection.dart';

class AppBody extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new AudiorecorderRamon();
}

class AudiorecorderRamon extends State<AppBody> with SingleTickerProviderStateMixin {
  String _id = "";
  String _path = "";
  SQFLiteConnect _db;
  Color color;
  Timer timer;
  AudiorecorderRamon() { 
    _id = SQFLiteConnect.generateId();
    checkPerms();
    _db = new SQFLiteConnect();
    color = new Color(0xFF000000);
  }

  void checkPerms() async{
    var perm1 = await SimplePermissions.checkPermission(Permission.WriteExternalStorage);
    if (!perm1) {
      SimplePermissions.requestPermission(Permission.WriteExternalStorage);
    }
    var dir = await getApplicationDocumentsDirectory();
    
    _path = dir.path + Platform.pathSeparator + "Soundboard";
    var exists = await new Directory(_path).exists();
    if(!exists) {
      await new Directory(_path).create(recursive: false);
    }
  }
  Recording _recording = new Recording();
  bool _isRecording = false;
  Random random = new Random();
  TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar( 
        title: new Text("Record audio"),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: (){Navigator.pop(context,true);}
        ),

      ),
      body: new Center(
        child: 
        new IconButton(
          onPressed: () {
            _startStop();
          },
          icon: new Icon(Icons.mic),
          color: color,
          iconSize: 250.0,
          splashColor: Colors.redAccent[100],
        ),
      ),
    );
  } 
  void _startStop() async {
    if (!_isRecording) {
      color = new Color(0xFFC62828);
      _start();
    } else {
      color = new Color(0xFF000000);
      _stop();
    }
  }

  _start() async {
    try {
      if (await AudioRecorder.hasPermissions) {
        await AudioRecorder.start(path: _path + Platform.pathSeparator + _id);
        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _recording = new Recording(duration: new Duration(), path: _path);
          _isRecording = isRecording;
          timer = new Timer(const Duration(seconds: 10), () => _stop());
        });
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e){
      print(e);
    }
  }

  _stop() async {
    if (timer.isActive) {
      timer.cancel();
    }
    var recording = await AudioRecorder.stop();
    bool isRecording = await AudioRecorder.isRecording;
    setState(() {
      _recording = recording;
      _isRecording = isRecording;
    });
    _controller.text = recording.path;
    _id = await _db.insertIntoTable(_id, recording.path);
    Navigator.of(context).push(new MaterialPageRoute(builder:  (context) => new PictureAndTitleScreenBody(_id))).then((val) => redirectback());
    
  }

  void redirectback() {
    Navigator.pop(context, "meep");
  }

}