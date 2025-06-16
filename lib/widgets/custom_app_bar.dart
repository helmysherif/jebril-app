import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/Audio_provider.dart';
import '../screens/home.dart';
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String label;
  final VoidCallback onPressed;
  final PreferredSizeWidget? bottom;
  const CustomAppBar({super.key , required this.label , required this.onPressed, this.bottom});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    AudioProvider audioProvider2 = Provider.of<AudioProvider>(context);
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      toolbarHeight: 100,
      title: Text(
        // "${audioProvider2.isRadioPlaying}",
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
              fontSize: 23,
              color: const Color(0xff484848),
              fontWeight: FontWeight.w600),
          textScaler: const TextScaler.linear(1.0)
      ),
      leading: IconButton(
        icon:
        const Icon(Icons.arrow_back_ios_sharp, color: Color(0xff484848)),
        onPressed: () {
          // audioProvider2.changeIsRadioPlaying(false);
          onPressed();
        },
      ),
      bottom: bottom
    );
  }
}
