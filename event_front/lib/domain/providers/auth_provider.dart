import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:event_booking_app/core/utils/secure_storage.dart';
import 'package:event_booking_app/data/models/user_model.dart';
import 'package:event_booking_app/data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthState {
  final UserModel? user;
  final String? token;
  final bool isAuthenticated;
  final String? error;

  AuthState({
    this.user,
    this.token,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await SecureStorage.getToken();
    print('Checking auth status, token: $token'); // Debug: Log token
    if (token != null && !JwtDecoder.isExpired(token)) {
      try {
        final user = await _authRepository.getProfile();
        state = state.copyWith(
          user: user,
          token: token,
          isAuthenticated: true,
          error: null,
        );
      } catch (e) {
        print('Error checking auth status: $e'); // Debug: Log error
        await SecureStorage.deleteToken();
        state = state.copyWith(
          user: null,
          token: null,
          isAuthenticated: false,
          error: e.toString(),
        );
      }
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final user = await _authRepository.login(email, password);
      final token = await SecureStorage.getToken();
      print('Login successful, token: $token'); // Debug: Log token
      state = state.copyWith(
        user: user,
        token: token,
        isAuthenticated: true,
        error: null,
      );
    } catch (e) {
      print('Login error: $e'); // Debug: Log error
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      final user = await _authRepository.register(name, email, password);
      state = state.copyWith(
        user: user,
        isAuthenticated: false,
        error: null,
      );
    } catch (e) {
      print('Register error: $e'); // Debug: Log error
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      await SecureStorage.deleteToken();
      state = state.copyWith(
        user: null,
        token: null,
        isAuthenticated: false,
        error: null,
      );
    } catch (e) {
      print('Logout error: $e'); // Debug: Log error
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> getProfile() async {
    try {
      final user = await _authRepository.getProfile();
      state = state.copyWith(user: user, error: null);
    } catch (e) {
      print('Get profile error: $e'); // Debug: Log error
      state = state.copyWith(error: e.toString());
    }
  }
}