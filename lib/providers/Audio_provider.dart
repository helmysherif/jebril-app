import 'package:flutter/material.dart';
import '../Sura.dart';
class AudioProvider extends ChangeNotifier {
  bool isRadioPlaying = false;
  bool _isPlaying = false;
  bool isNavigating = false;
  Surah? radioAudio = Surah(
    audio: "",
    arabicName: "",
    englishName: "",
    number: 0,
  );
  changeIsRadioPlaying(bool value) {
    if (isRadioPlaying == value) return;
    isRadioPlaying = value;
    if (!isRadioPlaying) {
      radioAudio = null; // Clear radio audio when stopping
    }
    notifyListeners();
  }
  void setIsPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }
  void navigationComplete() {
    isNavigating = false;
  }
  void prepareForNavigation() {
    isNavigating = true;
  }
  void setRadioAudio(Surah audio) {
    radioAudio = audio;
    notifyListeners();
  }
}


// import 'package:flutter/material.dart';
// import '../Sura.dart';
// class AudioProvider extends ChangeNotifier {
//   bool _isPlaying = false;
//   bool isRadioPlaying = false;
//   Surah? radioAudio;
//   bool isNavigating = false;
//   void setIsPlaying(bool value) {
//     if (_isPlaying == value || isNavigating) return;
//     _isPlaying = value;
//     _safeNotify();
//   }
//
//   Future<void> changeIsRadioPlaying(bool value) async {
//     if (isRadioPlaying == value) return;
//     isRadioPlaying = value;
//     await Future.delayed(Duration.zero); // Allow listeners to process
//     _safeNotify();
//   }
//
//   void setRadioAudio(Surah audio) {
//     if (isNavigating) return;
//     radioAudio = audio;
//     _safeNotify();
//   }
//
//   void prepareForNavigation() {
//     isNavigating = true;
//   }
//
//   void navigationComplete() {
//     isNavigating = false;
//   }
//
//   void _safeNotify() {
//     try {
//       if (hasListeners) {
//         notifyListeners();
//       }
//     } catch (e) {
//       debugPrint('Error notifying listeners: $e');
//     }
//   }
// }
