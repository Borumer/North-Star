import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:NorthStar/safehouse.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import 'database.service.dart';

class MyMap extends StatefulWidget {
  MyMap({Key key}) : super(key: key);
  @override
  MapState createState() => MapState();
}

class MapState extends State<MyMap> {
  Position _position;

  BitmapDescriptor greenPinLocationIcon;
  BitmapDescriptor yellowPinLocationIcon;
  BitmapDescriptor redPinLocationIcon;

  final _formKey = GlobalKey<FormState>();

  Set<Marker> _markers = {};
  Set<Polyline> shownPolylines;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  final firebaseDatabase = new FirebaseDatabase();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    setCustomMapPins();
    displayCurrentSafehouses();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  void setCustomMapPins() async {
    int pinSize = 95;
    // Retrieve image as bytes so it is resizable
    var greenPinLocationBytes =
        await getBytesFromAsset('assets/images/green_pin.png', pinSize);
    greenPinLocationIcon = BitmapDescriptor.fromBytes(greenPinLocationBytes);

    var yellowPinLocationBytes =
        await getBytesFromAsset('assets/images/yellow_pin.png', pinSize);
    yellowPinLocationIcon = BitmapDescriptor.fromBytes(yellowPinLocationBytes);

    var redPinLocationBytes =
        await getBytesFromAsset('assets/images/red_pin.png', pinSize);
    redPinLocationIcon = BitmapDescriptor.fromBytes(redPinLocationBytes);
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _position = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  GoogleMapController mapController;
  final textController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    super.dispose();
  }

  LatLng getCenter() {
    if (locationFound()) return LatLng(_position.latitude, _position.longitude);

    return null;
  }

  bool locationFound() {
    return _position != null;
  }

  Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  double screenHeight(BuildContext context, {double dividedBy = 1}) {
    return screenSize(context).height / dividedBy;
  }

  double screenWidth(BuildContext context, {double dividedBy = 1}) {
    return screenSize(context).width / dividedBy;
  }

  loadJson() async {
    return await DatabaseService.getAllSafehouses();
  }

