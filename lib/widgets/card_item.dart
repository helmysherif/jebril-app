import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
class CardItem extends StatelessWidget {
  final String image;
  final String label;
  final Function(int) onPressed;
  final int id;
  const CardItem({super.key , required this.onPressed , required this.label , required this.image , required this.id});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:() => onPressed(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal:10 , vertical:0),
        decoration: BoxDecoration(
          color:Colors.white,
          borderRadius:BorderRadius.circular(15),
          boxShadow:const [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 0, // How far the shadow spreads
              blurRadius: 15, // How soft the shadow is
              offset: Offset(0, 5), // Changes position of shadow (x,y)
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              image,
              height:50,
              // width: 50,
              // fit: BoxFit.cover,
              semanticsLabel: 'App Logo',
            ),
            // Image.asset(image , width:100,height:70),
            const SizedBox(height:20),
            Text(label , style:GoogleFonts.cairo(
              fontSize:17,
              fontWeight: FontWeight.w600,
              color: const Color(0xff606060)
            ),textAlign:TextAlign.center,
              textScaler: const TextScaler.linear(1.0),
            )
          ],
        ),
      ),
    );
  }
}
