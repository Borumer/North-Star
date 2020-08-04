import 'package:NorthStar/database.service.dart';
import 'package:NorthStar/snackbars.dart';
import 'package:NorthStar/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import 'map.dart';

class Safehouse {
  Safehouse(
      {this.address,
      this.capacity,
      this.reserved,
      this.compromised,
      this.ownerName,
      this.ownerID,
      this.markerPos,
      this.phoneNum,
      this.name});

  factory Safehouse.fromJSON(Map<dynamic, dynamic> json) => _itemFromJSON(json);

  static Safehouse _itemFromJSON(Map<dynamic, dynamic> json) {
    String markerAddress = json["address"].toString();

    return Safehouse(
        name: json['name'] as String,
        address: markerAddress,
        capacity: json['capacity'] as int,
        reserved: json['reserved'] as int,
        compromised: json['compromised'] as bool,
        ownerName: json['ownerName'] as String,
        markerPos: new Position(
            latitude: json['latitude'], longitude: json['longitude']),
        phoneNum: json['phoneNum']);
  }

  /// The name of the safehouse
  String name;

  /// The physical address of the safehouse
  String address;

  /// The number of people able to be accomodated at the safehouse
  int capacity;

  /// The number of spaces already reserved at the safehouse (including people already there)
  int reserved;

  /// Whether the safehouse is compromised by white slavecatchers
  bool compromised;

  /// The name of the safehouse owner
  final String ownerName;

  String ownerID;

  /// The global position of the safehouse
  final Position markerPos;

  /// The phone number to call the safehouse/safehouse owner
  final String phoneNum;
}

// ignore: must_be_immutable
class MySafehouse extends StatefulWidget {
  MySafehouse(
      {Key key,
      this.isOwner,
      this.index,
      this.safehouseInfo,
      this.title,
      this.userLocation,
      this.geolocator,
      this.markers,
      this.polylines,
      this.userID,
      this.icon})
      : super(key: key);

  final bool isOwner;
  final int index;
  final String userID;

  final Safehouse safehouseInfo;

  final String title;
  final Position userLocation;
  final Geolocator geolocator;
  BitmapDescriptor icon;

  Set<Marker> markers;
  final Set<Polyline> polylines;

  @override
  SafehouseState createState() => SafehouseState();
}

class SafehouseState extends State<MySafehouse> {
  final _formKey = GlobalKey<FormState>();
  final textController = TextEditingController();
  final textController2 = TextEditingController();
  bool hasReserved;

  void initState() {
    super.initState();
    setHasReserved();
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
    return DatabaseService.getAllSafehouses();
  }

  setHasReserved() async {
    hasReserved = await DatabaseService().safehouseAlreadyReserved(widget.userID);
  }