  void displayUserLocationMarker() {
    _markers.add(
      Marker(
        markerId: MarkerId("Home"),
        position: getCenter(),
        onTap: () async {
          displaySnackbar(BuildContext context) {
            final snackBar = SnackBar(
              content: Text('Please Enter a Value'),
              backgroundColor: Colors.black,
              duration: Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Okay',
                textColor: Colors.blue[600],
                onPressed: () async {
                  // Some code to undo the change.
                },
              ),
            );
            //Scaffold.of(context).showSnackBar(snackBar);
          }

          await showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                // DONE For Reserve, you'll need to give a dialogue for the number of people, and check if it's possible.
                return SimpleDialog(
                  title: const Text(
                    'Reserve Safehouse',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.black,
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: TextFormField(
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              controller: textController,
                              decoration: const InputDecoration(
                                hintText: 'Enter the Number of Residents',
                                hintStyle: TextStyle(color: Colors.grey),
                                fillColor: Colors.white,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  displaySnackbar(context);
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
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
                            Navigator.pop(context, "No");
                          },
                          child: const Text('Cancel'),
                        ),
                        RaisedButton(
                          textColor: Colors.black,
                          color: Colors.white,
                          onPressed: () {
                            Navigator.pop(context, "Yes");
                            if (_formKey.currentState.validate()) {
                              try {
                                int.parse(textController.text);
                              } catch (e) {
                                print("Woops! Try Again!");
                              }
                              if (!(textController.text is int)) {
                                print(int.parse(textController.text));
                              } else if (int.parse(textController.text) > 0 &&
                                  int.parse(textController.text) <= 8) {
                                print(textController.text);
                              }
                            }
                          },
                          child: const Text('Okay'),
                        ),
                      ],
                    ),
                  ],
                );
              });
        },
      ),
    );
  }

  void displayCurrentSafehouses() {
    // DONE Take the list, iterate through all the safehouses, make their markers(according to their capacity) and then generate the map
    loadJson().then(
      (data) async {
        print("Length: " + data.length.toString());
        for (var i = 0; i < data.length; i++) {
          String markerAddress = data[i]["streetNumber"].toString() +
              " " +
              data[i]["streetName"].toString() +
              ", " +
              data[i]["city"].toString() +
              " " +
              data[i]["state"].toString();

          var _icon;
          if (data[i]["compromised"]) {
            // If the safehouse is compromised
            _icon = redPinLocationIcon;
          } else if (data[i]["capacity"] == data[i]["reserved"]) {
            // If the safehouse is full
            _icon = yellowPinLocationIcon;
          } else if (data[i]["capacity"] > data[i]["reserved"]) {
            // If the safehouse is available
            _icon = greenPinLocationIcon;
          } else {
            // If the location is the user's current one
            _icon = BitmapDescriptor.defaultMarker;
          }

          // Destination Location Marker
          double latitude = data[i]["latitude"];
          double longitude = data[i]["longitude"];

          Marker destinationMarker = Marker(
            markerId: MarkerId("Marker #" + i.toString()),
            position: LatLng(latitude, longitude),
            onTap: () async {
              // var databaseService = new DatabaseService(38.29, -122.28);
              // var safehouse = await databaseService.getAllSafehouses();
              if (!data[i]["compromised"]) {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    // Safehouse currentSafehouse = new Safehouse(data[i]);
                    return new Container(
                      height: screenHeight(context, dividedBy: 1.5),
                      color: Colors
                          .transparent, //could change this to Color(0xFF737373),
                      //so you don't have to change MaterialApp canvasColor
                      child: new Container(
                        decoration: new BoxDecoration(
                          color: Colors.white,
                          borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(15.0),
                            topRight: const Radius.circular(15.0),
                          ),
                        ),
                        child: new Center(
                          child: MySafehouse(
                            index: i,
                            name: data[i]["name"],
                            address: markerAddress,
                            markerLatitude: latitude,
                            markerLongitude: longitude,
                            capacity: data[i]["capacity"],
                            reserved: data[i]["reserved"],
                            compromised: data[i]["compromised"],
                            ownerName: data[i]["ownerName"],
                            phoneNum: data[i]["phoneNum"],
                            userLocation: _position,
                            geolocator: geolocator,
                            markers: _markers,
                            polylines: shownPolylines,
                          ),
                        ),
                      ),
                    );
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                );
              } else {
                final snackBar = SnackBar(
                  content: Text('This Safehouse is Compromised!'),
                  backgroundColor: Colors.black,
                  duration: Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'It is Safe',
                    textColor: Colors.blue[600],
                    onPressed: () async {
                      // Some code to undo the change.
                      switch (await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          // DONE For Reserve, you'll need to give a dialogue for the number of people, and check if it's possible.
                          return SimpleDialog(
                            title: const Text(
                              'Declare Safe?',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.black,
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  'This will Declare the Safehouse Safe again',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              ButtonBar(
                                alignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  OutlineButton(
                                    textColor: Colors.red,
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context, "Cancel");
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  RaisedButton(
                                    textColor: Colors.black,
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.pop(context, "Proceed");
                                    },
                                    child: const Text('Proceed'),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      )) {
                        case "Proceed":
                          //Add Function
                          var databaseService = new DatabaseService();
                          databaseService.updateFirebaseDatabase(
                              i, "compromised", false);
                          break;
                      }
                    },
                  ),
                );
                // Find the Scaffold in the widget tree and use
                // it to show a SnackBar.
                Scaffold.of(context).showSnackBar(snackBar);
              }
            },
            icon: _icon,
          );
          _markers.add(destinationMarker);
        }
      },
    );
  }

  Future _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  Widget build(BuildContext context) {
    if (locationFound()) {
      displayUserLocationMarker();
      displayCurrentSafehouses();
      return GoogleMap(
        myLocationEnabled: true,
        onMapCreated: _onMapCreated,
        markers: _markers,
        polylines: shownPolylines,
        initialCameraPosition: CameraPosition(
          target: LatLng(_position.latitude, _position.longitude),
          zoom: 5.0,
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[CircularProgressIndicator()],
        ),
      );
    }
  }
}
