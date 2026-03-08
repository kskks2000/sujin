class Session {
  Session({
    required this.token,
    required this.baseUrl,
    required this.userName,
    required this.loginId,
    required this.userRole,
  });

  final String token;
  final String baseUrl;
  final String userName;
  final String loginId;
  final String userRole;

  factory Session.fromJson(Map<String, dynamic> json, String baseUrl) {
    final user = json['user'] as Map<String, dynamic>;
    return Session(
      token: json['access_token'] as String,
      baseUrl: baseUrl,
      userName: user['name'] as String,
      loginId: user['login_id'] as String,
      userRole: user['user_role'] as String,
    );
  }
}

