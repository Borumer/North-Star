import 'package:NorthStar/strings.dart';
import 'package:flutter/material.dart';

import 'database.service.dart';

/// Helper class for storing all snackbars
/// Used so that similar snack bars can be used throughout the app
/// Also used to store common properties and method calls of all snackbars
class Snackbars {

  static showCompromisedSnackBar(int index) {
    final message = SnackBar(
      content: Text('This Safehouse is Compromised!'),
      backgroundColor: Colors.black,
      duration: Duration(seconds: 5),
      action: SnackBarAction(
        label: 'It is Safe',
        textColor: Colors.blue[600],
        onPressed: () async {
          // Some code to undo the change.
          switch (await showDialog<String>(
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
                          Navigator.pop(context, "Cancel");
                        },
                        child: const Text('Cancel'),
                      ),
                      RaisedButton(
                        textColor: Colors.black,
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pop(context, "Proceed");
                        },
                        child: const Text('Proceed'),
                      ),
                    ],
                  ),
                ],
              );
            },
          )) {
            case "Proceed":
            //Add Function
              var databaseService = new DatabaseService();
              databaseService.updateFirebaseDatabase(
                  index, "compromised", false);
              break;
          }
        },
      ),
    );
    useScaffold(message);
  }

  static showInputValidationSnackBar() {
    final message = SnackBar(
      content: Text('Please Enter a Value'),
      backgroundColor: Colors.black,
      duration: Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Okay',
        textColor: Colors.blue[600],
        onPressed: () async {
          // Some code to undo the change.
        },
      ),
    );
    useScaffold(message);
  }

  static useScaffold(SnackBar sb) {
    Scaffold.of(topLevelContext).showSnackBar(sb);
  }
}