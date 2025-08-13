import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  final String id;
  final String fileName;
  final String fileUrl;
  final String category;
  final List<String> tags;
  final DateTime uploadDate;
  final String userId;
  final int fileSize;
  final String fileType;
  final String mimeType; // Fixed: Made this a proper field
  final String? description;
  final Map<String, dynamic>? metadata;

  DocumentModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.category,
    required this.tags,
    required this.uploadDate,
    required this.userId,
    required this.fileSize,
    required this.fileType,
    required this.mimeType, // Fixed: Required parameter
    this.description,
    this.metadata,
  });

  // Create DocumentModel from Firestore map
  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] ?? '',
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      category: map['category'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      uploadDate: map['uploadDate'] is Timestamp 
          ? (map['uploadDate'] as Timestamp).toDate()
          : DateTime.parse(map['uploadDate'] ?? DateTime.now().toIso8601String()),
      userId: map['userId'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      fileType: map['fileType'] ?? '',
      mimeType: map['mimeType'] ?? 'application/octet-stream', // Fixed: Added mimeType
      description: map['description'],
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata']) 
          : null,
    );
  }

  // Convert DocumentModel to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
      'category': category,
      'tags': tags,
      'uploadDate': Timestamp.fromDate(uploadDate),
      'userId': userId,
      'fileSize': fileSize,
      'fileType': fileType,
      'mimeType': mimeType, // Fixed: Added mimeType to map
      'description': description,
      'metadata': metadata,
    };
  }

  // Create a copy with updated fields
  DocumentModel copyWith({
    String? id,
    String? fileName,
    String? fileUrl,
    String? category,
    List<String>? tags,
    DateTime? uploadDate,
    String? userId,
    int? fileSize,
    String? fileType,
    String? mimeType,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      uploadDate: uploadDate ?? this.uploadDate,
      userId: userId ?? this.userId,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      mimeType: mimeType ?? this.mimeType, // Fixed: Added mimeType
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
    );
  }

  // Get formatted file size
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Check if document is an image
  bool get isImage {
    final imageTypes = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageTypes.contains(fileType.toLowerCase());
  }

  // Check if document is a PDF
  bool get isPdf {
    return fileType.toLowerCase() == 'pdf';
  }

  // Check if document is a Word document
  bool get isWordDocument {
    final wordTypes = ['doc', 'docx'];
    return wordTypes.contains(fileType.toLowerCase());
  }

  // Get file icon based on type
  String get fileIcon {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return '🖼️';
      case 'txt':
        return '📄';
      default:
        return '📎';
    }
  }

  // Get relative upload date
  String get relativeUploadDate {
    final now = DateTime.now();
    final difference = now.difference(uploadDate);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${uploadDate.day}/${uploadDate.month}/${uploadDate.year}';
    }
  }

  @override
  String toString() {
    return 'DocumentModel(id: $id, fileName: $fileName, category: $category, fileSize: $fileSize, uploadDate: $uploadDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DocumentModel &&
      other.id == id &&
      other.fileName == fileName &&
      other.fileUrl == fileUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^ fileName.hashCode ^ fileUrl.hashCode;
  }
}