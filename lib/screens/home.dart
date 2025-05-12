import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/providers/langs_provider.dart';
import 'package:jebril_app/screens/quran_screen.dart';
import 'package:jebril_app/widgets/card_item.dart';
import 'package:jebril_app/widgets/radio_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  static const String routeName = "home";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String selectedLanguage = 'عربي';

  List<Surah> radioAudio = [];
  final List<String> languages = ['English', 'عربي'];

  @override
  void initState() {
    super.initState();
    radioAudio = [
      Surah(
        audio: "https://a6.asurahosting.com:8470/radio.mp3",
        name: "",
        number: 0,
      )
    ];
  }
  @override
  Widget build(BuildContext context) {
    var pro = Provider.of<LangsProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    var taps = [
      {
        "image": "assets/images/quran.png",
        "title": localizations.quran
      },
      {
        "image": "assets/images/rewayat.png",
        "title": localizations.rewayat
      },
      {
        "image": "assets/images/prey.png",
        "title": localizations.tarawih
      },
      {
        "image": "assets/images/doaa.png",
        "title": localizations.prayers
      },
      {
        "image": "assets/images/wishlist.png",
        "title": localizations.wishlist
      },
      {
        "image": "assets/images/ellipise.png",
        "title": localizations.more
      }
    ];
    return Scaffold(
        backgroundColor: const Color(0xfff5f5f5),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/images/logo2.png", width: 60),
                        const SizedBox(width: 10),
                        Text(localizations.name,
                            style: GoogleFonts.cairo(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 10),
                      ],
                    ),
                    DropdownButton<String>(
                      value: pro.language == 'en' ? 'English' : 'عربي',
                      elevation: 0,
                      underline: const SizedBox.shrink(),
                      icon: const SizedBox.shrink(),
                      iconSize: 30,
                      items: languages
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? lang) {
                        if (lang != null) {
                          if (lang == 'English') {
                            pro.changeLanguage("en");
                          } else {
                            pro.changeLanguage("ar");
                          }
                        }
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return languages.map((String value) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 4),
                              Text(
                                value,
                                style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    color: const Color(0xff484848),
                                    fontWeight: FontWeight.w600),
                              ),
                              const Icon(Icons.keyboard_arrow_down),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Column(
                  children: [
                    RadioWidget(suraAudios: radioAudio, type: "radio"),
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
                              childAspectRatio:1.12
                          ),
                          itemBuilder: (context, index) {
                            final tap = taps[index];
                            return CardItem(
                                label: tap["title"]!,
                                image: tap["image"]!,
                                onPressed: (int id) {
                                  if(index == 0){
                                    Navigator.of(context).pushNamed(
                                      QuranScreen.routeName
                                    );
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
