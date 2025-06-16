import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/providers/Audio_provider.dart';
import 'package:jebril_app/providers/langs_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../Sura.dart';
import '../models/AudioResponse.dart';
import '../network/audios.dart';
import '../providers/quran_data_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/radio_widget.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final bool isHomeScreen;
  final String type;
  final bool hideAppBar;
  final bool showTaps;
  const MainLayout({super.key, required this.child, this.isHomeScreen = false , required this.type , this.hideAppBar = false , this.showTaps = false});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool isLoading = false;
  String appBarTitle = "";
  Future<void> getAllAudiosData()async{
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      QuranDataProvider quranDataProvider = Provider.of<QuranDataProvider>(context, listen: false);
      List<AudioResponse> response = await GetAudiosApi.getAudios();
      if (response.isEmpty) {
        throw Exception("Empty response");
      }
      quranDataProvider.setData(response);
    } catch (e) {
      print("error => $e");
      Fluttertoast.showToast(
        msg: "Internal Server Error",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
  @override
  void initState() {
    super.initState();
    getAllAudiosData();
  }
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    LangsProvider langsProvider = Provider.of(context);
    final List<String> languages = ['English', 'عربي'];
    final audioProvider = Provider.of<AudioProvider>(context);
    final quranDataProvider = Provider.of<QuranDataProvider>(context, listen: false);
    AudioResponse holyQuranData = quranDataProvider.getFilteredQuranData("holy_quran", 0);
    AudioResponse narrativeData = quranDataProvider.getFilteredQuranData("quran_narratives", 0);
    AudioResponse prayersData = quranDataProvider.getFilteredQuranData("prayers", 0);
    AudioResponse tarawihData = quranDataProvider.getFilteredQuranData("taraweeh", 0);
    if(langsProvider.language == "en"){
      if(widget.type == "quran"){
        appBarTitle = holyQuranData.enTitle;
      } else if(widget.type == "narratives"){
        appBarTitle = narrativeData.enTitle;
      } else if(widget.type == "tarawih"){
        appBarTitle = tarawihData.enTitle;
      } else if(widget.type == "prayers"){
        appBarTitle = prayersData.enTitle;
      } else if(widget.type == "more"){
        appBarTitle = localizations.more;
      } else if(widget.type == "media"){
        appBarTitle = localizations.socialMedia;
      } else if(widget.type == "info"){
        appBarTitle = localizations.sheikhInfo;
      } else if(widget.type == "favorite"){
        appBarTitle = localizations.favorite;
      }
    }
    else {
      if(widget.type == "quran"){
        appBarTitle = holyQuranData.arTitle;
      } else if(widget.type == "narratives"){
        appBarTitle = narrativeData.arTitle;
      } else if(widget.type == "tarawih"){
        appBarTitle = tarawihData.arTitle;
      } else if(widget.type == "prayers"){
        appBarTitle = prayersData.arTitle;
      } else if(widget.type == "more"){
        appBarTitle = localizations.more;
      } else if(widget.type == "media"){
        appBarTitle = localizations.socialMedia;
      } else if(widget.type == "info"){
        appBarTitle = localizations.sheikhInfo;
      }else if(widget.type == "favorite"){
        appBarTitle = localizations.favorite;
      }
    }
    return isLoading ? Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    ) :  Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: widget.isHomeScreen || widget.hideAppBar
          ? null
          : CustomAppBar(
              label: appBarTitle,
              onPressed: () {
                Navigator.of(context).pop();
              },

      ),
      body:  Column(
        children: [
          if (widget.isHomeScreen)
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
                              fontSize: 18, fontWeight: FontWeight.w600),
                          textScaler: const TextScaler.linear(1.0)),
                      const SizedBox(width: 10),
                    ],
                  ),
                  DropdownButton<String>(
                    value: langsProvider.language == 'en' ? 'English' : 'عربي',
                    elevation: 0,
                    underline: const SizedBox.shrink(),
                    icon: const SizedBox.shrink(),
                    iconSize: 30,
                    items:
                        languages.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? lang) {
                      if (lang != null) {
                        if (lang == 'English') {
                          langsProvider.changeLanguage("en");
                        } else {
                          langsProvider.changeLanguage("ar");
                        }
                      }
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return languages.map((String value) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 4),
                            Text(value,
                                style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    color: const Color(0xff484848),
                                    fontWeight: FontWeight.w600),
                                textScaler: const TextScaler.linear(1.0)),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ),
          // Main content area (will change with navigation)
           if (widget.isHomeScreen)
             Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 30, top: 20),
                child: RadioWidget(type: "radio")),
          Expanded(child: widget.child),
          if (!widget.isHomeScreen &&
              (audioProvider.isRadioPlaying || audioProvider.wasRadioPlaying))
            RadioWidget(type: "radio", inNotHomeScreen: true),
        ],
      ),
    );
  }
}
