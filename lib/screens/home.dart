import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jebril_app/providers/langs_provider.dart';
import 'package:jebril_app/widgets/card_item.dart';
import 'package:jebril_app/widgets/quran_radio_widget.dart';
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
  List<Map<String, String>> surahAudios = [];
  final List<String> languages = ['English', 'عربي'];
  @override
  void initState() {
    super.initState();
    surahAudios = generateSurahAudioUrls();
  }

  List<Map<String, String>> generateSurahAudioUrls() {
    List<String> surahNames = [
      "الفاتحة",
      "البقرة",
      "آل عمران",
      "النساء",
      "المائدة",
      "الأنعام",
      "الأعراف",
      "الأنفال",
      "التوبة",
      "يونس",
      "هود",
      "يوسف",
      "الرعد",
      "إبراهيم",
      "الحجر",
      "النحل",
      "الإسراء",
      "الكهف",
      "مريم",
      "طه",
      "الأنبياء",
      "الحج",
      "المؤمنون",
      "النور",
      "الفرقان",
      "الشعراء",
      "النمل",
      "القصص",
      "العنكبوت",
      "الروم",
      "لقمان",
      "السجدة",
      "الأحزاب",
      "سبأ",
      "فاطر",
      "يس",
      "الصافات",
      "ص",
      "الزمر",
      "غافر",
      "فصلت",
      "الشورى",
      "الزخرف",
      "الدخان",
      "الجاثية",
      "الأحقاف",
      "محمد",
      "الفتح",
      "الحجرات",
      "ق",
      "الذاريات",
      "الطور",
      "النجم",
      "القمر",
      "الرحمن",
      "الواقعة",
      "الحديد",
      "المجادلة",
      "الحشر",
      "الممتحنة",
      "الصف",
      "الجمعة",
      "المنافقون",
      "التغابن",
      "الطلاق",
      "التحريم",
      "الملك",
      "القلم",
      "الحاقة",
      "المعارج",
      "نوح",
      "الجن",
      "المزمل",
      "المدثر",
      "القيامة",
      "الإنسان",
      "المرسلات",
      "النبأ",
      "النازعات",
      "عبس",
      "التكوير",
      "الانفطار",
      "المطففين",
      "الانشقاق",
      "البروج",
      "الطارق",
      "الأعلى",
      "الغاشية",
      "الفجر",
      "البلد",
      "الشمس",
      "الليل",
      "الضحى",
      "الشرح",
      "التين",
      "العلق",
      "القدر",
      "البينة",
      "الزلزلة",
      "العاديات",
      "القارعة",
      "التكاثر",
      "العصر",
      "الهمزة",
      "الفيل",
      "قريش",
      "الماعون",
      "الكوثر",
      "الكافرون",
      "النصر",
      "المسد",
      "الإخلاص",
      "الفلق",
      "الناس"
    ];
    List<Map<String, String>> surahs = [];
    for (int i = 0; i < 114; i++) {
      String surahNumber = (i + 1).toString().padLeft(3, '0');
      surahs.add({
        'audio': 'https://server8.mp3quran.net/jbrl/$surahNumber.mp3',
        'name': surahNames[i],
        'number': (i + 1).toString(),
      });
    }
    return surahs;
  }

  @override
  Widget build(BuildContext context) {
    var pro = Provider.of<LangsProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    var taps = [
      {
        "image" : "assets/images/quran.png",
        "title" : localizations.quran
      },
      {
        "image" : "assets/images/rewayat.png",
        "title" : localizations.rewayat
      },
      {
        "image" : "assets/images/prey.png",
        "title" : localizations.tarawih
      },
      {
        "image" : "assets/images/doaa.png",
        "title" : localizations.prayers
      },
      {
        "image" : "assets/images/wishlist.png",
        "title" : localizations.wishlist
      },
      {
        "image" : "assets/images/ellipise.png",
        "title" : localizations.more
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
                    // child: QuranRadioWidget(suraAudios:const [
                    //   "https://backup.qurango.net/radio/mohammed_jibreel"
                    // ] , type:"radio"),
                    QuranRadioWidget(suraAudios: surahAudios, type: "quran"),
                    GridView.builder(
                      padding: const EdgeInsets.only(left:20 , right:20 , bottom:30),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing:25,
                          crossAxisSpacing:25
                      ),
                      itemBuilder: (context , index){
                        final tap = taps[index];
                        return CardItem(
                          label:tap["title"]!,
                          image:tap["image"]!,
                          onPressed:(){},
                        );
                      },
                      itemCount:6,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                    ),
                  ],
                ),
                //   child: QuranRadioWidget()
              ),
            ],
          ),
        ));
  }
}
