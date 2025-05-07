import 'package:flutter/cupertino.dart';
class LangsProvider extends ChangeNotifier{
  String language = "ar";
  void changeLanguage(String lang)
  {
    language = lang;
    notifyListeners();
  }
}