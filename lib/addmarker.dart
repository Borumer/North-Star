import 'package:NorthStar/safehouse.dart';
import 'package:NorthStar/strings.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MyAddmarker extends StatefulWidget {
  MyAddmarker({Key key}) : super(key: key);

  @override
  AddmarkerState createState() => AddmarkerState();
}

class AddmarkerState extends State<MyAddmarker> {
  final _formKey = GlobalKey<FormState>();
  Safehouse newSafehouse = Safehouse();

  @override
  Widget build(BuildContext context) {
    const Color btnForeground = Colors.white;
    const Color inputForeground = Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(4),
          children: <Widget>[
            Card(
              shadowColor: Colors.white,
              color: Colors.black,
              child: ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: btnForeground,
                ),
                title: Text(
                  'Add Safehouse\'s Marker', style: TextStyle(color: btnForeground)
                ),
                onTap: () {

                },
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
                    title: TextFormField(
                      controller: TextEditingController(),
                      style: TextStyle(color: inputForeground),
                      decoration: const InputDecoration(
                        hintText: "Add Address",
                        hintStyle: TextStyle(color: inputForeground),
                      ),
                      validator: (String value) {
                        if (value.isNotEmpty)
                          return null;
                        return "The safehouse address is required";
                      },
                      onSaved: (String value) {
                        newSafehouse.address = value;
                      }
                    ),
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
                title: TextFormField(
                  controller: TextEditingController(),
                  style: TextStyle(color: inputForeground),
                  decoration: const InputDecoration(
                    hintText: "Add Maximum Capacity",
                    hintStyle: TextStyle(color: inputForeground),
                    fillColor: Colors.white,
                  ),
                  validator: (String value) {
                    if (value.isNotEmpty) {
                      int x; // Declare variable for parsing
                      if (
                      (x = int.parse(value)) != null
                          && x > 0) // If the value is a positive integer
                        return null;
                      else
                        return "The capacity must be a positive integer!";
                    }
                    return "The capacity is required!";
                  },
                  onSaved: (String value) {
                    newSafehouse.capacity = int.parse(value);
                  }
                ),
              ),
            ),
            Card(
              shadowColor: Colors.black,
              child: ListTile(
                leading: Icon(
                  Icons.phone,
                  color: Colors.black,
                ),
                title: TextFormField(
                  controller: TextEditingController(),
                  style: TextStyle(color: inputForeground),
                  decoration: const InputDecoration(
                    hintText: "Add Phone Number",
                    hintStyle: TextStyle(color: inputForeground),
                    fillColor: Colors.white,
                  ),
                ),
                onTap: () async {

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
                        child: const Text('Add Safehouse to The Map', style: TextStyle(color: btnForeground)),
                        textColor: Colors.white,
                        color: Colors.black,
                        padding: EdgeInsets.all(15),
                        onPressed: () async {
                          await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return SimpleDialog(
                                title: const Text(
                                  'New Safehouse',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.black,
                                children: <Widget>[
                                  ListTile(
                                    title: Text(
                                      'This will display your house to new runaway slaves',
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
                                          Navigator.pop(context);
                                          if (_formKey.currentState.validate())
                                            _formKey.currentState.save();
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
      )
    );
  }
}
