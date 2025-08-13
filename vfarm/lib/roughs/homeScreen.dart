// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:vfarm/AskExpert.dart';
// import 'package:vfarm/MarketScreen.dart';
// import 'package:vfarm/MyVault.dart';
// import 'package:vfarm/govtSchemes.dart';
// import 'package:vfarm/session_manager.dart';
// import 'dart:math' as math;
// // Main wrapper widget that maintains the side menu across pages
// class MainWrapper extends StatefulWidget {
//   final Widget child;
//   final String currentRoute;

//   const MainWrapper({
//     super.key,
//     required this.child,
//     required this.currentRoute,
//   });

//   @override
//   State<MainWrapper> createState() => _MainWrapperState();
// }

// class _MainWrapperState extends State<MainWrapper> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         title: Text(_getPageTitle(widget.currentRoute)),
//         backgroundColor: const Color(0xFF0A9D88),
//         foregroundColor: Colors.white,
//       ),
//       drawer: SideMenu(currentRoute: widget.currentRoute),
//       body: widget.child,
//     );
//   }

//   String _getPageTitle(String route) {
//     switch (route) {
//       case '/home':
//         return 'Dashboard';
//       case '/govtSchemes':
//         return 'Government Schemes';
//       case '/searchSchemes':
//         return 'Search Schemes';
//       case '/bookService':
//         return 'Book Service';
//       case '/markets':
//         return 'Markets';
//       case '/askExpert':
//         return 'Ask Expert';
//       case '/myVault':
//         return 'My Vault';
//       default:
//         return 'VFarm';
//     }
//   }
// }

// class SideMenu extends StatelessWidget {
//   final String currentRoute;

