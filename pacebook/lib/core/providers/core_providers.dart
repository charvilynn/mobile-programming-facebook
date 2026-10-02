import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(storage);
});

// Auth state for router -- cached bool, updated on login/logout
final isLoggedInProvider = StateProvider<bool>((ref) => false);

// Async check at startup (read once in SplashScreen)
final authCheckProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  final result = await storage.isLoggedIn();
  ref.read(isLoggedInProvider.notifier).state = result;
  return result;
});

// ─── Shared Friend Suggestions Provider (Real Database Users) ────────────────
final friendSuggestionsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final res = await api.get('/users/suggestions');
    final list = res.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  } catch (_) {
    return [];
  }
});

// ─── Shared Notifications Provider ───────────────────────────────────────────
final notificationsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final res = await api.get('/notifications');
    if (res.data != null && res.data['data'] != null) {
      return (res.data['data'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
  } catch (_) {}
  return [];
});