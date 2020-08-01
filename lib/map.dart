import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:NorthStar/safehouse.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'database.service.dart';

class MyMap extends StatefulWidget {
  MyMap({Key key}) : super(key: key);
  @override
  MapState createState() => MapState();
}

class MapState extends State<MyMap> {
  Position _position;
  Set<Marker> _markers = {};

  final firebaseDatabase = new FirebaseDatabase();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // setCustomMapPin();
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

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

  Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  double screenHeight(BuildContext context, {double dividedBy = 1}) {
    return screenSize(context).height / dividedBy;
  }

  double screenWidth(BuildContext context, {double dividedBy = 1}) {
    return screenSize(context).width / dividedBy;
  }

  Future _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("1"),
          position: getCenter(),
          onTap: () async {
            // var databaseService = new DatabaseService(38.29, -122.28);
            // var safehouse = await databaseService.getAllSafehouses();

            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
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
                      child: MySafehouse(),
                    ),
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            );
          },
        ),
      );
    });
  }

  Widget build(BuildContext context) {
    if (locationFound()) {
      print(_position.longitude);
      print(_position.latitude);

      return GoogleMap(
        onMapCreated: _onMapCreated,
        markers: _markers,
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
