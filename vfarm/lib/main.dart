import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vfarm/MarketScreen.dart';
import 'package:vfarm/MyVault.dart';
import 'package:vfarm/SearchShemes.dart';
import 'package:vfarm/bookingService.dart';
import 'package:vfarm/session_manager.dart';
import 'package:vfarm/smart-Farming.dart';
import 'home.dart';
import 'settings.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'govtSchemes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
   
    await Firebase.initializeApp();
    await SessionManager.initialize();
  
    final hasValidSession = await AppInitializer.initializeApp();
    
    runApp(MyApp(hasValidSession: hasValidSession));
    
  } catch (e) {
    print('❌ Error during app initialization: $e');
    runApp(const MyApp(hasValidSession: false));
  }
}
class MyApp extends StatelessWidget {
  final bool hasValidSession;
  
  const MyApp({super.key, this.hasValidSession = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VFarm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      initialRoute: hasValidSession ? '/home' : '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/govtSchemes': (context) => const EnhancedGovtSchemesScreen(),
        '/searchSchemes': (context) => const SearchSchemesScreen(),
        '/bookService': (context) => const BookServiceScreen(),
        '/markets': (context) => const MarketsScreen(),
        '/askExpert': (context) => const MarketsScreen(),
        '/myVault': (context) => const MyVaultScreen(),
        '/settings': (context) => const SettingsPage(),
        '/smartFarming': (context) => const SmartFarmingPage(),
        
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );
      },
    );
  }
}

class AppInitializer {
  static Future<bool> initializeApp() async {
    try {
      final sessionManager = SessionManager.instance;
      
      if (sessionManager.isSessionValid()) {
        final userId = sessionManager.getCurrentUserId();
        final username = sessionManager.getUsername();
        final email = sessionManager.getUserEmail();
        
        print('Session Data - UserId: $userId, Username: $username, Email: $email');

        final restored = await sessionManager.initializeFromStoredSession();
        
        if (restored) {
          print('✅ Session restored successfully');
          return true;
        } else {
          print('❌ Session restoration failed');
          await sessionManager.clearSession();
          return false;
        }
      } else {
        print('ℹ️ No valid session found');
        return false;
      }
      
    } catch (e) {
      print('❌ App initialization failed: $e');
      await SessionManager.instance.clearSession();
      return false;
    }
  }
  
  static Future<void> handleAppResume() async {
    try {
      final sessionManager = SessionManager.instance;
      
      if (sessionManager.isUserLoggedIn() && !sessionManager.isSessionValid()) {
        print('⏰ Session expired - Clearing session');
        await sessionManager.clearSession();
      }
    } catch (e) {
      print('❌ Error handling app resume: $e');
    }
  }
}

class AppLifecycleManager extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      AppInitializer.handleAppResume();
    }
  }
}
