import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_cookbook_new/Modules/Home/Models/Chapter.dart';

import 'package:flutter_cookbook_new/Modules/Home/Models/Section.dart';
import 'package:flutter_cookbook_new/FCM/firebase_notification_handler.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

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
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Section> _sections = [];
  Future<List<Section>> sectionsFuture;

  @override
  void initState() {
    super.initState();
    new FirebaseNotifications().setUpFirebase();
    sectionsFuture = _getSections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder(
          future: this.sectionsFuture,
          builder: (context, asyncSnapShot) {
            switch (asyncSnapShot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                //Show progress bar
                return Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
              case ConnectionState.done:
                if (!asyncSnapShot.hasError) {
                  _sections = asyncSnapShot.data;
                  return _buildList();
                }
            }
          },
        ));
  }

  Widget _buildList() {
    List<ExpansionPanel> expansionPanelList = _buildExpansionList();

    return SingleChildScrollView(
      child: Container(
          child: ExpansionPanelList(
        animationDuration: Duration(milliseconds: 3),
        children: expansionPanelList,
        expansionCallback: (section, expanded) {
          print("############# Expanded - $section");
          setState(() {
            _sections[section].expanded = !_sections[section].expanded;
          });
        },
      )),
    );
  }

  List<ExpansionPanel> _buildExpansionList() {
    return _sections.map<ExpansionPanel>((sectionToExpand) {
      List<ListTile> childTiles =
          sectionToExpand.chapters.map<ListTile>((chapter) {
        return ListTile(
          contentPadding: EdgeInsets.fromLTRB(30, 0, 0, 0),
          title: Text(
            "- ${chapter.chapterName}",
          ),
          onTap: () {
            _loadChapterInWebview(chapter);
          },
        );
      }).toList();

      return ExpansionPanel(
        isExpanded: sectionToExpand.expanded,
        headerBuilder: (context, expanded) {
          return ListTile(
              title: Text(
            "${sectionToExpand.sectionName}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ));
        },
        body: Column(
          children: childTiles,
        ),
      );
    }).toList();
  }

  _loadChapterInWebview(Chapter chapter) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return WebviewScaffold(
        appBar: AppBar(
          title: Text(chapter.chapterName),
        ),
        url: chapter.chapterUrl,
      );
    }));
  }
}

Future<List<Section>> _getSections() async {
  List<Section> sections = [];
  String jsonString = await rootBundle.loadString('assets/cook_book.json');
  List<dynamic> jsonData = json.decode(jsonString);
  sections = Section.parseSectionListJSON(jsonData);
  return sections;
}
