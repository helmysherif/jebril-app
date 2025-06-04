class SheikhInfo {
  final String arabicInfo;
  final String englishInfo;

  SheikhInfo({required this.arabicInfo, required this.englishInfo});

  factory SheikhInfo.fromJson(Map<String, dynamic> json) {
    return SheikhInfo(
      arabicInfo: json['arabicInfo'],
      englishInfo: json['englishInfo'],
    );
  }
}