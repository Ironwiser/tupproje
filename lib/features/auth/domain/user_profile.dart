import '../../auth/domain/user_type.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.userType,
    this.fullName,
    this.companyId,
    this.companyName,
    this.isPremium = false,
  });

  final String id;
  final UserType userType;
  final String? fullName;
  final String? companyId;
  final String? companyName;
  final bool isPremium;

  factory UserProfile.fromJson(Map<String, dynamic> json, {String? companyName}) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      userType: UserType.values.byName(json['user_type'] as String? ?? 'individual'),
      companyId: json['company_id'] as String?,
      companyName: companyName,
      isPremium: json['is_premium'] as bool? ?? false,
    );
  }
}
