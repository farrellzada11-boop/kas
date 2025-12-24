import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../config/app_constants.dart';
import 'mock_data.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  String? _authToken;

  final ApiService _apiService = ApiService();

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  String? get error => _error;

  AuthService() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      final token = prefs.getString('auth_token');
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
        _authToken = token;
        if (token != null) {
          _apiService.setAuthToken(token);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
  }

  Future<void> _saveUserToStorage(User user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(user.toJson()));
      await prefs.setString('auth_token', token);
    } catch (e) {
      debugPrint('Error saving user to storage: $e');
    }
  }

  Future<void> _clearUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      await prefs.remove('auth_token');
    } catch (e) {
      debugPrint('Error clearing user from storage: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConstants.useMockData) {
        // Use mock data
        await Future.delayed(const Duration(milliseconds: 800));
        final user = MockData.getUserByEmail(email);

        if (user != null && password == 'password') {
          _currentUser = user;
          _authToken = 'mock_token_${user.id}';
          await _saveUserToStorage(user, _authToken!);
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = 'Email atau password salah';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        // Use API
        final response = await _apiService.post(
          AppConstants.loginEndpoint,
          {'email': email, 'password': password},
        );

        if (response['status'] == true) {
          final userData = response['data']['user'];
          final token = response['data']['token'];

          _currentUser = User.fromJson(userData);
          _authToken = token;
          _apiService.setAuthToken(token);
          await _saveUserToStorage(_currentUser!, token);
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = response['message'] ?? 'Login gagal';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConstants.useMockData) {
        // Use mock data
        await Future.delayed(const Duration(milliseconds: 800));
        final existingUser = MockData.getUserByEmail(email);
        if (existingUser != null) {
          _error = 'Email sudah terdaftar';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        final newUser = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          email: email,
          phone: phone,
          role: UserRole.user,
          createdAt: DateTime.now(),
        );

        _currentUser = newUser;
        _authToken = 'mock_token_${newUser.id}';
        await _saveUserToStorage(newUser, _authToken!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Use API
        final response = await _apiService.post(
          AppConstants.registerEndpoint,
          {'name': name, 'email': email, 'phone': phone, 'password': password},
        );

        if (response['status'] == true) {
          final userData = response['data']['user'];
          final token = response['data']['token'];

          _currentUser = User.fromJson(userData);
          _authToken = token;
          _apiService.setAuthToken(token);
          await _saveUserToStorage(_currentUser!, token);
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = response['message'] ?? 'Registrasi gagal';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    if (!AppConstants.useMockData && _authToken != null) {
      try {
        await _apiService.post(AppConstants.loginEndpoint.replaceAll('login', 'logout'), {});
      } catch (e) {
        debugPrint('Logout API error: $e');
      }
    }
    
    _currentUser = null;
    _authToken = null;
    _apiService.clearAuthToken();
    await _clearUserFromStorage();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
