import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelbuddy/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:travelbuddy/models/user.dart';

class ChatController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getChatList(String userId) {
    return _firestore
        .collection('chat_summaries')
        .doc(userId)
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<List<User>> fetchAllUsers(String token) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/allusers"),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    print('Fetch Users Response: ${response.body}');
    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final users = (data['users'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();
      return users;
    } else {
      throw Exception("Failed to load users: ${response.statusCode}");
    }
  }
}


