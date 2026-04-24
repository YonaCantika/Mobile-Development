import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  static const _tokenKey = 'jwt_token';
  static const _darkModeKey = 'pref_dark_mode';
  static const _displayNameKey = 'pref_display_name';

  bool _isLoading = false;
  String? _token;
  bool _isDarkMode = false;
  String _displayName = '';
  bool _isInitialized = false;

  bool get isLoading => _isLoading;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  bool get isDarkMode => _isDarkMode;
  String get displayName => _displayName;
  bool get isInitialized => _isInitialized;

  final ApiService _apiService = ApiService();

  AuthProvider() {
    initialize();
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _displayName = prefs.getString(_displayNameKey) ?? '';
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.login(username, password);
      _token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);
      if (_displayName.isEmpty) {
        _displayName = username;
        await prefs.setString(_displayNameKey, _displayName);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> setDisplayName(String value) async {
    _displayName = value.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayNameKey, _displayName);
    notifyListeners();
  }
}