class Surah {
  final String audio;
  final String englishName;
  final String arabicName;
  final int number;
  final String? narrative;
  Surah({
    required this.audio,
    required this.englishName,
    required this.arabicName,
    required this.number,
    this.narrative
  });
  Map<String, dynamic> toJson() {
    return {
      'audio': audio,
      'englishName': englishName,
      'arabicName': arabicName,
      'number': number,
      'narrative' : narrative
    };
  }
  // Create Surah from Map
  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      audio: json['audio'],
      englishName: json['englishName'],
      arabicName: json['arabicName'],
      number: json['number'],
      narrative : json['narrative']
    );
  }
  @override
  String toString() {
    return toJson().toString();
  }
}