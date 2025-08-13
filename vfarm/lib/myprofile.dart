// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:math' as math;

// // Import your models and session manager
// // import 'package:vfarm/models/user_profile_model.dart';
// // import 'package:vfarm/models/govt_scheme_model.dart';
// // import 'package:vfarm/models/document_model.dart';
// // import 'package:vfarm/services/session_manager.dart';

// class MyProfilePage extends StatefulWidget {
//   const MyProfilePage({super.key});

//   @override
//   State<MyProfilePage> createState() => _MyProfilePageState();
// }

// class _MyProfilePageState extends State<MyProfilePage>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _slideAnimation;

//   // User data variables
//   Map<String, dynamic> _userStats = {};
//   List<Map<String, dynamic>> _recentActivities = [];
//   List<Map<String, dynamic>> _userCrops = [];
//   List<Map<String, dynamic>> _applications = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _loadUserData();
//   }

//   void _initializeAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
//     ));

//     _slideAnimation = Tween<double>(
//       begin: 50.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
//     ));

//     _animationController.forward();
//   }

//   Future<void> _loadUserData() async {
//     try {
//       // Get current user profile from session
//       // final userProfile = SessionManager.instance.getCurrentUserProfile();
      
//       // Simulate loading user data - replace with actual Firebase calls
//       await Future.delayed(const Duration(seconds: 2));
      
//       setState(() {
//         _userStats = {
//           'vfarmPoints': 1250,
//           'profileCompletion': 85,
//           'documentsUploaded': 12,
//           'applicationsSubmitted': 3,
//           'communityPosts': 8,
//           'cropTypes': 4,
//           'farmSize': 5.2,
//           'experienceYears': 7,
//           'completedTasks': 24,
//           'totalTasks': 30,
//         };

//         _recentActivities = [
//           {
//             'title': 'Scheme Application Approved',
//             'description': 'PM Kisan Scheme - ₹2,000 credited',
//             'time': '2 hours ago',
//             'icon': Icons.check_circle,
//             'color': Colors.green,
//           },
//           {
//             'title': 'Document Uploaded',
//             'description': 'Land certificate uploaded successfully',
//             'time': '1 day ago',
//             'icon': Icons.upload_file,
//             'color': Colors.blue,
//           },
//           {
//             'title': 'Community Post',
//             'description': 'Shared crop health tips',
//             'time': '2 days ago',
//             'icon': Icons.forum,
//             'color': Colors.orange,
//           },
//           {
//             'title': 'Profile Updated',
//             'description': 'Updated farm location details',
//             'time': '3 days ago',
//             'icon': Icons.edit,
//             'color': Colors.purple,
//           },
//         ];

//         _userCrops = [
//           {'name': 'Rice', 'area': 2.5, 'health': 92, 'yield': 'High'},
//           {'name': 'Wheat', 'area': 1.8, 'health': 88, 'yield': 'Medium'},
//           {'name': 'Cotton', 'area': 0.7, 'health': 76, 'yield': 'Medium'},
//           {'name': 'Sugarcane', 'area': 0.2, 'health': 95, 'yield': 'High'},
//         ];

//         _applications = [
//           {
//             'schemeName': 'PM Kisan Scheme',
//             'status': 'Approved',
//             'appliedDate': '15 Jan 2024',
//             'amount': '₹2,000',
//             'color': Colors.green,
//           },
//           {
//             'schemeName': 'Crop Insurance',
//             'status': 'Under Review',
//             'appliedDate': '20 Jan 2024',
//             'amount': '₹15,000',
//             'color': Colors.orange,
//           },
//           {
//             'schemeName': 'Soil Health Card',
//             'status': 'Submitted',
//             'appliedDate': '25 Jan 2024',
//             'amount': 'Free',
//             'color': Colors.blue,
//           },
//         ];

