import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'audioplayer.dart';
import 'audiorecord.dart';
import 'pages/addtogroup_page.dart';
import 'pages/content_page.dart';
import 'sqflite_connection.dart';
import 'package:flutter/services.dart';

import 'package:simple_permissions/simple_permissions.dart';
import 'package:image_picker/image_picker.dart';
import './utils/drawer.dart';
import 'package:uni_links/uni_links.dart';

import 'utils/content.dart';
import 'utils/group.dart';


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
        primarySwatch: Colors.red,
      ),
      home: new MyHomePage(title: 'Personal Soundboard'),
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

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin  {
  Content content;
  List<Content> contents = new List();
  @override
  void initState() {
    super.initState();
    content = Content("", "", "", "");
    AudioplayerRamon.initAudioPlayer();
    gridviewthing();
    SimplePermissions.requestPermission(Permission.RecordAudio);

    initPlatformState();

  }
  
  Uri _latestUri;
  String _latestLink = "unknown";

  StreamSubscription _sub;
  Widget row;
  int count = 0;
  initPlatformState() async {
      await initPlatformStateForStringUniLinks();

  }

  initPlatformStateForStringUniLinks() async {
    // Attach a listener to the links stream
    _sub = getLinksStream().skip(count).listen((String link) {
      if (!mounted) return;
      setState(() {
        _latestLink = link ?? 'Unknown';
        _latestUri = null;
        try {
          if (link != null) _latestUri = Uri.parse(link);
        } on FormatException {}
      });
    }, onError: (err) {
      if (!mounted) return;
      setState(() {
        _latestLink = 'Failed to get latest link: $err.';
        _latestUri = null;
      });
    });

    // Attach a second listener to the stream
    getLinksStream().listen((String link) {
      print('got link: $link');
    }, onError: (err) {
      print('got err: $err');
    });

    // Get the latest link
    String initialLink;
    Uri initialUri;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialLink = await getInitialLink();
      print('initial link: $initialLink');
      if (initialLink != null) initialUri = Uri.parse(initialLink);
    } on PlatformException {
      initialLink = 'Failed to get initial link.';
      initialUri = null;
    } on FormatException {
      initialLink = 'Failed to parse the initial link as Uri.';
      initialUri = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    if(initialUri != null) {
      Map<String, String> m = initialUri.queryParameters;
      Group group = new Group(m["name"]);
      group.key = m["key"];
      SQFLiteConnect db = new SQFLiteConnect();
      bool exists = await db.groupExists(group.key);
      if(!exists) {
        m["name"].replaceAll(new RegExp("%20"), " ");
        await db.addGroup(group);
      }
      Navigator.of(context).push( new MaterialPageRoute(builder: (context) => new ContentPage(group)));
    }
    setState(() {
      _latestLink = initialLink;
      _latestUri = initialUri;
      count++;
    });
  }

  //Dialog
  Future<Null> _soundOptions(Content content) async {
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
              padding: const EdgeInsets.fromLTRB(1.0, 0.0, 0.0, 0.0),
              child: new SimpleDialogOption(
                onPressed: () {
                  deleteSounds(content.key);
                  Navigator.pop(context);
                },
                child: const Icon(Icons.delete, size: 80.0, color: Colors.black54,),
              ),
            ),
            new Container(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 1.0, 0.0),
              child: new SimpleDialogOption(
                onPressed: () {
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new AddToGroupPage(content)));              

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
    List<Map<String, dynamic>> sounds = await _db.getSounds();

    for(var sound in sounds) {
      contents.add(new Content.fromLocalDb(sound));
    }
    List<Widget> images = new List<Widget>();
    for (var item in sounds) {
      String path = item["image"];
      if (item["image"] == null) {
        images.add(new Icon(Icons.play_arrow));
      } else {
        final file = new File(path);
        images.add(new Image.file(file));
      }
    }
    row = new GridView.builder(
      itemCount: sounds.length,
      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (BuildContext builder, int index){
        return new Card(
          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
          child: new GridTile(
            footer: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new DecoratedBox(
                  decoration: new BoxDecoration( 
                    color: Colors.white70,
                    borderRadius: new BorderRadius.circular(5.0),
                  ),
                child: new Text(sounds[index]["title"] == null ? '' : sounds[index]["title"], textAlign: TextAlign.center,)
                )
              ],
            ),
            child: 
            new InkResponse(
              child: images[index],
              onTap: () {
                  AudioplayerRamon.localPath(sounds[index]["sound"]);
                },
              onLongPress: () {
                _soundOptions(contents[index]);
              },
            ),
          ),
        );
      },
    );
    setState(() {});
  }

  void deleteSounds(String id) async {
    SQFLiteConnect db = new SQFLiteConnect();
    bool complete = await db.deleteSound(id);
    if (complete) {
      gridviewthing();
    }
  }

  void _addSounds() async {
    await Navigator.of(context).push(
        new MaterialPageRoute(builder: (context) => new AppBody()),
      ).whenComplete(() =>
        gridviewthing()
      );
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
      
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Colors.red[400],
        onPressed: _addSounds,
        tooltip: 'Increment',
        child: new Icon(Icons.add_box),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      drawer: new TestDrawer(),
    );
  }
}



