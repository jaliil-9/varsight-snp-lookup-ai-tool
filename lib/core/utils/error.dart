import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorUtils {
  /// Shows a snackbar with an error message
  static void showErrorSnackBar(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[700],
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(10),
      icon: const Icon(Icons.error, color: Colors.white),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      duration: const Duration(seconds: 4),
    );
  }

  /// Shows a success snackbar
  static void showSuccessSnackBar(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.all(10),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      duration: const Duration(seconds: 3),
    );
  }

  /// Shows an info snackbar
  static void showInfoSnackBar(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.withOpacity(0.1),
      colorText: Colors.black,
      borderRadius: 10,
      margin: const EdgeInsets.all(10),
      icon: const Icon(Icons.info_outline, color: Colors.black),
      shouldIconPulse: true,
      barBlur: 20,
      isDismissible: true,
      duration: const Duration(seconds: 3),
    );
  }

  /// Gets the localized error message
  static String getErrorMessage(Object error) {
    if (error is SocketException ||
        error.toString().contains('SocketException') ||
        error.toString().contains('No internet connection')) {
      return "No internet connection";
    } else if (error is StorageException) {
      return "Storage error: \${error.message}";
    } else if (error is AuthException) {
      return "Authentication error: \${error.message}";
    } else if (error is PostgrestException) {
      return "Database error: \${error.message}";
    } else {
      return "Unknown error: \${error.toString()}";
    }
  }
}