//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         body: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//           child: const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(color: Colors.white),
//                 SizedBox(height: 20),
//                 Text(
//                   'Loading your profile...',
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: AnimatedBuilder(
//             animation: _animationController,
//             builder: (context, child) {
//               return Transform.translate(
//                 offset: Offset(0, _slideAnimation.value),
//                 child: Opacity(
//                   opacity: _fadeAnimation.value,
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.only(bottom: 20),
//                     child: Column(
//                       children: [
//                         _buildHeader(),
//                         const SizedBox(height: 20),
//                         _buildStatsOverview(),
//                         const SizedBox(height: 20),
//                         _buildCropAnalytics(),
//                         const SizedBox(height: 20),
//                         _buildApplicationsSection(),
//                         const SizedBox(height: 20),
//                         _buildRecentActivities(),
//                         const SizedBox(height: 20),
//                         _buildAchievements(),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     // final userProfile = SessionManager.instance.getCurrentUserProfile();
    
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
//             onPressed: () => Navigator.pop(context),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white,
//                         border: Border.all(color: Colors.white, width: 3),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.2),
//                             blurRadius: 10,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ),
//                       child: const Icon(
//                         Icons.person,
//                         color: Color(0xFF4CAF50),
//                         size: 30,
//                       ),
//                     ),
//                     const SizedBox(width: 15),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'John Farmer', // userProfile?.name ?? 'User'
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             '📍 Karnataka, India', // userProfile?.farmLocation ?? 'Location'
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.white.withOpacity(0.9),
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               '⭐ ${_userStats['vfarmPoints']} VFarm Points',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(Icons.edit, color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsOverview() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Profile Overview',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildCircularProgress(
//                   'Profile\nCompletion',
//                   _userStats['profileCompletion'] / 100,
//                   '${_userStats['profileCompletion']}%',
//                   Colors.blue,
//                 ),
//               ),
//               Expanded(
//                 child: _buildCircularProgress(
//                   'Task\nCompletion',
//                   _userStats['completedTasks'] / _userStats['totalTasks'],
//                   '${_userStats['completedTasks']}/${_userStats['totalTasks']}',
//                   Colors.green,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(child: _buildStatCard('Documents', '${_userStats['documentsUploaded']}', Icons.file_copy, Colors.purple)),
//               const SizedBox(width: 10),
//               Expanded(child: _buildStatCard('Applications', '${_userStats['applicationsSubmitted']}', Icons.assignment, Colors.orange)),
//               const SizedBox(width: 10),
//               Expanded(child: _buildStatCard('Posts', '${_userStats['communityPosts']}', Icons.forum, Colors.teal)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCircularProgress(String title, double progress, String value, Color color) {
//     return Column(
//       children: [
//         SizedBox(
//           width: 100,
//           height: 100,
//           child: Stack(
//             children: [
//               SizedBox(
//                 width: 100,
//                 height: 100,
//                 child: CircularProgressIndicator(
//                   value: progress,
//                   strokeWidth: 8,
//                   backgroundColor: color.withOpacity(0.2),
//                   valueColor: AlwaysStoppedAnimation<Color>(color),
//                 ),
//               ),
//               Center(
//                 child: Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: color,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 10),
//         Text(
//           title,
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.black54,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 24),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               color: color.withOpacity(0.8),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCropAnalytics() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.agriculture, color: Color(0xFF4CAF50), size: 24),
//               const SizedBox(width: 8),
//               const Text(
//                 'Crop Analytics',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF4CAF50).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '${_userStats['farmSize']} acres',
//                   style: const TextStyle(
//                     color: Color(0xFF4CAF50),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           ..._userCrops.map((crop) => _buildCropCard(crop)).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildCropCard(Map<String, dynamic> crop) {
//     final health = crop['health'] as int;
//     final healthColor = health > 90 ? Colors.green : health > 70 ? Colors.orange : Colors.red;
    
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: healthColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(Icons.eco, color: healthColor, size: 24),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   crop['name'],
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 Text(
//                   '${crop['area']} acres • ${crop['yield']} yield',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             children: [
//               SizedBox(
//                 width: 40,
//                 height: 40,
//                 child: CircularProgressIndicator(
//                   value: health / 100,
//                   strokeWidth: 4,
//                   backgroundColor: healthColor.withOpacity(0.2),
//                   valueColor: AlwaysStoppedAnimation<Color>(healthColor),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 '$health%',
//                 style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                   color: healthColor,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildApplicationsSection() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.assignment, color: Color(0xFF4CAF50), size: 24),
//               const SizedBox(width: 8),
//               const Text(
//                 'Scheme Applications',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 '${_applications.length} Total',
//                 style: TextStyle(
//                   color: Colors.grey.shade600,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           ..._applications.map((app) => _buildApplicationCard(app)).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildApplicationCard(Map<String, dynamic> application) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 12,
//             height: 50,
//             decoration: BoxDecoration(
//               color: application['color'],
//               borderRadius: BorderRadius.circular(6),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   application['schemeName'],
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Applied: ${application['appliedDate']}',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: application['color'].withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   application['status'],
//                   style: TextStyle(
//                     color: application['color'],
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 application['amount'],
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecentActivities() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.history, color: Color(0xFF4CAF50), size: 24),
//               SizedBox(width: 8),
//               Text(
//                 'Recent Activities',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           ..._recentActivities.map((activity) => _buildActivityItem(activity)).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildActivityItem(Map<String, dynamic> activity) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: activity['color'].withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               activity['icon'],
//               color: activity['color'],
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   activity['title'],
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 Text(
//                   activity['description'],
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             activity['time'],
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAchievements() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.emoji_events, color: Color(0xFF4CAF50), size: 24),
//               SizedBox(width: 8),
//               Text(
//                 'Achievements',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(child: _buildAchievementBadge('🌾', 'Crop Master', 'Grown 4+ crops')),
//               const SizedBox(width: 12),
//               Expanded(child: _buildAchievementBadge('📝', 'Documenter', '10+ docs uploaded')),
//               const SizedBox(width: 12),
//               Expanded(child: _buildAchievementBadge('🏆', 'Top Farmer', '1000+ VFarm points')),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAchievementBadge(String emoji, String title, String description) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFF4CAF50).withOpacity(0.1),
//             const Color(0xFF2E7D32).withOpacity(0.1),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
//       ),
//       child: Column(
//         children: [
//           Text(
//             emoji,
//             style: const TextStyle(fontSize: 24),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             description,
//             style: TextStyle(
//               fontSize: 10,
//               color: Colors.grey.shade600,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // User data variables
  Map<String, dynamic> _userStats = {};
  List<Map<String, dynamic>> _recentActivities = [];
  List<Map<String, dynamic>> _userCrops = [];
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      // Get current user profile from session
      // final userProfile = SessionManager.instance.getCurrentUserProfile();
      
      // Simulate loading user data - replace with actual Firebase calls
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _userStats = {
          'vfarmPoints': 1250,
          'profileCompletion': 85,
          'documentsUploaded': 12,
          'applicationsSubmitted': 3,
          'communityPosts': 8,
          'cropTypes': 4,
          'farmSize': 5.2,
          'experienceYears': 7,
          'completedTasks': 24,
          'totalTasks': 30,
        };

        _recentActivities = [
          {
            'title': 'Scheme Application Approved',
            'description': 'PM Kisan Scheme - ₹2,000 credited',
            'time': '2 hours ago',
            'icon': Icons.check_circle,
            'color': Colors.green,
          },
          {
            'title': 'Document Uploaded',
            'description': 'Land certificate uploaded successfully',
            'time': '1 day ago',
            'icon': Icons.upload_file,
            'color': Colors.blue,
          },
          {
            'title': 'Community Post',
            'description': 'Shared crop health tips',
            'time': '2 days ago',
            'icon': Icons.forum,
            'color': Colors.orange,
          },
          {
            'title': 'Profile Updated',
            'description': 'Updated farm location details',
            'time': '3 days ago',
            'icon': Icons.edit,
            'color': Colors.purple,
          },
        ];

        _userCrops = [
          {'name': 'Rice', 'area': 2.5, 'health': 92, 'yield': 'High'},
          {'name': 'Wheat', 'area': 1.8, 'health': 88, 'yield': 'Medium'},
          {'name': 'Cotton', 'area': 0.7, 'health': 76, 'yield': 'Medium'},
          {'name': 'Sugarcane', 'area': 0.2, 'health': 95, 'yield': 'High'},
        ];

        _applications = [
          {
            'schemeName': 'PM Kisan Scheme',
            'status': 'Approved',
            'appliedDate': '15 Jan 2024',
            'amount': '₹2,000',
            'color': Colors.green,
          },
          {
            'schemeName': 'Crop Insurance',
            'status': 'Under Review',
            'appliedDate': '20 Jan 2024',
            'amount': '₹15,000',
            'color': Colors.orange,
          },
          {
            'schemeName': 'Soil Health Card',
            'status': 'Submitted',
            'appliedDate': '25 Jan 2024',
            'amount': 'Free',
            'color': Colors.blue,
          },
        ];

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 20),
                Text(
                  'Loading your profile...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildStatsOverview(),
                        const SizedBox(height: 20),
                        _buildCropAnalytics(),
                        const SizedBox(height: 20),
                        _buildApplicationsSection(),
                        const SizedBox(height: 20),
                        _buildRecentActivities(),
                        const SizedBox(height: 20),
                        _buildAchievements(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // final userProfile = SessionManager.instance.getCurrentUserProfile();
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF4CAF50),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'John Farmer', // userProfile?.name ?? 'User'
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '📍 Karnataka, India', // userProfile?.farmLocation ?? 'Location'
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '⭐ ${_userStats['vfarmPoints']} VFarm Points',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildCircularProgress(
                  'Profile\nCompletion',
                  _userStats['profileCompletion'] / 100,
                  '${_userStats['profileCompletion']}%',
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildCircularProgress(
                  'Task\nCompletion',
                  _userStats['completedTasks'] / _userStats['totalTasks'],
                  '${_userStats['completedTasks']}/${_userStats['totalTasks']}',
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatCard('Documents', '${_userStats['documentsUploaded']}', Icons.file_copy, Colors.purple)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard('Applications', '${_userStats['applicationsSubmitted']}', Icons.assignment, Colors.orange)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard('Posts', '${_userStats['communityPosts']}', Icons.forum, Colors.teal)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(String title, double progress, String value, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Center(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropAnalytics() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.agriculture, color: Color(0xFF4CAF50), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Crop Analytics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_userStats['farmSize']} acres',
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._userCrops.map((crop) => _buildCropCard(crop)).toList(),
        ],
      ),
    );
  }

  Widget _buildCropCard(Map<String, dynamic> crop) {
    final health = crop['health'] as int;
    final healthColor = health > 90 ? Colors.green : health > 70 ? Colors.orange : Colors.red;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: healthColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.eco, color: healthColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${crop['area']} acres • ${crop['yield']} yield',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: health / 100,
                  strokeWidth: 4,
                  backgroundColor: healthColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$health%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: healthColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment, color: Color(0xFF4CAF50), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Scheme Applications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                '${_applications.length} Total',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._applications.map((app) => _buildApplicationCard(app)).toList(),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 50,
            decoration: BoxDecoration(
              color: application['color'],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application['schemeName'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Applied: ${application['appliedDate']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: application['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  application['status'],
                  style: TextStyle(
                    color: application['color'],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                application['amount'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history, color: Color(0xFF4CAF50), size: 24),
              SizedBox(width: 8),
              Text(
                'Recent Activities',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._recentActivities.map((activity) => _buildActivityItem(activity)).toList(),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: activity['color'].withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              activity['icon'],
              color: activity['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  activity['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Color(0xFF4CAF50), size: 24),
              SizedBox(width: 8),
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildAchievementBadge('🌾', 'Crop Master', 'Grown 4+ crops')),
              const SizedBox(width: 12),
              Expanded(child: _buildAchievementBadge('📝', 'Documenter', '10+ docs uploaded')),
              const SizedBox(width: 12),
              Expanded(child: _buildAchievementBadge('🏆', 'Top Farmer', '1000+ VFarm points')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String emoji, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.1),
            const Color(0xFF2E7D32).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}