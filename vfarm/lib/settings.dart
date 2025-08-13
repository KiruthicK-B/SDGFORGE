import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vfarm/models/user_profile_model.dart';
import 'package:vfarm/myprofile.dart';
import 'package:vfarm/session_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionManager _sessionManager = SessionManager.instance;
  
  UserProfileModel? _currentUser;
  bool _pushNotifications = true;
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Initialize all data with better error handling
  Future<void> _initializeData() async {
    try {
      // Load preferences first (these are local and should load quickly)
      await _loadPreferences();
      
      // Then load user data
      await _loadUserData();
    } catch (e) {
      print('Error initializing data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load settings. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  // Safe setState that checks if widget is still mounted
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _sessionManager.getCurrentUserId();
      print('Loading user data for userId: $userId'); // Debug log
      
      if (userId != null && userId.isNotEmpty) {
        final doc = await _firestore.collection('userdetails').doc(userId).get();
        print('Firestore document exists: ${doc.exists}'); // Debug log
        
        if (doc.exists && doc.data() != null) {
          _safeSetState(() {
            _currentUser = UserProfileModel.fromSnapshot(doc);
            _isLoading = false;
            _errorMessage = null;
          });
          print('User data loaded successfully: ${_currentUser?.name}'); // Debug log
        } else {
          print('Document does not exist or has no data'); // Debug log
          _safeSetState(() {
            _errorMessage = 'User profile not found';
            _isLoading = false;
          });
        }
      } else {
        print('No user ID found in session'); // Debug log
        _safeSetState(() {
          _errorMessage = 'No user session found. Please log in again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      _safeSetState(() {
        _errorMessage = 'Error loading user data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _pushNotifications = prefs.getBool('push_notifications') ?? true;
          _darkMode = prefs.getBool('dark_mode') ?? false;
          _selectedLanguage = prefs.getString('language') ?? 'English';
        });
      }
    } catch (e) {
      print('Error loading preferences: $e');
      // Don't stop loading for preference errors, use defaults
    }
  }

  Future<void> _savePreference(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (e) {
      print('Error saving preference: $e');
    }
  }

  Future<void> _showProfileSettings() async {
    if (_currentUser == null) return;

    final nameController = TextEditingController(text: _currentUser!.name);
    final phoneController = TextEditingController(text: _currentUser!.phone ?? '');
    final bioController = TextEditingController(text: _currentUser!.bio ?? '');
    final farmLocationController = TextEditingController(text: _currentUser!.farmLocation ?? '');
    final farmSizeController = TextEditingController(text: _currentUser!.farmSize?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile Settings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile Image
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blue.shade100,
                              backgroundImage: _currentUser!.profileImageUrl != null
                                  ? NetworkImage(_currentUser!.profileImageUrl!)
                                  : null,
                              child: _currentUser!.profileImageUrl == null
                                  ? Text(
                                      _currentUser!.name.isNotEmpty 
                                          ? _currentUser!.name[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(fontSize: 30, color: Colors.blue),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _uploadProfileImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField('Name', nameController, Icons.person),
                      _buildTextField('Phone', phoneController, Icons.phone),
                      _buildTextField('Bio', bioController, Icons.info, maxLines: 3),
                      _buildTextField('Farm Location', farmLocationController, Icons.location_on),
                      _buildTextField('Farm Size (acres)', farmSizeController, Icons.landscape, 
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _updateProfile(
                            nameController.text,
                            phoneController.text,
                            bioController.text,
                            farmLocationController.text,
                            farmSizeController.text,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Update Profile', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, 
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null && _currentUser != null) {
      try {
        final file = File(pickedFile.path);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${_currentUser!.uid}.jpg');
        
        await storageRef.putFile(file);
        final downloadUrl = await storageRef.getDownloadURL();
        
        await _firestore.collection('users').doc(_currentUser!.uid).update({
          'profileImageUrl': downloadUrl,
          'updatedAt': Timestamp.now(),
        });
        
        _safeSetState(() {
          _currentUser = _currentUser!.copyWith(
            profileImageUrl: downloadUrl,
            updatedAt: DateTime.now(),
          );
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
        }
      }
    }
  }

  Future<void> _updateProfile(String name, String phone, String bio, 
      String farmLocation, String farmSize) async {
    try {
      if (_currentUser == null) return;

      final updates = {
        'name': name,
        'phone': phone.isEmpty ? null : phone,
        'bio': bio.isEmpty ? null : bio,
        'farmLocation': farmLocation.isEmpty ? null : farmLocation,
        'farmSize': farmSize.isEmpty ? null : double.tryParse(farmSize),
        'updatedAt': Timestamp.now(),
      };

      await _firestore.collection('userdetails').doc(_currentUser!.uid).update(updates);
      
      _safeSetState(() {
        _currentUser = _currentUser!.copyWith(
          name: name,
          phone: phone.isEmpty ? null : phone,
          bio: bio.isEmpty ? null : bio,
          farmLocation: farmLocation.isEmpty ? null : farmLocation,
          farmSize: farmSize.isEmpty ? null : double.tryParse(farmSize),
          updatedAt: DateTime.now(),
        );
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  Future<void> _showHelpCenter() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Help Center',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildHelpItem('How to add crops?', 'Go to the crops section and tap the + button to add new crops to your farm.'),
                    _buildHelpItem('How to track weather?', 'Weather information is automatically updated based on your farm location.'),
                    _buildHelpItem('How to manage irrigation?', 'Use the irrigation scheduler to set up automated watering for your crops.'),
                    _buildHelpItem('How to view analytics?', 'Analytics can be found in the dashboard showing your farm performance metrics.'),
                    _buildHelpItem('Account verification', 'Upload required documents in profile settings to get your account verified.'),
                    _buildHelpItem('Contact support', 'Use the contact support option below to reach our team directly.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(answer, style: TextStyle(color: Colors.grey[600])),
        ),
      ],
    );
  }

  Future<void> _showContactSupport() async {
    final messageController = TextEditingController();
    final subjectController = TextEditingController();
    
    showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: 0.7,
    minChildSize: 0.4,
    maxChildSize: 0.9,
    expand: false,
    builder: (_, controller) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        controller: controller,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Contact Support',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submitSupportRequest(
                    subjectController.text, messageController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Send Message', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);

  }

  Future<void> _submitSupportRequest(String subject, String message) async {
    if (subject.isEmpty || message.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
      }
      return;
    }

    try {
      await _firestore.collection('support_requests').add({
        'userId': _currentUser?.uid,
        'userName': _currentUser?.name,
        'userEmail': _currentUser?.email,
        'subject': subject,
        'message': message,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Support request submitted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting request: $e')),
        );
      }
    }
  }

  Future<void> _showLanguageSelection() async {
    final languages = ['English', 'Hindi', 'Tamil', 'Telugu', 'Kannada', 'Malayalam'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) => RadioListTile<String>(
            title: Text(language),
            value: language,
            groupValue: _selectedLanguage,
            onChanged: (value) {
              _safeSetState(() => _selectedLanguage = value!);
              _savePreference('language', value!);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _sessionManager.clearSession();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.blue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? Colors.blue, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // Add retry functionality
  Widget _buildRetryButton() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _initializeData();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF0A9D88),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to home instead of just popping
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading settings...'),
                ],
              ),
            )
          : _errorMessage != null
              ? _buildRetryButton()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Profile Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFF0A9D88),
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [Color(0xFF0A9D88), Colors.blue.shade700],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              backgroundImage: _currentUser?.profileImageUrl != null
                                  ? NetworkImage(_currentUser!.profileImageUrl!)
                                  : null,
                              child: _currentUser?.profileImageUrl == null
                                  ? Text(
                                      _currentUser?.name.isNotEmpty == true 
                                          ? _currentUser!.name[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(fontSize: 24, color: Colors.white),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _currentUser?.name ?? 'User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _currentUser?.email ?? '',
                              style: TextStyle(color: Colors.white.withOpacity(0.8)),
                            ),
                            if (_currentUser?.isVerified == true)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Verified Member',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Account Section
                      const Text(
                        'Account',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      
                      _buildSettingsItem(
                        title: 'Profile Settings',
                        icon: Icons.person_outline,
                         onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const MyProfilePage(), // Replace with your profile page widget
                          ),
                        );
                      },
                      ),
                      
                    _buildSettingsItem(
                      title: 'Privacy & Security',
                      icon: Icons.security,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const MyProfilePage(), // Replace with your profile page widget
                          ),
                        );
                      },
                    ),

                      
                      _buildSettingsItem(
                        title: 'Payment Methods',
                        icon: Icons.payment,
                        iconColor: Colors.orange,
                        onTap: () {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Payment methods coming soon')),
                            );
                          }
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Preferences Section
                      const Text(
                        'Preferences',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      
                      _buildSettingsItem(
                        title: 'Push Notifications',
                        icon: Icons.notifications_outlined,
                        trailing: Switch(
                          value: _pushNotifications,
                          onChanged: (value) {
                            _safeSetState(() => _pushNotifications = value);
                            _savePreference('push_notifications', value);
                          },
                          activeColor: Colors.blue,
                        ),
                      ),
                      
                      _buildSettingsItem(
                        title: 'Dark Mode',
                        icon: Icons.dark_mode_outlined,
                        trailing: Switch(
                          value: _darkMode,
                          onChanged: (value) {
                            _safeSetState(() => _darkMode = value);
                            _savePreference('dark_mode', value);
                          },
                          activeColor: Colors.blue,
                        ),
                      ),
                      
                      _buildSettingsItem(
                        title: 'Language',
                        icon: Icons.language,
                        iconColor: Colors.teal,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_selectedLanguage, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          ],
                        ),
                        onTap: _showLanguageSelection,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Support Section
                      const Text(
                        'Support',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      
                      _buildSettingsItem(
                        title: 'Help Center',
                        icon: Icons.help_outline,
                        iconColor: Colors.purple,
                        onTap: _showHelpCenter,
                      ),
                      
                      _buildSettingsItem(
                        title: 'Contact Support',
                        icon: Icons.support_agent,
                        iconColor: Colors.orange,
                        onTap: _showContactSupport,
                      ),
                      
                      _buildSettingsItem(
                        title: 'Sign Out',
                        icon: Icons.logout,
                        iconColor: Colors.red,
                        onTap: _signOut,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // App Info
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'VFarm v1.0.0',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '© 2024 VFarm. All rights reserved.',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}