import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jebril_app/screens/more.dart';

import '../widgets/custom_app_bar.dart';
class SocialMediaScreen extends StatelessWidget {
  static const String routeName = "social-media";
  const SocialMediaScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
        extendBody: true,
        backgroundColor: const Color(0xfff5f5f5),
        appBar:CustomAppBar(
          label:localizations.socialMedia,
          onPressed:(){
            Navigator.of(context).pushReplacementNamed(More.routeName);
          }
       ),
      body: Container(
        padding:EdgeInsets.all(20),
        margin:EdgeInsets.all(20),
        width: double.infinity,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("data")
          ],
        ),
      ),
    );
  }
}
