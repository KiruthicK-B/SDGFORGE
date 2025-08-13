import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:vfarm/models/community_post_model.dart';

class CommunityService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _postsCollection = 'community_posts';

  // Create a new post
  static Future<bool> createPost({
    required String userId,
    required String username,
    String? userProfileImage,
    String? userLocation,
    required String content,
    List<File> images = const [],
    List<File> videos = const [],
  }) async {
    try {
      // Upload media files
      List<String> imageUrls = [];
      List<String> videoUrls = [];

      // Upload images
      for (int i = 0; i < images.length; i++) {
        final imageRef = _storage.ref().child('posts/$userId/${DateTime.now().millisecondsSinceEpoch}_image_$i.jpg');
        await imageRef.putFile(images[i]);
        final imageUrl = await imageRef.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      // Upload videos
      for (int i = 0; i < videos.length; i++) {
        final videoRef = _storage.ref().child('posts/$userId/${DateTime.now().millisecondsSinceEpoch}_video_$i.mp4');
        await videoRef.putFile(videos[i]);
        final videoUrl = await videoRef.getDownloadURL();
        videoUrls.add(videoUrl);
      }

      // Create post document
      final postData = {
        'userId': userId,
        'username': username,
        'userProfileImage': userProfileImage,
        'userLocation': userLocation,
        'content': content,
        'imageUrls': imageUrls,
        'videoUrls': videoUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'commentsCount': 0,
        'likedBy': [],
      };

      final docRef = await _firestore.collection(_postsCollection).add(postData);
      print('Post created successfully with ID: ${docRef.id}');
      return true;
    } catch (e) {
      print('Error creating post: $e');
      return false;
    }
  }

  // Get all posts with better error handling
  static Stream<List<CommunityPost>> getPosts() {
    print('Getting posts stream...');
    return _firestore
        .collection(_postsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Snapshot received: ${snapshot.docs.length} documents');
      
      if (snapshot.docs.isEmpty) {
        print('No posts found in collection');
        return <CommunityPost>[];
      }

      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          print('Processing document ${doc.id}: $data');
          
          // Handle Timestamp conversion
          DateTime? createdAt;
          DateTime? updatedAt;
          
          if (data['createdAt'] != null) {
            if (data['createdAt'] is Timestamp) {
              createdAt = (data['createdAt'] as Timestamp).toDate();
            } else if (data['createdAt'] is String) {
              createdAt = DateTime.parse(data['createdAt']);
            }
          }
          
          if (data['updatedAt'] != null) {
            if (data['updatedAt'] is Timestamp) {
              updatedAt = (data['updatedAt'] as Timestamp).toDate();
            } else if (data['updatedAt'] is String) {
              updatedAt = DateTime.parse(data['updatedAt']);
            }
          }

          // Create CommunityPost object manually to avoid fromJson issues
          return CommunityPost(
            id: doc.id,
            userId: data['userId'] ?? '',
            username: data['username'] ?? '',
            userProfileImage: data['userProfileImage'],
            userLocation: data['userLocation'],
            content: data['content'] ?? '',
            imageUrls: List<String>.from(data['imageUrls'] ?? []),
            videoUrls: List<String>.from(data['videoUrls'] ?? []),
            createdAt: createdAt ?? DateTime.now(),
            updatedAt: updatedAt ?? DateTime.now(),
            likesCount: data['likesCount'] ?? 0,
            commentsCount: data['commentsCount'] ?? 0,
            likedBy: List<String>.from(data['likedBy'] ?? []),
            isLikedByCurrentUser: false, // This will be set in the UI
          );
        } catch (e) {
          print('Error processing document ${doc.id}: $e');
          print('Document data: ${doc.data()}');
          return null;
        }
      }).where((post) => post != null).cast<CommunityPost>().toList();
    }).handleError((error) {
      print('Stream error: $error');
      return <CommunityPost>[];
    });
  }

  // Alternative method to get posts once (for debugging)
  static Future<List<CommunityPost>> getPostsOnce() async {
    try {
      print('Fetching posts once...');
      final snapshot = await _firestore
          .collection(_postsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      print('Retrieved ${snapshot.docs.length} documents');

      if (snapshot.docs.isEmpty) {
        print('No posts found');
        return [];
      }

      final posts = <CommunityPost>[];
      
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          print('Document ${doc.id} data: $data');
          
          // Handle Timestamp conversion
          DateTime? createdAt;
          DateTime? updatedAt;
          
          if (data['createdAt'] != null) {
            if (data['createdAt'] is Timestamp) {
              createdAt = (data['createdAt'] as Timestamp).toDate();
            } else if (data['createdAt'] is String) {
              createdAt = DateTime.parse(data['createdAt']);
            }
          }
          
          if (data['updatedAt'] != null) {
            if (data['updatedAt'] is Timestamp) {
              updatedAt = (data['updatedAt'] as Timestamp).toDate();
            } else if (data['updatedAt'] is String) {
              updatedAt = DateTime.parse(data['updatedAt']);
            }
          }

          final post = CommunityPost(
            id: doc.id,
            userId: data['userId'] ?? '',
            username: data['username'] ?? '',
            userProfileImage: data['userProfileImage'],
            userLocation: data['userLocation'],
            content: data['content'] ?? '',
            imageUrls: List<String>.from(data['imageUrls'] ?? []),
            videoUrls: List<String>.from(data['videoUrls'] ?? []),
            createdAt: createdAt ?? DateTime.now(),
            updatedAt: updatedAt ?? DateTime.now(),
            likesCount: data['likesCount'] ?? 0,
            commentsCount: data['commentsCount'] ?? 0,
            likedBy: List<String>.from(data['likedBy'] ?? []),
            isLikedByCurrentUser: false,
          );
          
          posts.add(post);
        } catch (e) {
          print('Error processing document ${doc.id}: $e');
        }
      }

      print('Successfully processed ${posts.length} posts');
      return posts;
    } catch (e) {
      print('Error getting posts: $e');
      return [];
    }
  }

  // Toggle like on post
  static Future<bool> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection(_postsCollection).doc(postId);
      
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) return;

        final data = postDoc.data()!;
        final likedBy = List<String>.from(data['likedBy'] ?? []);
        final likesCount = data['likesCount'] ?? 0;

        if (likedBy.contains(userId)) {
          // Unlike
          likedBy.remove(userId);
          transaction.update(postRef, {
            'likedBy': likedBy,
            'likesCount': likesCount - 1,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Like
          likedBy.add(userId);
          transaction.update(postRef, {
            'likedBy': likedBy,
            'likesCount': likesCount + 1,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
      
      return true;
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }

  // Debug method to check collection
  static Future<void> debugCollection() async {
    try {
      final snapshot = await _firestore.collection(_postsCollection).get();
      print('=== DEBUG COLLECTION ===');
      print('Collection: $_postsCollection');
      print('Total documents: ${snapshot.docs.length}');
      
      for (final doc in snapshot.docs) {
        print('Document ID: ${doc.id}');
        print('Document data: ${doc.data()}');
        print('---');
      }
    } catch (e) {
      print('Debug error: $e');
    }
  }
}