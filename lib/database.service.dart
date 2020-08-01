import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  double _latitude;
  double _longitude;

  DatabaseService(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
  }

  getAllSafehouses() async {
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
}
