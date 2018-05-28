import 'package:flutter/material.dart';

import 'package:audioplayer/audioplayer.dart';

enum PlayerState { stopped, playing, paused }

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'PersonalSoundboard',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
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
    initAudioPlayer();
  }
  int _counter = 0;
  
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
  
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _playSound(final path) async {
    final result = await audioPlayer.play(path);
    print(result);
    if (result == 1) {
       setState(() => playerState = PlayerState.playing);
      _incrementCounter();
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
        // child: new Column(
        //   // Column is also layout widget. It takes a list of children and
        //   // arranges them vertically. By default, it sizes itself to fit its
        //   // children horizontally, and tries to be as tall as its parent.
        //   //
        //   // Invoke "debug paint" (press "p" in the console where you ran
        //   // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
        //   // window in IntelliJ) to see the wireframe for each widget.
        //   //
        //   // Column has various properties to control how it sizes itself and
        //   // how it positions its children. Here we use mainAxisAlignment to
        //   // center the children vertically; the main axis here is the vertical
        //   // axis because Columns are vertical (the cross axis would be
        //   // horizontal).
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: <Widget>[
        //     new Text(
        //       'You have pushed the button this many times:',
        //     ),
        //     new Text(
        //       '$_counter',
        //       style: Theme.of(context).textTheme.display1,
        //     ),
        //   ],
        // ),      
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              new RaisedButton(
                child: new Text('1', textAlign: TextAlign.center),
                onPressed: () {
                  _getSound("http://www.rxlabz.com/labz/audio2.mp3");
                },
              ),
              new RaisedButton(
                child: new Text('2', textAlign: TextAlign.center),
                onPressed: () {
                  _getSound("http://www.rxlabz.com/labz/audio.mp3");
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
          _getSound("");
        },
        tooltip: 'Increment',
        child: new Icon(Icons.headset),
      ), // This trailing comma makes auto-formatting nicer for build methods.

    );
  }
}
