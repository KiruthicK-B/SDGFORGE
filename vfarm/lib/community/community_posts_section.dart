import 'package:flutter/material.dart';
import 'package:vfarm/community/community_service.dart';
import 'package:vfarm/community/create_post.dart';
import 'package:vfarm/models/community_post_model.dart';
import 'package:vfarm/session_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommunityPostsSection extends StatefulWidget {
  const CommunityPostsSection({super.key});

  @override
  State<CommunityPostsSection> createState() => _CommunityPostsSectionState();
}

class _CommunityPostsSectionState extends State<CommunityPostsSection>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showCreatePostDialog() async {
    // Get current user info from SessionManager
    final currentUserId = SessionManager.instance.getCurrentUserId();
    final currentUsername = SessionManager.instance.getUsername();
    final currentUserProfile = SessionManager.instance.getCurrentUserProfile();
    
    if (currentUserId == null || currentUsername == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to create a post')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreatePostDialog(
        userId: currentUserId,
        username: currentUsername,
        userProfileImage: currentUserProfile?.profileImageUrl,
        userLocation: currentUserProfile?.farmLocation,
        onPostCreated: () {
          // Refresh posts if needed
        },
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: post.userProfileImage != null
                              ? NetworkImage(post.userProfileImage!)
                              : null,
                          child: post.userProfileImage == null
                              ? Text(
                                  post.username.isNotEmpty ? post.username[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                children: [
                                  if (post.userLocation != null) ...[
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      post.userLocation!,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Text(' • ', style: TextStyle(color: Colors.grey)),
                                  ],
                                  Text(
                                    timeago.format(post.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Show more options
                          },
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  
                  // Post content
                  if (post.content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        post.content,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Images
                  if (post.imageUrls.isNotEmpty)
                    SizedBox(
                      height: post.imageUrls.length == 1 ? 250 : 180,
                      child: PageView.builder(
                        itemCount: post.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                post.imageUrls[index],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF0A9D88),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  
                  // Videos
                  if (post.videoUrls.isNotEmpty)
                    ...post.videoUrls.map((videoUrl) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: _buildVideoPlayer(videoUrl),
                        ),
                      );
                    }),
                  
                  const SizedBox(height: 12),
                  
                  // Engagement stats
                  if (post.likesCount > 0 || post.commentsCount > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          if (post.likesCount > 0) ...[
                            const Icon(
                              Icons.favorite,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post.likesCount}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (post.commentsCount > 0)
                            Text(
                              '${post.commentsCount} comments',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  
                  const Divider(height: 1),
                  
                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _toggleLike(post),
                            icon: Icon(
                              post.isLikedByCurrentUser
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: post.isLikedByCurrentUser
                                  ? Colors.red
                                  : Colors.grey[600],
                              size: 20,
                            ),
                            label: Text(
                              'Like',
                              style: TextStyle(
                                color: post.isLikedByCurrentUser
                                    ? Colors.red
                                    : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {
                              // Show comments
                            },
                            icon: Icon(
                              Icons.comment_outlined,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            label: Text(
                              'Comment',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {
                              // Share post
                            },
                            icon: Icon(
                              Icons.share_outlined,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            label: Text(
                              'Share',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

 // Updated _buildVideoPlayer method with better error handling
Widget _buildVideoPlayer(String videoUrl) {
  print('Building video player for URL: $videoUrl');
  
  VideoPlayerController? controller = _videoControllers[videoUrl];
  
  if (controller == null) {
    try {
      // Ensure the URL is properly formatted
      Uri videoUri = Uri.parse(videoUrl);
      print('Parsed video URI: $videoUri');
      
      controller = VideoPlayerController.networkUrl(videoUri);
      _videoControllers[videoUrl] = controller;
      
      controller.initialize().then((_) {
        print('Video initialized successfully: $videoUrl');
        if (mounted) {
          setState(() {});
        }
      }).catchError((error) {
        print('Video initialization error for $videoUrl: $error');
        if (mounted) {
          setState(() {});
        }
      });
    } catch (e) {
      print('Error creating video controller: $e');
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              const Text('Invalid video URL', style: TextStyle(color: Colors.red)),
              Text(videoUrl, style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      );
    }
  }

  if (controller.value.hasError) {
    print('Video player error: ${controller.value.errorDescription}');
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 8),
          const Text('Failed to load video', style: TextStyle(color: Colors.red)),
          Text(
            controller.value.errorDescription ?? 'Unknown error',
            style: const TextStyle(fontSize: 12, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              _videoControllers.remove(videoUrl);
              setState(() {});
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  if (!controller.value.isInitialized) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0A9D88)),
            SizedBox(height: 12),
            Text('Loading video...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              setState(() {
                if (controller!.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
              });
            },
            icon: Icon(
              controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.white,
              size: 56,
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, VideoPlayerValue value, child) {
              if (!value.isInitialized) return const SizedBox.shrink();
              
              return LinearProgressIndicator(
                value: value.position.inMilliseconds / value.duration.inMilliseconds,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0A9D88)),
                minHeight: 2,
              );
            },
          ),
        ),
      ],
    ),
  );
}
  void _toggleLike(CommunityPost post) async {
    final currentUserId = SessionManager.instance.getCurrentUserId();
    if (currentUserId == null) return;

    await CommunityService.toggleLike(post.id, currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[50]!,
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.groups,
                  color: Color(0xFF0A9D88),
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Community Posts',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        'Connect with fellow farmers',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A9D88), Color(0xFF149D80)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0A9D88).withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: _showCreatePostDialog,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Create Post',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Posts Feed
          Expanded(
            child: StreamBuilder<List<CommunityPost>>(
              stream: CommunityService.getPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0A9D88),
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please check your connection and try again',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                final posts = snapshot.data ?? [];
                
                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to share something with the community!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showCreatePostDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Create First Post'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A9D88),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    // Add current user's like status
                    final currentUserId = SessionManager.instance.getCurrentUserId();
                    final isLikedByCurrentUser = currentUserId != null && 
                        post.likedBy.contains(currentUserId);
                    
                    final updatedPost = CommunityPost(
                      id: post.id,
                      userId: post.userId,
                      username: post.username,
                      userProfileImage: post.userProfileImage,
                      userLocation: post.userLocation,
                      content: post.content,
                      imageUrls: post.imageUrls,
                      videoUrls: post.videoUrls,
                      createdAt: post.createdAt,
                      updatedAt: post.updatedAt,
                      likesCount: post.likesCount,
                      commentsCount: post.commentsCount,
                      likedBy: post.likedBy,
                      isLikedByCurrentUser: isLikedByCurrentUser,
                    );
                    
                    return _buildPostCard(updatedPost);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}