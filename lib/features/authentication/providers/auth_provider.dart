import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/features/authentication/notifiers/auth_notifier.dart';
import 'package:varsight/features/authentication/repositories/auth_repository.dart';

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
