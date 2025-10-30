class ApiConfig {
  static const String baseUrl = 'http://192.168.0.128:8000/api';

  // Authentication endpoints
  static const String sendOtp = '/send-otp';
  static const String verifyOtp = '/verify-otp';
  static const String register = '/register';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Profile endpoints
  static const String profile = '/profile';

  // Trip endpoints
  static const String trips = '/trips';

  // Document endpoints
  static String documents(int tripId) => '/trips/$tripId/documents';

  // Favourite endpoints
  static String favouriteTripAdd(int tripId) => '/trips/$tripId/favourite';
  static String favouriteTripRemove(int tripId) => '/trips/$tripId/favourite';
  static const String favouriteTrips = '/trips/getfavourites';

  // Headers
  static Map<String, String> getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
