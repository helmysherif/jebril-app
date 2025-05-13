import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/widgets/custom_icon_button.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/langs_provider.dart';

// import 'package:google_fonts/google_fonts.dart';
class RadioWidget extends StatefulWidget {
  final List<Surah> suraAudios;
  final int initialIndex;

  // String radioUrl;
  String type;

  RadioWidget(
      {super.key,
      required this.suraAudios,
      this.initialIndex = 0,
      required this.type});

  @override
  State<RadioWidget> createState() => _QuranRadioWidgetState();
}

class _QuranRadioWidgetState extends State<RadioWidget>
    with WidgetsBindingObserver {
  final player = AudioPlayer();
  late int _currentIndex;

  bool get isRadio => widget.type == 'radio';
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

  void handlePlayPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void handleSeek(double value) {
    player.seek(Duration(seconds: value.toInt()));
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    player.positionStream.listen((p) => setState(() => position = p));
    player.durationStream.listen((d) {
      if (!isRadio) setState(() => duration = d ?? Duration.zero);
    });
    player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
        _isBuffering = state.processingState == ProcessingState.buffering;
      });
      if (!isRadio && state.processingState == ProcessingState.completed) {
        player.seek(Duration.zero);
        player.pause();
      }
    });
    await _loadTrack(_currentIndex);
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
      if (player.playing) await player.play();
      setState(() => _currentIndex = index);
    } catch (e) {
      debugPrint('Error loading track: $e');
    }
  }

  Future<void> nextTrack() async {
    if (!isRadio && _currentIndex < widget.suraAudios.length - 1) {
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
    var pro = Provider.of<LangsProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double topVal = MediaQuery.of(context).size.width > 600 ? 10 : 0;
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          // child: SvgPicture.asset(
          //   "assets/images/background.svg",
          //   width: 800,
          //   fit: BoxFit.cover,
          //   height: 800,
          // ),
          child: Image.asset(
            "assets/images/play.png",
            fit: BoxFit.cover,
          ),
        ),
        Container(
          color: const Color.fromRGBO(0, 0, 0, 0.5),
        ),
        Center(
          child: LayoutBuilder(
            builder:(context , constraints){
              double calculateHeight() {
                if (isPortrait) {
                  // For portrait orientation
                  if (screenWidth > 600) {
                    // Tablets in portrait
                    return screenHeight * 0.31;
                  } else {
                    // Phones in portrait
                    return screenHeight * 0.21;
                  }
                } else {
                  // For landscape orientation
                  if (screenWidth > 800 && screenWidth < 1280) {
                    // Large tablets in landscape
                    return screenHeight * 1.05;
                  }
                  else if (screenWidth >= 1280 && screenWidth < 1500) {
                    // Large tablets in landscape
                    return screenHeight * 0.75;
                  }
                  else {
                    // Phones/small tablets in landscape
                    return screenHeight * 0.4; // Adjusted from 0.9 to be more reasonable
                  }
                }
              }
              return Container(
                width: screenWidth * 0.9,
                height: calculateHeight(),
                margin: EdgeInsets.symmetric(
                    horizontal: !isPortrait ? screenWidth * 0.04 : 20,
                    vertical: !isPortrait ? screenHeight * 0.07 : 20),
                // decoration: BoxDecoration(
                //   color: const Color.fromRGBO(0, 0, 0, 0.3),
                //   borderRadius: BorderRadius.circular(20),
                // ),
                child: Padding(
                  padding:
                  EdgeInsetsDirectional.only(top:topVal, start: 20, end: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Text("$screenWidth" , style:TextStyle(color:Colors.white , fontSize:20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 11),
                            child: Text(
                              'راديو الشيخ جبريل - قرآن',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width > 800 ? 27 : !isPortrait ? 27 : 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // const SizedBox(height: 5),
                          // Row(
                          //   children: [
                          //     CustomIconButton(
                          //       icon: Icons.access_time_rounded,
                          //       label: "مؤقت",
                          //       onPressed:(){},
                          //     ),
                          //     const SizedBox(width: 10),
                          //     CustomIconButton(
                          //       icon: Icons.share,
                          //       label: "مشاركة",
                          //       onPressed:(){},
                          //     ),
                          //     const SizedBox(width: 10),
                          //     CustomIconButton(
                          //       icon: Icons.arrow_forward_ios,
                          //       label: "الراديو",
                          //       onPressed:(){},
                          //     )
                          //   ],
                          // )
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isRadio ? "مباشر" : formatDuration(position),
                                style: GoogleFonts.cairo(
                                    fontSize: MediaQuery.of(context).size.width > 800 ? 27 : !isPortrait ? 22 : 18,
                                    color: Colors.white
                                ),
                              ),
                              Text(
                                !isRadio ? formatDuration(duration) : formatDuration(position),
                                style: GoogleFonts.cairo(
                                    fontSize: MediaQuery.of(context).size.width > 800 ? 27 : !isPortrait ? 22 : 18,
                                    color: Colors.white),
                              )
                            ],
                          ),
                          Directionality(
                            textDirection: pro.language == 'ar' && isRadio ? TextDirection.ltr : TextDirection.rtl,
                            child: SliderTheme(
                              data: const SliderThemeData(
                                  trackHeight: 4.0,
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 8.0,
                                    disabledThumbRadius: 6.0,
                                  ),
                                  activeTrackColor: Color(0xff00908B), // Green progress color
                                  inactiveTrackColor: Color(0xFFBDBDBD), // Gray background
                                  thumbColor: Color(0xFF00908B), // Green thumb
                                  overlayColor: Color(0xFF00908B), // Light green overlay when pressed
                                  activeTickMarkColor: Colors.transparent,
                                  inactiveTickMarkColor: Colors.transparent,
                                  disabledActiveTrackColor: Color(0xFF00908B),
                                  disabledThumbColor: Color(0xFF00908B)
                              ),
                              child: Slider(
                                padding: const EdgeInsets.only(
                                    left:0 , right:0 , top:5 , bottom:0),
                                min: 0.0,
                                max: isRadio ? 100.0 : duration.inSeconds.toDouble(),
                                value: isRadio ? 100 : position.inSeconds.toDouble(),
                                onChanged: !isRadio ? handleSeek : null,
                              ),
                            ),
                          ),
                          const SizedBox(height:10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Opacity(
                                opacity: widget.type != 'radio' ? 1 : 0.5,
                                child: IconButton(
                                  icon: const Icon(Icons.skip_next,
                                      color: Colors.white),
                                  onPressed: _hasPrevious && widget.type != 'radio'
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
                                opacity: widget.type != 'radio' ? 1 : 0.5,
                                child: IconButton(
                                  icon: const Icon(Icons.skip_previous,
                                      color: Colors.white),
                                  onPressed: _hasNext && widget.type != 'radio'
                                      ? nextTrack
                                      : null,
                                  iconSize: 35,
                                  padding:EdgeInsets.zero,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height:10)
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
    // return Stack(
    //   alignment: Alignment.bottomCenter,
    //   children: [
    //     ConstrainedBox(
    //       constraints: const BoxConstraints(
    //         maxHeight: 400, // Your maximum height
    //       ),
    //       child: Image.asset(
    //         "assets/images/play.png",
    //         fit: BoxFit.fill,
    //         width: double.infinity,
    //       ),
    //     ),
    //     Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 20),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Padding(
    //             padding: const EdgeInsetsDirectional.only(start: 20, end: 10),
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: [
    //                 Text(formatDuration(position),
    //                     style: const TextStyle(color: Colors.white)),
    //                 !isRadio
    //                     ? Text(formatDuration(duration),
    //                         style: const TextStyle(color: Colors.white))
    //                     : const Text("مباشر",
    //                         style: TextStyle(color: Colors.white)),
    //               ],
    //             ),
    //           ),
    //           Slider(
    //             min: 0.0,
    //             max: isRadio ? 100.0 : duration.inSeconds.toDouble(),
    //             // Ensure max is never 0
    //             value: isRadio ? 100 : position.inSeconds.toDouble(),
    //             onChanged: handleSeek,
    //             // activeColor: Colors.white,
    //             // inactiveColor: Colors.white.withOpacity(0.3),
    //           ),
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               IconButton(
    //                 icon: const Icon(Icons.skip_next, color: Colors.white),
    //                 onPressed: _hasPrevious && widget.type != 'radio'
    //                     ? prevTrack
    //                     : null,
    //                 iconSize: 35,
    //               ),
    //               IconButton(
    //                 icon: Icon(player.playing ? Icons.pause : Icons.play_arrow,
    //                     color: Colors.white),
    //                 onPressed: handlePlayPause,
    //                 iconSize: 45,
    //               ),
    //               IconButton(
    //                 icon: const Icon(Icons.skip_previous, color: Colors.white),
    //                 onPressed:
    //                     _hasNext && widget.type != 'radio' ? nextTrack : null,
    //                 iconSize: 35,
    //               )
    //             ],
    //           )
    //         ],
    //       ),
    //     )
    //   ],
    // );
  }
}

// import 'package:flutter/material.dart';
// class QuranRadioWidget extends StatefulWidget {
//   const QuranRadioWidget({super.key});
//
//   @override
//   State<QuranRadioWidget> createState() => _QuranRadioWidgetState();
// }
//
// class _QuranRadioWidgetState extends State<QuranRadioWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }
