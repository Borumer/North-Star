import 'package:NorthStar/safehouse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:NorthStar/map.dart';
import 'package:NorthStar/addmarker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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
      routes: <String, WidgetBuilder>{
        '/map': (BuildContext context) => new MyApp(),
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
  var uuid;

  @override
  void initState() {
    super.initState();
    setUuid();
  }

  void setUuid() async {
    var temp = await setUserID();
    setState(() {
      uuid = temp;
    });
  }

  Future<String> setUserID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("uuid") != null) {
      return prefs.getString("uuid");
    } else {
      var uuid = Uuid();
      var id = uuid.v4();
      prefs.setString("uuid", id);
      return id;
    }
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    if (this.uuid == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[CircularProgressIndicator()],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          foregroundColor: Colors.black,
          hoverColor: Colors.black,
          splashColor: Colors.black,
          child: Icon(
            Icons.add_location,
            color: Colors.white,
          ),
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyAddmarker(
                  ownerID: this.uuid,
                ),
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: MyMap(userID: this.uuid),
      );
    }
  }
}
