import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/widgets/sura_item.dart';
import 'package:provider/provider.dart';
import '../Sura.dart';
import '../helpers/shared_prefs_helper.dart';
import '../providers/Audio_provider.dart';
import '../providers/sura_details_provider.dart';
import '../widgets/sura_audio.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class FavoriteScreen extends StatefulWidget {
  static const String routeName = "favorite";
  const FavoriteScreen({super.key});
  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}
class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Surah> _favoriteSurahs = [];
  bool _isLoading = true;
  bool showRadio = false;
  int? currentlyPlayingIndex;
  bool isPlaying = false;
  String? currentlyPlayingId;
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }
  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favorites = await SharedPreferenceHelper.getFavoriteSurahs();
    if (mounted) {
      setState(() {
        _favoriteSurahs = favorites;
        _isLoading = false;
      });
    }
  }
  Future<void> _removeFavorite(Surah sura) async {
    await SharedPreferenceHelper.removeFavoriteSurah(sura);
    await _loadFavorites(); // Refresh the list
  }
  int suraIndex = 0;
  @override
  Widget build(BuildContext context) {
    SuraDetailsProvider pro = Provider.of<SuraDetailsProvider>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xfff5f5f5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) :
      Column(
        children: [
          Expanded(
            child: _favoriteSurahs.length == 0 ? Center(
              child:Text(
                localizations.emptyFavorite,
                style:GoogleFonts.cairo(
                  fontSize: 25,
                  fontWeight:FontWeight.w500
                ),
              ),
            ) : ListView.builder(
              padding: const EdgeInsets.only(top: 15),
              itemCount: _favoriteSurahs.length,
              itemBuilder: (context, index) {
                final sura = _favoriteSurahs[index];
                return SuraItem(
                  suraDetails: sura,
                  isPlaying: currentlyPlayingId == _favoriteSurahs[index].uniqueId && isPlaying && !audioProvider.isRadioPlaying,
                  onAudioPlay: (int suraNumber , String suraUniqueId) {
                    setState(() {
                      suraIndex = index;
                    });
                    setState(() {
                      if (currentlyPlayingId == suraUniqueId) {
                        currentlyPlayingIndex = null;
                        currentlyPlayingId = null;
                        isPlaying = false;
                        // showRadio = false;
                      } else {
                        if (audioProvider.isRadioPlaying) {
                          audioProvider.pauseRadio();
                          audioProvider.wasRadioPlaying = false;
                        }
                        currentlyPlayingId = suraUniqueId;
                        currentlyPlayingIndex = suraNumber;
                        // pro.changeSuraNumber(suraNumber);
                        showRadio = true;
                        isPlaying = true;
                      }
                    });
                  },
                  subTitle: sura.narrative,
                );
              },
            ),
          ),
          if (showRadio && !audioProvider.isRadioPlaying)
            SizedBox(
              height: 180,
              child: SuraAudio(
                suraAudios: _favoriteSurahs,
                isFavorite:true,
                uniqueId:currentlyPlayingId,
                suraNumber: currentlyPlayingIndex != null
                    ? _favoriteSurahs.indexWhere((s) => s.number == currentlyPlayingIndex) + 1
                    : 1,
                suraIndex: currentlyPlayingIndex ?? 0,
                isPlaying: isPlaying,
                rewayaName:_favoriteSurahs[suraIndex].narrative ?? "",
                isRadioPlaying:audioProvider.isRadioPlaying,
                onPause: (bool stat) {
                  if(mounted){
                    setState(() {
                      isPlaying = stat;
                      // currentlyPlayingIndex = suraDetailsProvider.suraNumber;
                    });
                  }
                },
                onTrackChanged: (int newIndex , int suraNumber) {
                  if(mounted){
                    setState(() {
                      currentlyPlayingIndex = suraNumber;
                      suraIndex = newIndex - 1;
                      currentlyPlayingId = _favoriteSurahs[newIndex - 1].uniqueId;
                      pro.changeIndex(newIndex);
                    });
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
