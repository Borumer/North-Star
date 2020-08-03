import 'package:NorthStar/strings.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  static DatabaseReference database = FirebaseDatabase.instance.reference();

  DatabaseService();
  var a;
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
    liveSafehouses = event.snapshot.value;
  }

  static onEntryUpdated(Event event) {
    print("Disco: " + event.snapshot.value.toString());
    print("Update!");
    liveSafehouses = event.snapshot.value;
  }

  // DONE Write function which only pulls out the snapshot.value (like no for loops and if conditions)
  // DONE Then return the list
  static getAllSafehouses() async {
    var safehouseData = await database.child("Safehouses").once();
    return safehouseData.value;
  }

  /// Gets and returns the value of a property at a certain index from the database
  /// Param index the row of the Safehouses list from which the property is retrieved
  /// Param property the name of the property
  getPropertyFromFirebaseDatabase(int index, String property) async {
    var propertyValue = await database
        .child("Safehouses")
        .child(index.toString())
        .child(property)
        .once();

    return propertyValue.value;
  }

  // That function will give you a single object i.e. our desired safehouse
  // If it is, you'll have to increment the values in the object, and upload that back to Firebase (which I will do if you don't wanna)
  updateFirebaseDatabase(int index, String property, Object value) async {
    database
        .child("Safehouses")
        .child(index.toString())
        .child(property)
        .set(value);
  }

  static addToFirebaseDatabase(Object safehouse) async {
    var temp = [];
    var safehouses = await getAllSafehouses();
    for (var safehouse in safehouses) {
      temp.add(safehouse);
    }
    temp.add(safehouse);
    database.child("Safehouses").set(temp);
  }

  /// Whether any safehouse is already reserved for the current user
  safehouseAlreadyReserved(String uuid) async {
    var allSafehouses = await getAllSafehouses();
    for (int i = 0; i < allSafehouses.length; i++) {
      var reservations = allSafehouses[i]["reservations"];
      if (reservations != null && reservations[uuid] != null) { // Current is reserved
        return true;
      }
    }
    return false;
  }

  // DONE Get all snackbars to work
  // DONE Finish drawing routes (polylines)
  // DONE Finish addmarker.dart
  // INPROGRESS Connect marker database listener to UI
  // INPROGRESS Reservations
  // DONE Call reservations from the database
  // DONE iterate through all objects, to get a list of their names
  // Make a card with all the names and corresponding reserved spots
  // DONE MARKER FOR LEAVE SAFEHOUSE BUTTON REPLACES RESERVE BUTTON
  // TODO Logic for Leave Safehouse Button
  // TODO Additional UI for a safehouse owner

}
