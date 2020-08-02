import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MyAddmarker extends StatefulWidget {
  MyAddmarker({Key key}) : super(key: key);

  @override
  AddmarkerState createState() => AddmarkerState();
}

class AddmarkerState extends State<MyAddmarker> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(4),
        children: <Widget>[
          Card(
            shadowColor: Colors.white,
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Add Safehouse\'s Marker',
                    style: TextStyle(color: Colors.white),
                  ),
                  // onTap: _createRoute,
                ),
              ],
            ),
          ),
          Card(
            shadowColor: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.home,
                    color: Colors.black,
                  ),
                  title: Text("Add Address"),
                  onTap: () {
                    return false;
                  },
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5.0),
            height: 200.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                for (int i = 0; i < 5; i++)
                  Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      'https://placeimg.com/640/480/any',
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.all(10),
                  ),
              ],
            ),
          ),
          Card(
            shadowColor: Colors.black,
            child: ListTile(
              leading: Icon(
                Icons.airline_seat_individual_suite,
                color: Colors.black,
              ),
              title: Text('Add Maximum Capacity'),
              onTap: () {
                return false;
              },
            ),
          ),
          Card(
            shadowColor: Colors.black,
            child: ListTile(
              leading: Icon(
                Icons.phone,
                color: Colors.black,
              ),
              title: Text('Add Phone Number'),
              onTap: () {
                // launch("tel:" + "Beep");
              },
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Visibility(
                visible:
                    true, //make dynamic and visible iff other values are valid and filled
                child: Expanded(
                  child: Container(
                    margin: EdgeInsets.all(5),
                    child: RaisedButton(
                      child: const Text('Add Safehouse to The Map'),
                      textColor: Colors.white,
                      color: Colors.black,
                      padding: EdgeInsets.all(15),
                      onPressed: () async {
                        await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              title: const Text(
                                'Declaring Compromised',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.black,
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                    'This will Declare this Safehouse Compromised',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                ButtonBar(
                                  alignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    OutlineButton(
                                      textColor: Colors.white,
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    RaisedButton(
                                      textColor: Colors.black,
                                      color: Colors.white,
                                      onPressed: () {
                                        Navigator.pop(context, "Yes");
                                      },
                                      child: const Text('Okay'),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
