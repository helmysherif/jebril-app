import 'package:flutter/material.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/providers/Audio_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/langs_provider.dart';
import 'custom_icon_button.dart';
class RadioWidget extends StatefulWidget {
  final int initialIndex;
  final String type;
  final bool inNotHomeScreen;
  RadioWidget(
      {super.key,
      this.initialIndex = 0,
        this.inNotHomeScreen = false,
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
  late AudioProvider audioProvider;
  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
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
    WidgetsBinding.instance.addObserver(this);
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final radioAudio = audioProvider.radioAudio;
    player.positionStream.listen((p) => setState(() => position = p));
    player.durationStream.listen((d) => setState(() => duration = d ?? Duration.zero));
    player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
        _isBuffering = state.processingState == ProcessingState.buffering;
      });
    });
    await _loadTrack(radioAudio.audio);
  }

  Future<void> _loadTrack(String radioUrl) async {
    try {
      // await player.stop();
      // await player.setUrl(widget.suraAudios[index]);
      await player.setSpeed(1.0);
      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(radioUrl),
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
      // setState(() => _currentIndex = index);
    } catch (e) {
      debugPrint('Error loading track: $e');
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    audioProvider = Provider.of<AudioProvider>(context, listen: false);
    _setupPlayerListeners();
  }
  void _setupPlayerListeners() {
    final player = audioProvider.player;
    // Clear existing listeners to avoid duplicates
    player.positionStream.listen(null).cancel();
    player.durationStream.listen(null).cancel();
    player.playerStateStream.listen(null).cancel();

    player.positionStream.listen((position) {
      if (mounted) setState(() => position = position);
    });
    player.durationStream.listen((duration) {
      if (mounted) setState(() => duration = duration ?? Duration.zero);
    });
    player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() => _isBuffering = state.processingState == ProcessingState.buffering);
      }
    });
  }
  @override
  void dispose() {
    player.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    LangsProvider pro = Provider.of<LangsProvider>(context);
    // AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double topVal = MediaQuery.of(context).size.width > 600 ? 10 : 0;
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    // audioProvider.addListener(_handleProviderChange);
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
            widget.inNotHomeScreen ? "assets/images/play2.jpg" : "assets/images/radio_background.png",
            fit: BoxFit.cover,
            height: 190,
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
                width: widget.inNotHomeScreen ? screenWidth : screenWidth * 0.9,
                height: widget.inNotHomeScreen ? 190 : calculateHeight(),
                margin: EdgeInsets.symmetric(
                    horizontal: !isPortrait ? screenWidth * 0.04 : 0,
                    vertical: !isPortrait ? screenHeight * 0.07 : 0),
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
                        mainAxisAlignment: !widget.inNotHomeScreen ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(!widget.inNotHomeScreen) Padding(
                            padding: const EdgeInsets.only(top: 11),
                            child: Text(
                              'راديو الشيخ جبريل - قرآن',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width > 800 ? 27 : !isPortrait ? 27 : 15,
                                fontWeight: FontWeight.w500,
                              ),
                                textScaler: const TextScaler.linear(1.0)
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top:10),
                            child: Row(
                              children: [
                                CustomIconButton(
                                  icon: Icons.access_time_rounded,
                                  label: "مؤقت",
                                  onPressed:(){},
                                ),
                                const SizedBox(width: 10),
                                CustomIconButton(
                                  icon: Icons.share,
                                  label: "مشاركة",
                                  onPressed:(){},
                                ),
                                const SizedBox(width: 10),
                                CustomIconButton(
                                  icon: Icons.arrow_forward_ios,
                                  label: "الراديو",
                                  onPressed:(){},
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width:7,
                                    height:7,
                                    margin:EdgeInsets.only(top:3),
                                    decoration:BoxDecoration(
                                      borderRadius:BorderRadius.circular(20),
                                      color:Color(0xffA20202)
                                    ),
                                  ),
                                  const SizedBox(width:5),
                                  Text(
                                      isRadio ? "مباشر" : formatDuration(position),
                                      style: GoogleFonts.cairo(
                                          fontSize: MediaQuery.of(context).size.width > 800 ? 27 : !isPortrait ? 22 : 15,
                                          color: Colors.white
                                      ),
                                      textScaler: const TextScaler.linear(1.0)
                                  )
                                ],
                              ),
                              StreamBuilder<Duration>(
                                stream: audioProvider.player.positionStream,
                                builder: (context, snapshot) {
                                  final position = snapshot.data ?? Duration.zero;
                                  return Text(
                                    formatDuration(position),
                                    style: const TextStyle(color: Colors.white),
                                      textScaler: const TextScaler.linear(1.0)
                                  );
                                },
                              ),
                              // Text(
                              //   !isRadio ? formatDuration(duration) : formatDuration(position),
                              //   style: GoogleFonts.cairo(
                              //       fontSize: MediaQuery.of(context).size.width > 800 ? 27 : !isPortrait ? 22 : 15,
                              //       color: Colors.white),
                              //     textScaler: const TextScaler.linear(1.0)
                              // )
                            ],
                          ),
                          Directionality(
                            textDirection: pro.language == 'ar' && isRadio ? TextDirection.ltr : TextDirection.rtl,
                            child: SliderTheme(
                              data: const SliderThemeData(
                                  trackHeight: 2.0,
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 6.0,
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
                            mainAxisAlignment: widget.inNotHomeScreen ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                            children: [
                              if(widget.inNotHomeScreen) Text(
                                  'راديو الشيخ جبريل - قرآن',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.width > 800 ? 27 : !isPortrait ? 27 : 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textScaler: const TextScaler.linear(1.0)
                              ),
                              if(widget.inNotHomeScreen) const Spacer(),
                              Opacity(
                                opacity: widget.type != 'radio' ? 1 : 0.5,
                                child: IconButton(
                                  icon: const Icon(Icons.skip_next,
                                      color: Colors.white),
                                  onPressed: null,
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
                                      audioProvider.isRadioPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white),
                                  onPressed: () async {
                                    if (audioProvider.isRadioPlaying) {
                                      await audioProvider.pauseRadio();
                                    } else {
                                      await audioProvider.playRadio();
                                    }
                                  },
                                  iconSize: 35,
                                  padding:EdgeInsets.zero,
                                ),
                              ),
                              Opacity(
                                opacity: widget.type != 'radio' ? 1 : 0.5,
                                child: IconButton(
                                  icon: const Icon(Icons.skip_previous,
                                      color: Colors.white),
                                  onPressed:null,
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
  }
}
