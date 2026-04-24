import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _token;

  bool get isLoading => _isLoading;
  String? get token => _token;

  final ApiService _apiService = ApiService();

  Future<void> login(String username, String password) async {
  _isLoading = true;
  notifyListeners();

  try {
    final data = await _apiService.login(username, password);
    _token = data['token'];
    
    // Simpan ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', _token!);

    _isLoading = false;
    notifyListeners();
    
  } catch (e) {
    _isLoading = false;
    notifyListeners();
    rethrow; // notif MERAH
  }
}
}
