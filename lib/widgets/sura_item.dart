import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/helpers/shared_prefs_helper.dart';
import 'package:jebril_app/providers/Audio_provider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/langs_provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class SuraItem extends StatefulWidget {
  final Surah suraDetails;
  final Function(int, String) onAudioPlay;
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
  double _downloadProgress = 0;
  bool _isDownloading = false;
  bool _isDownloaded = false;
  CancelToken? _cancelToken;

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
    _checkIfDownloaded();
  }
  @override
  void didUpdateWidget(SuraItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.suraDetails.number != widget.suraDetails.number) {
      _checkIfDownloaded(); // Check when widget updates with new sura
    }
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

  Future<void> _checkIfDownloaded() async {
    try{
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/سورة ${widget.suraDetails.arabicName} برواية ${widget.suraDetails.narrative}.mp3';
      final file = File(filePath);
      final exists = await file.exists();
      if (mounted) {
        setState(() {
          _isDownloaded = exists;
        });
      }
    }catch(e){
      debugPrint('Error checking download status: $e');
    }
  }

  Future<void> _playDownloadedAudio() async {
    if (!_isDownloaded) return;
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/surah_${widget.suraDetails.number}.mp3';
    AudioProvider audioProvider = Provider.of(context);
    try {
      await audioProvider.player.setFilePath(filePath);
      await audioProvider.player.play();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing downloaded file')),
      );
    }
  }

  Future<void> _deleteDownloadedAudio() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/surah_${widget.suraDetails.number}.mp3';
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      if (mounted) {
        setState(() {
          _isDownloaded = false;
        });
      }
    }
  }
  Future<void> _playAudio() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOffline = connectivityResult == ConnectivityResult.none;

    if (isOffline && _isDownloaded) {
      await _playDownloadedAudio();
    } else if (!isOffline) {
      widget.onAudioPlay(
          widget.suraDetails.number, widget.suraDetails.uniqueId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('No internet connection and no downloaded audio')),
      );
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await DeviceInfoPlugin()
              .androidInfo
              .then((info) => info.version.sdkInt) >=
          33) {
        var status = await Permission.audio.request();
        return status.isGranted;
      }
    }
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> _downloadSurahAudio() async {
    if (_isDownloading || _isDownloaded) return;
    // if (_isDownloading) {
    //   _cancelDownload();
    //   return;
    // }
    // if (_isDownloaded) {
    //   _showAlreadyDownloadedSnackbar();
    //   return;
    // }
    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      _showPermissionDeniedSnackbar();
      return;
    }
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });
    try {
      // _cancelToken = CancelToken();
      final dio = Dio();
      Directory directory = await getApplicationDocumentsDirectory();
      // if (Platform.isAndroid) {
      //   // Save to Downloads folder (visible in file manager)
      //   directory = Directory('/storage/emulated/0/Download/QuranAudio');
      //   if (!await directory.exists()) {
      //     await directory.create(recursive: true);
      //   }
      // } else {
      //   // For iOS, use documents directory (less accessible)
      //   directory = await getApplicationDocumentsDirectory();
      // }
      String savePath = '';
      if (widget.suraDetails.narrative != null) {
        savePath =
            '${directory.path}/سورة ${widget.suraDetails.arabicName} برواية ${widget.suraDetails.narrative}.mp3';
      } else {
        savePath = '${directory.path} ${widget.suraDetails.arabicName}.mp3';
      }
      await dio.download(
        widget.suraDetails.audio, // Replace with your actual audio URL
        savePath,
        // cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isDownloaded = true;
        });
      }
      _showDownloadCompleteSnackbar();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      _cancelToken = null;
    }
  }

  void _cancelDownload() {
    _cancelToken?.cancel();
    setState(() {
      _isDownloading = false;
      _downloadProgress = 0;
    });
  }

  String _getAudioUrl() {
    return widget.suraDetails.audio;
  }

  void _showDownloadCompleteSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download completed!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDownloadErrorSnackbar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download failed: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showPermissionDeniedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Storage permission required'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showAlreadyDownloadedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Surah already downloaded'),
        backgroundColor: Colors.blue,
      ),
    );
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
            if (!_isDownloaded)
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                    color: const Color(0xffF5F4F9),
                    borderRadius: BorderRadius.circular(25)),
                child: _isDownloading
                    ? CircularProgressIndicator(
                        value: _downloadProgress,
                        strokeWidth: 2,
                        color: Color(0xff00514A),
                      )
                    : IconButton(
                        icon: Icon(Icons.cloud_download_outlined),
                        iconSize: 21,
                        onPressed: _downloadSurahAudio,
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
                    widget.isPlaying ? Icons.pause : Icons.play_arrow_rounded),
                iconSize: 27,
                onPressed: _playAudio,
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
                  color: _isFavorite ? Color(0xff00514A) : null,
                ),
                iconSize: 21,
                onPressed: _toggleFavorite,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ));
  }
}
