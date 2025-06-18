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
}