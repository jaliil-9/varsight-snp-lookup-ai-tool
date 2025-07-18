import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/features/authentication/providers/auth_provider.dart';

class Validators {
  static String? validateEmptyField(context, String? value) {
    if (value == null || value.isEmpty) {
      return "This field cannot be empty";
    }
    return null;
  }

  static String? validateEmail(context, String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email";
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(value)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  static Future<String?> validateCurrentPassword(
    BuildContext context,
    WidgetRef ref,
    String? value,
  ) async {
    if (value == null || value.isEmpty) {
      return "Please enter your current password";
    }

    // Get email from the auth state
    final authState = ref.read(authRepositoryProvider);
    final email = authState.currentUser?.email;
    if (email == null) {
      return "User is not authenticated";
    }

    // Get auth notifier to check password
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final isValid = await authNotifier.reauthenticate(email, value);

    if (!isValid) {
      return "Password is incorrect";
    }

    return null;
  }

  static String? validateEmptyPassword(context, String? value) {
    if (value == null || value.isEmpty) {
      return "Password cannot be empty";
    }
    return null;
  }

  static String? validateNewPassword(context, String? value) {
    if (value == null || value.isEmpty) {
      return "New password cannot be empty";
    }
    if (value.length < 6) {
      return "New password must be at least 6 characters long";
    }
    return null;
  }

  static String? validateConfirmPassword(
    context,
    String? value,
    String? newPassword,
  ) {
    if (value != newPassword) {
      return "Passwords do not match";
    }
    return null;
  }
}
