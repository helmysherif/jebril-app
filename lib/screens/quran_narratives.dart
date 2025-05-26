import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/network/audios.dart';
import 'package:jebril_app/providers/langs_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants/sura_names.dart';
import '../models/AudioResponse.dart';
import '../models/Subcategories.dart';
import '../providers/Audio_provider.dart';
import '../providers/quran_data_provider.dart';
import '../providers/sura_details_provider.dart';
import '../widgets/sura_audio.dart';
import '../widgets/sura_item.dart';
import '../widgets/text_input_field.dart';
import 'home.dart';
class QuranNarratives extends StatefulWidget {
  static const String routeName = "narratives";
  const QuranNarratives({super.key});
  @override
  State<QuranNarratives> createState() => _QuranNarrativesState();
}
class _QuranNarrativesState extends State<QuranNarratives> {
  List<Subcategories> quranNarratives = [];
  List<Subcategories> selectedQuranNarratives = [];
  List<Surah> surahAudios = [];
  bool showRadio = false;
  int currentSuraNumber = 0;
  int? currentlyPlayingIndex;
  bool isPlaying = false;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    surahAudios = [];
    isPlaying = false;
    getNarrativesData(0);
    currentlyPlayingIndex = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SuraDetailsProvider>(context, listen: false);
      provider.reset();
    });
  }
  bool isLoading = false;
  List<String> extractNumbersFromFilenames(List<String> filenames) {
    final RegExp numberRegExp = RegExp(r'(\d+)\.mp3$');
    return filenames
        .map((filename) {
      final match = numberRegExp.firstMatch(filename);
      return match?.group(1); // Returns the matched digits as string
    })
        .whereType<String>() // Filters out null values
        .toList();
  }
  Future<void> getNarrativesData(int index) async {
    setState(() {
      isLoading = true;
    });
      QuranDataProvider quranDataProvider = Provider.of<QuranDataProvider>(context , listen:false);
      quranNarratives = quranDataProvider.getFilteredQuranData("quran_narratives", 0);
      selectedQuranNarratives = [quranNarratives[index]];
      List<String> narratives = await GetAudiosApi.getNarrativeAudiosCount(quranNarratives[index].id);
      narratives = extractNumbersFromFilenames(narratives);
      surahAudios = generateSurahAudioUrls(narratives);
      setState(() {isLoading = false;});
  }
  List<Surah> generateSurahAudioUrls(List<String> narratives) {
    List<Surah> surahs = [];
    if(narratives.isNotEmpty){
      for(int i = 0;i < narratives.length;i++){
        final narrativeNumber = int.tryParse(narratives[i]) ?? 0;
        final suraData = suraNamesData.firstWhere(
              (sura) => sura["number"] == narrativeNumber,
          orElse: () => {
            "number": narrativeNumber,
            "englishName": "Unknown",
            "arabicName": "غير معروف"
          },
        );
        surahs.add(Surah(
          audio:
          'https://radiojebril.net/sheikh_jebril_audios/sounds/quran_narratives/${selectedQuranNarratives[0].id}/${narratives[i]}.mp3',
          englishName: suraData["englishName"],
          arabicName: suraData["arabicName"],
          number: suraData["number"],
        ));
      }
    }
    return surahs;
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
  String filteredName = "";
  getSearchInputValue(String text) {
    filteredName = text;
    setState(() {});
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();final suraDetailsProvider = Provider.of<SuraDetailsProvider>(context, listen: false);
    suraDetailsProvider.reset();
    _searchController.dispose(); // If you have controllers
  }
  int clickedSuraNumber = 0;
  @override
  Widget build(BuildContext context) {
    LangsProvider langProvider = Provider.of<LangsProvider>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    SuraDetailsProvider suraDetailsProvider = Provider.of<SuraDetailsProvider>(context);
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
            "الروايات المتواترة",
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
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            },
          ),
        ),
      body:Column(
        children: [
          Column(
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
                          _searchController),
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
                          value:selectedQuranNarratives.isNotEmpty ? selectedQuranNarratives[0] : null,
                          elevation: 0,
                          underline: const SizedBox.shrink(),
                          icon: const SizedBox.shrink(),
                          iconSize: 30,
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(10),
                          dropdownColor:Colors.white,
                          items: quranNarratives.map<DropdownMenuItem<Subcategories>>(
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
                                isLoading = true;
                                if (!audioProvider.isRadioPlaying) {
                                  showRadio = false;
                                  isPlaying = false;
                                  currentlyPlayingIndex = null;
                                }
                              });
                              surahAudios = [];
                              selectedQuranNarratives = [sura];
                              List<String> narratives = await GetAudiosApi.getNarrativeAudiosCount(selectedQuranNarratives[0].id);
                              narratives = extractNumbersFromFilenames(narratives);
                              surahAudios = generateSurahAudioUrls(narratives);
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          selectedItemBuilder: (BuildContext context) {
                            return quranNarratives.map((Subcategories value) {
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
            ],
          ),
          Expanded(
            child: isLoading ? const Center(child: CircularProgressIndicator()) : getFilteredSurahs(filteredName).isNotEmpty ? ListView.builder(
              itemBuilder:(context, index){
                return SuraItem(
                  suraDetails: getFilteredSurahs(filteredName)[index],
                  onAudioPlay: (int suraNumber) {
                    setState(() {
                      if (currentlyPlayingIndex == suraNumber) {
                        currentlyPlayingIndex = null;
                        isPlaying = false;
                        // showRadio = false;
                      } else {
                        // if (audioProvider.isRadioPlaying) {
                        //   audioProvider.changeIsRadioPlaying(false);
                        // }
                        currentlyPlayingIndex = suraNumber;
                        suraDetailsProvider.changeSuraNumber(suraNumber);
                        showRadio = true;
                        isPlaying = true;
                      }
                    });
                  },
                  isPlaying:currentlyPlayingIndex == getFilteredSurahs(filteredName)[index].number && isPlaying && !audioProvider.isRadioPlaying,
                );
              },
              itemCount:getFilteredSurahs(filteredName).length,
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
          // Text("${suraDetailsProvider.suraNumber}" , style:TextStyle(fontSize:30)),
          if (showRadio || audioProvider.isRadioPlaying)
            SizedBox(
              height:180,
              child: SuraAudio(
                suraAudios: surahAudios,
                suraNumber: currentlyPlayingIndex != null
                    ? surahAudios.indexWhere((s) => s.number == currentlyPlayingIndex) + 1
                    : 1,
                suraIndex: currentlyPlayingIndex ?? 0,
                isPlaying: isPlaying,
                rewayaName: langProvider.language == 'en' ? selectedQuranNarratives[0].enTitle : selectedQuranNarratives[0].arTitle,
                isRadioPlaying:audioProvider.isRadioPlaying,
                radioUrl: audioProvider.isRadioPlaying ? audioProvider.radioAudio : null,
                onPause: (bool stat) {
                  if(mounted){
                    setState(() {
                      isPlaying = stat;
                      // currentlyPlayingIndex = suraDetailsProvider.suraNumber;
                    });
                  }
                },
                onTrackChanged: (int newIndex , int suraNumber) {
                  if(mounted){
                    setState(() {
                      currentlyPlayingIndex = suraNumber;
                      suraDetailsProvider.changeIndex(newIndex);
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
