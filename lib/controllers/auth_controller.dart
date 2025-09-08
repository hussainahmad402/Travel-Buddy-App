import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  String? _token;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _currentUser != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> sendOtp(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.sendOtp(email);
      _setLoading(false);
      
      if (response.status) {
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('An unexpected error occurred');
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.verifyOtp(email, otp);
      _setLoading(false);
      
      if (response.status) {
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('An unexpected error occurred');
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      _setLoading(false);
      print('response: ${response.user}');
      if (response.status) {
        if (response.token != null && response.status != null) {
          print("response.token: ${response.token}");
          _token = response.token;
          _currentUser = response.user;
          await StorageService.saveToken(_token!);
          await StorageService.setLoggedIn(true);
        }
        return true;
      } else {
        _setError(response.message);
        print("response.message: ${response.message}");
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('An unexpected error occurred');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.login(email, password);
      _setLoading(false);
      
      if (response.status) {
        if (response.token != null && response.user != null) {
          _token = response.token;
          _currentUser = response.user;
          await StorageService.saveToken(_token!);
          await StorageService.setLoggedIn(true);

          
        }
        return true;
      } else {
        _setError(response.message);
        print("response.message: ${response.message}");
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('An unexpected error occurred');
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.forgotPassword(email);
      _setLoading(false);
      
      if (response.status) {
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('An unexpected error occurred');
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      _setLoading(false);
      
      if (response.status) {
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError('An unexpected error occurred');
      return false;
    }
  }

  Future<void> loadStoredAuth() async {
    _token = await StorageService.getToken();
    final isLoggedIn = await StorageService.isLoggedIn();
    
    if (_token != null && isLoggedIn) {
      // Load user profile
      final response = await _apiService.getUserProfile(_token!);
      if (response.status && response.data != null) {
        _currentUser = response.data;
      } else {
        // Token might be expired, clear storage
        await logout();
      }
    }
    
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    await StorageService.clearAll();
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
}
