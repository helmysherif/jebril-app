import 'package:flutter/material.dart';
import 'package:jebril_app/Sura.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/langs_provider.dart';
import '../providers/sura_details_provider.dart';

class SuraAudio extends StatefulWidget {
  final List<Surah> suraAudios;
  final int suraNumber;
  final bool isPlaying;
  final Function(bool) onPause;
  const SuraAudio(
      {super.key, required this.onPause ,required this.suraNumber, required this.isPlaying , required this.suraAudios});
  @override
  State<SuraAudio> createState() => _SuraAudioState();
}
class _SuraAudioState extends State<SuraAudio> {
  final player = AudioPlayer();
  late int _currentIndex;
  bool _isPlaying = false;
  bool _isBuffering = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool get _hasPrevious => _currentIndex > 0;
  bool get _hasNext => _currentIndex < widget.suraAudios.length - 1;
  String formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return "${hours.toString().padLeft(2, '0')}:"
          "${minutes.toString().padLeft(2, '0')}:"
          "${seconds.toString().padLeft(2, '0')}";
    } else {
      return "${minutes.toString().padLeft(2, '0')}:"
          "${seconds.toString().padLeft(2, '0')}";
    }
  }
  handlePlayPause() {
    if (player.playing) {
      player.pause();
       widget.onPause(false);
    } else {
      player.play();
       widget.onPause(true);
    }
  }
  void handleSeek(double value) {
    player.seek(Duration(seconds: value.toInt()));
  }
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.suraNumber;
    _initPlayer(widget.suraNumber);
  }
  @override
  void didUpdateWidget(covariant SuraAudio oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the sura number changed
    if (widget.suraNumber != oldWidget.suraNumber) {
      _loadTrack(widget.suraNumber);
    }
    if(widget.isPlaying){
      player.play();
    } else {
      player.pause();
    }
  }
  Future<void> _initPlayer(int index) async {
    player.positionStream.listen((p) => setState(() => position = p));
    player.durationStream.listen((d) {
      setState(() => duration = d ?? Duration.zero);
    });
    player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
        _isBuffering = state.processingState == ProcessingState.buffering;
      });
      if (state.processingState == ProcessingState.completed) {
        player.seek(Duration.zero);
        player.pause();
      }
    });
    await _loadTrack(index);
  }
  void skipForward() async {
    try {
      final newPosition = position + const Duration(seconds: 10);
      if (newPosition > duration) {
        await player.seek(duration);
        setState(() => position = duration);
      } else {
        await player.seek(newPosition);
        setState(() => position = newPosition);
      }
    } catch (e) {
      debugPrint('Error skipping forward: $e');
    }
  }

  void skipBackward() async {
    try {
      final newPosition = position - const Duration(seconds: 10);
      if (newPosition < Duration.zero) {
        await player.seek(Duration.zero);
        setState(() => position = Duration.zero);
      } else {
        await player.seek(newPosition);
        setState(() => position = newPosition);
      }
    } catch (e) {
      debugPrint('Error skipping backward: $e');
    }
  }

  Future<void> _loadTrack(int index) async {
    try {
      // await player.stop();
      // await player.setUrl(widget.suraAudios[index]);
      await player.setSpeed(1.0);
      await player.setAudioSource(
        AudioSource.uri(
            Uri.parse(widget.suraAudios[index].audio),
            tag: "راديو الشيخ جبريل - قرآن"
        ),
        initialPosition: Duration.zero,
        preload: true,
      );
      player.positionStream.listen((p) {
        setState(() => position = p);
      });
      player.durationStream.listen((d) {
        setState(() => duration = d!);
      });
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            position = Duration.zero;
          });
          player.pause();
          player.seek(position);
        }
      });
      await player.play();
      setState(() => _currentIndex = index);
    } catch (e) {
      debugPrint('Error loading track: $e');
    }
  }

  Future<void> nextTrack() async {
    if (_currentIndex < widget.suraAudios.length - 1) {
      await _loadTrack(_currentIndex + 1);
    } else {
      // Return to beginning if at end
      await player.seek(Duration.zero);
    }
    await player.play();
    setState(() {});
  }

  Future<void> prevTrack() async {
    final currentPos = player.position;
    // If within first 3 seconds or first track
    if (currentPos.inSeconds > 3 || _currentIndex == 0) {
      await player.seek(Duration.zero);
    } else {
      await _loadTrack(_currentIndex - 1);
    }
    await player.play();
  }
  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Container(
        width: double.infinity,
        height: 180,
        padding:const EdgeInsets.symmetric(horizontal:10),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/play2.jpg"),
                fit: BoxFit.cover
            ),
            color: Colors.transparent
        ),
        child: Column(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment:MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(position),
                  style: GoogleFonts.cairo(
                      fontSize: MediaQuery.of(context).size.width > 800 ? 27 : !isPortrait ? 22 : 18,
                      color: Colors.white
                  ),
                ),
                Text(
                  formatDuration(duration),
                  style: GoogleFonts.cairo(
                      fontSize: MediaQuery.of(context).size.width > 800 ? 27 : !isPortrait ? 22 : 18,
                      color: Colors.white),
                )
              ],
            ),
            SliderTheme(
              data: const SliderThemeData(
                  trackHeight: 4.0,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: 8.0,
                    disabledThumbRadius: 6.0,
                  ),
                  activeTrackColor: Color(0xff00908B),
                  // Green progress color
                  inactiveTrackColor: Color(0xFFBDBDBD),
                  // Gray background
                  thumbColor: Color(0xFF00908B),
                  // Green thumb
                  overlayColor: Color(0xFF00908B),
                  // Light green overlay when pressed
                  activeTickMarkColor: Colors.transparent,
                  inactiveTickMarkColor: Colors.transparent,
                  disabledActiveTrackColor: Color(0xFF00908B),
                  disabledThumbColor: Color(0xFF00908B)
              ),
              child: Slider(
                padding: const EdgeInsets.only(
                    left: 0, right: 0, top: 5, bottom: 0),
                min: 0.0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged:handleSeek,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:10),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children: [
                      Text(
                        "القرآن المرتل - سورة ${widget.suraAudios[widget.suraNumber].name}",
                        style:GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize:17
                        ),
                      ),
                      const SizedBox(height:5),
                      Text(
                        "برواية حفص بن عاصم",
                        style:GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize:17
                        ),
                      )
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: 0.5,
                        child: IconButton(
                          icon: const Icon(Icons.skip_next,
                              color: Colors.white),
                          onPressed: _hasPrevious
                              ? prevTrack
                              : null,
                          iconSize: 35,
                          padding:EdgeInsets.zero,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: const Color(0xff263635),
                            borderRadius:BorderRadius.circular(30),
                            border:Border.all(
                                color: const Color(0xff028D7F),
                                width:2
                            )
                        ),
                        child: IconButton(
                          icon: Icon(
                              player.playing ? Icons.pause : Icons.play_arrow,
                              color: Colors.white),
                          onPressed: handlePlayPause,
                          iconSize: 35,
                          padding:EdgeInsets.zero,
                        ),
                      ),
                      Opacity(
                        opacity:0.5,
                        child: IconButton(
                          icon: const Icon(Icons.skip_previous,
                              color: Colors.white),
                          onPressed: _hasNext
                              ? nextTrack
                              : null,
                          iconSize: 35,
                          padding:EdgeInsets.zero,
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        )
    );
  }
}
// Text(
// suraAudios[suraNumber].name,
// style:TextStyle(
// color: Colors.white
// ),