import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  bool get isRadioPlaying => _player.playing;
  MyAudioHandler() {
    // Broadcast playback state
    _player.playerStateStream.listen((state) {
      playbackState.add(playbackStateFromPlayer(state));
    });

    // Broadcast current media item (optional)
    mediaItem.add(MediaItem(
      id: 'radio',
      album: 'Radio Quran',
      title: 'راديو الشيخ جبريل - قرآن',
      artUri: Uri.parse('asset:///assets/images/radio_background.png'),
    ));
  }

  Future<void> setRadioSource(String url, String title) async {
    await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  PlaybackState playbackStateFromPlayer(PlayerState state) {
    return PlaybackState(
      controls: [MediaControl.play, MediaControl.pause, MediaControl.stop],
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
      },
      playing: state.playing,
      processingState: {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[state.processingState]!,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      updateTime: DateTime.now(),
    );
  }
}

