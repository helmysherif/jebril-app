import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../Sura.dart';
class AudioProvider extends ChangeNotifier {
  final AudioPlayer player = AudioPlayer();
  bool _isLoading = false;
  bool wasRadioPlaying = false;
  Surah radioAudio = Surah(
    audio: "https://a6.asurahosting.com:8470/radio.mp3",
    arabicName: "",
    englishName: "",
    number: 0,
  );

  bool get isLoading => _isLoading;
  bool get isRadioPlaying => player.playing;

  AudioProvider() {
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await player.setAudioSource(
        AudioSource.uri(Uri.parse(radioAudio.audio)),
      );

      // Listen to player state changes and notify listeners
      player.playerStateStream.listen((_) => notifyListeners());
    } catch (e) {
      debugPrint('Error initializing player: $e');
    }
  }

  Future<void> playRadio() async {
    if (isRadioPlaying) return;
    wasRadioPlaying = true;
    _isLoading = true;
    notifyListeners();

    try {
      await player.play();
    } catch (e) {
      debugPrint('Error playing radio: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pauseRadio() async {
    if (!isRadioPlaying) return;

    try {
      await player.pause();
    } catch (e) {
      debugPrint('Error pausing radio: $e');
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
// class AudioProvider extends ChangeNotifier {
//   bool isRadioPlaying = false;
//   bool _isPlaying = false;
//   bool isNavigating = false;
//   final AudioPlayer player = AudioPlayer();
//   bool _isLoading = false;
//   bool keepRadioPlaying = false;
//   bool _isRadioPlaying = false;
//   bool get isLoading => _isLoading;
//   Surah radioAudio = Surah(
//     audio: "https://a6.asurahosting.com:8470/radio.mp3",
//     arabicName: "",
//     englishName: "",
//     number: 0,
//   );
//   AudioProvider() {
//     _initPlayer();
//   }
//   Future<void> _initPlayer() async {
//     try {
//       await player.setAudioSource(
//         AudioSource.uri(Uri.parse(radioAudio.audio)),
//       );
//       // Set up listeners
//       player.playerStateStream.listen((state) {
//         final isPlaying = state.playing;
//         if (isPlaying != _isRadioPlaying) {
//           _isRadioPlaying = isPlaying;
//           notifyListeners();
//         }
//       });
//     } catch (e) {
//       debugPrint('Error initializing player: $e');
//     }
//   }
//   Future<void> playRadio() async {
//     if (_isRadioPlaying) return;
//
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       await player.play();
//       _isRadioPlaying = true;
//     } catch (e) {
//       debugPrint('Error playing radio: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//   Future<void> pauseRadio() async {
//     if (!_isRadioPlaying) return;
//
//     try {
//       await player.pause();
//       _isRadioPlaying = false;
//     } catch (e) {
//       debugPrint('Error pausing radio: $e');
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   @override
//   void dispose() {
//     player.dispose();
//     super.dispose();
//   }
//   void changeIsRadioPlaying(bool playing) {
//     isRadioPlaying = playing;
//     notifyListeners();
//   }
//   void setKeepRadioPlaying(bool keepPlaying) {
//     keepRadioPlaying = keepPlaying;
//     notifyListeners();
//   }
//   void setRadioPlaying(bool playing) {
//     _isRadioPlaying = playing;
//     notifyListeners();
//   }
//
//   void toggleRadio() {
//     _isRadioPlaying = !_isRadioPlaying;
//     notifyListeners();
//   }
//   void setIsPlaying(bool value) {
//     _isPlaying = value;
//     notifyListeners();
//   }
//   void prepareForNavigation() {
//     isNavigating = true;
//     notifyListeners();
//   }
//
//   void completeNavigation() {
//     isNavigating = false;
//     notifyListeners();
//   }
//   void setRadioAudio(Surah audio) {
//     radioAudio = audio;
//     notifyListeners();
//   }
// }