class PictureAndTitleScreenBody extends StatefulWidget{
  String _id;
  PictureAndTitleScreenBody(String id) {
    _id = id;
  }
  @override
  State<StatefulWidget> createState() => new PictureAndTitleScreen(_id);
}


class PictureAndTitleScreen extends State<PictureAndTitleScreenBody> {
  File image;
  String _id = "";
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String title;
  SQFLiteConnect _db = new SQFLiteConnect();
  PictureAndTitleScreen(String id) {
    _id = id;
  }
  pickerGallery() async {
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = img;
    });
  }
  pickerCamera() async {
    File img = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      image = img;
    });
  }
  

 Future<Null> picker() async {
    await showDialog<Department>(
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
          contentPadding: new EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 50.0),
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
            children: <Widget>[
            new Container(
              padding: const EdgeInsets.fromLTRB(1.0, 0.0, 0.0, 0.0),
              child: new SimpleDialogOption(
                onPressed: () {
                  pickerGallery();
                  Navigator.pop(context);
                },
                child: const Icon(Icons.image, size: 80.0, color: Colors.blue,),
              ),
            ),
            new Container(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 1.0, 0.0),
              child: new SimpleDialogOption(
                onPressed: () {
                  pickerCamera();
                  Navigator.pop(context);
                },
                child: const Icon(Icons.camera_alt, size: 80.0, color: Colors.red,),
              ),
              )],
            )
          ],
        );
      }
    );
    setState(() { });

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(''),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: (){_insertIntoDb();},
        ),
      ),
    body: new Wrap(
      children: <Widget>[
        image == null?new Center(
          child: new Container( width: 220.0, height: 220.0,
          child: new IconButton(
              icon: new Icon(Icons.add_photo_alternate),
              iconSize: 200.0,
              color: Colors.green,
              onPressed: () {
                picker();
              },
            ),
          ),
        ):
    
      new Center( heightFactor: 1.1,
         child: new Container( width: 200.0, height: 200.0,
        child:new InkResponse(child: new Image.file(image), onTap: () {picker();},),
      
      ),
      ),

      new Center(
        child: new Form(
          key: _formKey,
          child: new TextFormField(
            textAlign: TextAlign.center,
            autofocus: false,
            maxLength: 30,
            autocorrect: false,
            decoration: new InputDecoration(
              hintText: 'Enter title here',
              border:  new OutlineInputBorder(
              )
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter the title';
              }
              else {
                title = value;
              }
            },
          ),
        ),
      
      ),
      new Center(
        child: new IconButton(
          color: Colors.green,
          icon: new Icon(Icons.check_circle),
          iconSize: 100.0,
          onPressed: () {
              _insertIntoDb();
          },
        ),
      )
    ]
    )
    );
  }

  _insertIntoDb() async {
    if(_formKey.currentState.validate()) {
      var m = await _db.insertTitleAndImage(_id,  title, image==null? null : image.path);
      if (m) {
        Navigator.pop(context, "meep 2");
      }
    }
  }
}

