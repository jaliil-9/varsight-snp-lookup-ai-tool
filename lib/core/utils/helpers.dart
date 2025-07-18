import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:varsight/config/storage_service.dart';

class Helpers {
  static ImageProvider getImageProvider(String? profileUrl) {
    return profileUrl != null && profileUrl.isNotEmpty
        ? NetworkImage(profileUrl)
        : const AssetImage('assets/images/user.jpg') as ImageProvider;
  }

  static Future<String?> uploadImage() async {
    try {
      final hasPermission = await StorageService.requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission required to upload images.');
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final fileExt = p.extension(image.path);
        final fileName = '${const Uuid().v4()}$fileExt';

        final imageFile = File(image.path);
        await Supabase.instance.client.storage
            .from('profile-images')
            .upload(
              fileName,
              imageFile,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        final imageUrl = Supabase.instance.client.storage
            .from('profile-images')
            .getPublicUrl(fileName);

        return imageUrl;
      }
      return null;
    } on StorageException catch (e) {
      throw Exception('Storage error: $e');
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  static Future<void> refreshProviders(
    WidgetRef ref,
    List<ProviderBase> providers,
  ) async {
    for (final provider in providers) {
      // ignore: unused_result
      ref.refresh(provider);
    }
  }
}

class AuthHelper {
  static String? getCurrentUserId() {
    return Supabase.instance.client.auth.currentUser?.id;
  }

  static String? getCurrentUserEmail() {
    return Supabase.instance.client.auth.currentUser?.email;
  }
}
