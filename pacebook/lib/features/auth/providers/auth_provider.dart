import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/repositories/auth_repository.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
  });

  AuthState copyWith({bool? isLoading, String? error, bool? isLoggedIn}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final Ref _ref;

  AuthNotifier(this._repo, this._ref) : super(const AuthState());

  /// Returns null on success, error message string on failure
  Future<String?> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.login(email, password);
      state = state.copyWith(isLoading: false, isLoggedIn: true);
      _ref.read(isLoggedInProvider.notifier).state = true;
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return _parseError(e);
    }
  }

  /// Returns null on success, error message string on failure
  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );
      state = state.copyWith(isLoading: false, isLoggedIn: true);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return _parseError(e);
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _ref.read(isLoggedInProvider.notifier).state = false;
    state = const AuthState();
  }

  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.contains('409')) return 'Email sudah terdaftar';
    if (msg.contains('401')) return 'Email atau password salah';
    if (msg.contains('network')) return 'Tidak ada koneksi internet';
    return 'Terjadi kesalahan. Coba lagi.';
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  );
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});