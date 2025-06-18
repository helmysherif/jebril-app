import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/providers/Audio_provider.dart';
import 'package:jebril_app/providers/langs_provider.dart';
import 'package:jebril_app/screens/favorite_screen.dart';
import 'package:jebril_app/screens/more.dart';
import 'package:jebril_app/screens/prayers.dart';
import 'package:jebril_app/screens/quran_narratives.dart';
import 'package:jebril_app/screens/quran_screen.dart';
import 'package:jebril_app/screens/tarawih.dart';
import 'package:jebril_app/widgets/card_item.dart';
import 'package:jebril_app/widgets/radio_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../models/AudioResponse.dart';
import '../network/audios.dart';
import '../providers/quran_data_provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  static const String routeName = "home";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String selectedLanguage = 'عربي';

  late Surah radioAudio;
  final List<String> languages = ['English', 'عربي'];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!mounted) return;
    //   final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    //   // If we should keep the radio playing (coming back from Quran screen)
    //   if (audioProvider.keepRadioPlaying && audioProvider.radioAudio != null) {
    //     audioProvider.changeIsRadioPlaying(true);
    //     audioProvider.setKeepRadioPlaying(false); // Reset the flag
    //   } else if (!audioProvider.isRadioPlaying) {
    //     // Set default radio if nothing is playing
    //     audioProvider.setRadioAudio(Surah(
    //       audio: "https://a6.asurahosting.com:8470/radio.mp3",
    //       arabicName: "",
    //       englishName: "",
    //       number: 0,
    //     ));
    //   }
    // });
  }
  @override
  Widget build(BuildContext context) {
    LangsProvider langsProvider = Provider.of<LangsProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    radioAudio = Surah(
      audio: "https://a6.asurahosting.com:8470/radio.mp3",
      arabicName: "",
      englishName: "",
      number: 0,
    );
    final localizations = AppLocalizations.of(context)!;
    var taps = [
      {
        "image": "assets/images/المصحف المرتل.svg",
        "title": localizations.quran
      },
      {
        "image": "assets/images/الروايات المتواترة.svg",
        "title": localizations.rewayat
      },
      {
        "image": "assets/images/التراويح والقيام.svg",
        "title": localizations.tarawih
      },
      {
        "image": "assets/images/الدعاء والذكر.svg",
        "title": localizations.prayers
      },
      {
        "image": "assets/images/قائمتي المفضلة.svg",
        "title": localizations.wishlist
      },
      {
        "image": "assets/images/المزيد.svg",
        "title": localizations.more
      }
    ];
    return Scaffold(
        backgroundColor: const Color(0xfff5f5f5),
        body: SingleChildScrollView(
          child:Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(left:20,right: 20,bottom: 30,top:20),
                    //   child: RadioWidget(suraAudios: radioAudio, type: "radio"),
                    // ),
                    // QuranRadioWidget(suraAudios: surahAudios, type: "quran"),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        int crossAxisCount;
                        if (width > 1200) {
                          crossAxisCount = 6; // For very large screens
                        } else if (width > 800) {
                          crossAxisCount = 4; // For tablets/desktops
                        } else if (width > 600) {
                          crossAxisCount = 3; // For larger phones in landscape
                        } else {
                          crossAxisCount = 2; // Default for phones in portrait
                        }
                        // Ensure we don't show more columns than we have items
                        crossAxisCount =
                        crossAxisCount > 6 ? 6 : crossAxisCount;
                        return GridView.builder(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 30),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 25,
                              crossAxisSpacing: 25,
                              childAspectRatio:1.3
                          ),
                          itemBuilder: (context, index) {
                            final tap = taps[index];
                            return CardItem(
                                label: tap["title"]!,
                                image: tap["image"]!,
                                onPressed: (int id) {
                                  if(index == 0){
                                    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
                                    // audioProvider.prepareForNavigation();
                                    Navigator.of(context).pushNamed(QuranScreen.routeName);
                                  }
                                  else if(index == 1){
                                    Navigator.of(context).pushNamed(QuranNarratives.routeName);
                                  }
                                  else if(index == 2){
                                    Navigator.of(context).pushNamed(Tarawih.routeName);
                                  }
                                  else if(index == 3){
                                    Navigator.of(context).pushNamed(Prayers.routeName);
                                  }
                                  else if(index == 4){
                                    Navigator.of(context).pushNamed(FavoriteScreen.routeName);
                                  }
                                  else if(index == 5){
                                    Navigator.of(context).pushNamed(More.routeName);
                                  }
                                },
                                id: index
                            );
                          },
                          itemCount: 6,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                        );
                      },
                    )
                  ],
                ),
                //   child: QuranRadioWidget()
              ),
            ],
          ),
        ));
  }
}
