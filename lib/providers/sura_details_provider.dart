import 'package:flutter/cupertino.dart';
class SuraDetailsProvider extends ChangeNotifier{
  int index = 0;
  void changeIndex(int num)
  {
    index = num;
    notifyListeners();
  }
}