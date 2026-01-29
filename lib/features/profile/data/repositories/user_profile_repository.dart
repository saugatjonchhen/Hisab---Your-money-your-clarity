import 'package:hive/hive.dart';
import '../models/user_profile_model.dart';

class UserProfileRepository {
  static const String _boxName = 'user_profile';

  Future<Box<UserProfile>> _openBox() async {
    return await Hive.openBox<UserProfile>(_boxName);
  }

  Future<UserProfile?> getProfile() async {
    final box = await _openBox();
    return box.get('current_profile');
  }

  Future<void> saveProfile(UserProfile profile) async {
    final box = await _openBox();
    await box.put('current_profile', profile);
  }

  Future<bool> hasProfile() async {
    final box = await _openBox();
    return box.containsKey('current_profile');
  }

  Future<void> clearProfile() async {
    final box = await _openBox();
    await box.delete('current_profile');
  }
}
