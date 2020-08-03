import 'package:NorthStar/database.service.dart';
import 'package:NorthStar/strings.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyAddmarkermap extends StatefulWidget {
  final DatabaseService databaseService;
  MyAddmarkermap({Key key, this.databaseService}) : super(key: key);

  @override
  AddmarkermapState createState() => AddmarkermapState();
}

class AddmarkermapState extends State<MyAddmarkermap> {
  Position _position;
  double latitude;
  double longitude;

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
            latitude = value.latitude;
            longitude = value.longitude;
          })),
    );
  }

  Future _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  double screenHeight(BuildContext context, {double dividedBy = 1}) {
    return screenSize(context).height / dividedBy;
  }

  @override
  Widget build(BuildContext context) {
    if (locationFound()) {
      displayUserLocationMarker();
      return Scaffold(
        appBar: AppBar(
          title: Text("Drag the Pin"),
        ),
        body: GoogleMap(
          myLocationEnabled: true,
          onMapCreated: _onMapCreated,
          markers: _markers,
          polylines: shownPolylines,
          initialCameraPosition: CameraPosition(
            target: LatLng(_position.latitude, _position.longitude),
            zoom: 18.0,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          foregroundColor: Colors.black,
          hoverColor: Colors.black,
          splashColor: Colors.black,
          child: Icon(
            Icons.check,
            color: Colors.white,
          ),
          onPressed: () {
            if (latitude == null && longitude == null) {
              latitude = _position.latitude;
              longitude = _position.longitude;
            }
            print(latitude);
            print(longitude);
            // var databaseService = DatabaseService();
            // print(databaseService.testGet());
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
