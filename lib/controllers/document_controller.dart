import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../models/document.dart';
import '../services/api_service.dart';

class DocumentController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Document> _documents = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Document> get documents => _documents;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> uploadDocument({
  required String token,
  required int tripId,
  required File file,
}) async {
  _setLoading(true);
  _setError(null);

  try {
    // Call the updated API service method that sends the file
    final response = await _apiService.uploadDocument(
      token: token,
      tripId: tripId,
      file: file,
    );

    print("Document upload API response: $response");

    _setLoading(false);

    if (response.status && response.data != null) {
      // Add the newly uploaded document to the list
      _documents.add(response.data!);
      notifyListeners();
      return true;
    } else {
      // If backend returns error
      _setError(response.message ?? 'Upload failed');
      return false;
    }
  } catch (e) {
    _setLoading(false);
    _setError('Unexpected error: $e');
    return false;
  }
}

  Future<bool> loadDocuments(String token, int tripId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getDocuments(token, tripId);
      print(" load document load ${response.data}");
      _setLoading(false);

      if (response.status && response.data != null) {
        _documents = response.data!;
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

  void clearDocuments() {
    _documents.clear();
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
}
