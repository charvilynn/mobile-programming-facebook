import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/post_card.dart';

class BookmarksNotifier extends StateNotifier<List<PostData>> {
  static const _storageKey = 'pacebook_bookmarked_posts';

  BookmarksNotifier() : super([]) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonListStr = prefs.getStringList(_storageKey);
      if (jsonListStr != null && jsonListStr.isNotEmpty) {
        state = jsonListStr.map((item) {
          final map = jsonDecode(item) as Map<String, dynamic>;
          return PostData.fromJson(map).copyWith(isBookmarked: true);
        }).toList();
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonListStr = state.map((post) => jsonEncode(post.toJson())).toList();
      await prefs.setStringList(_storageKey, jsonListStr);
    } catch (_) {}
  }

  bool isBookmarked(int postId) {
    return state.any((p) => p.id == postId);
  }

  bool toggleBookmark(PostData post) {
    final exists = state.any((p) => p.id == post.id);
    if (exists) {
      state = state.where((p) => p.id != post.id).toList();
      _saveToStorage();
 return false; // Removed
    } else {
      state = [post.copyWith(isBookmarked: true), ...state];
      _saveToStorage();
 return true; // Added
    }
  }

  void removeBookmark(int postId) {
    state = state.where((p) => p.id != postId).toList();
    _saveToStorage();
  }
}

final bookmarksProvider =
    StateNotifierProvider<BookmarksNotifier, List<PostData>>((ref) {
  return BookmarksNotifier();
});
