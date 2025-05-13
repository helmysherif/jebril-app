import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/constants/sura_names.dart';
import 'package:jebril_app/providers/langs_provider.dart';
import 'package:jebril_app/providers/sura_details_provider.dart';
import 'package:jebril_app/widgets/sura_audio.dart';
import 'package:jebril_app/widgets/sura_item.dart';
import 'package:jebril_app/widgets/text_input_field.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/AudioResponse.dart';
import '../models/Subcategories.dart';
import '../network/audios.dart';

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
  String filteredName = "";
  late Subcategories selectedQuran;
  bool isLoading = true;
  List<Subcategories> holyQuranData = [];
  bool isHolyQuranChanged = false;
  final TextEditingController _searchController = TextEditingController();

  List<Surah> generateSurahAudioUrls(String quranId) {
    List<Surah> surahs = [];
    for (int i = 0; i < 114; i++) {
      String surahNumber = (i + 1).toString().padLeft(3, '0');
      surahs.add(Surah(
        audio:
            'https://radiojebril.net/sheikh_jebril_audios/sounds/holy_quran/$quranId/$surahNumber.mp3',
        englishName: suraNamesData[i]["englishName"],
        arabicName: suraNamesData[i]["arabicName"],
        number: suraNamesData[i]["number"],
      ));
    }
    return surahs;
  }

  getSearchInputValue(String text) {
    filteredName = text;
    setState(() {});
  }

  List<Surah> getFilteredSurahs(String searchText) {
    if (searchText.isEmpty) {
      return surahAudios; // Return all surahs if search is empty
    } else {
      return surahAudios.where((surah) {
        final englishMatch =
            surah.englishName.toLowerCase().contains(searchText.toLowerCase());
        final arabicMatch =
            surah.arabicName.contains(searchText); // Arabic is case-sensitive
        return englishMatch || arabicMatch;
      }).toList();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHollyQuranData(0);
  }

  Future<void> getHollyQuranData(int index) async {
    setState(() => isLoading = true);
    try {
      List<AudioResponse> response = await GetAudiosApi.getAudios();
      setState(() {
        List<AudioResponse> filteredData =
            response.where((item) => item.id == "holy_quran").toList();
        holyQuranData = filteredData[index].subcategories;
        if (holyQuranData.isNotEmpty) {
          selectedQuran = holyQuranData[index];
          surahAudios = generateSurahAudioUrls(selectedQuran.id);
        }
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching audio data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var pro = Provider.of<SuraDetailsProvider>(context);
    var langProvider = Provider.of<LangsProvider>(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
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
      body: isLoading ? const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CircularProgressIndicator(),
          )
        ],
      ) : Column(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
                start: langProvider.language == 'ar' ? 11 : 9,
                end: langProvider.language == 'ar' ? 19 : 20,
                top: 20,
                bottom: 10),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextInputField(
                      getInputValue: getSearchInputValue,
                      controller:
                          _searchController), // Your custom text input widget
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: DropdownButton<Subcategories>(
                      value: selectedQuran,
                      elevation: 0,
                      underline: const SizedBox.shrink(),
                      icon: const SizedBox.shrink(),
                      iconSize: 30,
                      isExpanded: true,
                      items: holyQuranData.map<DropdownMenuItem<Subcategories>>(
                          (Subcategories value) {
                        return DropdownMenuItem<Subcategories>(
                          value: value,
                          child: Text(
                            value.arTitle ?? "",
                            style: GoogleFonts.cairo(
                                fontSize: 15,
                                color: const Color(0xff484848),
                                fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                      onChanged: (Subcategories? sura) async {
                        if(sura != null){
                          setState(() {
                            isHolyQuranChanged = true;
                            showRadio = false;
                            currentlyPlayingIndex = null;
                            isPlaying = false;
                          });
                          await Future.delayed(const Duration(milliseconds: 300));
                          setState(() {
                            selectedQuran = sura;
                            surahAudios = generateSurahAudioUrls(selectedQuran.id);
                            isHolyQuranChanged = false;
                          });
                        }
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return holyQuranData.map((Subcategories value) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  value.arTitle ?? "",
                                  style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      color: const Color(0xff484848),
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 30,
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          // Surah list - takes remaining space (only one Expanded)
          Expanded(
            child:isHolyQuranChanged ? const Column(
              mainAxisAlignment:MainAxisAlignment.center,
              children: [
                Center(
                  child:CircularProgressIndicator(),
                )
              ],
            ): getFilteredSurahs(filteredName).isNotEmpty ? ListView.builder(
              padding: const EdgeInsets.only(bottom: 8.0),
              itemBuilder: (context, index) {
                return SuraItem(
                  suraDetails: getFilteredSurahs(filteredName)[index],
                  onAudioPlay: (int suraNumber) {
                    setState(() {
                      if (currentlyPlayingIndex == index) {
                        currentlyPlayingIndex = null;
                        isPlaying = false;
                      } else {
                        currentlyPlayingIndex = index;
                        pro.changeIndex(suraNumber - 1);
                        showRadio = true;
                        isPlaying = true;
                      }
                    });
                  },
                  isPlaying: currentlyPlayingIndex == index,
                );
              },
              itemCount: getFilteredSurahs(filteredName).length,
            ) : Center(
              child: Text(
                AppLocalizations.of(context)!.emptySurasData,
                style:GoogleFonts.cairo(
                  fontSize:25,
                  color:Colors.black
                ),
              ),
            ),
          ),

          // Audio player - fixed height (no Expanded)
          if (showRadio)
            SuraAudio(
              suraAudios: surahAudios,
              suraNumber: pro.index,
              isPlaying: isPlaying,
              onPause: (bool stat) {
                setState(() {
                  isPlaying = stat;
                  currentlyPlayingIndex = isPlaying ? pro.index : null;
                });
              },
              onTrackChanged: (int newIndex) {
                setState(() {
                  currentlyPlayingIndex = newIndex;
                  pro.changeIndex(newIndex);
                });
              },
            ),
        ],
      ),
    );
  }
}
