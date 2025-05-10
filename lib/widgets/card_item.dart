import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class CardItem extends StatelessWidget {
  final String image;
  final String label;
  final VoidCallback onPressed;
  const CardItem({super.key , required this.onPressed , required this.label , required this.image});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:onPressed,
      child: Container(
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
            Image.asset(image , width:100,height:70),
            const SizedBox(height:20),
            Text(label , style:GoogleFonts.cairo(
              fontSize:22,
              fontWeight: FontWeight.w600,
              color: const Color(0xff606060)
            ))
          ],
        ),
      ),
    );
  }
}
