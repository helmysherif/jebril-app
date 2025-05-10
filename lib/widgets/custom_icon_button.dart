import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const CustomIconButton({super.key , required this.icon , required this.label , required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
              color: const Color.fromRGBO(
                  255, 255, 255, 0.3),
              borderRadius: BorderRadius.circular(30)),
          child: IconButton(
            onPressed:onPressed,
            icon: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.cairo(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}
