import 'package:shared_preferences/shared_preferences.dart';
import 'package:vfarm/models/user_profile_model.dart';

class SessionManager {
  static SessionManager? _instance;
  static SharedPreferences? _prefs;
  
  // Session state
  static String? _currentUserId;
  static UserProfileModel? _currentUserProfile;
  static bool _isInitialized = false;

  SessionManager._internal();
  
  static SessionManager get instance {
    _instance ??= SessionManager._internal();
    return _instance!;
  }

  factory SessionManager() => instance;

  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Session Keys
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserId = 'loggedInUserId';
  static const String _keyUsername = 'loggedInUsername';
  static const String _keyUserEmail = 'loggedInEmail';
  static const String _keyLoginTime = 'loginTimestamp';
  static const String _keyUserProfileName = 'userProfileName';
  static const String _keyUserProfileImageUrl = 'userProfileImageUrl';
  static const String _keyUserProfileUid = 'userProfileUid';
  static const String _keyUserProfilePhone = 'userProfilePhone';
  static const String _keyUserProfileFarmLocation = 'userProfileFarmLocation';
  static const String _keyUserProfileFarmSize = 'userProfileFarmSize';
  static const String _keyUserProfileCropTypes = 'userProfileCropTypes';
  static const String _keyUserProfileCreatedAt = 'userProfileCreatedAt';
  static const String _keyUserProfileUpdatedAt = 'userProfileUpdatedAt';
  static const String _keyUserProfileBio = 'userProfileBio';
  static const String _keyUserProfileIsVerified = 'userProfileIsVerified';
  
  final String _keyUserProfileEmail='userProfileEmail';

