class Subcategories {
  Subcategories({
    required this.id,
    required this.arTitle,
    required this.enTitle,});

  Subcategories.fromJson(dynamic json) {
    id = json['id'];
    arTitle = json['ar_title'];
    enTitle = json['en_title'];
  }
  late String id;
  late String arTitle;
  late String enTitle;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['ar_title'] = arTitle;
    map['en_title'] = enTitle;
    return map;
  }

}