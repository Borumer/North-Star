import 'package:flutter/cupertino.dart';

class MyNotifier extends ValueNotifier<MyDataClass> {
  MyNotifier(MyDataClass value) : super(value);

  void changeMyData(int i) {
    value.myInt = i;
    notifyListeners();
  }
}

class MyDataClass {
  int myInt;
}