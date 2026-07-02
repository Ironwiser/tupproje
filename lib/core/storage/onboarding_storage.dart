import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/user_type.dart';

abstract final class OnboardingStorage {
  static const _userTypeKey = 'pending_user_type';

  static Future<void> savePendingUserType(UserType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTypeKey, type.name);
  }

  static Future<UserType?> getPendingUserType() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_userTypeKey);
    if (value == null) return null;
    return UserType.values.byName(value);
  }

  static Future<void> clearPendingUserType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userTypeKey);
  }
}
