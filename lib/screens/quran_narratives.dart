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
import '../providers/quran_data_provider.dart';
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
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    surahAudios = [];
    getNarrativesData(0);
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
      List<AudioResponse> response = quranDataProvider.allAudioResponses;
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
  getSearchInputValue(String text) {}
  @override
  Widget build(BuildContext context) {
    LangsProvider langProvider = Provider.of<LangsProvider>(context);
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
                                  ),
                                );
                              }).toList(),
                          onChanged: (Subcategories? sura) async {
                            if(sura != null){
                              setState(() {
                                isLoading = true;
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
            child: isLoading ? const Center(child: CircularProgressIndicator()) : surahAudios.isNotEmpty ? ListView.builder(
              itemBuilder:(context, index){
                return SuraItem(
                  suraDetails: surahAudios[index],
                  onAudioPlay: (int suraNumber) {
                    setState(() {});
                  },
                  isPlaying:false,
                );
              },
              itemCount:surahAudios.length,
            ) : Center(
              child: Text(
                AppLocalizations.of(context)!.emptySurasData,
                style:GoogleFonts.cairo(
                    fontSize:25,
                    color:Colors.black
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
