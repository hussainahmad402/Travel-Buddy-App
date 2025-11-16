import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/trip.dart';
import '../models/document.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<AuthResponse> sendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sendOtp}?email=$email'),
        headers: ApiConfig.getHeaders(),
      );

      final data = json.decode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      return AuthResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.verifyOtp}?email=$email&otp=$otp',
        ),
        headers: ApiConfig.getHeaders(),
      );

      final data = json.decode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      return AuthResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.register}?name=$name&email=$email&password=$password&password_confirmation=$passwordConfirmation',
        ),
        headers: ApiConfig.getHeaders(),
      );

      final data = json.decode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      return AuthResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.login}?email=$email&password=$password',
        ),
        headers: ApiConfig.getHeaders(),
      );

      print("login api response ${response.statusCode}");

      final data = json.decode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      return AuthResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.forgotPassword}?email=$email',
        ),
        headers: ApiConfig.getHeaders(),
      );

      final data = json.decode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      return AuthResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.resetPassword}?otp=$otp&email=$email&new_password=$newPassword',
        ),
        headers: ApiConfig.getHeaders(),
      );

      final data = json.decode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      return AuthResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<User>> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profile}'),
        headers: ApiConfig.getHeaders(token: token),
      );

      print("get profile api response ${response.body}");

      final data = json.decode(response.body);
      return ApiResponse.fromJson(data, (json) => User.fromJson(json));
    } catch (e) {
      return ApiResponse<User>(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<User>> updateUserProfile({
    required String token,
    String? firstName,
    String? lastName,
    File? profilePicture,
    String? phone,
    String? address,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profile}');
      final request = http.MultipartRequest('POST', uri); // send as POST
      request.headers.addAll(
        ApiConfig.getHeaders(
          token: token,
          ContentType: true, // make sure we don’t force application/json
        ),
      );
      request.fields['_method'] = 'PUT'; // spoof PUT for Laravel

      if (firstName != null) request.fields['first_name'] = firstName;
      if (lastName != null) request.fields['last_name'] = lastName;
      if (phone != null) request.fields['phone'] = phone;
      if (address != null) request.fields['address'] = address;

      if (profilePicture != null) {
        final file = await http.MultipartFile.fromPath(
          'profile_picture',
          profilePicture.path,
        );
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.fromJson(data, (json) => User.fromJson(json));
      } else {
        return ApiResponse(
          status: false,
          message:
              'Failed to update profile: ${data['message'] ?? response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<void>> deleteUserProfile(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profile}'),
        headers: ApiConfig.getHeaders(token: token),
      );

      final data = json.decode(response.body);
      print("api response data : ${data}");
      return ApiResponse.fromJson(data, null);
    } catch (e) {
      return ApiResponse<void>(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Trip>> createTrip({
    required String token,
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
  }) async {
    try {
      final body = {
        'title': title,
        'destination': destination,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        if (notes != null) 'notes': notes,
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.trips}'),
        headers: ApiConfig.getHeaders(token: token),
        body: json.encode(body),
      );

      final data = json.decode(response.body);
      return ApiResponse.fromJson(data, (json) => Trip.fromJson(json));
    } catch (e) {
      return ApiResponse<Trip>(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<List<Trip>>> getTrips(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.trips}'),
        headers: ApiConfig.getHeaders(token: token),
      );

      final data = json.decode(response.body);
      print("response data: $data");

      if (data['body'] is List) {
        final trips = (data['body'] as List)
            .map((json) => Trip.fromJson(json))
            .toList();

        print("parsed trips: $trips");

        return ApiResponse<List<Trip>>(
          status: data['status'] ?? false,
          message: data['message'] ?? '',
          data: trips,
        );
      }

      return ApiResponse<List<Trip>>(
        status: false,
        message: 'Invalid response format',
      );
    } catch (e) {
      return ApiResponse<List<Trip>>(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Trip>> getTrip(String token, int tripId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.trips}/$tripId'),
        headers: ApiConfig.getHeaders(token: token),
      );

      final data = json.decode(response.body);
      return ApiResponse.fromJson(data, (json) => Trip.fromJson(json));
    } catch (e) {
      return ApiResponse<Trip>(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
Future<ApiResponse<Trip>> updateTrip({
  required String token,
  required int tripId,
  required String title,
  required String destination,
  required String startDate,
  required String endDate,
  String? notes,
}) async {
  try {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.trips}/$tripId',
    );

    final body = {
      'title': title,
      'destination': destination,
      'start_date': startDate,
      'end_date': endDate,
    };

    if (notes != null && notes.isNotEmpty) {
      body['notes'] = notes;
    }

    final response = await http.put(
      uri,
      headers: ApiConfig.getHeaders(token: token),
      body: jsonEncode(body),
    );

    final data = json.decode(response.body);

    return ApiResponse.fromJson(data, (json) => Trip.fromJson(json));
  } catch (e) {
    return ApiResponse<Trip>(
      status: false,
      message: 'Network error: ${e.toString()}',
    );
  }
}

  Future<ApiResponse<void>> deleteTrip(String token, int tripId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.trips}/$tripId'),
        headers: ApiConfig.getHeaders(token: token),
      );

      final data = json.decode(response.body);
      return ApiResponse.fromJson(data, null);
    } catch (e) {
      return ApiResponse<void>(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Document>> uploadDocument({
    required String token,
    required int tripId,
    required File file,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.documents(tripId)}',
      );

      // Use MultipartRequest
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Attach the file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // must match Laravel's $request->file('file')
          file.path,
          filename: file.path.split('/').last,
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = json.decode(response.body);
      print("upload document api response data: $data");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.fromJson(data, (json) => Document.fromJson(json));
      } else {
        return ApiResponse<Document>(
          status: false,
          message: 'Failed: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse<Document>(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<List<Document>>> getDocuments(
    String token,
    int tripId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.documents(tripId)}'),
        headers: ApiConfig.getHeaders(token: token),
      );

      print("get document api response ${response.body}");

      final data = json.decode(response.body);

      if (data['documents'] is List) {
        final documents = (data['documents'] as List)
            .map((json) => Document.fromJson(json))
            .toList();

        return ApiResponse<List<Document>>(
          status: data['status'] ?? false,
          message: data['message'] ?? '',
          data: documents,
        );
      }

      return ApiResponse<List<Document>>(
        status: false,
        message: 'Invalid response format',
      );
    } catch (e) {
      return ApiResponse<List<Document>>(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<List<Trip>>> getFavourites(String token) async {
    try {
      print("favourites api request: $token");
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.favouriteTrips}'),
        headers: ApiConfig.getHeaders(token: token),
      );
      final data = json.decode(response.body);
      print("favourites api response   sdfa: ${data['data']}");
      if (data['data'] is List) {
        final trips = (data['data'] as List)
            .map((json) => Trip.fromJson(json))
            .toList();
        print("favourites api response trips: $trips");
        return ApiResponse<List<Trip>>(
          status: data['status'] ?? false,
          message: data['message'] ?? '',
          data: trips,
        );
      }
      return ApiResponse<List<Trip>>(
        status: false,
        message: 'Invalid response format',
      );
    } catch (e) {
      return ApiResponse<List<Trip>>(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<void>> addFavourite(String token, int tripId) async {
    try {
      print("add favourite api request: $token $tripId");
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.trips}/$tripId/favourite'),
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode({'trip_id': tripId}),
      );
      final data = json.decode(response.body);
      print("add favourite api response: $data");
      return ApiResponse.fromJson(data, null);
    } catch (e) {
      return ApiResponse<void>(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<void>> removeFavourite(String token, int tripId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.trips}/$tripId/favourite'),
        headers: ApiConfig.getHeaders(token: token),
      );
      final data = json.decode(response.body);
      print("remove favourite api response: $data");
      return ApiResponse.fromJson(data, null);
    } catch (e) {
      return ApiResponse<void>(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
