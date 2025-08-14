import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vfarm/document_viewer_screen.dart';
import 'package:vfarm/firebase_service.dart';
import 'package:vfarm/models/document_model.dart';
import 'package:vfarm/session_manager.dart';
import 'dart:io';
import 'dart:async';

import 'package:vfarm/models/user_profile_model.dart';
import 'package:vfarm/profile_edit_screen.dart';

class MyVaultScreen extends StatefulWidget {
  const MyVaultScreen({super.key});

  @override
  State<MyVaultScreen> createState() => _MyVaultScreenState();
}

class _MyVaultScreenState extends State<MyVaultScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  UserProfileModel? _userProfile;
  bool _isLoading = true;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
 
  final SessionManager _sessionManager = SessionManager.instance;

  final List<String> _categories = [
    'All',
    'Crop History',
    'Invoices',
    'Land Documents',
    'Agri-Loan Records'
  ];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSession();
  }

  void _initializeAnimations() {
    _waveController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_waveController);
  }

  Future<void> _initializeSession() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Initialize SessionManager
      await SessionManager.initialize();
      
      // Check if user is authenticated and session is valid
      if (!_sessionManager.isAuthenticated()) {
        debugPrint('No valid session found, attempting to restore from storage');
        
        // Try to restore from stored session
        final restored = await _sessionManager.initializeFromStoredSession();
        if (!restored) {
          debugPrint('Failed to restore session, redirecting to login');
          _redirectToLogin();
          return;
        }
      }

      // Check if session is expired
      if (_sessionManager.isSessionExpired()) {
        debugPrint('Session expired, clearing and redirecting to login');
        await _sessionManager.clearSession();
        _redirectToLogin();
        return;
      }

      final userId = _sessionManager.getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        debugPrint('No user ID found, redirecting to login');
        _redirectToLogin();
        return;
      }

      debugPrint('Valid session found for userId: $userId');
      
      // Load user profile
      await _loadUserProfile(userId);
      
    } catch (e) {
      debugPrint('Error initializing session: $e');
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      debugPrint('Loading profile for userId: $userId');
      setState(() {
        _isLoading = true;
      });
      
      // Check if profile is already cached in SessionManager
      UserProfileModel? profile = _sessionManager.getCurrentUserProfile();
      
      // If not cached, load from Firebase
      if (profile == null) {
        profile = await FirebaseService.getUserProfile(userId);
        if (profile != null) {
          // Cache the profile in SessionManager
          _sessionManager.setCurrentUserProfile(profile);
        }
      }
      
      debugPrint('Profile loaded: ${profile?.name ?? 'null'}');
      
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Error loading profile: ${e.toString()}');
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.contains('Error') ? Colors.red : const Color(0xFF0A9D88),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
     appBar: AppBar(
  backgroundColor: const Color(0xFF0A9D88),
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
  ),
  title: const Text(
    'My Vault',
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.person, color: Colors.white),
      onPressed: () => _navigateToProfile(),
    ),
    // IconButton(
    //   icon: const Icon(Icons.logout, color: Colors.white),
    //   onPressed: () => _showLogoutDialog(),
    // ),
  ],
),

      body: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilter(),
          Expanded(
            child: _buildDocumentsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadOptions,
        backgroundColor: const Color(0xFF0A9D88),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Upload Document',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF0A9D88),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: _isLoading ? _buildShimmerHeader() : _buildUserHeader(),
    );
  }

  Widget _buildUserHeader() {
    // Safe method to get the first character for avatar
    String getInitial() {
      String? name = _userProfile?.name ?? _sessionManager.getUsername();
      if (name != null && name.trim().isNotEmpty) {
        return name.trim().substring(0, 1).toUpperCase();
      }
      return 'U'; // Default fallback
    }

    // Safe method to get display name
    String getDisplayName() {
      return _userProfile?.name.isNotEmpty == true 
          ? _userProfile!.name 
          : _sessionManager.getUsername()?.isNotEmpty == true
              ? _sessionManager.getUsername()!
              : 'User';
    }

    return Row(
      children: [
        GestureDetector(
          onTap: _showProfileImageOptions,
          child: CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            backgroundImage: _userProfile?.profileImageUrl != null &&
                    _userProfile!.profileImageUrl!.isNotEmpty
                ? CachedNetworkImageProvider(_userProfile!.profileImageUrl!)
                : null,
            child: _userProfile?.profileImageUrl == null ||
                    _userProfile!.profileImageUrl!.isEmpty
                ? Text(
                    getInitial(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A9D88),
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   '',
              //   style: TextStyle(
              //     fontSize: 14,
              //     color: Colors.white.withOpacity(0.8),
              //   ),
              // ),
              Text(
                getDisplayName(),
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (_userProfile?.farmLocation != null &&
                  _userProfile!.farmLocation!.isNotEmpty)
                Text(
                  _userProfile!.farmLocation!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerHeader() {
    return Shimmer.fromColors(
      baseColor: Colors.white24,
      highlightColor: Colors.white38,
      child: Row(
        children: [
          const CircleAvatar(radius: 30, backgroundColor: Colors.white),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search documents...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF0A9D88)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: const Color(0xFF0A9D88).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF0A9D88),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    // Check authentication using SessionManager
    if (!_sessionManager.isAuthenticated()) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Please login to view documents',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final userId = _sessionManager.getCurrentUserId();
    if (userId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'User ID not found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // FIXED: Pass userId to the stream
    return StreamBuilder<List<DocumentModel>>(
      stream: FirebaseService.getUserDocuments(userId: userId),
      builder: (context, snapshot) {
        debugPrint('Stream connection state: ${snapshot.connectionState}');
        debugPrint('Stream has error: ${snapshot.hasError}');
        debugPrint('Stream data length: ${snapshot.data?.length ?? 0}');
        debugPrint('User ID being used: $userId');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingList();
        }

        if (snapshot.hasError) {
          debugPrint('Error in stream: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading documents',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    snapshot.error.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<DocumentModel> documents = snapshot.data ?? [];
        debugPrint('Documents before filtering: ${documents.length}');

        // Filter documents
        if (_selectedCategory != 'All') {
          documents = documents
              .where((doc) => doc.category == _selectedCategory)
              .toList();
        }

        if (_searchController.text.isNotEmpty) {
          final searchTerm = _searchController.text.toLowerCase();
          documents = documents
              .where((doc) =>
                  doc.fileName.toLowerCase().contains(searchTerm) ||
                  doc.tags.any((tag) =>
                      tag.toLowerCase().contains(searchTerm)))
              .toList();
        }

        debugPrint('Documents after filtering: ${documents.length}');

        if (documents.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              return _buildDocumentCard(documents[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 80,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_waveAnimation.value * 0.1),
                  child: const Icon(
                    Icons.folder_open,
                    size: 80,
                    color: Color(0xFF0A9D88),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'No Documents Found',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedCategory == 'All'
                  ? 'Upload your first document to get started'
                  : 'No documents in $_selectedCategory category',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showUploadOptions,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Document'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A9D88),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(DocumentModel document) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getCategoryColor(document.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(document.category),
            color: _getCategoryColor(document.category),
            size: 24,
          ),
        ),
        title: Text(
          document.fileName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              document.category,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Uploaded ${_formatDate(document.uploadDate)}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            if (document.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: document.tags.take(3).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A9D88).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF0A9D88)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'view') {
              _viewDocument(document);
            } else if (value == 'delete') {
              _deleteDocument(document);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('View'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete'),
                dense: true,
              ),
            ),
          ],
        ),
        onTap: () => _viewDocument(document),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Crop History':
        return Colors.green;
      case 'Invoices':
        return Colors.blue;
      case 'Land Documents':
        return Colors.orange;
      case 'Agri-Loan Records':
        return Colors.purple;
      default:
        return const Color(0xFF0A9D88);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Crop History':
        return Icons.agriculture;
      case 'Invoices':
        return Icons.receipt;
      case 'Land Documents':
        return Icons.landscape;
      case 'Agri-Loan Records':
        return Icons.account_balance;
      default:
        return Icons.description;
    }
  }

  void _navigateToProfile() async {
    try {
      await _sessionManager.ensureAuthenticated();
      
      var profile = _sessionManager.getCurrentUserProfile();
      if (profile == null) {
        final userId = _sessionManager.getCurrentUserId();
        if (userId != null) {
          profile = await FirebaseService.getUserProfile(userId);
          if (profile != null) {
            _sessionManager.setCurrentUserProfile(profile);
          }
        }
      }

      if (profile != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileEditScreen(userProfile: profile!),
          ),
        );
      } else {
        _showSnackBar('Could not load user profile');
      }
    } catch (e) {
      _showSnackBar('Authentication required: ${e.toString()}');
      _redirectToLogin();
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Clear session using SessionManager
              await _sessionManager.clearSession();
              
              // Also sign out from Firebase if needed
              try {
                await FirebaseAuth.instance.signOut();
              } catch (e) {
                debugPrint('Firebase signout error: $e');
              }
              
              _redirectToLogin();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showProfileImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Update Profile Picture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfileImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfileImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      await _sessionManager.ensureAuthenticated();
      final userId = _sessionManager.getCurrentUserId();
      
      if (userId == null) {
        _showSnackBar('Please login to update profile image');
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );
      
      if (image != null) {
        _showLoadingDialog('Uploading profile image...');
        
        final imageUrl = await FirebaseService.uploadProfileImage(File(image.path));
        
        if (_userProfile != null) {
          final updatedProfile = UserProfileModel(
            uid: _userProfile!.uid,
            name: _userProfile!.username,
            email: _userProfile!.email,
            phone: _userProfile!.phone,
            farmLocation: _userProfile!.farmLocation,
            farmSize: _userProfile!.farmSize,
            cropTypes: _userProfile!.cropTypes,
            profileImageUrl: imageUrl,
            createdAt: _userProfile!.createdAt,
          );
          
          await FirebaseService.createOrUpdateProfile(updatedProfile);
          
          // Update the cached profile in SessionManager
          _sessionManager.setCurrentUserProfile(updatedProfile);
          
          // Reload profile to update UI
          await _loadUserProfile(userId);
        }
        
        Navigator.pop(context); // Close loading dialog
        _showSnackBar('Profile image updated successfully');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showSnackBar('Error uploading image: ${e.toString()}');
    }
  }

  void _showUploadOptions() {
    try {
      _sessionManager.ensureAuthenticated();
      final userId = _sessionManager.getCurrentUserId();
      
      if (userId == null) {
        _showSnackBar('Please login to upload documents');
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return DocumentUploadSheet(
              scrollController: scrollController,
              userId: userId,
              onDocumentUploaded: () {
                Navigator.pop(context);
                _showSnackBar('Document uploaded successfully');
                setState(() {}); // Refresh the documents list
              },
            );
          },
        ),
      );
    } catch (e) {
      _showSnackBar('Authentication required: ${e.toString()}');
      _redirectToLogin();
    }
  }

  void _viewDocument(DocumentModel document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewerScreen(document: document),
      ),
    );
  }

  void _deleteDocument(DocumentModel document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingDialog('Deleting document...');
              
              try {
                await FirebaseService.deleteDocument(document.id, document.fileUrl);
                Navigator.pop(context); // Close loading dialog
                _showSnackBar('Document deleted successfully');
                setState(() {}); // Refresh the list
              } catch (e) {
                Navigator.pop(context); // Close loading dialog
                _showSnackBar('Error deleting document: ${e.toString()}');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}



class DocumentUploadSheet extends StatefulWidget {
  final ScrollController scrollController;
  final String userId;
  final VoidCallback onDocumentUploaded;

  const DocumentUploadSheet({
    super.key,
    required this.scrollController,
    required this.userId,
    required this.onDocumentUploaded,
  });

  @override
  State<DocumentUploadSheet> createState() => _DocumentUploadSheetState();
}

class _DocumentUploadSheetState extends State<DocumentUploadSheet> {
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String _selectedCategory = 'Crop History';
  File? _selectedFile;
  bool _isUploading = false;

  final List<String> _categories = [
    'Crop History',
    'Invoices',
    'Land Documents',
    'Agri-Loan Records'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ListView(
        controller: widget.scrollController,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'Upload Document',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // File selection section
          GestureDetector(
            onTap: _isUploading ? null : _pickFile,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedFile != null ? const Color(0xFF0A9D88) : Colors.grey[300]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
                color: _selectedFile != null 
                    ? const Color(0xFF0A9D88).withOpacity(0.05)
                    : Colors.grey[50],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _selectedFile != null ? Icons.check_circle : Icons.cloud_upload,
                      size: 40,
                      color: _selectedFile != null ? const Color(0xFF0A9D88) : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFile != null 
                          ? 'File Selected: ${_selectedFile!.path.split('/').last}'
                          : 'Tap to select file',
                      style: TextStyle(
                        color: _selectedFile != null ? const Color(0xFF0A9D88) : Colors.grey[600],
                        fontWeight: _selectedFile != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_selectedFile == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'PDF, Images, or Documents',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // File name input
          TextField(
            controller: _fileNameController,
            enabled: !_isUploading,
            decoration: InputDecoration(
              labelText: 'Document Name',
              hintText: 'Enter a name for your document',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.description),
            ),
          ),
          const SizedBox(height: 16),
          
          // Category selection
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.category),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: _isUploading ? null : (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Tags input
          TextField(
            controller: _tagsController,
            enabled: !_isUploading,
            decoration: InputDecoration(
              labelText: 'Tags (optional)',
              hintText: 'Enter tags separated by commas',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.local_offer),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          
          // Upload button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isUploading || _selectedFile == null ? null : _uploadDocument,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A9D88),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isUploading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Uploading...'),
                      ],
                    )
                  : const Text(
                      'Upload Document',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Cancel button
          SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: _isUploading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0A9D88)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF0A9D88),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          // Auto-fill filename if empty
          if (_fileNameController.text.isEmpty) {
            String fileName = result.files.single.name;
            // Remove extension for cleaner display
            if (fileName.contains('.')) {
              fileName = fileName.substring(0, fileName.lastIndexOf('.'));
            }
            _fileNameController.text = fileName;
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error selecting file: ${e.toString()}');
    }
  }

  Future<void> _uploadDocument() async {
    if (_selectedFile == null) {
      _showSnackBar('Please select a file first');
      return;
    }

    if (_fileNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter a document name');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Parse tags
      List<String> tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Get file extension for fileType
      String fileName = _selectedFile!.path.split('/').last;
      String fileType = fileName.split('.').last.toLowerCase();

      // Create document model
      final document = DocumentModel(
        id: '', // Will be set by Firebase
        userId: widget.userId,
        fileName: _fileNameController.text.trim(),
        fileUrl: '', // Will be set after upload
        category: _selectedCategory,
        tags: tags,
        uploadDate: DateTime.now(),
        fileSize: await _selectedFile!.length(),
        fileType: fileType,
        mimeType: _getMimeType(_selectedFile!.path),
      );

      // FIXED: Upload document with proper parameters
      await FirebaseService.uploadDocument(
        _selectedFile!,
        _fileNameController.text.trim(),
        widget.userId,
        category: _selectedCategory,
        tags: tags,
      );
      
      // Success callback
      widget.onDocumentUploaded();
      
    } catch (e) {
      _showSnackBar('Error uploading document: ${e.toString()}');
      setState(() {
        _isUploading = false;
      });
    }
  }

  String _getMimeType(String filePath) {
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
      default:
        return 'application/octet-stream';
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.contains('Error') ? Colors.red : const Color(0xFF0A9D88),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
