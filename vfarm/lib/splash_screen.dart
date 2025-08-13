import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'login_screen.dart';
import 'home.dart'; // Replace with your actual main/home screen
import 'session_manager.dart'; // Add your session manager import
// import 'firebase_service.dart'; // Add your firebase service import when available

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _logoController;
  late AnimationController _textController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  
  String displayText = '';
  final String fullText = 'We Farm, We Evolve';
  int _charIndex = 0;
  
  // Session management
  bool _isSessionRestored = false;
  bool _navigateToMain = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _waveController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 3)
    )..repeat();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Text animations
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));

    // Start session check and animations
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize SessionManager first
    await SessionManager.initialize();
    
    // Check session
    await _checkAndRestoreSession();
    
    // Start animations sequence
    _startAnimations();
  }

  Future<void> _checkAndRestoreSession() async {
    try {
      final sessionManager = SessionManager();
      
      if (sessionManager.isUserLoggedIn()) {
        final userId = sessionManager.getCurrentUserId();
        final username = sessionManager.getUsername();
        
        if (userId != null && username != null) {
          debugPrint('Found existing session for user: $username');
          
          // Check if session is expired
          if (sessionManager.isSessionExpired()) {
            debugPrint('Session expired - clearing session');
            await sessionManager.clearSession();
            setState(() {
              _navigateToMain = false;
              _isSessionRestored = true;
            });
            return;
          }
          setState(() {
            _navigateToMain = true;
            _isSessionRestored = true;
          });
          
        } else {
          debugPrint('Invalid session data - clearing session');
          await sessionManager.clearSession();
          setState(() {
            _navigateToMain = false;
            _isSessionRestored = true;
          });
        }
      } else {
        debugPrint('No existing session found');
        setState(() {
          _navigateToMain = false;
          _isSessionRestored = true;
        });
      }
    } catch (e) {
      debugPrint('Error during session check: $e');
      setState(() {
        _navigateToMain = false;
        _isSessionRestored = true;
      });
    }
  }

  void _startAnimations() {
    // Start logo animation immediately
    _logoController.forward();

    // Start text animation after logo
    Timer(const Duration(milliseconds: 600), () {
      _textController.forward();
    });

    // Start typing animation after text slide in
    Timer(const Duration(milliseconds: 800), () {
      _startTypingAnimation();
    });

    // Navigate to appropriate screen after 3 seconds with custom transition
    Timer(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() {
    // Wait for session restore to complete
    if (!_isSessionRestored) {
      // If session restore is still in progress, wait a bit more
      Timer(const Duration(milliseconds: 500), () {
        _navigateToNextScreen();
      });
      return;
    }

    if (_navigateToMain) {
      _navigateToMainScreen(context);
    } else {
      _navigateToLogin();
    }
  }
void _navigateToMainScreen(BuildContext context) {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(), // Your main screen widget
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
    ),
  );
}

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void _startTypingAnimation() {
    Timer.periodic(const Duration(milliseconds: 70), (timer) {
      if (_charIndex < fullText.length) {
        setState(() {
          displayText += fullText[_charIndex];
          _charIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF149D80),
              Color(0xFF0D7A63),
              Color(0xFF095A4A),
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: Column(
          children: [
            const Spacer(),

            // App Logo with animations
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Image.asset(
                        'assets/finallogo.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // App Title with animation
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _textFadeAnimation,
                  child: SlideTransition(
                    position: _textSlideAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'VFarm',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black26,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Typing effect text with enhanced styling
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _textFadeAnimation,
                  child: SlideTransition(
                    position: _textSlideAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withOpacity(0.05),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayText,
                            style: const TextStyle(
                              fontSize: 22,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w300,
                              shadows: [
                                Shadow(
                                  blurRadius: 5,
                                  color: Colors.black26,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                          if (_charIndex < fullText.length)
                            Container(
                              margin: const EdgeInsets.only(left: 2),
                              child: AnimatedOpacity(
                                opacity: _charIndex % 2 == 0 ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 500),
                                child: const Text(
                                  '|',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Color.fromARGB(255, 17, 229, 67),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Session status indicator (optional - you can remove this)
            if (!_isSessionRestored)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Checking session...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // Enhanced wave animation
            SizedBox(
              height: 150,
              width: double.infinity,
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: EnhancedWavePainter(_waveController.value),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnhancedWavePainter extends CustomPainter {
  final double animationValue;

  EnhancedWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // First wave (main wave)
    final paint1 = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Second wave (overlay)
    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Third wave (subtle background)
    final paint3 = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Draw three overlapping waves for depth
    _drawWave(canvas, size, paint3, animationValue, 0.6, 15, 0.8);
    _drawWave(canvas, size, paint2, animationValue, 0.5, 25, 0.4);
    _drawWave(canvas, size, paint1, animationValue, 0.4, 35, 0.0);
  }

  void _drawWave(Canvas canvas, Size size, Paint paint, double animationValue,
      double baseHeight, double amplitude, double phase) {
    final path = Path();
    path.moveTo(0, size.height * baseHeight);

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * baseHeight +
            amplitude *
                sin((i / size.width * 2 * pi) +
                    animationValue * 2 * pi +
                    phase * pi),
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant EnhancedWavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}