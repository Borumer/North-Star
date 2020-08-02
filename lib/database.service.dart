import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  double _latitude;
  double _longitude;

  DatabaseService(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
  }

  DatabaseService.empty();

  /// Loop through the safehouse data in database
  /// Check if each row's coordinates equals the instance variables' longitude and latitude
  getCurrentSafehouse() async {
    var db = FirebaseDatabase.instance.reference().child("Safehouses");
    db.once().then((DataSnapshot snapshot) {
      for (var safehouse in snapshot.value) {
        if (safehouse["latitude"] == _latitude &&
            safehouse["longitude"] == _longitude) {
          print(safehouse);
          return safehouse;
        }
      }
      return null;
    });
  }

  // DONE Write function which only pulls out the snapshot.value (like no for loops and if conditions)
  // DONE Then return the list
  getAllSafehouses() async {
    var db = FirebaseDatabase.instance.reference();
    var safehouseData = await db.child("Safehouses").once();
    return safehouseData.value;
  }

  // TODO: Then, for each Marker, the onTap will pass the tapped marker's longitude and latitude to the function that is being used right now (the commented one in the first line, change the hard-coded values)
  // That function will give you a single object i.e. our desired safehouse
  // TODO: Then store that object in a global variable as you said, and use the key-value pair magic to give appropriate values to the sheet

  // TODO: For Reserve, you'll need to give a dialogue for the number of people, and check if it's possible.
  // If it is, you'll have to increment the values in the object, and upload that back to Firebase (which I will do if you don't wanna)
}
