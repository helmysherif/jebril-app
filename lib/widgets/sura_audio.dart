import 'package:flutter/material.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/providers/Audio_provider.dart';
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
  final Function(int) onTrackChanged;
  final bool isRadioPlaying;
  final String rewayaName;
  final Surah? radioUrl;
  const SuraAudio(
      {super.key, this.radioUrl ,required this.isRadioPlaying ,required this.rewayaName ,required this.onTrackChanged ,required this.onPause ,required this.suraNumber, required this.isPlaying , required this.suraAudios});
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
    if (!widget.isRadioPlaying || duration.inSeconds > 0) {
      player.seek(Duration(seconds: value.toInt()));
    }
  }
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.suraNumber;
    // Set up listeners first
    player.positionStream.listen((p) => setState(() => position = p));
    player.durationStream.listen((d) {
      final newDuration = d ?? Duration.zero;
      if (mounted) {
        setState(() {
          duration = newDuration;
        });
      }
    });
    player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
        _isBuffering = state.processingState == ProcessingState.buffering;
      });
      if (state.processingState == ProcessingState.completed && !widget.isRadioPlaying) {
        player.seek(Duration.zero);
        player.pause();
      }
    });
    // Load appropriate content based on initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isRadioPlaying) {
        _loadRadio();
      } else {
        _loadTrack(_currentIndex, shouldPlay: widget.isPlaying);
      }
    });
  }
  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }
  @override
  void didUpdateWidget(covariant SuraAudio oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle switching between radio and surah modes
    if (widget.isRadioPlaying != oldWidget.isRadioPlaying) {
      if (widget.isRadioPlaying) {
        _loadRadio();
      } else {
        _loadTrack(widget.suraNumber, shouldPlay: widget.isPlaying);
      }
    }
    // Handle radio URL changes
    else if (widget.isRadioPlaying &&
        widget.radioUrl?.audio != oldWidget.radioUrl?.audio) {
      _loadRadio();
    }
    // Handle surah changes
    else if (!widget.isRadioPlaying &&
        widget.suraNumber != oldWidget.suraNumber) {
      _currentIndex = widget.suraNumber;
      _loadTrack(_currentIndex, shouldPlay: widget.isPlaying);
    }

    // Sync play/pause state
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        player.play();
      } else {
        player.pause();
      }
    }
  }
  Future<void> _initPlayer(int index) async {
    player.positionStream.listen((p) => setState(() => position = p));
    player.durationStream.listen((d) {
      if (!widget.isRadioPlaying) {
        setState(() => duration = d ?? Duration.zero);
      }
    });
    player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
        _isBuffering = state.processingState == ProcessingState.buffering;
      });
      if (state.processingState == ProcessingState.completed && !widget.isRadioPlaying) {
        player.seek(Duration.zero);
        player.pause();
      }
    });
    if (widget.isRadioPlaying) {
      await _loadRadio();
    } else {
      await _loadTrack(index, shouldPlay: true);
    }
  }
  Future<void> _loadRadio() async {
    try {
      // Stop any existing playback
      await player.stop();

      if (widget.radioUrl?.audio == null) {
        debugPrint('Radio URL is null');
        return;
      }

      // Set up new audio source
      await player.setAudioSource(
        AudioSource.uri(
            Uri.parse(widget.radioUrl!.audio),
            tag: "راديو الشيخ جبريل - قرآن"
        ),
        preload: true,
      );
      await player.play();
      // Start playback if requested
      if (widget.isPlaying) {
        await player.play();
      }

      debugPrint('Radio loaded successfully: ${widget.radioUrl!.audio}');
    } catch (e) {
      debugPrint('Error loading radio: $e');
      // Consider showing an error to the user
    }
  }
  Future<void> _loadTrack(int index, {bool shouldPlay = true}) async {
    try {
      if (index < 1 || index > widget.suraAudios.length) {
        debugPrint('Invalid index: $index');
        return;
      }
      await player.setSpeed(1.0);
      final audioUrl = widget.suraAudios[index - 1].audio;

      if (audioUrl.isEmpty) {
        debugPrint('Invalid audio URL');
        return;
      }
      await player.setAudioSource(
        AudioSource.uri(Uri.parse(audioUrl)),
        preload: true,
      );

      if (shouldPlay) await player.play();
      setState(() => _currentIndex = index);
    } catch (e) {
      debugPrint('Error loading track: $e');
    }
  }

  Future<void> nextTrack() async {
    if (_currentIndex < widget.suraAudios.length - 1) {
      _currentIndex++;
      widget.onTrackChanged(_currentIndex); // Notify parent

      await _loadTrack(_currentIndex,shouldPlay: true);
      await player.play();
    }
  }

  Future<void> prevTrack() async {
    final currentPos = player.position;

    if (currentPos.inSeconds > 3 || _currentIndex == 0) {
      await player.seek(Duration.zero);
    } else {
      _currentIndex--;
      widget.onTrackChanged(_currentIndex); // Notify parent

      await _loadTrack(_currentIndex,shouldPlay: true);
      await player.play();
    }
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
                  widget.isRadioPlaying ? "مباشر" : formatDuration(position),
                  style: GoogleFonts.cairo(
                      fontSize: MediaQuery.of(context).size.width > 800 ? 27 : !isPortrait ? 22 : 18,
                      color: Colors.white
                  ),
                ),
                Text(
                  widget.isRadioPlaying ? formatDuration(position) : formatDuration(duration),
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
                max: duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0,
                value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds > 0
                    ? duration.inSeconds.toDouble()
                    : 1.0),
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
                      !widget.isRadioPlaying ? Text(
                        "القرآن المرتل - سورة ${ widget.isRadioPlaying ? '' : widget.suraAudios[widget.suraNumber - 1].arabicName}",
                        style:GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize:17
                        ),
                      ) : const SizedBox.shrink(),
                      const SizedBox(height:5),
                      Text(
                        widget.isRadioPlaying ? "راديو الشيخ جبريل - قرآن" : "برواية ${widget.rewayaName}",
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
                      widget.isRadioPlaying ? const Opacity(
                        opacity:0.5,
                        child: IconButton(
                          icon: Icon(Icons.skip_next,
                              color: Colors.white),
                          onPressed:null,
                          iconSize: 35,
                          padding:EdgeInsets.zero,
                        ),
                      ) : IconButton(
                        icon: const Icon(Icons.skip_next,
                            color: Colors.white),
                        onPressed: _hasPrevious
                            ? prevTrack
                            : null,
                        iconSize: 35,
                        padding:EdgeInsets.zero,
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
                      widget.isRadioPlaying ? const Opacity(
                        opacity:0.5,
                        child: IconButton(
                          icon: Icon(Icons.skip_previous,
                              color: Colors.white),
                          onPressed: null,
                          iconSize: 35,
                          padding:EdgeInsets.zero,
                        ),
                      ) : IconButton(
                        icon: const Icon(Icons.skip_previous,
                            color: Colors.white),
                        onPressed: _hasNext
                            ? nextTrack
                            : null,
                        iconSize: 35,
                        padding:EdgeInsets.zero,
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