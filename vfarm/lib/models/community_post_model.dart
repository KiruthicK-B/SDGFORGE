class CommunityPost {
  final String id;
  final String userId;
  final String username;
  final String? userProfileImage;
  final String? userLocation;
  final String content;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likesCount;
  final int commentsCount;
  final List<String> likedBy;
  final bool isLikedByCurrentUser;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.username,
    this.userProfileImage,
    this.userLocation,
    required this.content,
    this.imageUrls = const [],
    this.videoUrls = const [],
    required this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.likedBy = const [],
    this.isLikedByCurrentUser = false,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      userProfileImage: json['userProfileImage'],
      userLocation: json['userLocation'],
      content: json['content'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      videoUrls: List<String>.from(json['videoUrls'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
      isLikedByCurrentUser: json['isLikedByCurrentUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userProfileImage': userProfileImage,
      'userLocation': userLocation,
      'content': content,
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'likedBy': likedBy,
      'isLikedByCurrentUser': isLikedByCurrentUser,
    };
  }

  static Future<void> fromMap(Map<String, dynamic> data, String id) async {}
}
