import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  double _latitude;
  double _longitude;

  DatabaseService(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
  }

  // ignore: cancel_subscriptions
  var updateDatabase =
      FirebaseDatabase.instance.reference().onChildAdded.listen(onEntryAdded);
  // ignore: cancel_subscriptions
  var addDatabase = FirebaseDatabase.instance
      .reference()
      .onChildChanged
      .listen(onEntryUpdated);

  static onEntryAdded(Event event) {
    print("Dance: " + event.snapshot.value.toString());
    print("New!");
  }

  static onEntryUpdated(Event event) {
    print("Disco: " + event.snapshot.value.toString());
    print("Update!");
  }

  // DONE Write function which only pulls out the snapshot.value (like no for loops and if conditions)
  // DONE Then return the list
  static getAllSafehouses() async {
    var database = FirebaseDatabase.instance.reference();
    var safehouseData = await database.child("Safehouses").once();
    return safehouseData.value;
  }

  // That function will give you a single object i.e. our desired safehouse
  // If it is, you'll have to increment the values in the object, and upload that back to Firebase (which I will do if you don't wanna)
  updateFirebaseDatabase(int index, String property, Object value) async {
    var database = FirebaseDatabase.instance.reference();
    database
        .child("Safehouses")
        .child(index.toString())
        .child(property)
        .set(value);
  }
}
