import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jebril_app/screens/Sheikh_info_screen.dart';
import 'package:jebril_app/screens/social_media_screen.dart';
import '../widgets/custom_app_bar.dart';
import 'home.dart';
class More extends StatelessWidget {
  static const String routeName = "more";
  const More({super.key});
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xfff5f5f5),
      appBar:CustomAppBar(
         label:localizations.more,
         onPressed:(){
           Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
         }
      ),
      body:Padding(
        padding:EdgeInsets.all(20),
        child:Column(
          children: [
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap:(){
                Navigator.of(context).pushReplacementNamed(SocialMediaScreen.routeName);
              },
              child: Container(
                padding:EdgeInsets.all(20),
                decoration:BoxDecoration(
                  color:Colors.white,
                  borderRadius:BorderRadius.circular(15),
                    boxShadow:const [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 0, // How far the shadow spreads
                        blurRadius: 15, // How soft the shadow is
                        offset: Offset(0, 5), // Changes position of shadow (x,y)
                      )
                    ]
                ),
                child:Row(
                  children: [
                    Image.asset("assets/images/social-links.png"),
                    const SizedBox(width:15),
                    Text(
                      localizations.socialMedia,
                      style:GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight:FontWeight.bold,
                        color:Color(0xff484848)
                      ),
                        textScaler: const TextScaler.linear(1.0)
                    ),
                    const Spacer(),
                    Container(
                      padding:EdgeInsets.all(5),
                      decoration:BoxDecoration(
                        color: Color(0xfff5f4f9),
                        borderRadius:BorderRadius.circular(20)
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color:Color(0xff8e8e93),
                        size: 22,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height:20),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap:(){
                Navigator.of(context).pushReplacementNamed(SheikhInfoScreen.routeName);
              },
              child: Container(
                padding:EdgeInsets.all(20),
                decoration:BoxDecoration(
                    color:Colors.white,
                    borderRadius:BorderRadius.circular(15),
                    boxShadow:const [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 0, // How far the shadow spreads
                        blurRadius: 15, // How soft the shadow is
                        offset: Offset(0, 5), // Changes position of shadow (x,y)
                      )
                    ]
                ),
                child:Row(
                  children: [
                    Image.asset("assets/images/about.png"),
                    const SizedBox(width:15),
                    Text(
                      localizations.info,
                      style:GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight:FontWeight.bold,
                          color:Color(0xff484848)
                      ),
                        textScaler: const TextScaler.linear(1.0)
                    ),
                    const Spacer(),
                    Container(
                      padding:EdgeInsets.all(5),
                      decoration:BoxDecoration(
                          color: Color(0xfff5f4f9),
                          borderRadius:BorderRadius.circular(20)
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color:Color(0xff8e8e93),
                        size: 22,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
