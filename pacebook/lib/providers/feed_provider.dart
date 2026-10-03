import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../widgets/post_card.dart';

// Feed State
typedef FeedState = AsyncValue<List<PostData>>;

// FeedNotifier
class FeedNotifier extends AsyncNotifier<List<PostData>> {
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;

  @override
  Future<List<PostData>> build() async {
    return _fetchPosts(page: 1);
  }

  Future<void> loadFeed() async {
    state = const AsyncLoading();
    _page = 1;
    _hasMore = true;
    state = await AsyncValue.guard(() => _fetchPosts(page: 1));
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    state = await AsyncValue.guard(() => _fetchPosts(page: 1));
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    final current = state.valueOrNull ?? [];
    _isLoadingMore = true;
    try {
      _page++;
      final more = await _fetchPosts(page: _page);
      if (more.isEmpty) {
        _hasMore = false;
      } else {
        state = AsyncData([...current, ...more]);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  void addPost(PostData post) {
    final current = state.valueOrNull ?? [];
    state = AsyncData([post, ...current]);
  }

  void removePost(int postId) {
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((p) => p.id != postId).toList());
  }

  //  Real API fetch zero dummy data
  Future<List<PostData>> _fetchPosts({required int page}) async {
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/posts', queryParameters: {'page': page, 'limit': 15});
      final data = res.data['data'] as List<dynamic>? ?? [];
      return data
          .map((item) => PostData.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      // In case of unauthenticated or network error, return empty without crashing
      return [];
    }
  }
}

// Provider
final feedProvider = AsyncNotifierProvider<FeedNotifier, List<PostData>>(
  FeedNotifier.new,
);