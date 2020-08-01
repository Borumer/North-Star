import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:NorthStar/safehouse.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class MyMap extends StatefulWidget {
  MyMap({Key key}) : super(key: key);

  @override
  MapState createState() => MapState();
}

class MapState extends State<MyMap> {
  Position _position;
  BitmapDescriptor pinLocationIcon;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    setCustomMapPin("green");
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec =
    await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  void setCustomMapPin(String color) async {
    // Retrieve image as bytes so it is resizable
    var pinLocationBytes = await getBytesFromAsset('assets/images/' + color + '_pin.png', 100);
    pinLocationIcon = BitmapDescriptor.fromBytes(pinLocationBytes);
  }

  Future _onMapCreated(GoogleMapController controller) async {

    mapController = controller;

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("1"),
          position: getCenter(),
          icon: pinLocationIcon,
          onTap: () {},
          infoWindow: InfoWindow(
              title: "Safehouse!",
              snippet: "Visitors Expected: 2",
              onTap: () {
                //open the Solid Bottom Sheet
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return new Container(
                      height: 350.0,
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
              }),
        ),
      );
    });
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

  Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  double screenHeight(BuildContext context, {double dividedBy = 1}) {
    return screenSize(context).height / dividedBy;
  }

  double screenWidth(BuildContext context, {double dividedBy = 1}) {
    return screenSize(context).width / dividedBy;
  }

  GoogleMapController mapController;

  /// Precondition: locationFound() == true
  /// Returns a
  LatLng getCenter() {
    return LatLng(_position.latitude, _position.longitude);
  }

  bool locationFound() {
    return _position != null;
  }

  Widget build(BuildContext context) {
    if (locationFound()) {
      print(_position.longitude);
      print(_position.latitude);

      return GoogleMap(
        myLocationEnabled: true,
        onMapCreated: _onMapCreated,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(_position.latitude, _position.longitude),
          zoom: 5.0,
        ),
      );
    } else {
      return Center(
          child: Column(children: <Widget>[CircularProgressIndicator()]));
    }
  }
}
