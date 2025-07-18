import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/features/authentication/providers/auth_provider.dart';
import 'package:varsight/features/authentication/notifiers/auth_notifier.dart';
import 'package:varsight/main_nav.dart';
import 'package:varsight/features/authentication/presentations/sign_in/sign_in_screen.dart';

class AuthGatePage extends ConsumerWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      data: (state) {
        if (state is AuthAuthenticated || state is AuthGuest) {
          // Both authenticated and guest users go to main app
          return const MainNavScreen();
        }
        // Unauthenticated state shows login
        return const LoginPage();
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const LoginPage(),
    );
  }
}
