import 'package:NorthStar/safehouse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:NorthStar/map.dart';
import 'package:NorthStar/addmarker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'North Star',
      theme: ThemeData(
        primaryColor: Colors.black,
        indicatorColor: Colors.black,
        canvasColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'North Star'),
      routes: <String, WidgetBuilder> {
        '/map': (BuildContext context) => MyApp(),
        '/safehouse': (BuildContext context) => MySafehouse(title: 'safehouse'),
        '/addmarker': (BuildContext context) => MyAddmarker(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          FlatButton.icon(
              onPressed: () {
                Navigator.popAndPushNamed(context, '/map');
              },
              icon: Icon(
                Icons.sync,
                size: 20,
                color: Colors.white,
              ),
              label: Text("Sync")
          )
        ]
      ),
      body: MyMap(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.black,
        hoverColor: Colors.black,
        splashColor: Colors.black,
        child: Icon(
          Icons.add_location,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyAddmarker()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
