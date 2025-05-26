import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/providers/Audio_provider.dart';
import 'package:provider/provider.dart';

import '../providers/langs_provider.dart';
class SuraItem extends StatelessWidget {
  final Surah suraDetails;
  final Function(int) onAudioPlay;
  final bool isPlaying;
  const SuraItem({super.key , required this.isPlaying , required this.suraDetails , required this.onAudioPlay});
  @override
  Widget build(BuildContext context) {
    var pro = Provider.of<LangsProvider>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    return Container(
      padding:const EdgeInsets.symmetric(horizontal:10 , vertical:15),
      margin:const EdgeInsets.symmetric(vertical:10 , horizontal:20),
        decoration: BoxDecoration(
          color:Colors.white,
          borderRadius:BorderRadius.circular(10),
          boxShadow:const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              spreadRadius: 0, // How far the shadow spreads
              blurRadius: 15, // How soft the shadow is
              offset: Offset(0, 5), // Changes position of shadow (x,y)
            )
          ],
        ),
      child: Row(
       children: [
         Container(
           width:45,
           height:45,
           decoration: BoxDecoration(
             gradient: const LinearGradient(
               colors: [
                 Color(0xFF0A4D41), // Replace with the top color you picked
                 Color(0xAE145347),
               ],
               begin: Alignment.topCenter,
               end: Alignment.bottomCenter,
             ),
             borderRadius:BorderRadius.circular(30),
           ),
           child: Padding(
             padding: const EdgeInsets.only(top:8),
             child: Text(
               "${suraDetails.number}",
               style:GoogleFonts.amiri(
                 fontSize:23,
                 color: const Color(0xffE7DB9D),
                 fontWeight:FontWeight.w500
               ),
               textAlign:TextAlign.center,
             ),
           ),
         ),
         const SizedBox(width:10),
         Text(
           pro.language == 'en' ? suraDetails.englishName : suraDetails.arabicName,
           // "${suraDetails.number}",
           style:GoogleFonts.amiri(
               fontSize:pro.language == 'en' ?23:27,
             fontWeight:FontWeight.w600
           ),
           textAlign:TextAlign.center,
         ),
         const Spacer(),
         Container(
           width:35,
           height:35,
           decoration:BoxDecoration(
             color: const Color(0xffF5F4F9),
             borderRadius:BorderRadius.circular(25)
           ),
           child: IconButton(
             icon: const Icon(Icons.cloud_download_outlined),
             iconSize:21,
             onPressed:(){},
             padding:EdgeInsets.zero,
           ),
         ),
         const SizedBox(width:10),
         Container(
           width:35,
           height:35,
           decoration:BoxDecoration(
               color:const Color(0xffF5F4F9),
               borderRadius:BorderRadius.circular(25)
           ),
           child: IconButton(
             icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow_rounded),
             iconSize:27,
             onPressed:(){
               audioProvider.changeIsRadioPlaying(false);
               onAudioPlay(suraDetails.number);
             },
             padding:EdgeInsets.zero,
           ),
         ),
         const SizedBox(width:10),
         Container(
           width:35,
           height:35,
           decoration:BoxDecoration(
               color:const Color(0xffF5F4F9),
               borderRadius:BorderRadius.circular(25)
           ),
           child: IconButton(
             icon: const Icon(Icons.favorite_border),
             iconSize:21,
             onPressed:(){},
             padding:EdgeInsets.zero,
           ),
         ),
       ],
      )
    );
  }
}
