class Document {
  final int id;
  final String fileName;
  final String filePath;
  final String fileType; // 👈 Added field
  final int tripId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Document({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileType, // 👈 Added
    required this.tripId,
    this.createdAt,
    this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? 0,
      fileName: json['file_name'] ?? '',
      filePath: json['file_path'] ?? '',
      fileType: json['file_type'] ?? 'unknown', // 👈 Added
      tripId: json['trip_id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType, // 👈 Added
      'trip_id': tripId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