//   const SideMenu({super.key, required this.currentRoute});
// @override
// Widget build(BuildContext context) {
//   return Drawer(
//     child: Container(
//       color: const Color(0xFF0A9D88), // Teal background color
//       child: Column(
//         children: [
//           // Logo section
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             child: Center(
//               child: Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: [
//                       const Color(0xFFCCEA90), // Light green
//                       const Color(0xFF9CDA5E), // Darker green
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: CustomPaint(painter: LogoPainter()),
//               ),
//             ),
//           ),
//           // Menu items
//           _buildMenuItem(
//             icon: Icons.dashboard,
//             title: "Dashboard",
//             isSelected: currentRoute == '/home',
//             onTap: () {
//               _navigateToPage(context, '/home');
//             },
//           ),
//           _buildMenuItem(
//             icon: Icons.account_balance,
//             title: "Government Schemes & Funds",
//             isSelected: currentRoute == '/govtSchemes',
//             onTap: () {
//               _navigateToPage(context, '/govtSchemes');
//             },
//           ),
          
//           _buildMenuItem(
//             icon: Icons.engineering,
//             title: "Book a service",
//             isSelected: currentRoute == '/bookService',
//             onTap: () {
//               _navigateToPage(context, '/bookService');
//             },
//           ),
//           _buildMenuItem(
//             icon: Icons.storefront,
//             title: "Markets",
//             isSelected: currentRoute == '/markets',
//             onTap: () {
//               _navigateToPage(context, '/markets');
//             },
//           ),
//           _buildMenuItem(
//             icon: Icons.question_answer,
//             title: "Ask an expert",
//             isSelected: currentRoute == '/askExpert',
//             onTap: () {
//               _navigateToPage(context, '/askExpert');
//             },
//           ),
//           _buildMenuItem(
//             icon: Icons.folder,
//             title: "My Vault",
//             isSelected: currentRoute == '/myVault',
//             onTap: () {
//               _navigateToPage(context, '/myVault');
//             },
//           ),
//           // Spacer to push bottom items down
//           const Spacer(),
//           // Divider before bottom items
//           const Divider(color: Colors.white30, thickness: .5, height: 1),
//           // Settings button
//           _buildMenuItem(
//             icon: Icons.settings,
//             title: "Settings",
//             isSelected: currentRoute == '/settings',
//             onTap: () {
//               _navigateToPage(context, '/settings');
//             },
//             showRipple: true,
//           ),
//           // Logout button
//           _buildMenuItem(
//             icon: Icons.logout,
//             title: "Logout",
//             onTap: () {
//               _showLogoutDialog(context);
//             },
//             showRipple: true,
//           ),
//           const SizedBox(height: 20), // Bottom padding
//         ],
//       ),
//     ),
//   );
// }

//   void _navigateToPage(BuildContext context, String route) {
//     Navigator.of(context).pop(); // Close drawer
//     if (currentRoute != route) {
//       Navigator.of(context).pushReplacementNamed(route);
//     }
//   }
// void _showLogoutDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close dialog
//             },
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.of(context).pop(); // Close dialog
//               Navigator.of(context).pop(); // Close drawer if needed
              
//               try {
//                 // Clear session using SessionManager
//                 await SessionManager.instance.clearSession();
                
//                 // Sign out from Firebase
//                 await FirebaseAuth.instance.signOut();
                
//                 // Navigate to login and clear all previous routes
//                 Navigator.of(context).pushNamedAndRemoveUntil(
//                   '/login',
//                   (Route<dynamic> route) => false,
//                 );
//               } catch (e) {
//                 debugPrint('Logout error: $e');
//                 // Still navigate to login even if there's an error
//                 Navigator.of(context).pushNamedAndRemoveUntil(
//                   '/login',
//                   (Route<dynamic> route) => false,
//                 );
//               }
//             },
//             child: const Text(
//               'Logout',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//           IconButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close dialog
//               Navigator.of(context).pop(); // Close drawer if needed
              
//               // Navigate to settings page
//               Navigator.of(context).pushNamed('/settings');
//             },
//             icon: const Icon(
//               Icons.settings,
//               color: Colors.blue,
//             ),
//             tooltip: 'Settings',
//           ),
//         ],
//       );
//     },
//   );
// }
//   Widget _buildMenuItem({
//     required IconData icon,
//     required String title,
//     bool isSelected = false,
//     required Function() onTap,
//     bool showRipple = false,
//   }) {
//     return Container(
//       color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
//       child: ListTile(
//         leading: Icon(icon, color: Colors.white, size: 22),
//         title: Text(
//           title,
//           style: const TextStyle(color: Colors.white, fontSize: 16),
//         ),
//         onTap: () {
//           if (showRipple) {
//             // Add a slight delay for the ripple effect to be visible
//             Future.delayed(const Duration(milliseconds: 200), onTap);
//           } else {
//             onTap();
//           }
//         },
//       ),
//     );
//   }
// }

// // Custom painter for the wavy logo
// class LogoPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint =
//         Paint()
//           ..color = const Color(0xFF0A9D88).withOpacity(0.2)
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 4;

//     final double radius = size.width / 2;
//     final Offset center = Offset(size.width / 2, size.height / 2);

//     // Draw the circular outline
//     canvas.drawCircle(center, radius - 2, paint);

//     // Draw wavy lines inside the circle
//     paint.color = const Color(0xFF0A9D88).withOpacity(0.4);
//     final Path path1 = Path();
//     path1.moveTo(center.dx - radius + 10, center.dy);
//     path1.quadraticBezierTo(
//       center.dx - radius / 3,
//       center.dy - radius / 2,
//       center.dx + radius - 10,
//       center.dy - radius / 4,
//     );
//     canvas.drawPath(path1, paint);

//     final Path path2 = Path();
//     path2.moveTo(center.dx - radius + 10, center.dy + radius / 4);
//     path2.quadraticBezierTo(
//       center.dx,
//       center.dy,
//       center.dx + radius - 10,
//       center.dy + radius / 2,
//     );
//     canvas.drawPath(path2, paint);

//     final Path path3 = Path();
//     path3.moveTo(center.dx - radius + 15, center.dy - radius / 3);
//     path3.quadraticBezierTo(
//       center.dx,
//       center.dy + radius / 4,
//       center.dx + radius - 15,
//       center.dy - radius / 6,
//     );
//     canvas.drawPath(path3, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MainWrapper(currentRoute: '/home', child: VFarmHomeContent());
//   }
// }

// class VFarmHomeContent extends StatefulWidget {
//   const VFarmHomeContent({super.key});

//   @override
//   State<VFarmHomeContent> createState() => _VFarmHomeContentState();
// }

// class _VFarmHomeContentState extends State<VFarmHomeContent>
//     with TickerProviderStateMixin {
//   late PageController _pageController;
//   late AnimationController _typingController;
//   late AnimationController _pulseController;
//   late AnimationController _floatingController;
//   late ScrollController _scrollController;
  
//   Timer? _autoScrollTimer;
//   Timer? _typingTimer;
  
//   int _currentCarouselIndex = 0;
//   int _typingIndex = 0;
//   String _currentTypingText = '';
//   bool _isSearchFocused = false;
//   bool _isDisposed = false;

//   final List<String> _typingTexts = [
//     "Smart Farming Solutions",
//     "Government Schemes Available", 
//     "Expert Consultation Ready",
//     "Market Intelligence Here",
//     "Crop Management Tools",
//     "Weather Forecast Updates",
//     "AI-Powered Insights",
//     "Modern Equipment Access",
//   ];

//   final List<Map<String, dynamic>> _carouselItems = [
//     {
//       'image': 'assets/images/smart_farming.jpg',
//       'title': 'Smart Farming',
//       'subtitle': 'AI-powered crop management',
//       'description': 'Monitor soil, weather, and crop health',
//       'gradient': [Color(0xFF4CAF50), Color(0xFF2E7D32)],
//       'icon': Icons.psychology,
//       'route': '/smart-farming',
//     },
//     {
//       'image': 'assets/images/govt_schemes.jpg',
//       'title': 'Government Schemes',
//       'subtitle': 'Financial support & subsidies',
//       'description': 'Access schemes with easy application',
//       'gradient': [Color(0xFF2196F3), Color(0xFF1565C0)],
//       'icon': Icons.account_balance,
//       'route': '/government-schemes',
//     },
//     {
//       'image': 'assets/images/expert_consultation.jpg',
//       'title': 'Expert Consultation',
//       'subtitle': 'Professional farming advice 24/7',
//       'description': 'Connect with verified experts',
//       'gradient': [Color(0xFFFF9800), Color(0xFFE65100)],
//       'icon': Icons.support_agent,
//       'route': '/expert-consultation',
//     },
//     {
//       'image': 'assets/images/market_intelligence.jpg',
//       'title': 'My Vault',
//       'subtitle': 'Secure digital farming records',
//       'description': 'Store documents & data safely',
//       'gradient': [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
//       'icon': Icons.security,
//       'route': '/market-intelligence',
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(viewportFraction: 0.85);
//     _scrollController = ScrollController();
    
//     _typingController = AnimationController(
//       duration: const Duration(milliseconds: 100),
//       vsync: this,
//     );
    
//     _pulseController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat();
    
//     _floatingController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     )..repeat();

//     // Delay initialization to ensure widgets are built
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!_isDisposed) {
//         _startCarouselAutoScroll();
//         _startTypingAnimation();
//       }
//     });
//   }

//   void _startCarouselAutoScroll() {
//     _autoScrollTimer?.cancel();
//     _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (_isDisposed || !_pageController.hasClients) return;
      
//       if (_currentCarouselIndex < _carouselItems.length - 1) {
//         _currentCarouselIndex++;
//       } else {
//         _currentCarouselIndex = 0;
//       }
      
//       if (_pageController.hasClients) {
//         _pageController.animateToPage(
//           _currentCarouselIndex,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeInOutCubic,
//         );
//       }
//     });
//   }

//   void _startTypingAnimation() {
//     _typingTimer?.cancel();
//     _typingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
//       if (_isDisposed) return;
      
//       setState(() {
//         if (_currentTypingText.length < _typingTexts[_typingIndex].length) {
//           _currentTypingText = _typingTexts[_typingIndex].substring(
//             0,
//             _currentTypingText.length + 1,
//           );
//         } else {
//           Future.delayed(const Duration(milliseconds: 2500), () {
//             if (!_isDisposed) {
//               setState(() {
//                 _currentTypingText = '';
//                 _typingIndex = (_typingIndex + 1) % _typingTexts.length;
//               });
//             }
//           });
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _isDisposed = true;
//     _autoScrollTimer?.cancel();
//     _typingTimer?.cancel();
//     _pageController.dispose();
//     _scrollController.dispose();
//     _typingController.dispose();
//     _pulseController.dispose();
//     _floatingController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Color(0xFFF8FFF8),
//             Color(0xFFE8F5E8),
//             Colors.white,
//           ],
//         ),
//       ),
//       child: CustomScrollView(
//         controller: _scrollController,
//         slivers: [
//           // Custom App Bar with Search
//           SliverAppBar(
//             expandedHeight: 120,
//             floating: true,
//             pinned: true,
//             elevation: 0,
//             backgroundColor: Colors.transparent,
//             flexibleSpace: FlexibleSpaceBar(
//               background: _buildEnhancedSearchBar(),
//             ),
//           ),
          
//           // Content
//           SliverList(
//             delegate: SliverChildListDelegate([
//               _buildEnhancedTypingHeader(),
//               _buildEnhancedImageCarousel(),
//               _buildStatsSection(),
//               _buildEnhancedQuickServicesGrid(),
//               _buildTrendingSection(),
//               _buildEnhancedInstantServices(),
//               _buildNewsletterSection(),
//               const SizedBox(height: 30),
//             ]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEnhancedSearchBar() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(20, 60, 20, 20),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(30),
//           boxShadow: [
//             BoxShadow(
//               color: _isSearchFocused ? const Color(0xFF0A9D88).withOpacity(0.3) : Colors.grey.withOpacity(0.2),
//               spreadRadius: _isSearchFocused ? 4 : 2,
//               blurRadius: _isSearchFocused ? 15 : 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             AnimatedBuilder(
//               animation: _pulseController,
//               builder: (context, child) {
//                 return Transform.scale(
//                   scale: 1.0 + (_pulseController.value * 0.1),
//                   child: const Icon(
//                     Icons.search_rounded,
//                     color: Color(0xFF0A9D88),
//                     size: 26,
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(width: 15),
//             Expanded(
//               child: TextField(
//                 onTap: () => setState(() => _isSearchFocused = true),
//                 onEditingComplete: () => setState(() => _isSearchFocused = false),
//                 decoration: InputDecoration(
//                   hintText: "Search farming solutions...",
//                   hintStyle: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 16,
//                     fontWeight: FontWeight.w400,
//                   ),
//                   border: InputBorder.none,
//                 ),
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF0A9D88).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(
//                 Icons.mic_rounded,
//                 color: Color(0xFF0A9D88),
//                 size: 20,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEnhancedTypingHeader() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: AnimatedBuilder(
//         animation: _floatingController,
//         builder: (context, child) {
//           return Transform.translate(
//             offset: Offset(0, math.sin(_floatingController.value * 2 * math.pi) * 3),
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [
//                     Color(0xFF0A9D88),
//                     Color(0xFF149D80),
//                     Color(0xFF1DB584),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF0A9D88).withOpacity(0.4),
//                     spreadRadius: 2,
//                     blurRadius: 15,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Colors.white, Colors.green.shade50],
//                       ),
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 8,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'V',
//                         style: TextStyle(
//                           color: Color(0xFF0A9D88),
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Row(
//                           children: [
//                             const Text(
//                               "VFarm",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                                 letterSpacing: 1.2,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange,
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: const Text(
//                                 "PRO",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 6),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 _currentTypingText,
//                                 style: const TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             AnimatedOpacity(
//                               opacity: _currentTypingText.isNotEmpty ? 1.0 : 0.0,
//                               duration: const Duration(milliseconds: 500),
//                               child: Container(
//                                 width: 2,
//                                 height: 20,
//                                 color: Colors.greenAccent,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildStatsSection() {
//     final stats = [
//       {'value': '10K+', 'label': 'Farmers', 'icon': Icons.people},
//       {'value': '500+', 'label': 'Experts', 'icon': Icons.verified_user},
//       {'value': '2Cr+', 'label': 'Saved', 'icon': Icons.savings},
//     ];

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: stats.map((stat) {
//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 stat['icon'] as IconData,
//                 color: const Color(0xFF0A9D88),
//                 size: 28,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 stat['value'] as String,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF0A9D88),
//                 ),
//               ),
//               Text(
//                 stat['label'] as String,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildEnhancedImageCarousel() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // Responsive height calculation
//         double screenHeight = MediaQuery.of(context).size.height;
//         double carouselHeight = screenHeight > 800 ? 280 : 240;
        
//         return SizedBox(
//           height: carouselHeight,
//           child: PageView.builder(
//             controller: _pageController,
//             onPageChanged: (index) {
//               setState(() {
//                 _currentCarouselIndex = index;
//               });
//             },
//             itemCount: _carouselItems.length,
//             itemBuilder: (context, index) {
//               final item = _carouselItems[index];
//               return AnimatedBuilder(
//                 animation: _pageController,
//                 builder: (context, child) {
//                   double value = 1.0;
//                   if (_pageController.position.haveDimensions) {
//                     value = _pageController.page! - index;
//                     value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
//                   }
                  
//                   return Center(
//                     child: SizedBox(
//                       height: Curves.easeOut.transform(value) * carouselHeight,
//                       child: child,
//                     ),
//                   );
//                 },
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 10),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     gradient: LinearGradient(
//                       colors: item['gradient'] as List<Color>,
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: (item['gradient'][0] as Color).withOpacity(0.4),
//                         spreadRadius: 2,
//                         blurRadius: 15,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Stack(
//                     children: [
//                       Positioned.fill(child: CustomPaint(painter: EnhancedPatternPainter())),
//                       Padding(
//                         padding: EdgeInsets.all(MediaQuery.of(context).size.width > 400 ? 20 : 16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Header row with icon and badge
//                             Row(
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(8),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Icon(
//                                     item['icon'] as IconData,
//                                     color: Colors.white,
//                                     size: 20,
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                   child: const Text(
//                                     "NEW",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 9,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
                            
//                             // Flexible space
//                             const Spacer(flex: 1),
                            
//                             // Title
//                             Text(
//                               item['title'] as String,
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: MediaQuery.of(context).size.width > 400 ? 22 : 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
                            
//                             SizedBox(height: MediaQuery.of(context).size.height > 700 ? 8 : 4),
                            
//                             // Subtitle
//                             Text(
//                               item['subtitle'] as String,
//                               style: const TextStyle(
//                                 color: Colors.white70,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
                            
//                             // Description (only show on larger screens)
//                             if (MediaQuery.of(context).size.height > 700) ...[
//                               const SizedBox(height: 4),
//                               Text(
//                                 item['description'] as String,
//                                 style: const TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 11,
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
                            
//                             const Spacer(flex: 1),
                            
//                             // Button
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: () {},
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.white,
//                                   foregroundColor: item['gradient'][0] as Color,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   padding: EdgeInsets.symmetric(
//                                     vertical: MediaQuery.of(context).size.height > 700 ? 12 : 10
//                                   ),
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(
//                                       "Explore Now",
//                                       style: TextStyle(
//                                         fontSize: MediaQuery.of(context).size.width > 400 ? 14 : 13,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 6),
//                                     const Icon(Icons.arrow_forward, size: 14),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTrendingSection() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.trending_up, color: Colors.orange, size: 24),
//               const SizedBox(width: 8),
//               const Text(
//                 "Trending Now",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF0A9D88),
//                 ),
//               ),
//               const Spacer(),
//               TextButton(
//                 onPressed: () {},
//                 child: const Text("View All"),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 _buildTrendingCard("Wheat Price Up", "Rs.2,850/quintal", Colors.green),
//                 _buildTrendingCard("Monsoon Alert", "Expected in 3 days", Colors.blue),
//                 _buildTrendingCard("New Subsidy", "Rs.15,000 available", Colors.orange),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTrendingCard(String title, String subtitle, Color color) {
//     return Container(
//       margin: const EdgeInsets.only(right: 12),
//       padding: const EdgeInsets.all(16),
//       width: 160,
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//               color: color,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             subtitle,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[600],
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEnhancedQuickServicesGrid() {
//     final services = [
//       {
//         'icon': Icons.account_balance_wallet,
//         'title': 'Government\nSchemes',
//         'color': const Color(0xFF4CAF50),
//         'route': '/govtSchemes',
//         'badge': '50+ Active',
//       },
//       {
//         'icon': Icons.handyman,
//         'title': 'Book a\nService',
//         'color': const Color(0xFF2196F3),
//         'route': '/bookService',
//         'badge': 'Available',
//       },
//       {
//         'icon': Icons.psychology,
//         'title': 'Ask Expert',
//         'color': const Color(0xFFFF9800),
//         'route': '/markets',
//         'badge': '24/7 Live',
//       },
//       {
//         'icon': Icons.lock_person,
//         'title': 'My Vault',
//         'color': const Color(0xFF9C27B0),
//         'route': '/myVault',
//         'badge': 'Secure',
//       },
//     ];

//     return Container(
//       margin: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Text(
//                 "Quick Services",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF0A9D88),
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Text(
//                   "Most Used",
//                   style: TextStyle(
//                     color: Colors.orange,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 1.3,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//             ),
//             itemCount: services.length,
//             itemBuilder: (context, index) {
//               final service = services[index];
//               return Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(18),
//                   boxShadow: [
//                     BoxShadow(
//                       color: (service['color'] as Color).withOpacity(0.2),
//                       spreadRadius: 2,
//                       blurRadius: 12,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(18),
//                     onTap: () {
//                       Navigator.pushNamed(context, service['route'] as String);
//                     },
//                     child: Stack(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   color: (service['color'] as Color).withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 child: Icon(
//                                   service['icon'] as IconData,
//                                   size: 28,
//                                   color: service['color'] as Color,
//                                 ),
//                               ),
//                               const SizedBox(height: 12),
//                               Text(
//                                 service['title'] as String,
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black87,
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                         Positioned(
//                           top: 8,
//                           right: 8,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: service['color'] as Color,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               service['badge'] as String,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 8,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEnhancedInstantServices() {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(Icons.flash_on, color: Colors.orange, size: 20),
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 "Instant Services",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF0A9D88),
//                 ),
//               ),
//               const Spacer(),
//               const Text(
//                 "Super Fast",
//                 style: TextStyle(
//                   color: Colors.orange,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 15),
//           _buildEnhancedServiceRow([
//             {
//               'icon': Icons.agriculture,
//               'title': 'Equipment\nRental',
//               'color': const Color(0xFF2196F3),
//               'subtitle': 'Starting Rs.500/day',
//             },
//             {
//               'icon': Icons.local_florist,
//               'title': 'Quality\nFertilizer',
//               'color': const Color(0xFF4CAF50),
//               'subtitle': '20% off today',
//             },
//             {
//               'icon': Icons.science,
//               'title': 'Soil\nTesting',
//               'color': const Color(0xFFFF9800),
//               'subtitle': 'Results in 2hrs',
//             },
//             {
//               'icon': Icons.people_alt,
//               'title': 'Farm\nWorkers',
//               'color': const Color(0xFF9C27B0),
//               'subtitle': 'Verified & skilled',
//             },
//           ]),
//         ],
//       ),
//     );
//   }

//   Widget _buildNewsletterSection() {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF0A9D88), Color(0xFF149D80)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF0A9D88).withOpacity(0.3),
//             spreadRadius: 2,
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   "Stay Updated!",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 6),
//                 Text(
//                   "Get daily farming tips & market updates",
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           ElevatedButton(
//             onPressed: () {},
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white,
//               foregroundColor: const Color(0xFF0A9D88),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//             child: const Text("Subscribe", style: TextStyle(fontSize: 14)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEnhancedServiceRow(List<Map<String, dynamic>> services) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // Responsive sizing based on screen width
//         double itemWidth = (constraints.maxWidth - 48) / 4; // 4 items with spacing
//         bool isSmallScreen = MediaQuery.of(context).size.width < 400;
        
//         return Row(
//           children: services.map((service) {
//             return Expanded(
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 4),
//                 padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: (service['color'] as Color).withOpacity(0.15),
//                       spreadRadius: 1,
//                       blurRadius: 8,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
//                       decoration: BoxDecoration(
//                         color: (service['color'] as Color).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Icon(
//                         service['icon'] as IconData,
//                         size: isSmallScreen ? 20 : 24,
//                         color: service['color'] as Color,
//                       ),
//                     ),
//                     SizedBox(height: isSmallScreen ? 6 : 8),
//                     Text(
//                       service['title'] as String,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: isSmallScreen ? 9 : 11,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     if (service.containsKey('subtitle')) ...[
//                       SizedBox(height: isSmallScreen ? 2 : 4),
//                       Text(
//                         service['subtitle'] as String,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: isSmallScreen ? 7 : 9,
//                           color: Colors.grey[600],
//                           fontWeight: FontWeight.w400,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }

// class EnhancedPatternPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.1)
//       ..style = PaintingStyle.fill;

//     // Draw floating circles with varying sizes
//     for (int i = 0; i < 6; i++) {
//       final double radius = (i % 3 + 1) * 8.0;
//       final double x = size.width * (0.2 + (i * 0.15) % 0.6);
//       final double y = size.height * (0.1 + (i * 0.2) % 0.6);
//       canvas.drawCircle(Offset(x, y), radius, paint);
//     }

//     // Draw curved lines
//     final linePaint = Paint()
//       ..color = Colors.white.withOpacity(0.15)
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;

//     final path = Path();
//     path.moveTo(0, size.height * 0.3);
//     path.quadraticBezierTo(
//       size.width * 0.3,
//       size.height * 0.1,
//       size.width * 0.6,
//       size.height * 0.4,
//     );
//     canvas.drawPath(path, linePaint);

//     // Draw geometric shapes
//     final shapePaint = Paint()
//       ..color = Colors.white.withOpacity(0.08)
//       ..style = PaintingStyle.fill;

//     // Triangle
//     final trianglePath = Path();
//     trianglePath.moveTo(size.width * 0.8, size.height * 0.2);
//     trianglePath.lineTo(size.width * 0.85, size.height * 0.35);
//     trianglePath.lineTo(size.width * 0.75, size.height * 0.35);
//     trianglePath.close();
//     canvas.drawPath(trianglePath, shapePaint);

//     // Rectangle
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromLTWH(size.width * 0.1, size.height * 0.6, 30, 15),
//         const Radius.circular(4),
//       ),
//       shapePaint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

