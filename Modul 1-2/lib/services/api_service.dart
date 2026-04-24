import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://localhost:3000/api"; 

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      // DEBUG: Lihat apa yang dikirim Backend di Console VS Code
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Jika gagal, coba ambil pesan error-nya
        try {
          final data = jsonDecode(response.body);
          throw data['message'] ?? 'Gagal Login';
        } catch (e) {
          throw 'Error Server: ${response.statusCode}';
        }
      }
    } catch (e) {
      // Supaya pesan error di SnackBar lebih bersih
      rethrow; 
    }
  }
}