class AuthUser {
  final int id;
  final String email;
  final String username;
  final String role;
  final String? firstName;
  final String? lastName;

  /// Profile avatar URL or path (may be relative); null if none.
  final String? avatarUrl;

  AuthUser({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    this.firstName,
    this.lastName,
    this.avatarUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> j) {
    final rawAvatar = j['avatar'];
    String? avatarUrl;
    if (rawAvatar is String && rawAvatar.trim().isNotEmpty) {
      avatarUrl = rawAvatar.trim();
    }
    return AuthUser(
      id: j['id'] as int,
      email: j['email'] as String,
      username: j['username'] as String,
      role: j['role'] as String? ?? 'USER',
      firstName: j['first_name'] as String?,
      lastName: j['last_name'] as String?,
      avatarUrl: avatarUrl,
    );
  }

  AuthUser copyWith({
    String? email,
    String? username,
    String? role,
    String? firstName,
    String? lastName,
    String? avatarUrl,
  }) {
    return AuthUser(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  bool get isModeratorOrAdmin => role == 'MODERATOR' || role == 'ADMIN';
}
