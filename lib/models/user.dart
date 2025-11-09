import 'dart:io';

import 'package:flutter/material.dart';

class User {
  final int id;
  final String? first_name;
  final String? lastName;
  final String? profile_picture; // URL from server
  final String email;
  final String? phone;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Local file for picked image (optional)
  final File? profilePictureFile;

  User({
    required this.id,
    required this.first_name,
    this.lastName,
    this.profile_picture,
    this.email = '',
    this.phone,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.profilePictureFile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      first_name: json['first_name'] ?? '',
      lastName: json['last_name'],
      email: json['email'] ?? '',
      profile_picture: json['profile_picture'], // server URL
      phone: json['phone'],
      address: json['address'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': first_name,
      'last_name': lastName,
      'email': email,
      'profile_picture': profile_picture, // URL only
      'phone': phone,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? first_name,
    String? lastName,
    String? profilePictureUrl,
    File? profilePictureFile,
    String? email,
    String? phone,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      first_name: first_name ?? this.first_name,
      lastName: lastName ?? this.lastName,
      profile_picture: profilePictureUrl ?? this.profile_picture,
      profilePictureFile: profilePictureFile ?? this.profilePictureFile,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Helper to get the correct ImageProvider for profile picture
  /// Returns FileImage if local file exists, else NetworkImage from server URL
  ImageProvider getProfileImage({String fallbackUrl = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRaAsJaTD22xdCgfrjTCJzLQmODiZ-tYaXisA&s'}) {
    if (profilePictureFile != null) {
      print('Using local profile picture file.');
      return FileImage(profilePictureFile!);
    } else if (profile_picture != null && profile_picture!.isNotEmpty) {
      print('Using profile picture from server URL.');
      return NetworkImage(profile_picture!);
    } else {
      print('Using fallback profile picture URL.');
      return NetworkImage(fallbackUrl);
    }
  }
}
