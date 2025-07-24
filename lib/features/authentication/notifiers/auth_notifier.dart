import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:varsight/core/services/network.dart';
import '../repositories/auth_repository.dart';
import 'package:varsight/features/personalization/providers/profile_providers.dart';

sealed class AuthState {
  const AuthState();

  bool get isAuthenticated => this is AuthAuthenticated;
  bool get isGuest => this is AuthGuest;
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}

class AuthGuest extends AuthState {
  const AuthGuest();
}

class AuthUnauthenticated extends AuthState {}

class AuthNotifier extends AsyncNotifier<AuthState> {
  late final AuthRepository _repo;
  late final NetworkService _networkService;

  @override
  Future<AuthState> build() async {
    _repo = AuthRepository();
    _networkService = NetworkService();
    final user = _repo.currentUser;
    if (user != null) {
      return AuthAuthenticated(user);
    } else {
      // Default to guest mode if no user is signed in
      return const AuthGuest();
    }
  }

  Future<void> login(String email, String password) async {
    state = await AsyncValue.guard(() async {
      // Check network connectivity before proceeding
      final isConnected = await _networkService.isConnected();
      if (!isConnected) {
        throw SocketException('No internet connection');
      }
      final response = await _repo.loginWithEmailAndPassword(email, password);
      final user = response.user;
      if (user != null) {
        // Invalidate profile provider so it reloads for the new user
        ref.invalidate(profileProvider);
        return AuthAuthenticated(user);
      }
      throw AuthException('Login failed');
    });
  }

  Future<void> register(String email, String password) async {
    state = await AsyncValue.guard(() async {
      // Check network connectivity before proceeding
      final isConnected = await _networkService.isConnected();
      if (!isConnected) {
        throw SocketException('No internet connection');
      }
      final response = await _repo.registerWithEmailAndPassword(
        email,
        password,
      );
      final user = response.user;
      if (user != null) {
        // Invalidate profile provider so it reloads for the new user
        ref.invalidate(profileProvider);
        return AuthAuthenticated(user);
      }
      throw AuthException('Registration failed');
    });
  }

  Future<void> logout() async {
    state = await AsyncValue.guard(() async {
      // Check network connectivity before proceeding
      final isConnected = await _networkService.isConnected();
      if (!isConnected) {
        throw SocketException('No internet connection');
      }
      await _repo.logout();
      // Invalidate profile provider so it clears profile state
      ref.invalidate(profileProvider);
      return AuthUnauthenticated();
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await AsyncValue.guard(() async {
      // Check network connectivity before proceeding
      final isConnected = await _networkService.isConnected();
      if (!isConnected) {
        throw SocketException('No internet connection');
      }
      await _repo.sendPasswordResetEmail(email);
    });
  }

  Future<bool> reauthenticate(String email, String password) async {
    try {
      // Check network connectivity before proceeding
      final isConnected = await _networkService.isConnected();
      if (!isConnected) {
        throw SocketException('No internet connection');
      }
      final response = await _repo.reauthenticate(email, password);
      return response;
    } catch (e) {
      return false;
    }
  }
}
