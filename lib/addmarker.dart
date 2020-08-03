import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:NorthStar/snackbars.dart';
import 'database.service.dart';

class MyAddmarker extends StatefulWidget {
  MyAddmarker({Key key, this.ownerID}) : super(key: key);
  final String ownerID;

  @override
  AddmarkerState createState() => AddmarkerState();
}

class AddmarkerState extends State<MyAddmarker> {
  final _formKey = GlobalKey<FormState>();
  final textController0 = TextEditingController();
  final textController = TextEditingController();
  final textController1 = TextEditingController();
  final textController2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color btnForeground = Colors.white;
    const Color inputForeground = Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Safehouse"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(4),
          children: <Widget>[
            Card(
              shadowColor: Colors.black,
              child: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: ListTile(
                  leading: Icon(
                    Icons.home,
                    color: Colors.black,
                  ),
                  title: TextFormField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    controller: textController0,
                    decoration: new InputDecoration(
                      hintText: "Enter Owner's Name",
                      hintStyle: TextStyle(color: inputForeground),
                      fillColor: Colors.black,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please Enter a Name';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
            Card(
              shadowColor: Colors.black,
              child: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: ListTile(
                  leading: Icon(
                    Icons.home,
                    color: Colors.black,
                  ),
                  title: TextFormField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    controller: textController,
                    decoration: new InputDecoration(
                      hintText: "Enter the Address",
                      hintStyle: TextStyle(color: inputForeground),
                      fillColor: Colors.black,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please Enter an Address';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
            Card(
              shadowColor: Colors.black,
              child: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: ListTile(
                  leading: Icon(
                    Icons.airline_seat_individual_suite,
                    color: Colors.black,
                  ),
                  title: TextFormField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    controller: textController1,
                    decoration: const InputDecoration(
                      hintText: 'Add Maximum Capacity',
                      hintStyle: TextStyle(color: inputForeground),
                      fillColor: Colors.black,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please Enter a Valid Number';
                      } else {
                        try {
                          int.parse(textController1.text);
                          if (int.parse(textController1.text) <= 0) {
                            return 'Please Enter a Number above 0';
                          }
                          return null;
                        } catch (e) {
                          return "Please Enter a Valid Number";
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
            Card(
              shadowColor: Colors.black,
              child: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: ListTile(
                  leading: Icon(
                    Icons.phone,
                    color: Colors.black,
                  ),
                  title: TextFormField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    controller: textController2,
                    decoration: const InputDecoration(
                      hintText: 'Add Phone Number',
                      hintStyle: TextStyle(color: inputForeground),
                      fillColor: Colors.black,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please Enter a Phone Number';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(5),
              child: RaisedButton(
                child: const Text('Add Safehouse to The Map',
                    style: TextStyle(color: btnForeground)),
                textColor: Colors.white,
                color: Colors.black,
                padding: EdgeInsets.all(15),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    await showDialog<String>(
                      barrierDismissible: false,
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
                                'This Will Make the Provided Safehouse Available Globally',
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
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    if (_formKey.currentState.validate()) {
                                      var address = Uri.encodeQueryComponent(
                                          textController.text);
                                      print(address);

                                      var response = await http.post(
                                          "https://maps.googleapis.com/maps/api/geocode/json?address=" +
                                              address +
                                              "&key=AIzaSyBnrNelKTw8w-loWPgOjPDLex6WV5rpjVA");
                                      var responseJson =
                                          json.decode(response.body);
                                      print(responseJson);

                                      var _latitude =
                                          await responseJson["results"][0]
                                              ["geometry"]["location"]["lat"];
                                      var _longitude =
                                          await responseJson["results"][0]
                                              ["geometry"]["location"]["lng"];

                                      var newSafehouse = {
                                        "address": textController.text,
                                        "capacity":
                                            int.parse(textController1.text),
                                        "compromised": false,
                                        "latitude": _latitude,
                                        "longitude": _longitude,
                                        "ownerID": widget.ownerID,
                                        "name": textController0.text,
                                        "phoneNum": textController2.text,
                                        "reserved": 0,
                                      };
                                      DatabaseService.addToFirebaseDatabase(
                                          newSafehouse);
                                    }
                                  },
                                  child: const Text('Okay'),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
