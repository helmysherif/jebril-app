import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/helpers/helper_functions.dart';
import 'package:jebril_app/network/audios.dart';
import 'package:jebril_app/providers/langs_provider.dart';
import 'package:jebril_app/widgets/custom_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants/sura_names.dart';
import '../models/AudioResponse.dart';
import '../models/Subcategories.dart';
import '../providers/Audio_provider.dart';
import '../providers/quran_data_provider.dart';
import '../providers/sura_details_provider.dart';
import '../widgets/custom_app_bar.dart';
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
  late AudioResponse wholeData;
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
  Future<void> getNarrativesData(int index) async {
    setState(() {
      isLoading = true;
    });
      QuranDataProvider quranDataProvider = Provider.of<QuranDataProvider>(context , listen:false);
      quranNarratives = quranDataProvider.getFilteredQuranData("quran_narratives", 0).subcategories;
    wholeData = quranDataProvider.getFilteredQuranData("quran_narratives", 0);
      selectedQuranNarratives = [quranNarratives[index]];
      List<String> narratives = await GetAudiosApi.getNarrativeAudiosCount("quran_narratives" , quranNarratives[index].id);
      narratives = HelperFunctions.extractNumbersFromFilenames(narratives);
      surahAudios = HelperFunctions.generateSurahAudioUrls("quran_narratives" , narratives , selectedQuranNarratives[0]);
      setState(() {isLoading = false;});
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
    super.dispose();
    // final suraDetailsProvider = Provider.of<SuraDetailsProvider>(context, listen: false);
    // suraDetailsProvider.reset();
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
      // appBar:CustomAppBar(
      //   label:langProvider.language == 'en' ? wholeData.enTitle : wholeData.arTitle,
      //     onPressed:(){
      //       Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      //     }
      // ),
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
                        child: CustomDropdown(
                          items: quranNarratives,
                          value: selectedQuranNarratives,
                          onPressed:(Subcategories narrative)async{
                            setState(() {
                              isLoading = true;
                              if (!audioProvider.isRadioPlaying) {
                                showRadio = false;
                                isPlaying = false;
                                currentlyPlayingIndex = null;
                              }
                            });
                            surahAudios = [];
                            selectedQuranNarratives = [narrative];
                            List<String> narratives = await GetAudiosApi.getNarrativeAudiosCount("quran_narratives" , selectedQuranNarratives[0].id);
                            narratives = HelperFunctions.extractNumbersFromFilenames(narratives);
                            surahAudios = HelperFunctions.generateSurahAudioUrls("quran_narratives" , narratives , selectedQuranNarratives[0]);
                            setState(() {
                              isLoading = false;
                            });
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
                  onAudioPlay: (int suraNumber , String uniqueName) {
                    setState(() {
                      if (currentlyPlayingIndex == suraNumber) {
                        currentlyPlayingIndex = null;
                        isPlaying = false;
                        // showRadio = false;
                      } else {
                        if (audioProvider.isRadioPlaying) {
                          audioProvider.pauseRadio();
                          audioProvider.wasRadioPlaying = false;
                        }
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
          if (showRadio && !audioProvider.isRadioPlaying)
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
