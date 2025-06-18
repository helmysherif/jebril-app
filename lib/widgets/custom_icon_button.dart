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
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              color: const Color.fromRGBO(
                  255, 255, 255, 0.3),
              borderRadius: BorderRadius.circular(30)),
          child: IconButton(
            onPressed:onPressed,
            icon: Icon(
              icon,
              color: Colors.white,
              size: 19,
            ),
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500),
            textScaler: const TextScaler.linear(1.0)

        )
      ],
    );
  }
}
