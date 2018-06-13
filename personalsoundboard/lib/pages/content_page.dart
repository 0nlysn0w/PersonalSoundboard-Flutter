import 'dart:io';

import 'package:flutter/material.dart';

import '../audioplayer.dart';
import '../utils/content.dart';
import './addcontent_page.dart';
import '../utils/group.dart';

import 'package:firebase_database/firebase_database.dart';

class ContentPage extends StatefulWidget {
  ContentPage(this.group);
  final Group group;

  @override
  ContentPageState createState() => new ContentPageState(group);
}

class ContentPageState extends State<ContentPage> {
  ContentPageState(this.group);
  
  Group group;
  Widget row;
  
  List<Content> contents = new List();
  Content content;

  DatabaseReference contentRef;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();    
    final FirebaseDatabase database = FirebaseDatabase.instance;
    contentRef = database.reference().child('content');
    contentRef.onChildAdded.listen(_onEntryAdded);
    contentRef.onChildChanged.listen(_onEntryChanged);
    gridViewCustomBuild();
  }

    _onEntryAdded(Event event) {
    setState(() {
      contents.add(Content.fromSnapshot(event.snapshot));
      contents = contents.where((c) => c.group == group.key).toList();
    });
  }

  _onEntryChanged(Event event) {
    var old = contents.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      List<Content> unfilteredcontents = List();
      unfilteredcontents[contents.indexOf(old)] = Content.fromSnapshot(event.snapshot);
      contents = unfilteredcontents.where((c) => c.group == group.key);
    });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Content of " + group.name),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(context, new MaterialPageRoute(builder: (context) => new AddContentPage(group)));
            },
          )
        ],
      ),
      body: 
      // row
      new GridView.extent(
          children: _cardGridBuilder(contents.length), 
          maxCrossAxisExtent: 120.0,
        )
    );
  }

  List<Widget> _cardGridBuilder(numberOfContents) {
    List<Card> cards = new List<Card>.generate(numberOfContents, 
    (int index) {
      return new Card(
          child: new GridTile(
            footer: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new DecoratedBox(
                  decoration: new BoxDecoration( 
                    color: Colors.white70,
                    borderRadius: new BorderRadius.circular(5.0),
                  ),
                child: new Text(contents[index].name == null ? '' : contents[index].name, textAlign: TextAlign.center,)
                )
              ],
            ),
            child: 
            new InkResponse(
              child: contents[index].coverUrl == null
                ? new Icon(Icons.play_arrow)
                : new Image.network(contents[index].coverUrl),
              onTap: () {
                  AudioplayerRamon.onlinePath(contents[index].soundUrl);
                },
              onLongPress: () {
                // _soundOptions(sounds[index]["id"]);
               // _db.deleteSound(sounds[index]["id"]);
                // gridviewthing();
              },
            ),
          ),
        );
      });
    return cards;
  }

  void gridViewCustomBuild() async {

    List<Widget> images = new List<Widget>();
    for (var item in contents) {
      String path = item.coverUrl;
      if (path == null) {
        images.add(new Icon(Icons.play_arrow));
      } else {
        final file = new File(path);
        images.add(new Image.file(file));
      }
    }
    row = new GridView.builder(
      itemCount: contents.length,
      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (BuildContext builder, int index){
        return new Card(
          child: new GridTile(
            footer: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new DecoratedBox(
                  decoration: new BoxDecoration( 
                    color: Colors.white70,
                    borderRadius: new BorderRadius.circular(5.0),
                  ),
                child: new Text(contents[index].name == null ? '' : contents[index].name, textAlign: TextAlign.center,)
                )
              ],
            ),
            child: 
            new InkResponse(
              child: images[index],
              onTap: () {
                  AudioplayerRamon.onlinePath(contents[index].soundUrl);
                },
              onLongPress: () {
                // _soundOptions(sounds[index]["id"]);
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

}
