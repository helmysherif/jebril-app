import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/constants/sura_names.dart';
import 'package:jebril_app/helpers/helper_functions.dart';
import 'package:jebril_app/providers/Audio_provider.dart';
import 'package:jebril_app/providers/langs_provider.dart';
import 'package:jebril_app/providers/quran_data_provider.dart';
import 'package:jebril_app/providers/sura_details_provider.dart';
import 'package:jebril_app/screens/home.dart';
import 'package:jebril_app/widgets/custom_app_bar.dart';
import 'package:jebril_app/widgets/custom_dropdown.dart';
import 'package:jebril_app/widgets/sura_audio.dart';
import 'package:jebril_app/widgets/sura_item.dart';
import 'package:jebril_app/widgets/text_input_field.dart';
import 'package:path_provider/path_provider.dart';
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
  late AudioResponse wholeData;
  List<Surah> _offlineSurahs = [];
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool isOffline = false;
  String? suraUniqueName = "";
  Surah? clickedSura;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedQuran = [];
    wholeData =
        AudioResponse(arTitle: '', enTitle: '', subcategories: [], id: '');
    // getHollyQuranData(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    // Check initial status
    final initialStatus = await Connectivity().checkConnectivity();
    _updateConnectionStatus(initialStatus);

    // Listen for ongoing changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Handle empty result list
    if (results.isEmpty) {
      setState(() {
        isOffline = true;
      });
      _loadOfflineSurahs();
      return;
    }
    final isNowOffline = !results.any((result) =>
    result != ConnectivityResult.none);
    if (isNowOffline != isOffline) {
      setState(() {
        isOffline = isNowOffline;
        print("Network status changed. Offline: $isOffline");
      });
      print("isOffline => $isOffline");
      if (isNowOffline) {
        _loadOfflineSurahs();
      }
    }
  }
  Future<void> _loadOfflineSurahs() async {
    try {
      print("Loading offline surahs...");
      final downloaded = await HelperFunctions.getDownloadedSurahs();
      print("Downloaded surahs count: ${downloaded.length}");

      if (mounted) {
        setState(() {
          _offlineSurahs = downloaded;
          print("Offline surahs updated: ${_offlineSurahs.length}");
        });
      }
    } catch (e) {
      print("Error loading offline surahs: $e");
      if (mounted) {
        setState(() {
          _offlineSurahs = [];
        });
      }
    }
  }
  @override
  void dispose() {
    _searchController.dispose();
    _connectivitySubscription?.cancel();
    // final suraDetailsProvider = Provider.of<SuraDetailsProvider>(context, listen: false);
    // suraDetailsProvider.reset();
    super.dispose();
  }

  List<Surah> generateSurahAudioUrls(Subcategories quran, int numOfSuras) {
    List<Surah> surahs = [];

    for (int i = 0; i < numOfSuras; i++) {
      String surahNumber = (i + 1).toString().padLeft(3, '0');
      surahs.add(Surah(
          audio:
          'https://radiojebril.net/sheikh_jebril_audios/sounds/holy_quran/${quran
              .id}/$surahNumber.mp3',
          englishName: suraNamesData[i]["englishName"],
          arabicName: suraNamesData[i]["arabicName"],
          number: suraNamesData[i]["number"],
          narrative: quran.arTitle
      ));
    }
    return surahs;
  }

  Future<bool> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  getSearchInputValue(String text) {
    filteredName = text;
    setState(() {});
  }

  Future<List<Surah>> _getDownloadedSurahs() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = Directory(directory.path).listSync();

    List<Surah> downloadedSurahs = [];

    for (var file in files) {
      if (file.path.endsWith('.mp3')) {
        final fileName = file.path
            .split('/')
            .last;
        final matches = RegExp(r'surah_(\d+)_').firstMatch(fileName);
        if (matches != null) {
          final suraNumber = int.parse(matches.group(1)!);
              final sura = suraNamesData.firstWhere(
              (s)
          =>
          s["number"] == suraNumber
    ,
    orElse: () => {"englishName": "", "arabicName": "", "number": 0},
    );

    downloadedSurahs.add(Surah(
      audio: file.path,
      englishName: sura["englishName"],
      arabicName: sura["arabicName"],
      number: sura["number"],
      narrative: "محفوظة محلياً", // "Saved locally"
      isDownloaded: true,
    ));
    }
    }
    }

    return downloadedSurahs;
  }

  List<Surah> getFilteredSurahs(String searchText) {
    if (searchText.isEmpty) {
      return surahAudios;
    } else {
      return surahAudios.where((surah) {
        final englishMatch = surah.englishName.toLowerCase().contains(searchText.toLowerCase());
        final arabicMatch = surah.arabicName.contains(searchText);
        return englishMatch || arabicMatch;
      }).toList();
    }
  }



  Future<void> _initializeData() async {
    await getHollyQuranData(0);
    final provider = Provider.of<SuraDetailsProvider>(context, listen: false);
    provider.reset();
  }

  int holyQuranDataLength = 0;

  Future<void> getHollyQuranData(int index) async {
    setState(() => isLoading = true);
    try {
      QuranDataProvider quranDataProvider = Provider.of<QuranDataProvider>(
          context, listen: false);
      holyQuranData = quranDataProvider
          .getFilteredQuranData("holy_quran", 0)
          .subcategories;
      wholeData = quranDataProvider.getFilteredQuranData("holy_quran", 0);
      selectedQuran = [holyQuranData.first];
      var test = await GetAudiosApi.getNarrativeAudiosCount(
          "holy_quran", selectedQuran[0].id);
      holyQuranDataLength = test.length;
      setState(() {
        surahAudios =
            generateSurahAudioUrls(selectedQuran[0], holyQuranDataLength);
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
      // appBar: CustomAppBar(
      //   label:langProvider.language == 'en' ? wholeData.enTitle : wholeData.arTitle,
      //     onPressed:(){
      //       Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      //     }
      // ),
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
                          child: CustomDropdown(
                            items: holyQuranData,
                            value: selectedQuran,
                            onPressed: (Subcategories sura) async {
                              setState(() {
                                isHolyQuranChanged = true;
                                // Close SuraAudio widget when changing recitation (non-radio)
                                if (!audioProvider2.isRadioPlaying) {
                                  showRadio = false;
                                  isPlaying = false;
                                  currentlyPlayingIndex = null;
                                }
                              });
                              await Future.delayed(
                                  const Duration(milliseconds: 300));
                              var holyQuranDataLength = await GetAudiosApi
                                  .getNarrativeAudiosCount(
                                  "holy_quran", selectedQuran[0].id);
                              setState(() {
                                selectedQuran = [sura];
                                surahAudios = generateSurahAudioUrls(
                                    sura, holyQuranDataLength.length);
                                isHolyQuranChanged = false;
                              });
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // Surah list - takes remaining space (only one Expanded)
                Expanded(
                  child: isHolyQuranChanged || isLoading ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: CircularProgressIndicator(),
                      )
                    ],
                  ) : _buildContent(audioProvider2 , pro)
                ),
              ],
            ),
          ),
          if (showRadio)
            SizedBox(
              height: 180,
              child: SuraAudio(
                suraAudios: isOffline
                    ? _offlineSurahs
                    : surahAudios,
                suraNumber: pro.suraNumber,
                suraIndex: currentlyPlayingIndex ?? 0,
                isPlaying: isPlaying,
                isOffline: isOffline,
                uniqueId: suraUniqueName,
                rewayaName:selectedQuran.isNotEmpty ? selectedQuran[0].arTitle : "",
                isRadioPlaying: false,
                radioUrl: null,
                onPause: (bool stat) {
                  if (mounted) {
                    setState(() {
                      isPlaying = stat;
                    });
                  }
                },
                onTrackChanged: (int newIndex, int suraNumber , String uniqueName) {
                  if (mounted) {
                    setState(() {
                      isPlaying = true;
                      suraUniqueName = uniqueName;
                      currentlyPlayingIndex = newIndex;
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
  Widget _buildContent(AudioProvider audioProvider2, SuraDetailsProvider pro) {
    if (isOffline) {
      if (_offlineSurahs.isEmpty) {
        return Center(
          child: Text(
            'No downloaded surahs available offline',
            style: TextStyle(fontSize: 18),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 8.0),
        itemCount: _offlineSurahs.length,
        itemBuilder: (context, index) {
          final sura = _offlineSurahs[index];
          currentlyPlayingIndex = index;
          // suraUniqueName = sura.uniqueId;
          return SuraItem(
            suraDetails: sura,
              isOffline:isOffline,
            onAudioPlay: (int suraNumber, String uniqueName) {
              setState(() {
                if (suraUniqueName == uniqueName) {
                  isPlaying = !isPlaying;
                } else {
                  suraUniqueName = uniqueName;
                  isPlaying = true;
                  currentlyPlayingIndex = suraNumber;
                }

                if (audioProvider2.isRadioPlaying) {
                  audioProvider2.changeIsRadio(false);
                }

                pro.changeSuraNumber(suraNumber);
                showRadio = true;
              });
            },
            addToFavorite: (int index) {
              print("index => $index");
            },
            isPlaying: suraUniqueName == sura.uniqueId &&
                isPlaying &&
                !audioProvider2.isRadioPlaying,
          );
        },
      );
    } else {
      final filtered = getFilteredSurahs(filteredName);
      if (filtered.isEmpty) {
        return Center(
          child: Text('No surahs found'),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 8.0),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final sura = filtered[index];
          return SuraItem(
            suraDetails: sura,
            onAudioPlay: (int suraNumber, String uniqueName) {
              setState(() {
                if (suraUniqueName == uniqueName) {
                  isPlaying = !isPlaying;
                } else {
                  suraUniqueName = uniqueName;
                  isPlaying = true;
                  currentlyPlayingIndex = suraNumber;
                }

                if (audioProvider2.isRadioPlaying) {
                  audioProvider2.changeIsRadio(false);
                }

                pro.changeSuraNumber(suraNumber);
                showRadio = true;
              });
            },
            addToFavorite: (int index) {
              print("index => $index");
            },
            isPlaying: suraUniqueName == sura.uniqueId &&
                isPlaying &&
                !audioProvider2.isRadioPlaying,
          );
        },
      );
    }
  }
}
