// lib/services/custom_file_picker.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class CustomFilePickerService {
  static Future<FilePickResult?> pickFile(BuildContext context) async {
    if (kIsWeb) {
      return await _pickFileWeb(context);
    } else {
      return await _pickFileMobile(context);
    }
  }

  static Future<FilePickResult?> _pickFileWeb(BuildContext context) async {
    try {
      // Try file_picker first for web
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true, // Important for web
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        return FilePickResult(
          webBytes: file.bytes,
          fileName: file.name,
          fileSize: file.size,
        );
      }
    } catch (e) {
      // Fallback to image picker for web
      return await _pickImageWeb(context);
    }
    return null;
  }

  static Future<FilePickResult?> _pickImageWeb(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
    String? choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
          ],
        ),
      ),
    );

    ImageSource? source;
    if (choice == 'gallery') {
      source = ImageSource.gallery;
    } else if (choice == 'camera') {
      source = ImageSource.camera;
    }

    if (source != null) {
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (file != null) {
        final bytes = await file.readAsBytes();
        return FilePickResult(
          webBytes: bytes,
          fileName: file.name,
          fileSize: bytes.length,
        );
      }
    }

    return null;
  }

  static Future<FilePickResult?> _pickFileMobile(BuildContext context) async {
    String? choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select File Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image'),
              subtitle: const Text('Photos, screenshots'),
              onTap: () => Navigator.pop(context, 'image'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              subtitle: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Document'),
              subtitle: const Text('PDF, DOC, TXT files'),
              onTap: () => Navigator.pop(context, 'document'),
            ),
          ],
        ),
      ),
    );

    switch (choice) {
      case 'image':
        return await _pickImageMobile(ImageSource.gallery);
      case 'camera':
        return await _pickImageMobile(ImageSource.camera);
      case 'document':
        return await _pickDocumentMobile();
      default:
        return null;
    }
  }

  static Future<FilePickResult?> _pickImageMobile(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (file != null) {
        final mobileFile = File(file.path);
        final fileSize = await mobileFile.length();
        
        return FilePickResult(
          mobileFile: mobileFile,
          fileName: file.name,
          fileSize: fileSize,
        );
      }
    } catch (e) {
      throw Exception('Error picking image: $e');
    }
    return null;
  }

  static Future<FilePickResult?> _pickDocumentMobile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        if (file.path != null) {
          return FilePickResult(
            mobileFile: File(file.path!),
            fileName: file.name,
            fileSize: file.size,
          );
        }
      }
    } catch (e) {
      // Fallback to image picker if file picker fails
      throw Exception('Document picker failed. Please try selecting an image instead: $e');
    }
    return null;
  }

  // Helper method to validate file size
  static bool isFileSizeValid(int fileSize, {int maxSizeMB = 10}) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024; // Convert MB to bytes
    return fileSize <= maxSizeBytes;
  }

  // Helper method to get file extension
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  // Helper method to check if file type is supported
  static bool isSupportedFileType(String fileName) {
    const supportedExtensions = [
      'pdf', 'doc', 'docx', 'txt', 
      'jpg', 'jpeg', 'png', 'gif',
      'xls', 'xlsx'
    ];
    final extension = getFileExtension(fileName);
    return supportedExtensions.contains(extension);
  }
}

class FilePickResult {
  final File? mobileFile;
  final Uint8List? webBytes;
  final String fileName;
  final int fileSize;

  FilePickResult({
    this.mobileFile,
    this.webBytes,
    required this.fileName,
    required this.fileSize,
  });

  // Get file extension
  String get fileExtension => fileName.split('.').last.toLowerCase();

  // Check if it's an image
  bool get isImage => ['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension);

  // Check if it's a document
  bool get isDocument => ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'].contains(fileExtension);

  // Format file size for display
  String get formattedSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Validate file
  bool get isValid {
    return CustomFilePickerService.isSupportedFileType(fileName) &&
           CustomFilePickerService.isFileSizeValid(fileSize);
  }
}

// Enhanced Error Handling for File Operations
class FilePickerException implements Exception {
  final String message;
  final String? code;

  FilePickerException(this.message, {this.code});

  @override
  String toString() => 'FilePickerException: $message${code != null ? ' (Code: $code)' : ''}';
}

// File Upload Progress Callback
typedef FileUploadProgressCallback = void Function(double progress);

// Enhanced File Upload Service
class EnhancedFileUploadService {
  static Future<String> uploadFileWithProgress({
    required FilePickResult fileResult,
    required String category,
    required String userId,
    FileUploadProgressCallback? onProgress,
  }) async {
    try {
      // Validate file before upload
      if (!fileResult.isValid) {
        throw FilePickerException('Invalid file type or size too large');
      }

      // Generate unique file path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileResult.fileExtension;
      final fileName = '${timestamp}_${fileResult.fileName}';
      final path = 'documents/$userId/$category/$fileName';

      // Upload based on platform
      if (kIsWeb && fileResult.webBytes != null) {
        return await _uploadWebFile(
          fileResult.webBytes!,
          path,
          onProgress,
        );
      } else if (fileResult.mobileFile != null) {
        return await _uploadMobileFile(
          fileResult.mobileFile!,
          path,
          onProgress,
        );
      } else {
        throw FilePickerException('No valid file data found');
      }
    } catch (e) {
      throw FilePickerException('Upload failed: $e');
    }
  }

  static Future<String> _uploadWebFile(
    Uint8List fileBytes,
    String path,
    FileUploadProgressCallback? onProgress,
  ) async {
    // Implementation for web file upload with progress
    // This would integrate with your Firebase Storage service
    // For now, returning a placeholder
    return 'https://example.com/uploaded-file-url';
  }

  static Future<String> _uploadMobileFile(
    File file,
    String path,
    FileUploadProgressCallback? onProgress,
  ) async {
    // Implementation for mobile file upload with progress
    // This would integrate with your Firebase Storage service
    // For now, returning a placeholder
    return 'https://example.com/uploaded-file-url';
  }
}