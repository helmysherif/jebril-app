import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/Sura.dart';
import 'package:jebril_app/helpers/shared_prefs_helper.dart';
import 'package:jebril_app/providers/Audio_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized/synchronized.dart';
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
  final bool isOffline;
  const SuraItem(
      {super.key,
      this.isPrayer = false,
      required this.isPlaying,
      required this.suraDetails,
      required this.onAudioPlay,
      this.subTitle,
        this.isOffline = false,
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
  int _resumePosition = 0;
  bool _isDownloadPaused = false;
  final AudioPlayer player = AudioPlayer();
  final _fileLock = Lock();
  final _downloadLock = Lock();
  int _downloadedBytes = 0; // Track downloaded bytes
  File? _downloadFile;
  RandomAccessFile? _raf;
  StreamSubscription<List<int>>? _downloadSubscription;
  int _totalBytes = 0;
  bool _shouldPause = false;
  Completer<void>? _pauseCompleter;
  bool _shouldCancel = false;
  bool _isResuming = false;
  Future<void> _checkFavoriteStatus() async {
    final isFav = await SharedPreferenceHelper.isFavorite(widget.suraDetails);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }
  @override
  void dispose() {
    _downloadSubscription?.cancel();
    _cancelToken?.cancel();
    _raf?.close();
    player.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _loadDownloadStatus();
    WidgetsFlutterBinding.ensureInitialized();
    // await cleanUpTempFiles();
  }
  Future<void> cleanUpTempFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = Directory(directory.path).listSync();

      for (var file in files) {
        if (file is File && file.path.contains('temp_')) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error cleaning temp files: $e');
    }
  }
  @override
  void didUpdateWidget(SuraItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.suraDetails.number != widget.suraDetails.number) {
      _checkIfDownloaded(); // Check when widget updates with new sura
    }
  }
  Future<void> _loadDownloadStatus() async {
    final isDownloaded = await SharedPreferenceHelper.getDownloadStatus(widget.suraDetails);
    if (mounted) {
      setState(() {
        widget.suraDetails.isDownloaded = isDownloaded;
        // Reset progress if not downloaded
        if (!isDownloaded) _downloadProgress = 0;
      });
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
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = generateFilePath(directory);

      final file = File(filePath);
      final exists = await file.exists();
      final fileSize = exists ? await file.length() : 0;
      const minimumExpectedSize = 100000;
      final isComplete = exists && fileSize > minimumExpectedSize;

      // final isComplete = exists && fileSize > minimumExpectedSize;
      // final isComplete = exists && // true
      //     fileSize > 0 && // true
      //     !_isDownloading && // true
      //     (_downloadProgress >= 1.0 || // false
      //         (_totalBytes > 0 && fileSize >= _totalBytes) || // false
      //         fileSize > 100000);
      if (mounted) {
        setState(() {
          widget.suraDetails.isDownloaded = isComplete;
          if (!isComplete) {
            _downloadProgress = 0;
          }
        });
      }
    } catch(e) {
      debugPrint('Error checking download status: $e');
      if (mounted) {
        setState(() {
          widget.suraDetails.isDownloaded = false;
          _downloadProgress = 0;
        });
      }
    }
  }

  Future<void> _playDownloadedAudio() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = generateFilePath(directory);

    try {
      // Check if file exists and is complete
      final file = File(filePath);
      final exists = await file.exists();
      final fileSize = exists ? await file.length() : 0;
      const minimumExpectedSize = 100000; // Adjust this threshold as needed
      widget.suraDetails.audio = filePath;
      if (exists && fileSize > minimumExpectedSize) {
        // Play downloaded file if complete
        widget.onAudioPlay(widget.suraDetails.number, widget.suraDetails.uniqueId);
      } else {
        // Fall back to online audio if incomplete
        await _playOnlineAudio();
      }
    } catch (e) {
      // Fall back to online audio on any error
      await _playOnlineAudio();
    }
  }

  Future<void> _playOnlineAudio() async {
    print("widget.suraDetails => ${widget.suraDetails.audio}");
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No internet connection available')),
        );
      }
      return;
    }
    widget.onAudioPlay(widget.suraDetails.number, widget.suraDetails.uniqueId);
  }

  Future<void> _deleteDownloadedAudio() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = generateFilePath(directory);

      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        if (mounted) {
          setState(() {
            widget.suraDetails.isDownloaded = false;
            _downloadProgress = 0;
          });
        }
        await SharedPreferenceHelper.setDownloadStatus(widget.suraDetails, false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف السورة'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الحذف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this Surah audio?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deleteDownloadedAudio(); // Call delete method
              },
            ),
          ],
        );
      },
    );
  }

  String? tempFile;
  bool _rafWriting = false;
  bool _rafClosed = true; // Add this flag
  Future<void> _downloadSurahAudio() async {
    if (_isDownloading && !_isResuming) {
      await _pauseDownload();
      return;
    }

    await _downloadLock.synchronized(() async {
      // Check permissions
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        if (mounted) setState(() => _isDownloading = false);
        _showPermissionDeniedSnackbar();
        return;
      }

      // Set downloading state
      if (mounted) {
        setState(() {
          _isDownloading = true;
          _isDownloadPaused = false;
          widget.suraDetails.isDownloaded = false;
        });
      }

      try {
        final directory = await getApplicationDocumentsDirectory();
        tempFile = '${directory.path}/temp_${widget.suraDetails.number}.mp3';
        final savePath = generateFilePath(directory);

        // Use a temporary file during download
        _downloadFile = File(tempFile!);

        // Initialize download
        // _cancelToken = CancelToken();
        final dio = Dio();

        // For resuming, check existing temp file
        if (_isResuming) {
          final fileExists = await _downloadFile!.exists();
          _downloadedBytes = fileExists ? await _downloadFile!.length() : 0;
        } else {
          _downloadedBytes = 0;
          // Ensure we start with a clean temp file
          if (await _downloadFile!.exists()) {
            await _downloadFile!.delete();
          }
        }

        // Start download
        final response = await dio.get(
          widget.suraDetails.audio,
          options: Options(
            responseType: ResponseType.stream,
            headers: {'Range': 'bytes=$_downloadedBytes-'},
          ),
          cancelToken: _cancelToken,
        );

        _totalBytes = _getTotalBytesFromResponse(response);

        final responseStream = response.data as ResponseBody;
        _downloadSubscription = responseStream.stream.listen(
              (chunk) => _handleDownloadChunk(chunk),
          onError: _handleDownloadError,
          onDone: () => _handleDownloadComplete(savePath), // Pass final path
          cancelOnError: true,
        );
      } catch (e) {
        _handleDownloadError(e);
      }
    });
  }

  Future<void> _handleDownloadChunk(List<int> chunk) async {
    await _fileLock.synchronized(() async {
      if (_shouldPause) return;

      try {
        // Only open if null or previously closed
        if (_raf == null || _rafClosed) {
          _raf = await _downloadFile!.open(mode: FileMode.append);
          _rafClosed = false;
        }

        _rafWriting = true;
        await _raf!.writeFrom(chunk);
        _rafWriting = false;
        _downloadedBytes += chunk.length;

        if (mounted) {
          setState(() {
            _downloadProgress = _totalBytes > 0
                ? (_downloadedBytes / _totalBytes).clamp(0.0, 1.0)
                : 0;
          });
        }
      } catch (e) {
        // print('Chunk write error: $e');
        // debugPrint('Chunk write error: $e');
        _cancelToken?.cancel();
      }
    });
  }

  int _getTotalBytesFromResponse(Response response) {
    final contentRange = response.headers.value('content-range');
    if (contentRange != null) {
      final totalBytesMatch = RegExp(r'/(\d+)').firstMatch(contentRange);
      if (totalBytesMatch != null) {
        return int.parse(totalBytesMatch.group(1)!);
      }
    }
    final contentLength = response.headers.value(HttpHeaders.contentLengthHeader);
    if (contentLength != null) {
      return int.parse(contentLength) + _downloadedBytes;
    }

    return 0;
  }

  void _handleDownloadError(dynamic e) async {
    debugPrint("Download error: $e");

    await _fileLock.synchronized(() async {
      await _cleanupResources();
      await Future.delayed(Duration(milliseconds: 300));
      await _safeDeleteFile(_downloadFile);
    });

    if (mounted) {
      setState(() {
        _isDownloading = false;
        _isResuming = false;
      });

      if (e is! DioException || e.type != DioExceptionType.cancel) {
        _showDownloadErrorSnackbar(e.toString());
      }
    }
  }

  Future<void> _handleDownloadComplete(String finalPath) async {
    await _fileLock.synchronized(() async {
      try {
        // Close resources
        await _cleanupResources();

        // Verify we have a temp file
        if (_downloadFile == null || !await _downloadFile!.exists()) {
          throw Exception('No download file available');
        }

        final fileSize = await _downloadFile!.length();
        const minSize = 100000;

        if (fileSize > minSize) {
          // Create final directory if it doesn't exist
          final finalFile = File(finalPath);
          final directory = finalFile.parent;
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }

          // Move temp file to final location
          await _downloadFile!.rename(finalPath);

          // Update state
          if (mounted) {
            setState(() {
              _isDownloading = false;
              widget.suraDetails.isDownloaded = true;
              widget.suraDetails.audio = finalPath;
              _downloadProgress = 1.0;
            });
          }

          // Persist download status
          await SharedPreferenceHelper.setDownloadStatus(widget.suraDetails, true);
          await SharedPreferenceHelper.setDownloadedAudioPath(widget.suraDetails, finalPath);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Download completed successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception('Downloaded file is incomplete');
        }
      } catch (e) {
        debugPrint('Download completion error: $e');
        await _safeDeleteFile(_downloadFile);
        if (mounted) {
          setState(() {
            _isDownloading = false;
            widget.suraDetails.isDownloaded = false;
            _downloadProgress = 0;
          });
        }
        _showDownloadErrorSnackbar('Download failed: ${e.toString()}');
      }
    });
  }

  Future<void> _cleanupResources() async {
    try {
      // Wait for any ongoing write to complete
      while (_rafWriting) {
        await Future.delayed(Duration(milliseconds: 50));
      }

      if (_raf != null) {
        await _raf!.flush();
        await _raf!.close();
        _rafClosed = true;
        _raf = null;
      }

      if (_downloadSubscription != null) {
        await _downloadSubscription!.cancel();
        _downloadSubscription = null;
      }
    } catch (e) {
      debugPrint('Resource cleanup error: $e');
    }
  }

  Future<void> _safeDeleteFile(File? file) async {
    await _fileLock.synchronized(() async {
      try {
        if (file != null && await file.exists()) {
          await file.delete();
        }
      } on FileSystemException catch (e) {
        debugPrint('File deletion error: $e');
        await Future.delayed(Duration(milliseconds: 300));
        try {
          if (await file!.exists()) {
            await file.delete(); // retry once after wait
          }
        } catch (_) {}
      }
    });
  }
  String generateFilePath(Directory directory){
    return widget.suraDetails.narrative != null
        ? '${directory.path}/سورة ${widget.suraDetails.number} ${widget.suraDetails.arabicName} برواية ${widget.suraDetails.narrative}.mp3'
        : '${directory.path}/سورة ${widget.suraDetails.arabicName}${widget.suraDetails.number}.mp3';
  }

  Future<bool> _verifyDownloadComplete() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = generateFilePath(directory);

      final file = File(filePath);
      if (!await file.exists()) return false;

      // For extra safety, you could verify minimum file size here
      // final size = await file.length();
      // return size > minimumExpectedSize;

      return _downloadProgress >= 1.0;
    } catch (e) {
      debugPrint('Verification error: $e');
      return false;
    }
  }

  Future<void> _pauseDownload() async {
    if (mounted) {
      setState(() {
        _isDownloadPaused = true;
        _isDownloading = false;
        _resumePosition = _downloadedBytes;
      });
    }

    await _downloadLock.synchronized(() async {
      try {
        _cancelToken?.cancel();
        await _cleanupResources();

        // If download was very small, delete the temp file
        if (_downloadFile != null &&
            await _downloadFile!.exists() &&
            await _downloadFile!.length() < 10000) {
          await _downloadFile!.delete();
        }
      } catch (e) {
        debugPrint('Pause error: $e');
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _isDownloadPaused = false;
          });
        }
      }
    });
  }

  Future<void> _resumeDownload() async {
    if (!_isDownloadPaused) return;

    // Update state first
    if (mounted) {
      setState(() {
        _isDownloadPaused = false;
        _isDownloading = true;
        _isResuming = true;
      });
    }

    if (tempFile == null) {
      debugPrint('No temp file path available for resume');
      return;
    }
    final tempFilePath = File(tempFile!);
    if (!await tempFilePath.exists()) {
      debugPrint('Temp file does not exist at $tempFilePath');
      if (mounted) {
        setState(() {
          _isDownloadPaused = false;
          _downloadProgress = 0;
        });
      }
      return;
    }
    _downloadedBytes = await tempFilePath.length();
    debugPrint('Resuming from $_downloadedBytes bytes');

    // Update state
    if (mounted) {
      setState(() {
        _isDownloadPaused = false;
        _isDownloading = true;
        _isResuming = true;
      });
    }
    try {
      await _downloadSurahAudio();
    } catch (e) {
      debugPrint('Resume failed: $e');
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isDownloadPaused = true;
          _isResuming = false;
        });
      }
      _showDownloadErrorSnackbar('Failed to resume download');
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

  Future<void> _playAudio() async {
    if (_isDownloaded) {
      final isReallyDownloaded = await _verifyDownloadComplete();
      if (!isReallyDownloaded) {
        if (mounted) {
          setState(() {
            _isDownloaded = false;
          });
        }
        // Fall through to online play
      } else {
        await _playDownloadedAudio();
        return;
      }
    }

    // Online play logic
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No internet connection available')),
      );
      return;
    }
    widget.onAudioPlay(widget.suraDetails.number, widget.suraDetails.uniqueId);
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
  Widget _buildDownloadControl() {
    if (widget.suraDetails.isDownloaded) {
      return Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: const Color(0xffF5F4F9),
          borderRadius: BorderRadius.circular(25),
        ),
        child: IconButton(
          icon: const Icon(Icons.delete_outline, size: 21),
          onPressed: _showDeleteConfirmationDialog,
          padding: EdgeInsets.zero,
        ),
      );
    }
    else if (_isDownloading || _isDownloadPaused || _isResuming) {
      return Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: const Color(0xffF5F4F9),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value:  _totalBytes > 0 ? _downloadProgress : null,
              strokeWidth: 2,
              color: Color(0xff00514A),
            ),
            IconButton(
              icon: Icon(
                _isDownloadPaused ? Icons.play_arrow : Icons.pause,
                size: 21,
              ),
              onPressed: () async {
                // _isDownloadPaused = !_isDownloadPaused;
                if (_isDownloadPaused) {
                  await _resumeDownload();
                } else {
                  await _pauseDownload();
                }
              },
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: const Color(0xffF5F4F9),
          borderRadius: BorderRadius.circular(25),
        ),
        child: IconButton(
          icon: Icon(Icons.cloud_download_outlined),
          iconSize: 21,
          onPressed: _downloadSurahAudio,
          padding: EdgeInsets.zero,
        ),
      );
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
            // Text("$_isDownloadPaused"),
            _buildDownloadControl(),
            const SizedBox(width: 10),
            Text("$_isDownloadPaused"),
            // Text("${widget.suraDetails.isDownloaded}"),
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
                onPressed: () async {
                  audioProvider.wasRadioPlaying = false;
                  audioProvider.changeIsRadio(false);
                  print("sura audio => ${widget.suraDetails.audio}");
                  if (widget.suraDetails.isDownloaded) {
                    await _playDownloadedAudio();
                  } else {
                    await _playOnlineAudio();
                  }
                  // final audioProvider = Provider.of<AudioProvider>(context, listen: false);
                  //
                  // // Stop radio if playing
                  // if (audioProvider.isRadioPlaying) {
                  //   await audioProvider.pauseRadio();
                  //   audioProvider.wasRadioPlaying = false;
                  //   audioProvider.changeIsRadio(false);
                  // }
                  //
                  // if (_isDownloaded) {
                  //   try {
                  //     // Play downloaded file
                  //     final directory = await getApplicationDocumentsDirectory();
                  //     String filePath;
                  //
                  //     if (widget.suraDetails.narrative != null) {
                  //       filePath = '${directory.path}/سورة ${widget.suraDetails.arabicName} برواية ${widget.suraDetails.narrative}.mp3';
                  //     } else {
                  //       filePath = '${directory.path}/سورة ${widget.suraDetails.arabicName}.mp3';
                  //     }
                  //
                  //     widget.onAudioPlay(widget.suraDetails.number, widget.suraDetails.uniqueId);
                  //   } catch (e) {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(content: Text('Error playing downloaded file: $e')),
                  //     );
                  //   }
                  // } else {
                  //   // Play online audio
                  //   widget.onAudioPlay(widget.suraDetails.number, widget.suraDetails.uniqueId);
                  // }
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
