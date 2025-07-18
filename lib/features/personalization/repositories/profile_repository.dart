import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:varsight/features/personalization/models/profile_model.dart';

class ProfileRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<void> saveUserRecord(ProfileModel user) async {
    await client.from('users').upsert(user.toJson(), onConflict: 'id');
  }

  Future<void> updateUserRecord(ProfileModel user) async {
    await client.from('users').update(user.toJson()).eq('id', user.id).select();
  }

  Future<ProfileModel?> getUserById(String id) async {
    final response =
        await client.from('users').select().eq('id', id).maybeSingle();
    return response != null ? ProfileModel.fromJson(response) : null;
  }

  Future<void> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
  }) async {
    final updates = {
      if (firstName != null) 'firstname': firstName,
      if (lastName != null) 'lastname': lastName,
    };

    if (updates.isNotEmpty) {
      await client.from('users').update(updates).eq('id', userId).select();
    }
  }

  Future<void> updateProfilePicture({
    required String userId,
    required String profilePictureUrl,
  }) async {
    await client
        .from('users')
        .update({'profilepicture': profilePictureUrl})
        .eq('id', userId)
        .select()
        .single();
  }

  Future<void> deleteProfilePicture(
    String userId,
    String profilePictureUrl,
  ) async {
    try {
      // First update the user record
      await client
          .from('users')
          .update({'profilepicture': null})
          .eq('id', userId)
          .select();

      // Then remove from storage
      final uri = Uri.parse(profilePictureUrl);
      final filename = uri.pathSegments.last;
      await client.storage.from('profile-images').remove([filename]);
    } catch (e) {
      throw Exception('Failed to delete profile picture: $e');
    }
  }
}
