import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../Sura.dart';
import '../constants/sura_names.dart';
import '../models/Subcategories.dart';

class HelperFunctions
{
  static List<String> extractNumbersFromFilenames(List<String> filenames) {
    final RegExp numberRegExp = RegExp(r'(\d+)\.mp3$');
    return filenames
        .map((filename) {
      final match = numberRegExp.firstMatch(filename);
      return match?.group(1); // Returns the matched digits as string
    })
        .whereType<String>() // Filters out null values
        .toList();
  }
  static List<Surah> generateSurahAudioUrls(String type , List<String> narratives , Subcategories cat) {
    List<Surah> surahs = [];
    if(narratives.isNotEmpty){
      for(int i = 0;i < narratives.length;i++){
        final narrativeNumber = int.tryParse(narratives[i]) ?? 0;
        final suraData = suraNamesData.firstWhere(
              (sura) => sura["number"] == narrativeNumber,
          orElse: () => {
            "number": narrativeNumber,
            "englishName": "Unknown",
            "arabicName": "غير معروف"
          },
        );
        surahs.add(Surah(
          audio:
          'https://radiojebril.net/sheikh_jebril_audios/sounds/$type/${cat.id}/${narratives[i]}.mp3',
          englishName: suraData["englishName"],
          arabicName: suraData["arabicName"],
          number: suraData["number"],
          narrative: cat.arTitle
        ));
      }
    }
    return surahs;
  }
  static Future<List<Surah>> getDownloadedSurahs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      print("Checking directory: ${directory.path}");

      final dir = Directory(directory.path);
      if (!await dir.exists()) {
        print("Directory doesn't exist");
        return [];
      }

      final files = await dir.list()
          .where((entity) => entity.path.endsWith('.mp3'))
          .toList();

      print("Found ${files.length} MP3 files");

      List<Surah> downloaded = [];

      for (var file in files) {
        try {
          final path = file.path;
          final fileName = path.split('/').last;
          print("Processing file: $fileName");

          // Add your parsing logic here
          // Make sure this matches your actual file naming pattern
          final match = RegExp(r'سورة (.+?) برواية (.+?)\.mp3').firstMatch(fileName);
          if (match != null) {
            final arabicName = match.group(1);
            final narrative = match.group(2);

            // Find matching sura data
            final suraData = suraNamesData.firstWhere(
                  (s) => s["arabicName"] == arabicName,
            );

            if (suraData != null) {
              downloaded.add(Surah(
                audio: path,
                englishName: suraData["englishName"] ?? "",
                arabicName: arabicName ?? "",
                number: suraData["number"] ?? 0,
                narrative: narrative,
                isDownloaded: true,
              ));
            }
          }
        } catch (e) {
          print("Error processing file ${file.path}: $e");
        }
      }

      return downloaded;
    } catch (e) {
      print("Error in getDownloadedSurahs: $e");
      return [];
    }
  }
}