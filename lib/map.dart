import 'package:NorthStar/strings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:NorthStar/safehouse.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:NorthStar/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
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

  Set<Marker> _markers = {};
  Set<Polyline> shownPolylines;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final firebaseDatabase = new FirebaseDatabase();

  @override
  void initState() {
    super.initState();
    topLevelContext = context;
    shownPolylines = <Polyline>{};
    setUserID();
    _getCurrentLocation();
    setCustomMapPins();
    displayCurrentSafehouses();
    setInitialSafehouseData();
  }

  void setInitialSafehouseData() async {
    liveSafehouses = await DatabaseService.getAllSafehouses();
  }

  Future<String> setUserID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("uuid") != null) {
      return prefs.getString("uuid");
    } else {
      var uuid = Uuid();
      var id = uuid.v4();
      return id;
    }
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

  setCustomMapPins() async {
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

    return [greenPinLocationBytes, yellowPinLocationBytes, redPinLocationBytes];
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
    print (liveSafehouses);
    return liveSafehouses;
  }

  void displayUserLocationMarker() {
    _markers.add(
      Marker(
        markerId: MarkerId("Home"),
        position: getCenter(),
        onTap: () async {
          Snackbars.showHome();
        },
      ),
    );
  }

  void displayCurrentSafehouses() {
    // DONE Take the list, iterate through all the safehouses, make their markers(according to their capacity) and then generate the map
    loadJson().then(
      (data) async {
        if (data == null) return;

        for (var i = 0; i < data.length; i++) {
          var _icon;
          if (liveSafehouses[i]["compromised"]) {
            // If the safehouse is compromised
            _icon = redPinLocationIcon;
          } else if (liveSafehouses[i]["capacity"] == liveSafehouses[i]["reserved"]) {
            // If the safehouse is full
            _icon = yellowPinLocationIcon;
          } else if (liveSafehouses[i]["capacity"] > liveSafehouses[i]["reserved"]) {
            // If the safehouse is available
            _icon = greenPinLocationIcon;
          } else {
            // If the location is the user's current one
            _icon = BitmapDescriptor.defaultMarker;
          }

          // Destination Location Marker
          double latitude = liveSafehouses[i]["latitude"];
          double longitude = liveSafehouses[i]["longitude"];

          if (latitude == null || longitude == null) return;

          Marker destinationMarker = Marker(
            markerId: MarkerId("Marker #" + i.toString()),
            position: LatLng(latitude, longitude),
            onTap: () async {
              if (!liveSafehouses[i]["compromised"]) {
                Safehouse currentSafehouse = Safehouse.fromJSON(liveSafehouses[i]);
                currentSafehouse.ownerID = await setUserID();
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
                            index: i,
                            safehouseInfo: currentSafehouse,
                            userLocation: _position,
                            geolocator: geolocator,
                            markers: _markers,
                            polylines: shownPolylines,
                            icon: _icon
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
                setState(() {
                  _icon = Snackbars.showCompromisedSnackBar(i, _icon);
                });
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
