import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/user_profile_repository.dart';

part 'user_profile_provider.g.dart';

@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  @override
  Future<UserProfile?> build() async {
    final repository = UserProfileRepository();
    return await repository.getProfile();
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = UserProfileRepository();
      await repository.saveProfile(profile);
      return profile;
    });
  }

  Future<void> completeSetup(UserProfile profile) async {
    final updatedProfile = profile.copyWith(isSetupComplete: true);
    await updateProfile(updatedProfile);
  }
}
