class GuruAuthSession {
  final String accessToken;
  final String role;
  final Map<String, dynamic> user;

  const GuruAuthSession({
    required this.accessToken,
    required this.role,
    required this.user,
  });

  bool get isValidGuruSession {
    return accessToken.trim().isNotEmpty && role.trim().toLowerCase() == 'guru';
  }

  factory GuruAuthSession.fromJson(Map<String, dynamic> json) {
    final userData = json['user'];
    final user = userData is Map<String, dynamic>
        ? userData
        : const <String, dynamic>{};

    return GuruAuthSession(
      accessToken: json['token']?.toString() ?? '',
      role: user['role']?.toString() ?? '',
      user: user,
    );
  }
}
