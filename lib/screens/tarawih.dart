import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/helpers/helper_functions.dart';
import 'package:jebril_app/models/AudioResponse.dart';
import 'package:jebril_app/providers/Audio_provider.dart';
import 'package:jebril_app/providers/langs_provider.dart';
import 'package:jebril_app/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../Sura.dart';
import '../constants/sura_names.dart';
import '../models/Subcategories.dart';
import '../network/audios.dart';
import '../providers/quran_data_provider.dart';
import '../providers/sura_details_provider.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/sura_audio.dart';
import '../widgets/sura_item.dart';
import '../widgets/text_input_field.dart';
import 'home.dart';
class Tarawih extends StatefulWidget {
  static const String routeName = "tarawih";
  const Tarawih({super.key});
  @override
  State<Tarawih> createState() => _TarawihState();
}

class _TarawihState extends State<Tarawih> {
  late AudioResponse taraweehData;
  String filteredName = "";
  List<Subcategories> selectedData = [];
  bool showRadio = false;
  bool isPlaying = false;
  bool isHolyQuranChanged = false;
  int? currentlyPlayingIndex;
  bool isLoading = false;
  List<Surah> surahAudios = [];
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedData = [];
    getTarawihData();
  }
  getSearchInputValue(String text) {
    filteredName = text;
    setState(() {});
  }
  Future<void> getTarawihData() async {
    try {
      setState(() {
        isLoading = true;
      });
      QuranDataProvider quranDataProvider = Provider.of<QuranDataProvider>(context , listen:false);
      taraweehData = quranDataProvider.getFilteredQuranData("taraweeh", 0);
      selectedData = [taraweehData.subcategories.first];
      List<String> taraweehAudiosData = await GetAudiosApi.getNarrativeAudiosCount("taraweeh" , selectedData[0].id);
      taraweehAudiosData = HelperFunctions.extractNumbersFromFilenames(taraweehAudiosData);
      surahAudios = HelperFunctions.generateSurahAudioUrls("taraweeh" , taraweehAudiosData , selectedData[0].id);
      setState(() {
        isLoading = false;
      });
    } catch (e) { }
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
  void dispose() {
    _searchController.dispose();
    // final suraDetailsProvider = Provider.of<SuraDetailsProvider>(context, listen: false);
    // suraDetailsProvider.reset();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    LangsProvider langsProvider = Provider.of<LangsProvider>(context);
    SuraDetailsProvider suraDetailsProvider = Provider.of<SuraDetailsProvider>(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xfff5f5f5),
      // appBar:CustomAppBar(
      //   label:langsProvider.language == 'en' ? taraweehData.enTitle : taraweehData.arTitle,
      //     onPressed:(){
      //       Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      //     }
      // ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
                start: langsProvider.language == 'ar' ? 11 : 9,
                end: langsProvider.language == 'ar' ? 19 : 20,
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
                    child: CustomDropdown(
                      items:taraweehData.subcategories,
                      value:selectedData,
                      onPressed: (Subcategories sura)async{
                        setState(() {
                          isLoading = true;
                        });
                        setState(() {
                          isHolyQuranChanged = true;
                          // Close SuraAudio widget when changing recitation (non-radio)
                          if (!audioProvider.isRadioPlaying) {
                            showRadio = false;
                            isPlaying = false;
                            currentlyPlayingIndex = null;
                          }
                        });
                        await Future.delayed(const Duration(milliseconds: 300));
                        selectedData = [sura];
                        List<String> taraweehAudiosData = await GetAudiosApi.getNarrativeAudiosCount("taraweeh" , selectedData[0].id);
                        taraweehAudiosData = HelperFunctions.extractNumbersFromFilenames(taraweehAudiosData);
                        surahAudios = HelperFunctions.generateSurahAudioUrls("taraweeh" , taraweehAudiosData , selectedData[0].id);
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
          Expanded(
            child: isLoading ? const Center(child: CircularProgressIndicator()) : getFilteredSurahs(filteredName).isNotEmpty ? ListView.builder(
              itemBuilder:(context, index){
                return SuraItem(
                  suraDetails: getFilteredSurahs(filteredName)[index],
                  subTitle:"صلاة التراويح و القيام",
                  onAudioPlay: (int suraNumber) {
                    setState(() {
                      if (currentlyPlayingIndex == suraNumber) {
                        currentlyPlayingIndex = null;
                        isPlaying = false;
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
                rewayaName: langsProvider.language == 'en' ? selectedData[0].enTitle : selectedData[0].arTitle,
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
            )
        ],
      )
    );
  }
}
