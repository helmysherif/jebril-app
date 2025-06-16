import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../Sura.dart';
class SharedPreferenceHelper {
  static const _favoriteSurahsKey = 'favorite_surahs';
  // Add a surah to favorites
  static Future<void> addFavoriteSurah(Surah sura) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteSurahs();

    // Check if already exists by number
    if (!favorites.any((s) => s.number == sura.number && s.arabicName == sura.arabicName && s.englishName == sura.englishName)) {
      favorites.add(sura);
      await _saveFavorites(favorites);
    }
  }

  // Remove a surah from favorites
  static Future<void> removeFavoriteSurah(Surah sura) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteSurahs();
    favorites.removeWhere((s) => s.number == sura.number);
    await _saveFavorites(favorites);
  }

  // Get all favorite surahs
  static Future<List<Surah>> getFavoriteSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoriteSurahsKey) ?? [];
    return favoritesJson.map((json) => Surah.fromJson(jsonDecode(json))).toList();
  }

  // Check if a surah is favorite
  static Future<bool> isFavorite(Surah sura) async {
    final favorites = await getFavoriteSurahs();
    return favorites.any((s) => s.number == sura.number && s.arabicName == sura.arabicName && s.englishName == sura.englishName);
  }

  // Helper method to save favorites
  static Future<void> _saveFavorites(List<Surah> surahs) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = surahs.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_favoriteSurahsKey, favoritesJson);
  }
}