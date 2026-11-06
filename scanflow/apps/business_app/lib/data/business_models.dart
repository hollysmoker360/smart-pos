class UserSummary {
  const UserSummary({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;

  factory UserSummary.fromJson(Map<String, dynamic> json) => UserSummary(
        id: _requiredString(json, 'id'),
        email: _requiredString(json, 'email'),
        fullName: _requiredString(json, 'fullName'),
        role: _requiredString(json, 'role'),
      );
}

class BusinessSummary {
  const BusinessSummary({
    required this.id,
    required this.name,
    required this.status,
  });

  final String id;
  final String name;
  final String status;

  factory BusinessSummary.fromJson(Map<String, dynamic> json) =>
      BusinessSummary(
        id: _requiredString(json, 'id'),
        name: _requiredString(json, 'name'),
        status: _requiredString(json, 'status'),
      );
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
    required this.business,
  });

  final String token;
  final UserSummary user;
  final BusinessSummary? business;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson = _requiredMap(json, 'user');
    final businessJson = json['business'];
    return AuthSession(
      token: _requiredString(json, 'token'),
      user: UserSummary.fromJson(userJson),
      business: businessJson is Map<String, dynamic>
          ? BusinessSummary.fromJson(businessJson)
          : null,
    );
  }
}

class CurrentUser {
  const CurrentUser({required this.user, required this.business});

  final UserSummary user;
  final BusinessSummary business;

  factory CurrentUser.fromJson(Map<String, dynamic> json) => CurrentUser(
        user: UserSummary.fromJson(_requiredMap(json, 'user')),
        business: BusinessSummary.fromJson(_requiredMap(json, 'business')),
      );
}

class BranchSummary {
  const BranchSummary({
    required this.id,
    required this.name,
    required this.currency,
    required this.timezone,
    required this.active,
  });

  final String id;
  final String name;
  final String currency;
  final String timezone;
  final bool active;

  factory BranchSummary.fromJson(Map<String, dynamic> json) => BranchSummary(
        id: _requiredString(json, 'id'),
        name: _requiredString(json, 'name'),
        currency: _requiredString(json, 'currency'),
        timezone: _requiredString(json, 'timezone'),
        active: json['active'] as bool? ?? false,
      );
}

class EmployeeInvitation {
  const EmployeeInvitation({
    required this.invitationId,
    required this.email,
    required this.role,
    required this.invitationUrl,
    required this.expiresAt,
    required this.branchIds,
  });

  final String invitationId;
  final String email;
  final String role;
  final String invitationUrl;
  final DateTime expiresAt;
  final List<String> branchIds;

  factory EmployeeInvitation.fromJson(Map<String, dynamic> json) =>
      EmployeeInvitation(
        invitationId: _requiredString(json, 'invitationId'),
        email: _requiredString(json, 'email'),
        role: _requiredString(json, 'role'),
        invitationUrl: _requiredString(json, 'invitationUrl'),
        expiresAt: DateTime.parse(_requiredString(json, 'expiresAt')),
        branchIds: (json['branchIds'] as List<dynamic>? ?? const [])
            .map((id) => id.toString())
            .toList(growable: false),
      );
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('Response is missing a valid "$key" value');
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is Map<String, dynamic>) return value;
  throw FormatException('Response is missing a valid "$key" object');
}
