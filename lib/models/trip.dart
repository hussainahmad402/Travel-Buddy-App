import 'package:travelbuddy/models/document.dart';

class Trip {
  final int id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String? notes;
  final int userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  bool? isFavourite;
  final List<Document>? documents; // ✅ Added

  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.notes,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    required this.isFavourite,
    this.documents,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      destination: json['destination'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      notes: json['notes'],
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      isFavourite: (json['is_favourite'] ?? json['favourite'] ?? 0) == 1,
      documents: json['documents'] != null
          ? List<Document>.from(json['documents'].map((x) => Document.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'notes': notes,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_favourite': isFavourite,
      'documents': documents?.map((e) => e.toJson()).toList(),
    };
  }

  Trip copyWith({
    int? id,
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavourite,
    List<Document>? documents,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavourite: isFavourite ?? this.isFavourite,
      documents: documents ?? this.documents,
    );
  }
}
