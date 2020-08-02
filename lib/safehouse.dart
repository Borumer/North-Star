import 'package:NorthStar/database.service.dart';
import 'package:NorthStar/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math' as Math;
import 'package:geolocator/geolocator.dart';


// ignore: must_be_immutable
class MySafehouse extends StatefulWidget {
  MySafehouse({Key key, this.title, this.userLocation, this.geolocator, this.markers, this.polylines}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final Position userLocation;
  final Geolocator geolocator;
  Set<Marker> markers;
  Set<Polyline> polylines;

  @override
  SafehouseState createState() => SafehouseState();
}

class SafehouseState extends State<MySafehouse> {
  String _currentAddress;
  String _startAddress;
  String contactInfo = "Contact Info";

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
    return rootBundle.loadString('assets/Fakedata.json')
        .then((response) => json.decode(response));
  }

  SolidController _controller = SolidController();

  Widget build(BuildContext context) {
    // minHeight: screenHeight(context, dividedBy: 3.1),
    // maxHeight: screenHeight(context, dividedBy: 1.5),
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
                onTap: () {
                  _controller.show();
                  loadJson().then((data) async {
                    int randomInd = Math.Random().nextInt(10);
                    var addressData = data[randomInd];
                    String _destinationAddress = addressData["StreetNumber"].toString() + " " + addressData["StreetName"].toString() + ", " + addressData["City"].toString() + addressData["state"].toString();
                    _destinationAddress = addressData["longitude"].toString() + "," + addressData["latitude"].toString();
                    print (_destinationAddress);

                    // Destination Location Marker
                    Marker destinationMarker = Marker(
                      markerId: MarkerId(addressData["estimated_population"].toString()),
                      position: LatLng(addressData["latitude"], addressData["longitude"]),
                      infoWindow: InfoWindow(
                        title: 'Destination',
                        snippet: _destinationAddress,
                      ),
                      icon: BitmapDescriptor.defaultMarker,
                    );

                    // Object for PolylinePoints
                    PolylinePoints polylinePoints;
                    // List of coordinates to join
                    List<LatLng> polylineCoordinates = [];
                    // Map storing polylines created by connecting
                    // two points
                    Map<PolylineId, Polyline> polylines = {};

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
                    _createPolylines(widget.userLocation, new Position(longitude: addressData["longitude"], latitude: addressData["latitude"]));
                    setState(() {
                      widget.markers.add(destinationMarker);
                      widget.polylines = Set<Polyline>.of(polylines.values);
                    });
                  });
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
                  Icons.access_time,
                  color: Colors.black,
                ),
                title: Text('Expected Visitors'),
                trailing: Text(
                  'None',
                  style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                ),
                onTap: () {
                  return false;
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.airline_seat_individual_suite,
                  color: Colors.black,
                ),
                title: Text('Maximum Capacity'),
                trailing: Text(
                  'None',
                  style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                ),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.message,
                  color: Colors.black,
                ),
                title: Text('SMS'),
                subtitle: Text('Safehouse Owner'),
                onTap: () {
                  launch("sms:PHONE_NUMBER");
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.phone,
                  color: Colors.black,
                ),
                title: Text('Call'),
                subtitle: Text('Safehouse Owner'),
                onTap: () {
                  launch("tel:PHONE_NUMBER");
                },
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.all(5),
                child: OutlineButton(
                  child: const Text('Reserve'),
                  textColor: Colors.black,
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                  onPressed: () {
                    //Add Function
                  },
                  padding: EdgeInsets.all(15),
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
                                    'This will declare this safehouse: Compromised',
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
                    }),
              ),
            ),
          ],
        ),
      ],
    );

    // Container(
    //       color: Colors.black,
    //       height: 50,
    //       child: Center(
    //         child: Icon(
    //           Icons.remove,
    //           color: Colors.white,
    //           size: 40,
    //         ),
    //       ),
    //     ),
  }
}
