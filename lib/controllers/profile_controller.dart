import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class ProfileController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _errorMessage;
  User? _userProfile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get userProfile => _userProfile;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> loadUserProfile(String token) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getUserProfile(token);
      _setLoading(false);
      
      if (response.status && response.data != null) {
        _userProfile = response.data!;
        notifyListeners();
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

  Future<bool> updateUserProfile({
    required String token,
    String? name,
    String? phone,
    String? address,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.updateUserProfile(
        token: token,
        name: name,
        phone: phone,
        address: address,
      );
      _setLoading(false);
      
      if (response.status && response.data != null) {
        _userProfile = response.data!;
        notifyListeners();
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

  Future<bool> deleteUserProfile(String token) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.deleteUserProfile(token);
      _setLoading(false);
      
      if (response.status) {
        _userProfile = null;
        notifyListeners();
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

  void clearError() {
    _setError(null);
  }

  void clearProfile() {
    _userProfile = null;
    notifyListeners();
  }
}
