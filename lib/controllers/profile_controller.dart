import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Added this import
import '../models/user.dart';
import '../services/api_service.dart';

class ProfileController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker(); // Added image picker instance

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

  // --- NEW METHOD ---
  /// Handles the logic of picking an image from the gallery.
  /// Returns a File object or null if no image is selected.
  /// Throws an exception if picking fails, which the UI can catch.
  Future<File?> pickImageFromGallery() async {
    print("Controller picking image...");
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
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
    String? firstName,
    String? lastName,
    File? profilePicture,
    String? phone,
    String? address,
  }) async {
    _setLoading(true);
    _setError(null);
    print(
        'Updating profile with firstName: $firstName, lastName: $lastName, phone: $phone, address: $address');

    try {
      final response = await _apiService.updateUserProfile(
        token: token,
        firstName: firstName,
        lastName: lastName,
        profilePicture: profilePicture,
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