  // Save session
  Future<bool> saveUserSession({
    required String userId,
    required String username,
    String? email,
    UserProfileModel? profile,
  }) async {
    try {
      await _prefs?.setBool(_keyIsLoggedIn, true);
      await _prefs?.setString(_keyUserId, userId);
      await _prefs?.setString(_keyUsername, username);
      await _prefs?.setString(_keyLoginTime, DateTime.now().toIso8601String());
      if (email != null) await _prefs?.setString(_keyUserEmail, email);

      // Cache profile data for fast access
      if (profile != null) {
        await _prefs?.setString(_keyUserProfileUid, profile.uid);
        await _prefs?.setString(_keyUserProfileName, profile.name);
        await _prefs?.setString(_keyUserProfileEmail, profile.email);
        if (profile.phone != null) await _prefs?.setString(_keyUserProfilePhone, profile.phone!);
        if (profile.farmLocation != null) await _prefs?.setString(_keyUserProfileFarmLocation, profile.farmLocation!);
        if (profile.farmSize != null) await _prefs?.setDouble(_keyUserProfileFarmSize, profile.farmSize!);
        await _prefs?.setStringList(_keyUserProfileCropTypes, profile.cropTypes);
        if (profile.profileImageUrl != null) await _prefs?.setString(_keyUserProfileImageUrl, profile.profileImageUrl!);
        await _prefs?.setString(_keyUserProfileCreatedAt, profile.createdAt.toIso8601String());
        if (profile.updatedAt != null) await _prefs?.setString(_keyUserProfileUpdatedAt, profile.updatedAt!.toIso8601String());
        if (profile.bio != null) await _prefs?.setString(_keyUserProfileBio, profile.bio!);
        await _prefs?.setBool(_keyUserProfileIsVerified, profile.isVerified);
      }

      _currentUserId = userId;
      _currentUserProfile = profile;
      _isInitialized = true;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get current user data
  String? getCurrentUserId() => _currentUserId ?? _prefs?.getString(_keyUserId);
  String? getUsername() => _prefs?.getString(_keyUsername);
  String? getUserEmail() => _prefs?.getString(_keyUserEmail);
  
  // Enhanced getCurrentUserProfile with caching
  UserProfileModel? getCurrentUserProfile() {
    // Return cached profile if available
    if (_currentUserProfile != null) {
      return _currentUserProfile;
    }
    
    // Try to restore from SharedPreferences
    final uid = _prefs?.getString(_keyUserProfileUid);
    final name = _prefs?.getString(_keyUserProfileName);
    final email = _prefs?.getString(_keyUserProfileEmail);
    final cropTypesString = _prefs?.getStringList(_keyUserProfileCropTypes);
    final createdAtString = _prefs?.getString(_keyUserProfileCreatedAt);
    
    // Check if we have the minimum required data
    if (uid != null && name != null && email != null && 
        cropTypesString != null && createdAtString != null) {
      
      try {
        final createdAt = DateTime.parse(createdAtString);
        final updatedAtString = _prefs?.getString(_keyUserProfileUpdatedAt);
        final updatedAt = updatedAtString != null ? DateTime.parse(updatedAtString) : null;
        
        _currentUserProfile = UserProfileModel(
          uid: uid,
          name: name,
          email: email,
          phone: _prefs?.getString(_keyUserProfilePhone),
          farmLocation: _prefs?.getString(_keyUserProfileFarmLocation),
          farmSize: _prefs?.getDouble(_keyUserProfileFarmSize),
          cropTypes: cropTypesString,
          profileImageUrl: _prefs?.getString(_keyUserProfileImageUrl),
          createdAt: createdAt,
          updatedAt: updatedAt,
          bio: _prefs?.getString(_keyUserProfileBio),
          isVerified: _prefs?.getBool(_keyUserProfileIsVerified) ?? false,
        );
        return _currentUserProfile;
      } catch (e) {
        // If there's an error parsing dates, return null
        return null;
      }
    }
    
    return null;
  }
  
  bool isUserLoggedIn() => _prefs?.getBool(_keyIsLoggedIn) ?? false;
  bool get isInitialized => _isInitialized;

  // Check session validity
  bool isSessionValid({int maxDaysValid = 30}) {
    if (!isUserLoggedIn()) return false;
    
    final loginTimeString = _prefs?.getString(_keyLoginTime);
    if (loginTimeString == null) return false;
    
    try {
      final loginTime = DateTime.parse(loginTimeString);
      final daysSinceLogin = DateTime.now().difference(loginTime).inDays;
      return daysSinceLogin <= maxDaysValid && getCurrentUserId() != null;
    } catch (e) {
      return false;
    }
  }

  // Check if session is expired
  bool isSessionExpired({int maxDaysValid = 30}) {
    return !isSessionValid(maxDaysValid: maxDaysValid);
  }

  // Initialize from stored session
  Future<bool> initializeFromStoredSession() async {
    try {
      if (!isSessionValid()) {
        await clearSession();
        return false;
      }

      final userId = getCurrentUserId();
      final username = getUsername();
      
      if (userId == null || username == null) return false;

      _currentUserId = userId;
      
      // Restore cached profile
      final profile = getCurrentUserProfile();
      if (profile != null) {
        _currentUserProfile = profile;
      }
      
      _isInitialized = true;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Enhanced setCurrentUserProfile with persistence
  void setCurrentUserProfile(UserProfileModel profile) {
    _currentUserProfile = profile;
    
    // Persist all profile data to SharedPreferences for faster access
    _prefs?.setString(_keyUserProfileUid, profile.uid);
    _prefs?.setString(_keyUserProfileName, profile.name);
    _prefs?.setString(_keyUserProfileEmail, profile.email);
    if (profile.phone != null) _prefs?.setString(_keyUserProfilePhone, profile.phone!);
    if (profile.farmLocation != null) _prefs?.setString(_keyUserProfileFarmLocation, profile.farmLocation!);
    if (profile.farmSize != null) _prefs?.setDouble(_keyUserProfileFarmSize, profile.farmSize!);
    _prefs?.setStringList(_keyUserProfileCropTypes, profile.cropTypes);
    if (profile.profileImageUrl != null) _prefs?.setString(_keyUserProfileImageUrl, profile.profileImageUrl!);
    _prefs?.setString(_keyUserProfileCreatedAt, profile.createdAt.toIso8601String());
    if (profile.updatedAt != null) _prefs?.setString(_keyUserProfileUpdatedAt, profile.updatedAt!.toIso8601String());
    if (profile.bio != null) _prefs?.setString(_keyUserProfileBio, profile.bio!);
    _prefs?.setBool(_keyUserProfileIsVerified, profile.isVerified);
  }

  // Enhanced clearSession - clear profile cache
  Future<bool> clearSession() async {
    try {
      await _prefs?.remove(_keyIsLoggedIn);
      await _prefs?.remove(_keyUserId);
      await _prefs?.remove(_keyUsername);
      await _prefs?.remove(_keyUserEmail);
      await _prefs?.remove(_keyLoginTime);
      await _prefs?.remove(_keyUserProfileName);
      await _prefs?.remove(_keyUserProfileImageUrl);
      await _prefs?.remove(_keyUserProfileUid);
      await _prefs?.remove(_keyUserProfilePhone);
      await _prefs?.remove(_keyUserProfileFarmLocation);
      await _prefs?.remove(_keyUserProfileFarmSize);
      await _prefs?.remove(_keyUserProfileCropTypes);
      await _prefs?.remove(_keyUserProfileCreatedAt);
      await _prefs?.remove(_keyUserProfileUpdatedAt);
      await _prefs?.remove(_keyUserProfileBio);
      await _prefs?.remove(_keyUserProfileIsVerified);
      
      _currentUserId = null;
      _currentUserProfile = null;
      _isInitialized = false;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Ensure authenticated
  Future<void> ensureAuthenticated() async {
    if (!_isInitialized || _currentUserId == null) {
      final restored = await initializeFromStoredSession();
      if (!restored) {
        throw Exception('User not authenticated. Please login again.');
      }
    }
  }

  // Check authentication status
  bool isAuthenticated() {
    return _isInitialized && _currentUserId != null && isSessionValid();
  }

  void printSessionInfo() {}
}