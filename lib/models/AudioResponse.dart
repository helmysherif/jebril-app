import 'Subcategories.dart';
class AudioResponse {
  late String id;
  late String arTitle;
  late String enTitle;
  late List<Subcategories> subcategories;
  AudioResponse({
    required this.id,
    required this.arTitle,
    required this.enTitle,
      required this.subcategories});

  AudioResponse.fromJson(dynamic json) {
    id = json['id'];
    arTitle = json['ar_title'];
    enTitle = json['en_title'];
      subcategories = [];
      json['subcategories'].forEach((v) {
        subcategories.add(Subcategories.fromJson(v));
      });

  }


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['ar_title'] = arTitle;
    map['en_title'] = enTitle;
    map['subcategories'] = subcategories.map((v) => v.toJson()).toList();
    return map;
  }

}