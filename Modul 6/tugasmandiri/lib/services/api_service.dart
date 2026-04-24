import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "https://dummyjson.com";
  static const _cachedUserDataKey = 'cached_user_data';

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
              'expiresInMins': 30,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {...data, 'token': data['accessToken'] ?? data['token']};
      } else {
        try {
          final data = jsonDecode(response.body);
          throw data['message'] ?? 'Gagal Login';
        } catch (e) {
          throw 'Error Server: ${response.statusCode}';
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> fetchAndCacheOnlineData() async {
    final response = await http
        .get(Uri.parse('$baseUrl/users/1'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw 'Gagal mengambil data online';
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final fullName = '${data['firstName']} ${data['lastName']}';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedUserDataKey, fullName);

    return fullName;
  }

  Future<String> getCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cachedUserDataKey) ?? 'Belum ada cache';
  }
}
