import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:varsight/features/personalization/models/profile_model.dart';
import 'package:varsight/features/personalization/notifiers/profile_notifier.dart';
import 'package:varsight/features/personalization/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(),
);

final profileProvider = AsyncNotifierProvider<ProfileNotifier, ProfileModel?>(
  ProfileNotifier.new,
);
