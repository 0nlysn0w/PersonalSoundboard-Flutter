import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../audioplayer.dart';
import '../sqflite_connection.dart';
import '../utils/content.dart';
import './addcontent_page.dart';
import '../utils/group.dart';
import 'dart:async';

import '../utils/helper.dart';

import 'package:firebase_database/firebase_database.dart';

import 'addtogroup_page.dart';

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
  List<Group> dbGroups;




  DatabaseReference contentRef;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();    
    final FirebaseDatabase database = FirebaseDatabase.instance;
    contentRef = database.reference().child('content');
    contentRef.onChildAdded.listen(_onEntryAdded);
    contentRef.onChildChanged.listen(_onEntryChanged);
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

  _deleteContent(Content contentToDelete){
    contentRef.child(contentToDelete.key).remove();
    Navigator.pop(
    context,
    new MaterialPageRoute(
        builder: (context) => new ContentPage(group)));
  }

  void getGroups() async {
    SQFLiteConnect db = new SQFLiteConnect();
    dbGroups = await db.groups();
  }


  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Content of " + group.name),
        // actions: <Widget>[
        //   new IconButton(
        //     icon: new Icon(Icons.add_circle_outline),
        //     onPressed: () {
        //       Navigator.push(context, new MaterialPageRoute(builder: (context) => new AddContentPage(group)));
        //     },
        //   )
        // ],
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
              onLongPress: () async {
                _soundOptions(contents[index]);
                // _db.deleteSound(sounds[index]["id"]);
                // gridviewthing();
              },
            ),
          ),
        );
      });
    return cards;
  }

    Future<Null> _soundOptions(Content pressedContent) async {
    await showDialog(
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
                  _deleteContent(pressedContent);
                  Navigator.pop(context);
                },
                child: const Icon(Icons.delete, size: 80.0, color: Colors.black54,),
              ),
            ),
            new Container(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 1.0, 0.0),
              child: new SimpleDialogOption(
                onPressed: ()  {
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new AddToGroupPage(pressedContent)));              
                          

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




}
