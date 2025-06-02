import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jebril_app/models/AudioResponse.dart';

import '../Sura.dart';
import '../constants/sura_names.dart';
class GetAudiosApi {
  static Future<List<AudioResponse>> getAudios() async {
    Uri url = Uri.https("radiojebril.net" , "/sheikh_jebril_audios/lookup/categories.json");
    http.Response response = await http.get(url).timeout(const Duration(seconds: 10));
    List<dynamic> jsonRes = jsonDecode(response.body);
    List<AudioResponse> audioResponse = jsonRes
        .map((json) => AudioResponse.fromJson(json))
        .toList();
    return audioResponse;
  }
  static Future<List<String>> getNarrativeAudiosCount(String type , String id) async {
    try {
      final response = await http.get(Uri.parse(
          'https://radiojebril.net/sheikh_jebril_audios/sounds/$type/$id'));
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
  static Future<List<String>> getPrayersAudiosNames(String type, String id) async {
    try {
      final response = await http.get(Uri.parse(
          'https://radiojebril.net/sheikh_jebril_audios/sounds/$type/$id/'));

      if (response.statusCode == 200) {
        final regex = RegExp(r'href="([^"]+\.mp3)"');
        final matches = regex.allMatches(response.body);

        return matches.map((match) {
          final encodedName = match.group(1)!;
          // Get just the filename part
          final filename = encodedName.split('/').last;
          // URL decode the filename
          return Uri.decodeComponent(filename);
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}