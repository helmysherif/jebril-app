import 'package:flutter/cupertino.dart';
import '../models/AudioResponse.dart';
import '../models/Subcategories.dart';
import '../network/audios.dart';
class QuranDataProvider extends ChangeNotifier{
  List<AudioResponse> allAudioResponses = [];
  setData(List<AudioResponse> data){
    allAudioResponses = data;
    notifyListeners();
  }
  AudioResponse getFilteredQuranData(String filterId, int index) {
    if (allAudioResponses.isEmpty) {
      return AudioResponse(
          arTitle: '',
          enTitle: '',
          subcategories: [],
          id: ''
      );
    }
    try {
      return allAudioResponses.firstWhere((element) => element.id == filterId);
    } catch (e) {
      return AudioResponse(
          arTitle: '',
          enTitle: '',
          subcategories: [],
          id: ''
      );
    }
  }
}