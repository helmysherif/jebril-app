import 'package:flutter/material.dart';
import 'package:jebril_app/widgets/sura_item.dart';
import 'package:provider/provider.dart';
import '../Sura.dart';
import '../helpers/shared_prefs_helper.dart';
import '../providers/Audio_provider.dart';
import '../providers/sura_details_provider.dart';
import '../widgets/sura_audio.dart';
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
  int index = 0;
  @override
  Widget build(BuildContext context) {
    SuraDetailsProvider pro = Provider.of<SuraDetailsProvider>(context);
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xfff5f5f5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) :
      Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 15),
              itemCount: _favoriteSurahs.length,
              itemBuilder: (context, index) {
                final sura = _favoriteSurahs[index];
                index = index;
                return Dismissible(
                  key: Key(sura.number.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) => _removeFavorite(sura),
                  child: SuraItem(
                    key: ValueKey(sura.number), // Important for state management
                    suraDetails: sura,
                    isPlaying: currentlyPlayingIndex == sura.number && isPlaying,
                    onAudioPlay: (int suraNumber) {
                      setState(() {
                        if (currentlyPlayingIndex == suraNumber) {
                          currentlyPlayingIndex = null;
                          isPlaying = false;
                          // showRadio = false;
                        } else {
                          if (audioProvider.isRadioPlaying) {
                            audioProvider.pauseRadio();
                            audioProvider.wasRadioPlaying = false;
                          }
                          currentlyPlayingIndex = suraNumber;
                          pro.changeSuraNumber(suraNumber);
                          showRadio = true;
                          isPlaying = true;
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          if (showRadio && !audioProvider.isRadioPlaying)
            SizedBox(
              height: 180,
              child: SuraAudio(
                suraAudios: _favoriteSurahs,
                suraNumber: currentlyPlayingIndex != null
                    ? _favoriteSurahs.indexWhere((s) => s.number == currentlyPlayingIndex) + 1
                    : 1,
                suraIndex: currentlyPlayingIndex ?? 0,
                isPlaying: isPlaying,
                rewayaName:_favoriteSurahs[index].narrative ?? "",
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
