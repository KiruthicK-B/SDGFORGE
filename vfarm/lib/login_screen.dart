import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController _usernameEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers first
    _initializeAnimations();
    
    // Check if user is already logged in
    _checkExistingSession();
    
    // Load remember me preference
    _loadRememberMePreference();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.bounceOut,
    ));

    // Start animations
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
    _scaleAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _scaleAnimationController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _usernameEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Enhanced session checking with better validation
  Future<void> _checkExistingSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('loggedInUserId');
      final username = prefs.getString('loggedInUsername');
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final loginTimestamp = prefs.getString('loginTimestamp');
      
      // Validate session data
      if (userId != null && 
          username != null && 
          userId.isNotEmpty && 
          username.isNotEmpty &&
          isLoggedIn) {
        
        // Optional: Check if session is still valid (e.g., within 30 days)
        if (loginTimestamp != null) {
          final loginTime = DateTime.parse(loginTimestamp);
          final now = DateTime.now();
          final daysDifference = now.difference(loginTime).inDays;
          
          if (daysDifference > 30) {
            // Session expired, clear it
            await _clearSession();
            return;
          }
        }
        
        // Valid session found, navigate to home
        if (mounted) {
          debugPrint('Existing valid session found for user: $username');
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Clear any incomplete session data
        await _clearIncompleteSession();
      }
    } catch (e) {
      debugPrint('Error checking existing session: $e');
      await _clearSession();
    }
  }

  // Clear incomplete or invalid session data
  Future<void> _clearIncompleteSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = ['loggedInUserId', 'loggedInUsername', 'loggedInEmail', 'isLoggedIn', 'loginTimestamp'];
      
      bool hasIncompleteData = false;
      for (String key in keys) {
        if (prefs.containsKey(key)) {
          final value = prefs.get(key);
          if (value == null || (value is String && value.isEmpty)) {
            hasIncompleteData = true;
            break;
          }
        }
      }
      
      if (hasIncompleteData) {
        await _clearSession();
      }
    } catch (e) {
      debugPrint('Error clearing incomplete session: $e');
    }
  }

  // Complete session clearing
  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('loggedInUserId');
      await prefs.remove('loggedInUsername');
      await prefs.remove('loggedInEmail');
      await prefs.remove('isLoggedIn');
      await prefs.remove('loginTimestamp');
      await prefs.remove('biometricUserId');
      await prefs.remove('biometricUsername');
      await prefs.remove('biometricEmail');
      debugPrint('Session cleared successfully');
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }

  // Load remember me preference and auto-fill if enabled
  Future<void> _loadRememberMePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('rememberMe') ?? false;
      
      if (rememberMe) {
        final savedUsername = prefs.getString('savedUsername') ?? '';
        final savedPassword = prefs.getString('savedPassword') ?? '';

            if (savedUsername.isNotEmpty && savedPassword.isNotEmpty) {
              setState(() {
            _rememberMe = true;
            _usernameEmailController.text = savedUsername;
            _passwordController.text = savedPassword;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading remember me preference: $e');
    }
  }

  // Enhanced remember me handling
  Future<void> _handleRememberMe(String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_rememberMe) {
        await prefs.setBool('rememberMe', true);
        await prefs.setString('savedUsername', username);
        await prefs.setString('savedPassword', password);
        debugPrint('Remember me data saved');
      } else {
        await prefs.setBool('rememberMe', false);
        await prefs.remove('savedUsername');
        await prefs.remove('savedPassword');
        debugPrint('Remember me data cleared');
      }
    } catch (e) {
      debugPrint('Error handling remember me: $e');
    }
  }

  // Enhanced session creation
  Future<void> _createSession(String docId, Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      
      // Save main session data
      await prefs.setString('loggedInUserId', docId);
      await prefs.setString('loggedInUsername', userData['username'] ?? '');
      await prefs.setString('loggedInEmail', userData['email'] ?? '');
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('loginTimestamp', now.toIso8601String());
      
      // Save biometric session data for future biometric logins
      await prefs.setString('biometricUserId', docId);
      await prefs.setString('biometricUsername', userData['username'] ?? '');
      await prefs.setString('biometricEmail', userData['email'] ?? '');
      await prefs.setString('biometricLoginTimestamp', now.toIso8601String());
      
      debugPrint('Complete session created for user: ${userData['username']}');
    } catch (e) {
      debugPrint('Error creating session: $e');
      rethrow;
    }
  }

  // Enhanced biometric authentication with better session management
  Future<void> _authenticate(BuildContext context) async {
    final LocalAuthentication auth = LocalAuthentication();

    try {
      // Check biometric availability
      final bool isDeviceSupported = await auth.isDeviceSupported();
      final bool canCheckBiometrics = await auth.canCheckBiometrics;

      if (!isDeviceSupported || !canCheckBiometrics) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric authentication not available on this device.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Check available biometrics
      final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No biometric methods are set up on this device.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Perform biometric authentication
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (didAuthenticate) {
        await _handleSuccessfulBiometricAuth(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric authentication failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric authentication error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Handle successful biometric authentication
  Future<void> _handleSuccessfulBiometricAuth(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final biometricUserId = prefs.getString('biometricUserId');
      final biometricUsername = prefs.getString('biometricUsername');
      final biometricEmail = prefs.getString('biometricEmail');
      
      if (biometricUserId != null && 
          biometricUsername != null && 
          biometricUserId.isNotEmpty && 
          biometricUsername.isNotEmpty) {
        
        // Verify user still exists in database
        final userDoc = await FirebaseFirestore.instance
            .collection('userdetails')
            .doc(biometricUserId)
            .get();
            
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          
          // Create a fresh session
          await _createSession(biometricUserId, userData);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome back, ${userData['username']}!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          // User no longer exists, clear biometric data
          await _clearSession();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User account not found. Please login again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No biometric user data found. Please login with username/password first.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error handling biometric auth success: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing biometric login: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Enhanced login with comprehensive session management
  Future<void> _login() async {
    final usernameOrEmail = _usernameEmailController.text.trim();
    final password = _passwordController.text.trim();
    
    // Validate input
    if (usernameOrEmail.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter both username/email and password'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final usersRef = FirebaseFirestore.instance.collection('userdetails');

      // Try to find user by username first
      QuerySnapshot querySnapshot = await usersRef
          .where('username', isEqualTo: usernameOrEmail)
          .where('password', isEqualTo: password)
          .get();

      // If no user found by username, try by email
      if (querySnapshot.docs.isEmpty) {
        querySnapshot = await usersRef
            .where('email', isEqualTo: usernameOrEmail)
            .where('password', isEqualTo: password)
            .get();
      }

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        final docId = querySnapshot.docs.first.id;

        // Create comprehensive session
        await _createSession(docId, userData);
        
        // Handle remember me functionality
        await _handleRememberMe(usernameOrEmail, password);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome, ${userData['username']}!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid username/email or password!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required FocusNode focusNode,
    bool obscureText = false,
    bool isPassword = false,
  }) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  prefixIcon,
                  color: focusNode.hasFocus ? const Color(0xFF149D80) : Colors.grey,
                ),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      )
                    : null,
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF149D80), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF149D80),
              Color(0xFF0D7A63),
              Color(0xFF095A4A),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 60.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo with scale animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset('assets/finallogo.png', height: 80),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Welcome text with fade animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to VFarm',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  // Username/Email field
                  _buildTextField(
                    controller: _usernameEmailController,
                    hintText: 'Username or Email',
                    prefixIcon: Icons.person_outline,
                    focusNode: _usernameFocusNode,
                  ),
                  const SizedBox(height: 20),
                  
                  // Password field
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline,
                    focusNode: _passwordFocusNode,
                    obscureText: !_isPasswordVisible,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),
                  
                  // Remember me and Forgot password
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    activeColor: Colors.white,
                                    checkColor: const Color(0xFF149D80),
                                    side: const BorderSide(color: Colors.white, width: 2),
                                  ),
                                ),
                                const Text(
                                  "Remember me",
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Forgot password feature coming soon!'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  
                  // Login button and biometric
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimation,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    colors: [Colors.white, Color(0xFFF5F5F5)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : () async {
                                    setState(() => _isLoading = true);
                                    try {
                                      await _login();
                                    } finally {
                                      if (mounted) {
                                        setState(() => _isLoading = false);
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: const Color(0xFF149D80),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SpinKitThreeBounce(
                                          color: Color(0xFF149D80),
                                          size: 25.0,
                                        )
                                      : const Text(
                                          "LOGIN",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            
                            // Biometric button
                            Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _authenticate(context),
                                  borderRadius: BorderRadius.circular(30),
                                  child: const Icon(
                                    Icons.fingerprint,
                                    color: Color(0xFF149D80),
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  
                  // Sign up link
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/signup'),
                        child: RichText(
                          text: const TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}