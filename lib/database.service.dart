import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  double _latitude;
  double _longitude;

  DatabaseService(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
  }

  // DONE Write function which only pulls out the snapshot.value (like no for loops and if conditions)
  // DONE Then return the list
  static getAllSafehouses() async {
    var db = FirebaseDatabase.instance.reference();
    var safehouseData = await db.child("Safehouses").once();
    return safehouseData.value;
  }

  /// Loop through the safehouse data in database
  /// Check if each row's coordinates equals the instance variables' longitude and latitude
  getCurrentSafehouseIndex() async {
    var db = FirebaseDatabase.instance.reference().child("Safehouses");
    db.once().then((DataSnapshot snapshot) {
      print(_latitude.toString() + " " + _longitude.toString());
      for (var i = 0; i < snapshot.value.length; i++) {
        if (snapshot.value[i]["latitude"] == _latitude &&
            snapshot.value[i]["longitude"] == _longitude) {
          return i;
        }
      }
      return null;
    });
  }

  // That function will give you a single object i.e. our desired safehouse
  // If it is, you'll have to increment the values in the object, and upload that back to Firebase (which I will do if you don't wanna)
  updateFirebaseDatabase(int index, String property, Object value) async {
    var db = FirebaseDatabase.instance.reference();
    db.child("Safehouses").child(index.toString()).child(property).set(value);
  }

  // TODO Connect marker database listener to UI
  // DONE Finish drawing routes (polylines)
  // TODO Finish addmarker.dart
  // TODO Get all snackbars to work

}
