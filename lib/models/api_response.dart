import 'user.dart';

class AuthResponse {
  final bool status;
  final String message;
  final String? token;
  final User? user;

  AuthResponse({
    required this.status,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class ApiResponse<T> {
  final bool status;
  final String message;
  final T? data;
  final List<String>? errors;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT) {
    return ApiResponse<T>(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : null,
      errors: json['errors'] != null 
          ? List<String>.from(json['errors']) 
          : null,
    );
  }
}
