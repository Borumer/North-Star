import 'package:NorthStar/strings.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'database.service.dart';
import 'map.dart';

/// Helper class for storing all snackbars
/// Used so that similar snack bars can be used throughout the app
/// Also used to store common properties and method calls of all snackbars
class Snackbars {
  static useScaffold(SnackBar sb) {
    Scaffold.of(topLevelContext).showSnackBar(sb);
  }

  static showHome() {
    final message = SnackBar(
      content: Text(
        'You are Here',
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.black,
      duration: Duration(seconds: 3),
    );
    useScaffold(message);
  }

  static void showReservationComfirmationSnackBar() {
    final message = SnackBar(
      content: Text(
        'Your Reservation has been Confirmed!',
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.black,
      duration: Duration(seconds: 3),
    );
    useScaffold(message);
  }

  static BitmapDescriptor showCompromisedSnackBar(int index, BitmapDescriptor icon) {
    BitmapDescriptor newIcon = icon;
    final message = SnackBar(
      content: Text('This Safehouse is Compromised!'),
      backgroundColor: Colors.black,
      duration: Duration(seconds: 5),
      action: SnackBarAction(
        label: 'IT IS SAFE',
        textColor: Colors.blue[600],
        onPressed: () async {
          // Some code to undo the change.
          await showDialog<String>(
            barrierDismissible: false,
            context: topLevelContext,
            builder: (BuildContext context) {
              // DONE For Reserve, you'll need to give a dialogue for the number of people, and check if it's possible.
              return SimpleDialog(
                title: const Text(
                  'Declare Safe?',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.black,
                children: <Widget>[
                  ListTile(
                    title: Text(
                      'This will Declare the Safehouse Safe again',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: <Widget>[
                      OutlineButton(
                        textColor: Colors.red,
                        borderSide: BorderSide(
                          color: Colors.red,
                        ),
                        onPressed: () {
                          //Navigator.pop(topLevelContext);
                        },
                        child: const Text('Cancel'),
                      ),
                      RaisedButton(
                        textColor: Colors.black,
                        color: Colors.white,
                        onPressed: () {
                          var databaseService = new DatabaseService();
                          databaseService.updateFirebaseDatabase(
                              index, "compromised", false);
                          var ms = new MapState();
                          newIcon = ms.greenPinLocationIcon; // Set marker icon back to green
                        },
                        child: const Text('Proceed'),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
    useScaffold(message);
    return newIcon;
  }
}
