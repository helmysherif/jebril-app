import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/models/Subcategories.dart';
import 'package:jebril_app/providers/Audio_provider.dart';
import 'package:jebril_app/providers/langs_provider.dart';
import 'package:jebril_app/providers/sura_details_provider.dart';
import 'package:jebril_app/widgets/sura_item.dart';
import 'package:provider/provider.dart';
import '../models/AudioResponse.dart';
import '../network/audios.dart';
import '../providers/quran_data_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/sura_audio.dart';
import 'home.dart';

class Prayers extends StatefulWidget {
  static const String routeName = "prayers";

  const Prayers({super.key});

  @override
  State<Prayers> createState() => _PrayersState();
}

class _PrayersState extends State<Prayers> with SingleTickerProviderStateMixin {
  bool isLoading = false;
  bool isLoading2 = false;
  AudioResponse? prayersData;
  late TabController _tabController;
  late Subcategories currentSubcategory;
  List<Surah> audiosData = [];
  bool showRadio = false;
  bool isPlaying = false;
  int? currentlyPlayingIndex;
  Surah? currentAudio;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // audiosData = [];
    WidgetsBinding.instance.addPostFrameCallback((_){
      getPrayersData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  Future<void> loadTabData(int tabIndex) async {
    currentSubcategory = prayersData!.subcategories[tabIndex];
    List<String> prayersAudios = await GetAudiosApi.getPrayersAudiosNames(
        "prayers",
        currentSubcategory.id
    );
    setState(() {
      audiosData = prayersAudios.asMap().entries.map((entry) {
        final index = entry.key;  // This is the 0-based index
        final audioName = entry.value;
        String englishName = audioName;
        String arabicName = audioName;
        if (audioName.contains(' - ')) {
          var parts = audioName.split(' - ');
          englishName = parts[0];
          arabicName = parts[1].replaceAll('.mp3', '');
        } else {
          englishName = englishName.replaceAll('.mp3', '');
        }
        return Surah(
          audio: "https://radiojebril.net/sheikh_jebril_audios/sounds/prayers/${currentSubcategory.id}/${Uri.encodeComponent(audioName)}",
          englishName: englishName,
          arabicName: arabicName,
          number: index + 1,  // Using 1-based numbering
        );
      }).toList();
    });
  }
  Future<void> getPrayersData() async {
    try{
      setState(() {
        isLoading = true;
      });
      audiosData = [];
      QuranDataProvider quranDataProvider =
      Provider.of<QuranDataProvider>(context, listen: false);
      prayersData = quranDataProvider.getFilteredQuranData("prayers", 0);
      if (prayersData != null && prayersData!.subcategories.isNotEmpty) {
        _tabController = TabController(
          length: prayersData!.subcategories.length,
          vsync: this,
        );
        await loadTabData(_tabController.index);
      }
      _tabController.addListener(() async {
        if (_tabController.indexIsChanging) {
          setState(() {
            isLoading2 = true;
            showRadio = false;
            currentlyPlayingIndex = null;
            isPlaying = false;
            // AudioProvider audioProvider = Provider.of(context);
            // audioProvider.changeIsRadioPlaying(false);
            audiosData = []; // 👈 Clear it immediately to show the loader
          });
          await loadTabData(_tabController.index);
          setState(() {
            isLoading2 = false;
          });
        }
      });
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch(e){
      if (mounted) {
        setState(() => isLoading = false);
      }
      debugPrint("Error loading prayers data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    LangsProvider langsProvider = Provider.of<LangsProvider>(context);
    SuraDetailsProvider suraDetailsProvider = Provider.of<SuraDetailsProvider>(context);
    if (isLoading || prayersData == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
            langsProvider.language == 'en'
                ? prayersData!.enTitle ?? ""
                : prayersData!.arTitle ?? "",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
                fontSize: 23,
                color: const Color(0xff484848),
                fontWeight: FontWeight.w600),
            textScaler: const TextScaler.linear(1.0)),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_sharp, color: Color(0xff484848)),
          onPressed: () {
            audioProvider.changeIsRadioPlaying(false);
            Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(85),
          child: Container(
            color: Color(0xfff5f5f5),
            padding: EdgeInsets.all(20),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorPadding: EdgeInsets.zero,
              // labelPadding: EdgeInsets.zero,
              labelColor: Color(0xff014A43),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xff014A43),
              textScaler: const TextScaler.linear(1.0),
              dividerHeight: 2,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 2.0,
                  color: Color(0xff014A43), // Indicator color
                ),
                insets: EdgeInsets.zero,
                // borderRadius:BorderRadius.circular(10)
              ),
              labelStyle: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              tabs: prayersData!.subcategories.map((subcategory) {
                return Tab(
                  text: langsProvider.language == 'en'
                      ? subcategory.enTitle
                      : subcategory.arTitle,
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body:Column(
        children: [
          isLoading || prayersData == null ? Center(child: CircularProgressIndicator()) : prayersData!.subcategories.isEmpty ? Center(child: Text("No prayers found")) : Expanded(
            child: TabBarView(
              controller:_tabController,
              children: prayersData!.subcategories.map((subcategory) {
                if (isLoading2) {
                  return Center(child: CircularProgressIndicator());
                } else if (audiosData.length == 0) {
                  return Center(child: Text(
                    langsProvider.language == 'en' ? "No audio files found" : "لا يوجد بيانات لهذا الدعاء",
                    style:GoogleFonts.cairo(
                        fontSize:25
                    ),
                  ));
                } else {
                  return ListView.builder(
                    itemCount: audiosData.length,
                    itemBuilder: (context, index) {
                      return audiosData.length > 0 ? SuraItem(
                        suraDetails: audiosData[index],
                        isPrayer: true,
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
                              currentAudio = audiosData[currentlyPlayingIndex! - 1];
                              suraDetailsProvider.changeSuraNumber(suraNumber);
                              showRadio = true;
                              isPlaying = true;
                            }
                          });
                        },
                        isPlaying:currentlyPlayingIndex == audiosData[index].number && isPlaying && !audioProvider.isRadioPlaying,
                      ) : Container();
                    },
                  );
                }
              }).toList(),
            ),
          ),
          if (showRadio || audioProvider.isRadioPlaying)
            SuraAudio(
              suraAudios: audiosData,
              isPrayer : true,
              suraNumber: currentlyPlayingIndex != null
                  ? audiosData.indexWhere((s) => s.number == currentlyPlayingIndex) + 1
                  : 1,
              suraIndex: currentlyPlayingIndex ?? 0,
              isPlaying: isPlaying,
              rewayaName: currentAudio == null ? "" : langsProvider.language == 'en' ? currentAudio!.englishName : currentAudio!.arabicName,
              // rewayaName: langsProvider.language == 'en' ? prayersData!.subcategories[_tabController.index].enTitle : prayersData!.subcategories[_tabController.index].arTitle,
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
                    currentAudio = audiosData[currentlyPlayingIndex! - 1];
                    suraDetailsProvider.changeIndex(newIndex);
                  });
                }
              },
            )
        ],
      )
    );
  }
}
