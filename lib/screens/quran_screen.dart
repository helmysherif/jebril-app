import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/providers/sura_details_provider.dart';
import 'package:jebril_app/widgets/radio_widget.dart';
import 'package:jebril_app/widgets/sura_audio.dart';
import 'package:jebril_app/widgets/sura_item.dart';
import 'package:provider/provider.dart';

class QuranScreen extends StatefulWidget {
  static const String routeName = "quran";

  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  List<Surah> surahAudios = [];
  bool showRadio = false;
  int currentSuraNumber = 0;
  int? currentlyPlayingIndex;
  bool isPlaying = false;
  List<Surah> generateSurahAudioUrls() {
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
    List<Surah> surahs = [];
    for (int i = 0; i < 114; i++) {
      String surahNumber = (i + 1).toString().padLeft(3, '0');
      surahs.add(Surah(
        audio: 'https://server8.mp3quran.net/jbrl/$surahNumber.mp3',
        name: surahNames[i],
        number: (i + 1),
      ));
    }
    return surahs;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    surahAudios = generateSurahAudioUrls();
  }

  @override
  Widget build(BuildContext context) {
    var pro = Provider.of<SuraDetailsProvider>(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        elevation:0,
        scrolledUnderElevation:0,
        backgroundColor: Colors.white,
        centerTitle: true,
        toolbarHeight: 100,
        title: Text(
          "المصحف المرتل",
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
              fontSize: 23,
              color: const Color(0xff484848),
              fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_sharp, color: Color(0xff484848)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top:20),
              child: ListView.builder(itemBuilder: (context, index) {
                return SuraItem(
                  suraDetails:surahAudios[index],
                  onAudioPlay:(int suraNumber){
                    setState(() {
                      if (currentlyPlayingIndex == index) {
                        currentlyPlayingIndex = null;
                        isPlaying = false;
                      } else {
                        currentlyPlayingIndex = index;
                        pro.changeIndex(index);
                        showRadio = true;
                        isPlaying = true;
                      }
                    });
                  }, isPlaying: currentlyPlayingIndex == index,
                );
              },
                itemCount:surahAudios.length,
              ),
            ),
          ),
          showRadio ? SuraAudio(
            suraAudios:surahAudios,
            suraNumber:pro.index,
            isPlaying : isPlaying,
            onPause:(bool stat){
              isPlaying = stat;
              if(isPlaying){
                currentlyPlayingIndex = pro.index;
              } else {
                currentlyPlayingIndex = null;
              }
              setState(() {});
            },
          ) : const SizedBox.shrink()
        ],
      ),
    );
  }
}
