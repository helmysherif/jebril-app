import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/helpers/shared_prefs_helper.dart';
import 'package:jebril_app/providers/Audio_provider.dart';
import 'package:provider/provider.dart';

import '../providers/langs_provider.dart';

class SuraItem extends StatefulWidget {
  final Surah suraDetails;
  final Function(int) onAudioPlay;
  final Function(int)? addToFavorite;
  final bool isPlaying;
  final String? subTitle;
  final bool isPrayer;

  const SuraItem(
      {super.key,
      this.isPrayer = false,
      required this.isPlaying,
      required this.suraDetails,
      required this.onAudioPlay,
      this.subTitle,
      this.addToFavorite});

  @override
  State<SuraItem> createState() => _SuraItemState();
}

class _SuraItemState extends State<SuraItem> {
  bool _isFavorite = false;
  Future<void> _checkFavoriteStatus() async {
    final isFav = await SharedPreferenceHelper.isFavorite(widget.suraDetails);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }
  Future<void> _toggleFavorite() async {
    print("_isFavorite => $_isFavorite");
    if (_isFavorite) {
      await SharedPreferenceHelper.removeFavoriteSurah(widget.suraDetails);
    } else {
      await SharedPreferenceHelper.addFavoriteSurah(widget.suraDetails);
    }
    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    var pro = Provider.of<LangsProvider>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
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
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0A4D41), // Replace with the top color you picked
                    Color(0xAE145347),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text("${widget.suraDetails.number}",
                    style: GoogleFonts.amiri(
                        fontSize: 23,
                        color: const Color(0xffE7DB9D),
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                    textScaler: const TextScaler.linear(1.0)),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.subTitle != null
                    ? Text(widget.subTitle!,
                        style: GoogleFonts.cairo(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1.0))
                    : Container(),
                Text(
                    pro.language == 'en'
                        ? widget.suraDetails.englishName
                        : widget.suraDetails.arabicName,
                    // "${suraDetails.number}",
                    style: !widget.isPrayer
                        ? GoogleFonts.amiri(
                            fontSize: pro.language == 'en' ? 23 : 27,
                            fontWeight: FontWeight.w600)
                        : GoogleFonts.cairo(
                            fontSize: 18, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    textScaler: const TextScaler.linear(1.0))
              ],
            ),
            const Spacer(),
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                  color: const Color(0xffF5F4F9),
                  borderRadius: BorderRadius.circular(25)),
              child: IconButton(
                icon: const Icon(Icons.cloud_download_outlined),
                iconSize: 21,
                onPressed: () {},
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                  color: const Color(0xffF5F4F9),
                  borderRadius: BorderRadius.circular(25)),
              child: IconButton(
                icon: Icon(widget.isPlaying ? Icons.pause : Icons.play_arrow_rounded),
                iconSize: 27,
                onPressed: () {
                  // audioProvider.changeIsRadioPlaying(false);
                  widget.onAudioPlay(widget.suraDetails.number);
                },
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                  color: const Color(0xffF5F4F9),
                  borderRadius: BorderRadius.circular(25)),
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : null,
                ),
                iconSize: 21,
                onPressed:_toggleFavorite,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ));
  }
}
