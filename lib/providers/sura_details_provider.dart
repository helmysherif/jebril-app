import 'package:flutter/cupertino.dart';
class SuraDetailsProvider extends ChangeNotifier{
  int index = 0;
  int suraNumber = 0;
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  void changeIndex(int num)
  {
    index = num;
    notifyListeners();
  }
  void changeSuraNumber(int num)
  {
    suraNumber = num;
    notifyListeners();
  }
  void changeIsPlaying(bool playing) {
    if (_isPlaying != playing) {
      _isPlaying = playing;
      notifyListeners();
    }
  }
  void reset() {
    index = 0;
    suraNumber = 0;
    _isPlaying = false;
    notifyListeners();
  }
}