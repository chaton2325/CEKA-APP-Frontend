import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  ApiService get apiService => _apiService;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    if (_token != null) {
      _apiService.setToken(_token);
      await fetchUser();
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access_token'];
        _user = User.fromJson(data['user']);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _token!);
        _apiService.setToken(_token);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.register(username, email, password);
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['access_token'];
        _user = User.fromJson(data['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _token!);
        _apiService.setToken(_token);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Register error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _apiService.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    notifyListeners();
  }

  Future<void> fetchUser() async {
    try {
      final response = await _apiService.getMe();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = User.fromJson(data['user']);
        notifyListeners();
      } else if (response.statusCode == 401) {
        await logout();
      }
    } catch (e) {
      debugPrint('Fetch user error: $e');
    }
  }

  Future<bool> updateProfile({String? username, String? bio, File? profilePhoto, File? bannerPhoto}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final streamedResponse = await _apiService.updateProfile(
        username: username,
        bio: bio,
        profilePhoto: profilePhoto,
        bannerPhoto: bannerPhoto,
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = User.fromJson(data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<String?> deleteAccount(String currentPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.deleteAccount(currentPassword);
      if (response.statusCode == 200) {
        await logout();
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final data = jsonDecode(response.body);
      _isLoading = false;
      notifyListeners();
      return data['error']?.toString() ?? 'delete_account_failed';
    } catch (e) {
      debugPrint('Delete account error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return 'delete_account_failed';
  }

  Future<String?> requestDataDeletion(String reason) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.requestDataDeletion(reason);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final data = jsonDecode(response.body);
      _isLoading = false;
      notifyListeners();
      return data['error']?.toString() ?? 'data_deletion_request_failed';
    } catch (e) {
      debugPrint('Data deletion request error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return 'data_deletion_request_failed';
  }
}
