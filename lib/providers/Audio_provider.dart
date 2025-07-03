import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:jebril_app/providers/audio_handler.dart';
import 'package:just_audio/just_audio.dart';
import '../Sura.dart';
class AudioProvider extends ChangeNotifier {
  final AudioPlayer player = AudioPlayer();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;
  bool wasRadioPlaying = false;
  bool isRadio = false;
  Surah radioAudio = Surah(
    audio: "https://a6.asurahosting.com:8470/radio.mp3",
    arabicName: "",
    englishName: "",
    number: 0,
  );
  bool _isRadioPlaying = false;
  bool get isLoading => _isLoading;
  bool get isRadioPlaying => player.playing;
  void setIsRadioPlaying(bool playing) {
    _isRadioPlaying = playing;
    notifyListeners();
  }
  AudioProvider() {
    _initPlayer();
  }
  Future<void> playRadio2() async {
    // This will be handled by the widget through AudioService
    _isRadioPlaying = true;
    notifyListeners();
  }

  Future<void> pauseRadio2() async {
    // This will be handled by the widget through AudioService
    _isRadioPlaying = false;
    notifyListeners();
  }
  changeIsRadio(bool radio){
    this.isRadio = radio;
    notifyListeners();
  }
  Future<void> resetPlayer() async {
    try {
      await _audioPlayer.stop(); // Stops playback
      await _audioPlayer.seek(Duration.zero); // Seeks to beginning
      // No need to call setAudioSource(null)
      notifyListeners();
    } catch (e) {
      debugPrint("Error resetting audio player: $e");
    }
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
  late final MyAudioHandler audioHandler;
  Future<void> playRadio() async {
    if (isRadioPlaying) return;
    wasRadioPlaying = true;
    _isLoading = true;
    notifyListeners();
    try {
      await player.play();
      await audioHandler.play();
      // await audioHandler.playRadio("https://a6.asurahosting.com:8470/radio.mp3");
    } catch (e) {
      debugPrint('Error playing radio: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> playLocalFile(String filePath) async {
    try {
      await player.setFilePath(filePath);
      await player.play();
      _isRadioPlaying = true;
      notifyListeners();
    } catch (e) {
      print('Error playing local file: $e');
    }
  }
  Future<void> playLocalAudio(String filePath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setFilePath(filePath);
      await _audioPlayer.play();
      // _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing local audio: $e');
      throw e;
    }
  }
  Future<void> pauseRadio() async {
    if (!isRadioPlaying) return;

    try {
      await player.pause();
      await audioHandler.pause();
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
