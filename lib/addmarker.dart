import 'package:NorthStar/addmarkermap.dart';
import 'package:NorthStar/snackbars.dart';
import 'package:NorthStar/strings.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'database.service.dart';
import 'safehouse.dart';

class MyAddmarker extends StatefulWidget {
  MyAddmarker({Key key}) : super(key: key);

  @override
  AddmarkerState createState() => AddmarkerState();
}

class AddmarkerState extends State<MyAddmarker> {
  final _formKey = GlobalKey<FormState>();
  final textController0 = TextEditingController();
  final textController1 = TextEditingController();
  final textController2 = TextEditingController();
  final textController3 = TextEditingController();
  final textController4 = TextEditingController();
  final textController5 = TextEditingController();
  final textController6 = TextEditingController();

  Safehouse newSafehouse = Safehouse();
  Position _position;

  BitmapDescriptor greenPinLocationIcon;
  BitmapDescriptor yellowPinLocationIcon;
  BitmapDescriptor redPinLocationIcon;

  Set<Marker> _markers = {};
  Set<Polyline> shownPolylines;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  @override
  void initState() {
    super.initState();
    topLevelContext = context;
    _getCurrentLocation();
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

  LatLng getCenter() {
    if (locationFound()) return LatLng(_position.latitude, _position.longitude);

    return null;
  }

  bool locationFound() {
    return _position != null;
  }

  void displayUserLocationMarker() {
    _markers.add(
      Marker(
          draggable: true,
          markerId: MarkerId("Home"),
          position: getCenter(),
          onDragEnd: ((value) {
            print(value.latitude);
            print(value.longitude);
          })),
    );
  }

  Future _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    const Color btnForeground = Colors.white;
    const Color inputForeground = Colors.black;
    var _databaseService = new DatabaseService();

    const addressDetails = [
      "Street Number",
      "Street Name",
      "City",
      "State",
      "Country"
    ];
    var textControllers = [
      textController0,
      textController1,
      textController2,
      textController3,
      textController4,
      textController5,
      textController6
    ];
    if (locationFound()) {
      displayUserLocationMarker();
      bool allowUpload = true;
      // _databaseService.testSet();

      return Scaffold(
        appBar: AppBar(
          title: Text("New Safehouse"),
        ),
        body: ListView(
          padding: EdgeInsets.all(4),
          children: <Widget>[
            Card(
              child: Container(
                height: 300,
                child: GoogleMap(
                  myLocationEnabled: true,
                  onMapCreated: _onMapCreated,
                  markers: _markers,
                  polylines: shownPolylines,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_position.latitude, _position.longitude),
                    zoom: 18.0,
                  ),
                  onTap: (value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyAddmarkermap(),
                      ),
                    );
                  },
                ),
              ),
            ),
            Card(
              shadowColor: Colors.white,
              color: btnForeground,
              child: ListTile(
                leading: Icon(
                  Icons.my_location,
                  color: inputForeground,
                ),
                title: Text(
                  'Using Current Location',
                  style: TextStyle(color: inputForeground),
                ),
              ),
            ),
            Card(
              shadowColor: Colors.white,
              color: inputForeground,
              child: ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: btnForeground,
                ),
                title: Text(
                  'Change Location',
                  style: TextStyle(color: btnForeground),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyAddmarkermap()),
                  );
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
                    title: Text('Address Details'),
                  ),
                  for (var i = 0; i < addressDetails.length; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: ListTile(
                        title: TextFormField(
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          controller: textControllers[i],
                          decoration: new InputDecoration(
                            hintText: addressDetails[i],
                            hintStyle: TextStyle(color: inputForeground),
                            fillColor: Colors.black,
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please Enter a Valid ' +
                                  addressDetails[i];
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5.0),
              height: 200.0,
              child: Padding(
                padding: EdgeInsets.only(bottom: 5),
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
                    controller: textController5,
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
                          int.parse(textController5.text);
                          if (int.parse(textController5.text) <= 0) {
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
                    controller: textController6,
                    decoration: const InputDecoration(
                      hintText: 'Add Phone Number',
                      hintStyle: TextStyle(color: inputForeground),
                      fillColor: Colors.black,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please Enter a Valid Number';
                      } else {
                        try {
                          int.parse(textController6.text);
                          if (int.parse(textController6.text) <= 0) {
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
            Visibility(
              visible:
                  allowUpload, //make dynamic and visible iff other values are valid and filled
              // child: Expanded(
              child: Container(
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
                                      // databaseService.updateFirebaseDatabase(index, property, value)
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
              // ),
            ),
          ],
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
