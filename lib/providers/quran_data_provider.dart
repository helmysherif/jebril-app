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
  List<Subcategories> getFilteredQuranData(String filterId, int index) {
    final filteredData = allAudioResponses.where((item) => item.id == filterId).toList();
    if (filteredData.isNotEmpty &&
        index < filteredData.length &&
        filteredData[index].subcategories.isNotEmpty) {
      return filteredData[index].subcategories;
    }
    return [];
  }
}