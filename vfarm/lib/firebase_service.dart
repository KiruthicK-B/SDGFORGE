import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vfarm/models/document_model.dart';
import 'package:vfarm/models/user_profile_model.dart';
import 'session_manager.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final _sessionManager = SessionManager.instance;

  // Session Management
  static Future<void> initializeWithSession(String userId, String username) async {
    try {
      final profile = await getUserProfile(userId);
      await _sessionManager.saveUserSession(
        userId: userId,
        username: username,
        profile: profile,
      );
      if (profile != null) _sessionManager.setCurrentUserProfile(profile);
    } catch (e) {
      debugPrint('FirebaseService: Error initializing session: $e');
    }
  }

  static Future<bool> initializeFromStoredSession() async {
    try {
      final restored = await _sessionManager.initializeFromStoredSession();
      if (restored) {
        final userId = _sessionManager.getCurrentUserId();
        if (userId != null) {
          final profile = await getUserProfile(userId);
          if (profile != null) _sessionManager.setCurrentUserProfile(profile);
        }
      }
      return restored;
    } catch (e) {
      return false;
    }
  }

  // Authentication
  static Future<UserProfileModel?> loginWithEmailPassword(String email, String password) async {
    try {
      final querySnapshot = await _firestore
          .collection('userdetails')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        data['uid'] = doc.id; // Ensure uid is set to document ID
        final profile = UserProfileModel.fromMap(data);

        await _sessionManager.saveUserSession(
          userId: doc.id,
          username: profile.username,
          email: email,
          profile: profile,
        );

        return profile;
      } else {
        throw Exception('Invalid email or password');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> logout() async {
    try {
      await _auth.signOut();
      await _sessionManager.clearSession();
    } catch (e) {
      debugPrint('FirebaseService: Logout error: $e');
    }
  }

  // Current User Methods
  static String? getCurrentUserId() => _sessionManager.getCurrentUserId();
  static UserProfileModel? getCurrentUserProfile() => _sessionManager.getCurrentUserProfile();
  static bool isAuthenticated() => _sessionManager.isAuthenticated();

  static Future<void> ensureAuthenticated() async {
    await _sessionManager.ensureAuthenticated();
  }

  // Document Methods - Only for current sessioned user
  static Stream<List<DocumentModel>> getUserDocuments({required String userId}) {
    final userId = getCurrentUserId();
    if (userId == null) {
      debugPrint('No authenticated user - returning empty stream');
      return Stream.value([]);
    }

    debugPrint('Getting documents for current user: $userId');
    
    return _firestore
        .collection('documents')
        .where('userId', isEqualTo: userId)
        .orderBy('uploadDate', descending: true)
        .snapshots()
        .map((snapshot) {
      debugPrint('Firestore query returned ${snapshot.docs.length} documents for user: $userId');
      
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          return DocumentModel(
            id: doc.id,
            userId: data['userId'] ?? '',
            fileName: data['fileName'] ?? 'Unknown',
            fileUrl: data['fileUrl'] ?? '',
            category: data['category'] ?? 'Other',
            tags: List<String>.from(data['tags'] ?? []),
            uploadDate: (data['uploadDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
            fileSize: data['fileSize']?.toInt() ?? 0,
            fileType: data['fileType'] ?? '',
            mimeType: data['mimeType'] ?? '',
          );
        } catch (e) {
          debugPrint('Error parsing document ${doc.id}: $e');
          return DocumentModel(
            id: doc.id,
            userId: userId,
            fileName: 'Error loading document',
            fileUrl: '',
            category: 'Other',
            tags: [],
            uploadDate: DateTime.now(),
            fileSize: 0,
            fileType: '',
            mimeType: '',
          );
        }
      }).toList();
    }).handleError((error) {
      debugPrint('Stream error: $error');
      return <DocumentModel>[];
    });
  }

  static Future<void> uploadDocument(
    File file,
    String fileName, String userId, {
    String category = 'Other',
    List<String> tags = const [],
  }) async {
    await ensureAuthenticated();
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    try {
      debugPrint('Starting upload for file: $fileName, userId: $userId');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = file.path.split('.').last;
      final storageFileName = '${timestamp}_${fileName.replaceAll(' ', '_')}.$fileExtension';
      
      final storageRef = _storage
          .ref()
          .child('documents')
          .child(userId)
          .child(storageFileName);
      
      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      final fileSize = await file.length();
      
      final documentData = {
        'userId': userId,
        'fileName': fileName,
        'fileUrl': downloadUrl,
        'category': category,
        'tags': tags,
        'uploadDate': FieldValue.serverTimestamp(),
        'fileSize': fileSize,
        'fileType': fileExtension.toLowerCase(),
        'mimeType': _getMimeType(file.path),
        'storagePath': storageRef.fullPath,
      };
      
      await _firestore.collection('documents').add(documentData);
      debugPrint('Document uploaded successfully for user: $userId');
      
    } catch (e) {
      debugPrint('Error uploading document: $e');
      throw Exception('Failed to upload document: $e');
    }
  }

  static Future<void> deleteDocument(String documentId, String fileUrl) async {
    await ensureAuthenticated();
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    try {
      // Verify document belongs to current user before deleting
      final doc = await _firestore.collection('documents').doc(documentId).get();
      if (doc.exists && doc.data()?['userId'] == userId) {
        await _firestore.collection('documents').doc(documentId).delete();
        
        if (fileUrl.isNotEmpty) {
          try {
            final storageRef = _storage.refFromURL(fileUrl);
            await storageRef.delete();
          } catch (e) {
            debugPrint('Error deleting file from storage: $e');
          }
        }
        debugPrint('Document deleted successfully for user: $userId');
      } else {
        throw Exception('Document not found or unauthorized');
      }
    } catch (e) {
      debugPrint('Error deleting document: $e');
      throw Exception('Failed to delete document: $e');
    }
  }

  static Future<List<DocumentModel>> searchDocuments(String query) async {
    await ensureAuthenticated();
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    try {
      final snapshot = await _firestore
          .collection('documents')
          .where('userId', isEqualTo: userId)
          .get();

      final documents = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return DocumentModel.fromMap(data);
      }).toList();

      final filteredDocs = documents.where((doc) {
        return doc.fileName.toLowerCase().contains(query.toLowerCase()) ||
            doc.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())) ||
            doc.category.toLowerCase().contains(query.toLowerCase());
      }).toList();

      filteredDocs.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
      return filteredDocs;
    } catch (e) {
      throw Exception('Search failed: ${e.toString()}');
    }
  }

  // Profile Methods
  static Future<UserProfileModel?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('userdetails').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id; // Ensure uid is set
        return UserProfileModel.fromMap(data);
      }
      
      doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id; // Ensure uid is set
        return UserProfileModel.fromMap(data);
      }
      
      return null;
    } catch (e) {
      debugPrint('FirebaseService.getUserProfile error: $e');
      rethrow;
    }
  }

  static Future<void> createOrUpdateProfile(UserProfileModel profile) async {
    await ensureAuthenticated();
    final currentUserId = getCurrentUserId();
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      String userId = profile.uid.isNotEmpty ? profile.uid : currentUserId;
      
      // Only allow updating current user's profile
      if (userId != currentUserId) {
        throw Exception('Unauthorized profile update');
      }

      await _firestore
          .collection('userdetails')
          .doc(userId)
          .set(profile.toMap(), SetOptions(merge: true));

      _sessionManager.setCurrentUserProfile(profile);
    } catch (e) {
      throw Exception('Failed to save profile: ${e.toString()}');
    }
  }

  static Future<String> uploadProfileImage(File imageFile) async {
    await ensureAuthenticated();
    final userId = getCurrentUserId();
    if (userId == null) throw Exception('User not authenticated');

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = _storage
          .ref()
          .child('profile_images')
          .child('${userId}_$timestamp.jpg');
      
      final uploadTask = await storageRef.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Profile image upload failed: ${e.toString()}');
    }
  }

  // Utility Methods
  static String _getMimeType(String filePath) {
    String extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}