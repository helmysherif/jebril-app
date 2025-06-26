import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/providers/Audio_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../providers/langs_provider.dart';
import '../providers/sura_details_provider.dart';

class SuraAudio extends StatefulWidget {
  final List<Surah> suraAudios;
  final int suraNumber;
  final bool isPlaying;
  final Function(bool) onPause;
  final Function(int , int , String) onTrackChanged;
  final bool isRadioPlaying;
  final String rewayaName;
  final Surah? radioUrl;
  final int? suraIndex;
  final bool isPrayer;
  final bool isFavorite;
  final bool isOffline;
  final String? uniqueId;
  const SuraAudio(
      {super.key, this.radioUrl, this.isOffline = false ,this.uniqueId ,this.isFavorite = false ,this.isPrayer = false ,this.suraIndex  ,required this.isRadioPlaying ,required this.rewayaName ,required this.onTrackChanged ,required this.onPause ,required this.suraNumber, required this.isPlaying , required this.suraAudios});
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
  bool get _hasNext => _currentIndex < widget.suraAudios.length;
  late List<Surah> clickedSura;
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
  handlePlayPause()  {
    if (player.playing) {
       player.pause();
      widget.onPause(false); // Notify parent of pause
    } else {
      // // Only seek to start if we're at the end of the track
      // if (player.position >= (duration - const Duration(seconds: 1))) {
      //   await player.seek(Duration.zero);
      // }
       player.play();
      widget.onPause(true); // Notify parent of play
    }
  }
  String get _audioSource {
    if (widget.isOffline) {
      return widget.suraAudios.firstWhere(
            (s) => s.number == widget.suraNumber,
        orElse: () => widget.suraAudios.first,
      ).audio;
    } else if (widget.isRadioPlaying && widget.radioUrl != null) {
      return widget.radioUrl!.audio;
    } else {
      return widget.suraAudios[widget.suraNumber - 1].audio; // Adjusted index
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
    currSura = widget.suraAudios.firstWhere(
          (s) => s.number == widget.suraIndex,
      orElse: () => widget.suraAudios.isNotEmpty ? widget.suraAudios[0] : Surah(
        audio: '',
        englishName: '',
        arabicName: '',
        number: 0,
        narrative: '',
      ),
    );
    _currentIndex = widget.suraIndex ?? 0;
    // Set up listeners first
    // player.playerStateStream.listen((state) {
    //   final isNowPlaying = state.playing;
    //   if (isNowPlaying != _isPlaying) {
    //     setState(() => _isPlaying = isNowPlaying);
    //     widget.onPause(!isNowPlaying); // Notify parent of state change
    //   }
    // });
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
  Surah? currSura;
  void _updateCurrentSurah() {
    if (widget.isRadioPlaying) {
      currSura = widget.radioUrl;
    } else if (widget.uniqueId != null) {
      // Find surah by uniqueId when switching tracks
      currSura = widget.suraAudios.firstWhere(
            (s) => s.uniqueId == widget.uniqueId,
        orElse: () => widget.suraAudios.isNotEmpty
            ? widget.suraAudios[0]
            : Surah(audio: '', englishName: '', arabicName: '', number: 0, narrative: ''),
      );
    } else {
      // Fallback to index-based lookup
      currSura = widget.suraAudios.isNotEmpty && _currentIndex < widget.suraAudios.length
          ? widget.suraAudios[_currentIndex]
          : null;
    }
  }
  @override
  void didUpdateWidget(covariant SuraAudio oldWidget) {
    super.didUpdateWidget(oldWidget);
    // currSura = widget.suraAudios.firstWhere(
    //       (s) => s.number == widget.suraIndex,
    //   orElse: () => widget.suraAudios.isNotEmpty ? widget.suraAudios[0] : Surah(
    //     audio: '',
    //     englishName: '',
    //     arabicName: '',
    //     number: 0,
    //     narrative: '',
    //   ),
    // );
    // print("currSura => ${currSura?.arabicName}");
    // if(!widget.isPlaying){
    //   player.pause();
    // } else {
    //   player.play();
    // }
    // In offline mode, ignore radio-related updates
    // if (widget.isOffline) {
    //   print("widget.suraNumber => ${widget.suraNumber}");
    //   if (widget.suraNumber != oldWidget.suraNumber) {
    //     _currentIndex = widget.suraNumber;
    //     _loadTrack(_currentIndex, shouldPlay: widget.isPlaying);
    //   }
    //   return;
    // }
    // Original update logic for online mode
    if (widget.isRadioPlaying != oldWidget.isRadioPlaying) {
      if (widget.isRadioPlaying) {
        _loadRadio();
      } else {
        _loadTrack(widget.suraNumber, shouldPlay: widget.isPlaying);
      }
    }
    else if(widget.uniqueId != oldWidget.uniqueId){
      _loadTrack(widget.suraNumber, shouldPlay: widget.isPlaying);
    }
    // Handle radio URL changes
    else if (widget.isRadioPlaying &&
        widget.radioUrl?.audio != oldWidget.radioUrl?.audio) {
      _loadRadio();
    }
    // Handle surah changes
    // else if (!widget.isRadioPlaying &&
    //     widget.suraNumber != oldWidget.suraNumber) {
    //   _currentIndex = widget.suraNumber;
    //   _loadTrack(_currentIndex, shouldPlay: widget.isPlaying);
    // }
    if (widget.uniqueId != oldWidget.uniqueId) {
      _updateCurrentSurah();
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
  int _retryCount = 0;
  int _maxRetries = 2;
  bool _isConnectionError = false;
  Future<bool> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }
  Future<void> _handleConnectionError(Surah sura) async {
    if (!mounted) return;

    setState(() => _isConnectionError = true);

    // Try to play downloaded version if available
    final downloadedPath = await _getDownloadedFilePath(sura);
    final isDownloaded = await File(downloadedPath).exists();

    if (isDownloaded) {
      try {
        await player.setAudioSource(AudioSource.file(downloadedPath));
        await player.play();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Playing downloaded version'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error playing downloaded version: $e');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error and no downloaded version available'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
  Future<void> _loadRadio() async {
    try {
      await player.stop();
      if (widget.radioUrl?.audio == null) return;

      await player.setAudioSource(
        AudioSource.uri(Uri.parse(_audioSource),
            tag: "راديو الشيخ جبريل - قرآن"
        ),
        preload: true,
      );

      if (widget.isPlaying) await player.play();
    } catch (e) {
      debugPrint('Error loading radio: $e');
    }
  }
  Future<void> _loadTrack(int index, {bool shouldPlay = true}) async {
    try {
      await player.stop();
      setState(() => _isConnectionError = false);

      // Find the sura by uniqueId
      clickedSura = widget.suraAudios.where((audio) => audio.uniqueId == widget.uniqueId).toList();

      if (clickedSura.isEmpty) {
        debugPrint('No surah found with uniqueId: ${widget.uniqueId}');
        return;
      }

      final sura = clickedSura[0];
      final isDownloaded = await _checkIfSuraDownloaded(sura);

      // Use downloaded version if available
      if (isDownloaded) {
        final filePath = await _getDownloadedFilePath(sura);
        await player.setAudioSource(AudioSource.file(filePath));
        debugPrint('Playing downloaded version: ${sura.arabicName}');
      }
      // Try online version if not downloaded
      else {
        await _loadOnlineWithRetries(sura.audio);
      }

      if (shouldPlay) {
        await player.play();
        setState(() => _currentIndex = index);
      }
    } catch (e) {
      debugPrint('Error loading track: $e');
      if (e.toString().contains('Connection aborted')) {
        await _handleConnectionError(clickedSura[0]);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
  Future<void> _loadOnlineWithRetries(String url) async {
    bool success = false;

    for (int i = 0; i < _maxRetries; i++) {
      try {
        await player.setAudioSource(
          AudioSource.uri(Uri.parse(url)),
          preload: true,
        );
        success = true;
        break;
      } catch (e) {
        debugPrint('Attempt ${i + 1} failed: $e');
        if (i < _maxRetries - 1) {
          await Future.delayed(Duration(seconds: 1));
        }
      }
    }

    if (!success) {
      throw Exception('Failed after $_maxRetries attempts');
    }
  }
  Future<bool> _checkIfSuraDownloaded(Surah sura) async {
    final path = await _getDownloadedFilePath(sura);
    return File(path).exists();
  }
  Future<String> _getDownloadedFilePath(Surah sura) async {
    final directory = await getApplicationDocumentsDirectory();
    if (sura.narrative != null) {
      return '${directory.path}/سورة ${sura.arabicName} برواية ${sura.narrative}.mp3';
    }
    return '${directory.path}/سورة ${sura.arabicName}.mp3';
  }
  Future<void> _playDownloadedVersion(String path) async {
    try {
      await player.setAudioSource(AudioSource.file(path));
      await player.play();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playing downloaded version'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error playing downloaded version: $e');
    }
  }
  Future<void> nextTrack() async {
    if (_hasNext) {
      // _currentIndex++;
      int currentIndex = 0;
      if(!widget.isFavorite){
        // clickedSura = widget.suraAudios.where((audio) => audio.uniqueId == widget.uniqueId).toList();
        currentIndex = widget.suraAudios.indexWhere((audio) => audio.uniqueId == clickedSura[0].uniqueId);
      } else {
        currentIndex = widget.suraAudios.indexWhere((audio) => audio.uniqueId == clickedSura[0].uniqueId);
      }
      if(currentIndex == -1) return;
      int nextIndex = currentIndex + 1;
      if (nextIndex >= widget.suraAudios.length) {
        debugPrint('No more tracks available');
        return;
      }
      clickedSura = [widget.suraAudios[nextIndex]];
      _currentIndex = nextIndex;
      // final newSuraNumber = widget.suraAudios[_currentIndex - 1].number;
      print("clickedSura2 => ${clickedSura[0].arabicName}");
      print("_currentIndex2 => $_currentIndex");
      widget.onTrackChanged(_currentIndex, clickedSura[0].number , clickedSura[0].uniqueId);
      await _loadTrack(_currentIndex, shouldPlay: true);
      await player.play();
    }
  }

  Future<void> prevTrack() async {
    print("1245");
    final currentPos = player.position;
    if (currentPos.inSeconds > 0.5) {
      await player.seek(Duration.zero);
    } else {
      try {
        // if (_currentIndex > 1) {
        //   _currentIndex--;
        //   final newSuraNumber = widget.suraAudios[_currentIndex - 1].number;
        //   widget.onTrackChanged(_currentIndex, newSuraNumber);
        //   await _loadTrack(_currentIndex, shouldPlay: true);
        //   await player.play();
        // }
        int currentIndex = 0;
        if(!widget.isFavorite){
          currentIndex = widget.suraAudios.indexWhere((audio) => audio.uniqueId == clickedSura[0].uniqueId);
        } else {
          currentIndex = widget.suraAudios.indexWhere((audio) => audio.uniqueId == clickedSura[0].uniqueId);
        }
        if (currentIndex == -1) {
          debugPrint('Clicked sura not found in the list');
          return;
        }
        final prevIndex = currentIndex - 1;
        if (prevIndex < 0) {
          debugPrint('Already at the first track');
          return;
        }
        clickedSura = [widget.suraAudios[prevIndex]];
        print("prev clickedSura => ${clickedSura[0].arabicName}");
        _currentIndex = prevIndex + 1;
        widget.onTrackChanged(_currentIndex, clickedSura[0].number , clickedSura[0].uniqueId);
        print("prev currentIndex => $currentIndex");
        // Load and play
        await _loadTrack(_currentIndex, shouldPlay: true);
      } catch (e){}
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
                      fontSize: MediaQuery.of(context).size.width > 800 ? 27 : !isPortrait ? 22 : 15,
                      color: Colors.white
                  ),
                  textScaler: const TextScaler.linear(1.0)
                ),
                Text(
                  widget.isRadioPlaying ? formatDuration(position) : formatDuration(duration),
                  style: GoogleFonts.cairo(
                      fontSize: MediaQuery.of(context).size.width > 800 ? 27 : !isPortrait ? 22 : 15,
                      color: Colors.white),
                    textScaler: const TextScaler.linear(1.0)
                )
              ],
            ),
            SliderTheme(
              data: const SliderThemeData(
                  trackHeight: 2.0,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: 6.0,
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
                      !widget.isRadioPlaying && !widget.isPrayer ? Text(
                        "القرآن المرتل - سورة ${ widget.isRadioPlaying ? '' : currSura?.arabicName}",
                        style:GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize:17
                        ),
                          textScaler: const TextScaler.linear(1.0)
                      ) : const SizedBox.shrink(),
                      const SizedBox(height:5),
                      Text(
                        widget.isRadioPlaying ? "راديو الشيخ جبريل - قرآن" : widget.isPrayer ? " ${widget.rewayaName}" : "برواية ${currSura?.narrative}",
                        style:GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize:17
                        ),
                          textScaler: const TextScaler.linear(1.0)
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
                        onPressed: prevTrack,

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