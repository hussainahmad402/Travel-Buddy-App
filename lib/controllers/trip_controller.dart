import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/api_service.dart';

class TripController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<Trip> _trips = [];
  Trip? _selectedTrip;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Trip> get trips => _trips;
  Trip? get selectedTrip => _selectedTrip;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> createTrip({
    
    required String token,
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.createTrip(
        token: token,
        title: title,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        notes: notes,
      );
      _setLoading(false);
        print("response data create trip ${response.data!.id}");
      
      if (response.status && response.data != null) {
        _trips.add(response.data!);
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

  Future<bool> loadTrips(String token) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getTrips(token);
      print("response data 1: ${response}");
      _setLoading(false);
      
      if (response.status && response.data != null) {
        _trips = response.data!;
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

  Future<bool> loadTrip(String token, int tripId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getTrip(token, tripId);
      _setLoading(false);
      
      if (response.status && response.data != null) {
        _selectedTrip = response.data!;
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

  Future<bool> updateTrip({
    required String token,
    required int tripId,
    String? notes,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.updateTrip(
        token: token,
        tripId: tripId,
        notes: notes,
      );
      _setLoading(false);
      
      if (response.status && response.data != null) {
        // Update the trip in the list
        final index = _trips.indexWhere((trip) => trip.id == tripId);
        if (index != -1) {
          _trips[index] = response.data!;
        }
        
        // Update selected trip if it's the same
        if (_selectedTrip?.id == tripId) {
          _selectedTrip = response.data!;
        }
        
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

  Future<bool> deleteTrip(String token, int tripId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.deleteTrip(token, tripId);
      _setLoading(false);
      
      if (response.status) {
        // Remove trip from list
        _trips.removeWhere((trip) => trip.id == tripId);
        
        // Clear selected trip if it's the same
        if (_selectedTrip?.id == tripId) {
          _selectedTrip = null;
        }
        
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

  void selectTrip(Trip trip) {
    _selectedTrip = trip;
    notifyListeners();
  }

  void clearSelectedTrip() {
    _selectedTrip = null;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  void clearTrips() {
    _trips.clear();
    _selectedTrip = null;
    notifyListeners();
  }
}
