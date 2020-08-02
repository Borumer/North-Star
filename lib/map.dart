import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:NorthStar/safehouse.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math' as Math;

import 'database.service.dart';

class MyMap extends StatefulWidget {
  MyMap({Key key}) : super(key: key);
  @override
  MapState createState() => MapState();
}

class MapState extends State<MyMap> {
  Position _position;
  BitmapDescriptor pinLocationIcon;
  Set<Marker> _markers = {};
  Set<Polyline> shownPolylines;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  final firebaseDatabase = new FirebaseDatabase();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    setCustomMapPin("green");
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

  void setCustomMapPin(String color) async {
    // Retrieve image as bytes so it is resizable
    var pinLocationBytes =
        await getBytesFromAsset('assets/images/' + color + '_pin.png', 100);
    pinLocationIcon = BitmapDescriptor.fromBytes(pinLocationBytes);
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

    loadJson() async {
      return new DatabaseService.empty().getAllSafehouses();
    }

    setState(() {
      _markers.add(
        Marker(
          icon: pinLocationIcon,
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
                      child: MySafehouse(
                          userLocation: _position,
                          geolocator: geolocator,
                          markers: _markers,
                          polylines: shownPolylines
                      ),
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
      // DONE Take the list, iterate through all the safehouses, make their markers(according to their capacity) and then generate the map
      loadJson().then((data) async {
        for (var addressData in data) {
          String _destinationAddress = addressData["StreetNumber"].toString() +
              " " +
              addressData["StreetName"].toString() +
              ", " +
              addressData["City"].toString() +
              addressData["state"].toString();
          _destinationAddress = addressData["longitude"].toString() +
              "," +
              addressData["latitude"].toString();
          print(_destinationAddress);

          // Destination Location Marker
          double lat = addressData["latitude"];
          double lon = addressData["longitude"];
          Marker destinationMarker = Marker(
            markerId: MarkerId(addressData["estimated_population"].toString()),
            position: LatLng(lat, lon),
            infoWindow: InfoWindow(
              title: 'Destination',
              snippet: _destinationAddress,
            ),
            icon: pinLocationIcon,
          );
          _markers.add(destinationMarker);
        }
      });
    });
  }

  Widget build(BuildContext context) {
    if (locationFound()) {
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
