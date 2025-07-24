import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:varsight/core/utils/helpers.dart';
import 'package:varsight/core/services/network.dart';
import 'package:varsight/features/personalization/models/profile_model.dart';
import 'package:varsight/features/personalization/providers/profile_providers.dart';
import 'package:varsight/features/personalization/repositories/profile_repository.dart';

class ProfileNotifier extends AsyncNotifier<ProfileModel?> {
  late final ProfileRepository _repository;
  late final NetworkService _networkService;

  @override
  Future<ProfileModel?> build() async {
    _repository = ref.read(profileRepositoryProvider);
    _networkService = ref.read(networkServiceProvider);
    return getCurrentProfile();
  }

  Future<ProfileModel?> getCurrentProfile() async {
    try {
      final isConnected = await _networkService.isConnected();
      if (!isConnected) {
        throw const SocketException('No internet connection');
      }

      final userId = AuthHelper.getCurrentUserId();
      if (userId == null) return null;

      return await _repository.getUserById(userId);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> saveProfileChanges({
    required String userId,
    String? firstName,
    String? lastName,
    String? profilePicture,
  }) async {
    state = await AsyncValue.guard(() async {
      try {
        final isConnected = await _networkService.isConnected();
        if (!isConnected) {
          throw SocketException("No internet connection");
        }

        await _repository.updateProfile(
          userId: userId,
          firstName: firstName,
          lastName: lastName,
        );

        return getCurrentProfile();
      } catch (error) {
        rethrow;
      }
    });
  }

  Future<String?> pickAndUploadImage(String userId) async {
    state = await AsyncValue.guard(() async {
      // Check network connectivity before proceeding
      final isConnected = await _networkService.isConnected();
      if (!isConnected) {
        throw SocketException('No internet connection');
      }
      try {
        final currentProfilePicture = state.value?.profilePicture;

        // Upload image and get URL
        final imageUrl = await Helpers.uploadImage();
        if (imageUrl == null) return state.value;

        // Update profile with new image URL
        await _repository.updateProfilePicture(
          userId: userId,
          profilePictureUrl: imageUrl,
        );

        // Delete old profile picture if it exists
        if (currentProfilePicture != null && currentProfilePicture.isNotEmpty) {
          final uri = Uri.parse(currentProfilePicture);
          final filename = uri.pathSegments.last;
          await Supabase.instance.client.storage.from('profile-images').remove([
            filename,
          ]);
        }

        // Get and return the updated profile
        final updatedProfile = await getCurrentProfile();

        return updatedProfile;
      } catch (error) {
        rethrow;
      }
    });

    return state.value?.profilePicture;
  }

  Future<void> deleteProfilePicture(String userId) async {
    state = await AsyncValue.guard(() async {
      // Check network connectivity before proceeding
      final isConnected = await _networkService.isConnected();
      if (!isConnected) {
        throw SocketException('No internet connection');
      }
      try {
        final profilePictureUrl = state.value?.profilePicture;
        if (profilePictureUrl != null) {
          await _repository.deleteProfilePicture(userId, profilePictureUrl);
        }
        return getCurrentProfile();
      } catch (error) {
        rethrow;
      }
    });
  }
}
