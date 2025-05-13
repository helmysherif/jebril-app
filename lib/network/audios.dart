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
}