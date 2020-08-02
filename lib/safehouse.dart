import 'package:NorthStar/database.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class Safehouse {
  Safehouse({
    this.address,
    this.capacity,
    this.reserved,
    this.compromised,
    this.ownerName,
    this.markerPos,
    this.phoneNum,
    this.name
  });

  factory Safehouse.fromJSON(Map<dynamic, dynamic> json) => _itemFromJSON(json);

  static Safehouse _itemFromJSON(Map<dynamic, dynamic> json) {
    String markerAddress = json["streetNumber"].toString() +
        " " +
        json["streetName"].toString() +
        ", " +
        json["city"].toString() +
        " " +
        json["state"].toString();

    return Safehouse(
      name: json['name'] as String,
      address: markerAddress,
      capacity: json['capacity'] as int,
      reserved: json['reserved'] as int,
      compromised: json['compromised'] as bool,
      ownerName: json['ownerName'] as String,
      markerPos: new Position(latitude: json['latitude'], longitude: json['longitude']),
      phoneNum: json['phoneNum']
    );

  }

  /// The name of the safehouse
  final String name;
  /// The physical address of the safehouse
  final String address;

  /// The number of people able to be accomodated at the safehouse
  final int capacity;

  /// The number of spaces already reserved at the safehouse (including people already there)
  int reserved;
  /// Whether the safehouse is compromised by white slavecatchers
  bool compromised;

  /// The name of the safehouse owner
  final String ownerName;

  /// The global position of the safehouse
  final Position markerPos;

  /// The phone number to call the safehouse/safehouse owner
  final String phoneNum;
}

// ignore: must_be_immutable
class MySafehouse extends StatefulWidget {
  MySafehouse({
    Key key,
    this.index,
    this.safehouseInfo,
    this.title,
    this.userLocation,
    this.geolocator,
    this.markers,
    this.polylines,
  }) : super(key: key);

  final int index;

  final Safehouse safehouseInfo;

  final String title;
  final Position userLocation;
  final Geolocator geolocator;

  Set<Marker> markers;
  final Set<Polyline> polylines;

  @override
  SafehouseState createState() => SafehouseState();
}

class SafehouseState extends State<MySafehouse> {

  final _formKey = GlobalKey<FormState>();

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
    return DatabaseService.getAllSafehouses();
  }

  Widget build(BuildContext context) {
    // minHeight: screenHeight(context, dividedBy: 3.1),
    // maxHeight: screenHeight(context, dividedBy: 1.5),

    var databaseService =
        new DatabaseService(widget.safehouseInfo.markerPos.latitude, widget.safehouseInfo.markerPos.longitude);

    _createRoute() {
      _controller.show();
      loadJson().then((data) async {
        // Object for PolylinePoints
        PolylinePoints polylinePoints;
        // List of coordinates to join
        List<LatLng> polylineCoordinates = [];
        // Map storing polylines created by connecting
        // two points
        Map<PolylineId, Polyline> polylines = {};

        // Create the polylines for showing the route between two places
        // Create the polylines for showing the route between two places
        _createPolylines(Position start, Position destination) async {
// Initializing PolylinePoints
          polylinePoints = PolylinePoints();
          // Generating the list of coordinates to be used for
          // drawing the polylines
          PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
            apiKey, // Google Maps API Key
            PointLatLng(start.latitude, start.longitude),
            PointLatLng(destination.latitude, destination.longitude),
            travelMode: TravelMode.transit,
          );
          // Adding the coordinates to the list
          if (result.points.isNotEmpty) {
            result.points.forEach((PointLatLng point) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            });
          }
          // Defining an ID
          PolylineId id = PolylineId('poly');
          // Initializing Polyline
          Polyline polyline = Polyline(
            polylineId: id,
            color: Colors.red,
            points: polylineCoordinates,
            width: 3,
          );
          // Adding the polyline to the map
          polylines[id] = polyline;
        }

        _createPolylines(widget.userLocation, widget.safehouseInfo.markerPos);
        setState(() {
          widget.polylines.addAll(Set<Polyline>.of(polylines.values));
        });
        print("Polyline Coordinates " + polylineCoordinates.toString());
      });
    }

    return ListView(
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
                  Icons.navigation,
                  color: Colors.white,
                ),
                title: Text(
                  'Get Directions',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: _createRoute,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.home,
                  color: Colors.black,
                ),
                title: Text(widget.address),
                onTap: () {
                  return false;
                },
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
                  Icons.airline_seat_individual_suite,
                  color: Colors.black,
                ),
                title: Text('Maximum Capacity'),
                trailing: Text(
                  widget.safehouseInfo.capacity.toString(),
                  style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                ),
                onTap: () {
                  return false;
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.access_time,
                  color: Colors.black,
                ),
                title: Text('Expected Visitors'),
                trailing: Text(
                  widget.safehouseInfo.reserved.toString(),
                  style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                ),
                onTap: () {
                  return false;
                },
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
                  Icons.message,
                  color: Colors.black,
                ),
                title: Text('SMS'),
                subtitle: Text('Safehouse Owner: ' + widget.safehouseInfo.ownerName),
                onTap: () {
                  launch("sms:" + widget.safehouseInfo.phoneNum);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.phone,
                  color: Colors.black,
                ),
                title: Text('Call'),
                subtitle: Text('Safehouse Owner: ' + widget.safehouseInfo.ownerName),
                onTap: () {
                  launch("tel:" + widget.safehouseInfo.phoneNum);
                },
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Visibility(
              visible: widget.safehouseInfo.reserved != widget.safehouseInfo.capacity,
              child: Expanded(
                child: Container(
                  margin: EdgeInsets.all(5),
                  child: OutlineButton(
                    child: const Text('Reserve'),
                    textColor: Colors.black,
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                    onPressed: () async {
                      switch (await showDialog<String>(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      TextFormField(
                                        decoration: const InputDecoration(
                                          hintText: 'Enter your email',
                                        ),
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                        style: TextStyle(
                                          color: Colors.lightGreen
                                        )
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0),
                                        child: RaisedButton(
                                          onPressed: () {
                                            // Validate will return true if the form is valid, or false if
                                            // the form is invalid.
                                            if (_formKey.currentState
                                                .validate()) {
                                              // Process data.
                                            }
                                          },
                                          child: Text('Submit'),
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
                                      },
                                      child: const Text('Okay'),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          })) {
                        case "Yes":
                          //Add Function
                          break;
                        case "No":
                          //Add Function
                          break;
                      }
                    },
                    padding: EdgeInsets.all(15),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(5),
                child: RaisedButton(
                  child: const Text('Compromised'),
                  textColor: Colors.white,
                  color: Colors.black,
                  padding: EdgeInsets.all(15),
                  onPressed: () async {
                    switch (await showDialog<String>(
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
                        })) {
                      case "Yes":
                        databaseService.updateFirebaseDatabase(
                            widget.index, "compromised", true);
                        break;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
