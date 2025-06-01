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
    final filteredData = allAudioResponses.where((item) => item.id == filterId).toList();
    return filteredData[index];
  }
}