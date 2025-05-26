import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/constants/sura_names.dart';
import 'package:jebril_app/providers/Audio_provider.dart';
import 'package:jebril_app/providers/langs_provider.dart';
import 'package:jebril_app/providers/quran_data_provider.dart';
import 'package:jebril_app/providers/sura_details_provider.dart';
import 'package:jebril_app/screens/home.dart';
import 'package:jebril_app/widgets/sura_audio.dart';
import 'package:jebril_app/widgets/sura_item.dart';
import 'package:jebril_app/widgets/text_input_field.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/AudioResponse.dart';
import '../models/Subcategories.dart';
import '../network/audios.dart';
import '../widgets/radio_widget.dart';

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
  List<Subcategories> selectedQuran = [];
  bool isLoading = true;
  List<Subcategories> holyQuranData = [];
  bool isHolyQuranChanged = false;
  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    final suraDetailsProvider = Provider.of<SuraDetailsProvider>(context, listen: false);
    suraDetailsProvider.reset();
    super.dispose();
  }
  List<Surah> generateSurahAudioUrls(String quranId , int numOfSuras) {
    List<Surah> surahs = [];
    for (int i = 0; i < numOfSuras; i++) {
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
    selectedQuran = [];
    getHollyQuranData(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SuraDetailsProvider>(context, listen: false);
      provider.reset();
    });
  }
  int holyQuranDataLength = 0;
  Future<void> getHollyQuranData(int index) async {
    setState(() => isLoading = true);
    try {
      QuranDataProvider quranDataProvider = Provider.of<QuranDataProvider>(context , listen:false);
      holyQuranData = quranDataProvider.getFilteredQuranData("holy_quran", 0);
      selectedQuran = [holyQuranData.first];
      var test = await GetAudiosApi.getHollyQuranAudiosCount(selectedQuran[0].id);
      holyQuranDataLength = test.length;
      setState(() {
        surahAudios = generateSurahAudioUrls(selectedQuran[0].id , holyQuranDataLength);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    SuraDetailsProvider pro = Provider.of<SuraDetailsProvider>(context);
    LangsProvider langProvider = Provider.of<LangsProvider>(context);
    AudioProvider audioProvider2 = Provider.of<AudioProvider>(context);
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
          // "${audioProvider2.isRadioPlaying}",
          "المصحف المرتل",
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
              fontSize: 23,
              color: const Color(0xff484848),
              fontWeight: FontWeight.w600),
            textScaler: const TextScaler.linear(1.0)
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_sharp, color: Color(0xff484848)),
          onPressed: () {
            // if (audioProvider2.isRadioPlaying) {
            //   audioProvider2.setKeepRadioPlaying(true);
            // }
            audioProvider2.changeIsRadioPlaying(false);
            // Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
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
                            value:selectedQuran.isNotEmpty ? selectedQuran[0] : null,
                            elevation: 0,
                            underline: const SizedBox.shrink(),
                            icon: const SizedBox.shrink(),
                            iconSize: 30,
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(10),
                            dropdownColor:Colors.white,
                            items: holyQuranData.map<DropdownMenuItem<Subcategories>>(
                                    (Subcategories value) {
                                  return DropdownMenuItem<Subcategories>(
                                    value: value,
                                    child: Text(
                                      langProvider.language == 'ar' ? value.arTitle : value.enTitle ?? "",
                                      style: GoogleFonts.cairo(
                                          fontSize: 15,
                                          color: const Color(0xff484848),
                                          fontWeight: FontWeight.w600),
                                        textScaler: const TextScaler.linear(1.0)
                                    ),
                                  );
                                }).toList(),
                            onChanged: (Subcategories? sura) async {
                              if(sura != null){
                                setState(() {
                                  isHolyQuranChanged = true;
                                  // Close SuraAudio widget when changing recitation (non-radio)
                                  if (!audioProvider2.isRadioPlaying) {
                                    showRadio = false;
                                    isPlaying = false;
                                    currentlyPlayingIndex = null;
                                  }
                                });
                                await Future.delayed(const Duration(milliseconds: 300));
                                var holyQuranDataLength = await GetAudiosApi.getHollyQuranAudiosCount(selectedQuran[0].id);
                                setState(() {
                                  selectedQuran = [sura];
                                  surahAudios = generateSurahAudioUrls(sura.id , holyQuranDataLength.length);
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
                                        langProvider.language == 'ar' ? value.arTitle : value.enTitle ?? "",
                                        style: GoogleFonts.cairo(
                                            fontSize: 18,
                                            color: const Color(0xff484848),
                                            fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                          textScaler: const TextScaler.linear(1.0)
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
                  child:isHolyQuranChanged || isLoading ? const Column(
                    mainAxisAlignment:MainAxisAlignment.center,
                    children: [
                      Center(
                        child:CircularProgressIndicator(),
                      )
                    ],
                  ): getFilteredSurahs(filteredName).isNotEmpty && !isLoading ? ListView.builder(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    itemBuilder: (context, index) {
                      return SuraItem(
                        suraDetails: getFilteredSurahs(filteredName)[index],
                        onAudioPlay: (int suraNumber) {
                          setState(() {
                            if (currentlyPlayingIndex == suraNumber) {
                              currentlyPlayingIndex = null;
                              isPlaying = false;
                              // showRadio = false;
                            } else {
                              if (audioProvider2.isRadioPlaying) {
                                audioProvider2.changeIsRadioPlaying(false);
                              }
                              currentlyPlayingIndex = suraNumber;
                              pro.changeIndex(suraNumber);
                              pro.changeSuraNumber(suraNumber);
                              showRadio = true;
                              isPlaying = true;
                            }
                          });
                        },
                        isPlaying: currentlyPlayingIndex == getFilteredSurahs(filteredName)[index].number && isPlaying && !audioProvider2.isRadioPlaying,
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
                        textScaler: const TextScaler.linear(1.0)
                    ),
                  ),
                ),

                // Audio player - fixed height (no Expanded)
                // if(audioProvider.isRadioPlaying && !showRadio)
                //   RadioWidget(suraAudios: audioProvider.radioAudio, type: "radio"),
              ],
            ),
          ),
          if (showRadio || audioProvider2.isRadioPlaying)
            SizedBox(
              height:180,
              child: SuraAudio(
                suraAudios: surahAudios,
                suraNumber: pro.index,
                suraIndex: currentlyPlayingIndex ?? 0,
                isPlaying: isPlaying,
                rewayaName: selectedQuran.isNotEmpty ? selectedQuran[0].arTitle : "",
                isRadioPlaying:audioProvider2.isRadioPlaying,
                radioUrl: audioProvider2.isRadioPlaying ? audioProvider2.radioAudio : null,
                onPause: (bool stat) {
                  if(mounted){
                    setState(() {
                      isPlaying = stat;
                      // currentlyPlayingIndex = pro.suraNumber;
                    });
                  }
                },
                onTrackChanged: (int newIndex , int suraNumber) {
                  if(mounted){
                    setState(() {
                      currentlyPlayingIndex = suraNumber;
                      pro.changeIndex(newIndex);
                    });
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
