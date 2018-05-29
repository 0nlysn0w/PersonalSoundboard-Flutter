import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }
  
  Future<ByteData> loadAsset() async {
      return await rootBundle.load('sounds/roald.mp3');
  }

  dynamic _localPath() async {
    if(isPlaying) {
      audioPlayer.stop();
    }
    final file = new File('${(await getTemporaryDirectory()).path}/roald.mp3');
    await file.writeAsBytes((await loadAsset()).buffer.asUint8List());
    final result = await audioPlayer.play(file.path, isLocal: true);
    if (result == 1) {
       setState(() => playerState = PlayerState.playing);
    }
  }

  PlayerState playerState = PlayerState.stopped;
  AudioPlayer audioPlayer;
  
  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
    audioPlayer.setCompletionHandler(() {
      _onComplete();
    });

    audioPlayer.setErrorHandler((msg) {
      setState(() {
        _onComplete();
      });
    });
  }


  void _playSound(final path) async {
    final result = await audioPlayer.play(path);
    print(result);
    if (result == 1) {
       setState(() => playerState = PlayerState.playing);
    }
  }

  void _getSound(final path) async {
    if (isPlaying) {
      await audioPlayer.stop();
      _playSound(path);
    } else {
      _playSound(path);
    }
  }

  void _onComplete() {
    setState(() {
          playerState = PlayerState.stopped;
        });
  }


Future<Null> _askedToLead() async {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

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
                    print(value);
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
            new SimpleDialogOption(
              onPressed: () { Navigator.pop(context, Department.image); },
              child: const Text('State department'),
            ),
            new SimpleDialogOption(
              onPressed: () { Navigator.pop(context, Department.audio); },
              child: const Text('State department'),
            ),
          ],
        );
      }
    )
  ) {
    case Department.title:
      // Let's go.
      // ...
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
      body: new Card(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ListTile(
              leading: const Icon(Icons.album),
              title: const Text('The Enchanted Nightingale'),
              subtitle: const Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
            ),
            new ButtonTheme.bar( // make buttons use the appropriate styles for cards
              child: new ButtonBar(
                children: <Widget>[
                  new FlatButton(
                    child: const Text('BUY TICKETS'),
                    onPressed: () { /* ... */ },
                  ),
                  new FlatButton(
                    child: const Text('LISTEN'),
                    onPressed: () { /* ... */ },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          _askedToLead();
        },
        tooltip: 'Increment',
        child: new Icon(Icons.add_box),
      ), // This trailing comma makes auto-formatting nicer for build methods.

    );
  }
}
