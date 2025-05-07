import 'package:flutter/material.dart';
import 'package:jebril_app/providers/langs_provider.dart';
import 'package:jebril_app/widgets/quran_radio_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  static const String routeName = "home";
  final String selectedLanguage = 'عربي';
  final List<String> languages = ['English', 'عربي'];
  onLanguageSelected(lang){

  }
  @override
  Widget build(BuildContext context) {
    var pro = Provider.of<LangsProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              height:80,
              padding:const EdgeInsets.symmetric(horizontal:20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset("assets/images/logo2.png" , width:60),
                      const SizedBox(width:10),
                      Text(AppLocalizations.of(context)!.name ,
                          style:GoogleFonts.cairo(
                          fontSize:18,
                          fontWeight:FontWeight.w600
                      )),
                      const SizedBox(width:10),
                    ],
                  ),
                  DropdownButton<String>(
                    value:pro.language == 'en' ? 'English' : 'عربي',
                    elevation: 0,
                    underline: const SizedBox.shrink(),
                    icon: const SizedBox.shrink(),
                    iconSize:30,
                    items:languages.map<DropdownMenuItem<String>>((String value){
                      return DropdownMenuItem<String>(
                        value:value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged:(String? lang) {
                      if(lang != null){
                        if(lang == 'English'){
                          pro.changeLanguage("en");
                        } else {
                          pro.changeLanguage("ar");
                        }
                      }
                    },
                    selectedItemBuilder:(BuildContext context){
                      return languages.map((String value) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 4),
                            Text(
                              value,
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                color:const Color(0xff484848),
                                fontWeight:FontWeight.w600
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:25),
              child: QuranRadioWidget(suraAudios:const [
                "https://backup.qurango.net/radio/mohammed_jibreel"
              ] , type:"radio"),
              // child: QuranRadioWidget(suraAudios:const [
              //   "https://server8.mp3quran.net/jbrl/001.mp3",
              //   "https://server8.mp3quran.net/jbrl/002.mp3",
              //   "https://server8.mp3quran.net/jbrl/003.mp3"
              // ] , type:"radio"),
            )
          ],
        ),
      )
    );
  }
}
