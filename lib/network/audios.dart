import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jebril_app/models/AudioResponse.dart';
class GetAudiosApi {
  static Future<List<AudioResponse>> getAudios() async {
    Uri url = Uri.https("radiojebril.net" , "/sheikh_jebril_audios/lookup/categories.json");
    http.Response response = await http.get(url);
    List<dynamic> jsonRes = jsonDecode(response.body);
    List<AudioResponse> audioResponse = jsonRes
        .map((json) => AudioResponse.fromJson(json))
        .toList();
    return audioResponse;
  }
  static Future<List<String>> getNarrativeAudiosCount(String narrative) async {
    try {
      final response = await http.get(Uri.parse(
          'https://radiojebril.net/sheikh_jebril_audios/sounds/quran_narratives/$narrative'));
      if (response.statusCode == 200) {
        // Parse HTML to count audio links
        final regex = RegExp(r'href="([^"]+\.mp3)"');
        int audiosCount = regex.allMatches(response.body).length;
        List<String> audioNumber = regex
            .allMatches(response.body)
            .map((match) => match.group(1)!)
            .toList();
        return audioNumber;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  static Future<List<String>> getHollyQuranAudiosCount(String quranId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://radiojebril.net/sheikh_jebril_audios/sounds/holy_quran/$quranId'));
      if (response.statusCode == 200) {
        // Parse HTML to count audio links
        final regex = RegExp(r'href="([^"]+\.mp3)"');
        int audiosCount = regex.allMatches(response.body).length;
        List<String> audioNumber = regex
            .allMatches(response.body)
            .map((match) => match.group(1)!)
            .toList();
        return audioNumber;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}