class LoginResponse {
  final String token;

  LoginResponse({required rthis.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
    );
  }
}