  Widget build(BuildContext context) {
    // minHeight: screenHeight(context, dividedBy: 3.1),
    // maxHeight: screenHeight(context, dividedBy: 1.5),
    var databaseService = new DatabaseService();
    var reservations;
    SolidController _controller = SolidController();

    void setReservations() async {
      reservations = await databaseService.getPropertyFromFirebaseDatabase(widget.index, "reservations");
    }
    setReservations();
    setHasReserved();

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
          PolylineResult result =
              await polylinePoints.getRouteBetweenCoordinates(
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
    String leaveSafehouseText = "Leave";
    print("--------------");
    print(hasReserved != null);
    print(hasReserved != null && hasReserved);
    return ListView(
      padding: const EdgeInsets.all(4),
      children: <Widget>[

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
                title: Text(widget.safehouseInfo.address),
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
                subtitle:
                    Text('Safehouse Owner: ' + widget.safehouseInfo.ownerName),
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
                subtitle:
                    Text('Safehouse Owner: ' + widget.safehouseInfo.ownerName),
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
              visible: true,//widget.safehouseInfo.reserved <
                  //widget.safehouseInfo.capacity && !widget.isOwner && (hasReserved == null || !hasReserved),
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
                      await showDialog<String>(
                        barrierDismissible: false,
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
                                      padding: EdgeInsets.all(3),
                                      child: TextFormField(
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                        controller: textController2,
                                        decoration: const InputDecoration(
                                          hintText: 'Enter Your Name',
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          fillColor: Colors.white,
                                        ),
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please Enter a Name';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(3),
                                      child: TextFormField(
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          controller: textController,
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Enter the Number of Residents',
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            fillColor: Colors.white,
                                          ),
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              print("Value is empty: true -->" +
                                                  value);
                                              return 'Please enter a value';
                                            }
                                            int val;
                                            if ((val = int.tryParse(
                                                    textController.text)) ==
                                                null) {
                                              // If not a number
                                              print(
                                                  "Value is alphabet or contains non-numerical characters");
                                              return "Please enter a valid number";
                                            }
                                            val =
                                                int.parse(textController.text);
                                            if (val <= 0) {
                                              return 'Please Enter a Number above 0';
                                            } else if (val >
                                                (widget.safehouseInfo.capacity -
                                                    widget.safehouseInfo
                                                        .reserved)) {
                                              return 'There are only ' +
                                                  (widget.safehouseInfo
                                                              .capacity -
                                                          widget.safehouseInfo
                                                              .reserved)
                                                      .toString() +
                                                  ' Spots Available';
                                            } else {
                                              Navigator.pop(context);
                                              Snackbars
                                                  .showReservationComfirmationSnackBar();
                                            }

                                            return null;
                                          }),
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
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: RaisedButton(
                                      textColor: Colors.black,
                                      color: Colors.white,
                                      onPressed: () async {
                                        if (_formKey.currentState.validate()) {
                                          try {
                                            var results = await databaseService
                                                .getPropertyFromFirebaseDatabase(
                                                    widget.index,
                                                    "reservations");
                                            if (results == null) {
                                              print("It is null");
                                              databaseService
                                                  .updateFirebaseDatabase(
                                                      widget.index,
                                                      "reservations", {
                                                widget.userID: [
                                                  {
                                                    "spots": int.parse(
                                                        textController.text)
                                                  },
                                                  {
                                                    "userName":
                                                        textController2.text
                                                  }
                                                ]
                                              });
                                            } else {
                                              print("It is has something: " +
                                                  results);
                                              var temp = [];
                                              for (var result in results) {
                                                temp.add(result);
                                              }
                                              temp.add({
                                                widget.userID: [
                                                  {
                                                    "spots": int.parse(
                                                        textController.text)
                                                  },
                                                  {
                                                    "userName":
                                                        textController2.text
                                                  }
                                                ]
                                              });
                                              databaseService
                                                  .updateFirebaseDatabase(
                                                      widget.index,
                                                      "reservations",
                                                      temp);
                                            }
                                            var reserved = await databaseService.getPropertyFromFirebaseDatabase(widget.index, "reserved");
                                            reserved += int.parse(
                                                textController.text);
                                            databaseService.updateFirebaseDatabase(
                                                widget.index,
                                                "reserved",
                                                reserved);
                                            return null;
                                          } catch (e) {
                                            return "Woops";
                                          }
                                        }
                                      },
                                      child: const Text('Okay'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                    padding: EdgeInsets.all(15),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: true,//!widget.isOwner && !(widget.safehouseInfo.reserved <
                  //widget.safehouseInfo.capacity) && hasReserved != null && hasReserved,
              child: Expanded(
                child: Container(
                  margin: EdgeInsets.all(5),
                  child: OutlineButton(
                    child: Text(leaveSafehouseText),
                    textColor: Colors.black,
                    borderSide: BorderSide(
                      color: Colors.black,
                    ),
                    onPressed: () async {
                      var all = await DatabaseService.getAllSafehouses();
                      for (int i = 0; i < all.length; i++) {
                        var currentReservations = all[i]["reservations"];
                        if (currentReservations != null && currentReservations[widget.userID] != null) {
                          // Removes the reservations and reserved from the safehouse
                          int reservedInt = all[i]["reserved"];
                          databaseService.updateFirebaseDatabase(widget.index, "reserved", reservedInt - currentReservations[widget.userID][0]["spots"]);
                          currentReservations[widget.userID] = null;
                          databaseService.updateFirebaseDatabase(widget.index, "reservations", currentReservations);

                        }
                      }
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.all(15),
                  ),
                ),
              ),
            ),

          ],
        ),
        Row(
        children: <Widget>[
          Expanded(
          child: Container(
            margin: EdgeInsets.all(5),
            child: RaisedButton(
              child: const Text('Compromised'),
              textColor: Colors.white,
              color: Colors.black,
              padding: EdgeInsets.all(15),
              onPressed: () async {
                await showDialog<String>(
                  barrierDismissible: false,
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
                                Navigator.pop(context);
                                databaseService.updateFirebaseDatabase(
                                    widget.index, "compromised", true);
                                databaseService.updateFirebaseDatabase(widget.index, "reserved", 0);
                                databaseService.updateFirebaseDatabase(widget.index, "reservations", null);
                                setState(() {
                                  MapState ms = new MapState();
                                  ms.initState();
                                  widget.icon = ms.redPinLocationIcon;
                                });
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
    ]
        )
      ],
    );
  }
}
