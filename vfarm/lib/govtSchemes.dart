
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vfarm/home.dart';
import 'package:vfarm/models/govt_scheme_model.dart';
import 'package:vfarm/models/user_profile_model.dart';
import 'package:vfarm/scheme_service.dart';
import 'package:vfarm/screens/scheme_application_screen.dart';
import 'package:vfarm/session_manager.dart';
import 'package:vfarm/status/application_status_sheet.dart';
class EnhancedGovtSchemesScreen extends StatefulWidget {
  const EnhancedGovtSchemesScreen({super.key});

  @override
  State<EnhancedGovtSchemesScreen> createState() => _EnhancedGovtSchemesScreenState();
}

class _EnhancedGovtSchemesScreenState extends State<EnhancedGovtSchemesScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SchemeService _schemeService = SchemeService();
  List<GovtSchemeModel> _allSchemes = [];
  List<GovtSchemeModel> _eligibleSchemes = [];
  List<GovtSchemeModel> _filteredSchemes = [];
  List<SchemeApplicationModel> _userApplications = [];
  bool _isLoading = true;
  UserProfileModel? _userProfile;
  
  // Filter variables
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  String _searchQuery = '';
  final List<String> _categories = ['All', 'Subsidy', 'Loan', 'Insurance', 'Training', 'Technology'];
  final List<String> _statusFilters = ['All', 'Eligible', 'Not Eligible'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      setState(() => _isLoading = true);
      
      final userId = SessionManager.instance.getCurrentUserId();
      print('User ID: $userId');
      
      // Get user profile
      _userProfile = SessionManager.instance.getCurrentUserProfile();
      print('User Profile from session: ${_userProfile?.toJson()}');
      
      if (_userProfile == null && userId != null) {
        try {
          _userProfile = await _fetchUserProfileFromDatabase(userId);
          print('User Profile from database: ${_userProfile?.toJson()}');
          
          if (_userProfile != null) {
            SessionManager.instance.setCurrentUserProfile(_userProfile!);
          }
        } catch (e) {
          print('Error fetching user profile: $e');
        }
      }
      
      // Fetch all schemes
      _allSchemes = await _schemeService.getAllSchemes();
      print('All schemes count: ${_allSchemes.length}');
      
      if (_userProfile != null && userId != null) {
        // Filter eligible schemes
        _eligibleSchemes = _allSchemes.where((scheme) {
          final cropEligible = scheme.eligibleCropTypes.contains('all') ||
              _userProfile!.cropTypes.any((crop) => 
                  scheme.eligibleCropTypes.contains(crop.toLowerCase()));
          return cropEligible;
        }).toList();
        
        print('Eligible schemes count: ${_eligibleSchemes.length}');
        
        if (_eligibleSchemes.isEmpty) {
          _eligibleSchemes = _allSchemes;
          print('No eligible schemes found, showing all schemes');
        }
        
        // Fetch user applications
        _userApplications = await _schemeService.getUserApplications(userId);
        print('User applications count: ${_userApplications.length}');
      } else {
        _eligibleSchemes = _allSchemes;
        print('No user profile, showing all schemes');
      }
      
      // Apply initial filters
      _applyFilters();
      
    } catch (e) {
      print('Error in _initializeData: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      try {
        _allSchemes = await _schemeService.getAllSchemes();
        _eligibleSchemes = _allSchemes;
        _applyFilters();
      } catch (fallbackError) {
        print('Fallback error: $fallbackError');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<UserProfileModel?> _fetchUserProfileFromDatabase(String userId) async {
    try {
      print('Fetching user profile for userId: $userId');
      
      final doc = await FirebaseFirestore.instance
          .collection('userdetails')
          .doc(userId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        print('User profile found in database');
        return UserProfileModel.fromMap(doc.data()!);
      } else {
        print('No user profile found in database for userId: $userId');
        return null;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredSchemes = _eligibleSchemes.where((scheme) {
        // Category filter
        bool categoryMatch = _selectedCategory == 'All' || 
            scheme.category?.toLowerCase() == _selectedCategory.toLowerCase();
        
        // Status filter
        bool statusMatch = _selectedStatus == 'All' ||
            (_selectedStatus == 'Eligible' && _isUserEligible(scheme)) ||
            (_selectedStatus == 'Not Eligible' && !_isUserEligible(scheme));
        
        // Search filter
        bool searchMatch = _searchQuery.isEmpty ||
            scheme.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            scheme.description.toLowerCase().contains(_searchQuery.toLowerCase());
        
        return categoryMatch && statusMatch && searchMatch;
      }).toList();
    });
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar with improved design
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: 'Search schemes by name or description...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF0A9D88),
                  size: 24,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Enhanced filter chips
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Category filter with improved design
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A9D88).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF0A9D88).withOpacity(0.3),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF0A9D88),
                              size: 10,
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getCategoryIcon(category),
                                      size: 16,
                                      color: const Color(0xFF0A9D88),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(category),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value ?? 'All';
                              });
                              _applyFilters();
                            },
                            style: const TextStyle(
                              color: Color(0xFF0A9D88),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      
                      // Status filter with improved design
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.blue,
                              size: 10,
                            ),
                            items: _statusFilters.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getStatusIcon(status),
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(status),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value ?? 'All';
                              });
                              _applyFilters();
                            },
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      
                      // Clear filters button with improved design
                      if (_selectedCategory != 'All' || _selectedStatus != 'All' || _searchQuery.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = 'All';
                                _selectedStatus = 'All';
                                _searchQuery = '';
                              });
                              _applyFilters();
                            },
                            icon: const Icon(Icons.clear_all_rounded, size: 15),
                            label: const Text('Clear All'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              backgroundColor: Colors.grey.shade100,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Refresh button with improved design
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0A9D88).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _initializeData,
                  icon: const Icon(Icons.refresh_rounded),
                  color: const Color(0xFF0A9D88),
                  tooltip: 'Refresh Schemes',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'subsidy':
        return Icons.money_rounded;
      case 'loan':
        return Icons.account_balance_rounded;
      case 'insurance':
        return Icons.security_rounded;
      case 'training':
        return Icons.school_rounded;
      case 'technology':
        return Icons.computer_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'eligible':
        return Icons.check_circle_rounded;
      case 'not eligible':
        return Icons.cancel_rounded;
      default:
        return Icons.list_rounded;
    }
  }

  Widget _buildSchemesTab() {
    return Column(
      children: [
        _buildFilterSection(),
        Expanded(
          child: Container(
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced header
                  // Container(
                  //   padding: const EdgeInsets.all(20),
                  //   decoration: BoxDecoration(
                  //     gradient: const LinearGradient(
                  //       colors: [Color(0xFF0A9D88), Color(0xFF0C7B68)],
                  //       begin: Alignment.topLeft,
                  //       end: Alignment.bottomRight,
                  //     ),
                  //     borderRadius: BorderRadius.circular(16),
                  //     boxShadow: [
                  //       // BoxShadow(
                  //       //   color: const Color(0xFF0A9D88).withOpacity(0.3),
                  //       //   blurRadius: 8,
                  //       //   offset: const Offset(0, 4),
                  //       // ),
                  //     ],
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       // const Icon(
                  //       //   Icons.agriculture_rounded,
                  //       //   color: Colors.white,
                  //       //   size: 32,
                  //       // ),
                  //       const SizedBox(width: 10),
                  //       // Expanded(
                  //       //   child: Column(
                  //       //     crossAxisAlignment: CrossAxisAlignment.start,
                  //       //     children: [
                  //       //       const Text(
                  //       //         "Government Schemes",
                  //       //         style: TextStyle(
                  //       //           fontSize: 24,
                  //       //           fontWeight: FontWeight.bold,
                  //       //           color: Colors.white,
                  //       //         ),
                  //       //       ),
                  //       //       const SizedBox(height: 4),
                  //       //       Text(
                  //       //         "Explore agricultural support programs",
                  //       //         style: TextStyle(
                  //       //           fontSize: 14,
                  //       //           color: Colors.white.withOpacity(0.9),
                  //       //         ),
                  //       //       ),
                  //       //     ],
                  //       //   ),
                  //       // ),
                  //       // Container(
                  //       //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  //       //   decoration: BoxDecoration(
                  //       //     color: Colors.white.withOpacity(0.2),
                  //       //     borderRadius: BorderRadius.circular(25),
                  //       //   ),
                  //       //   child: Text(
                  //       //     "${_filteredSchemes.length} Available",
                  //       //     style: const TextStyle(
                  //       //       color: Colors.white,
                  //       //       fontWeight: FontWeight.bold,
                  //       //       fontSize: 14,
                  //       //     ),
                  //       //   ),
                  //       // ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 0),
                  
                  Expanded(
                    child: _filteredSchemes.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _initializeData,
                            color: const Color(0xFF0A9D88),
                            child: ListView.builder(
                              itemCount: _filteredSchemes.length,
                              itemBuilder: (context, index) {
                                final scheme = _filteredSchemes[index];
                                final isEligible = _isUserEligible(scheme);
                                return _buildEnhancedSchemeCard(scheme, isEligible);
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.agriculture_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedStatus != 'All'
                ? 'No schemes match your filters'
                : 'No Schemes Available',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'All' || _selectedStatus != 'All'
                ? 'Try adjusting your search criteria or filters'
                : 'New schemes will appear here when available',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _initializeData,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A9D88),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  bool _isUserEligible(GovtSchemeModel scheme) {
    if (_userProfile == null) return true;
    
    final cropEligible = scheme.eligibleCropTypes.contains('all') ||
        scheme.eligibleCropTypes.any((eligibleCrop) =>
            _userProfile!.cropTypes.any((userCrop) =>
                userCrop.toLowerCase() == eligibleCrop.toLowerCase()));
    
    return cropEligible;
  }

  void _showApplicationForm(GovtSchemeModel scheme) {
    if (_userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Please complete your profile first to apply for schemes'),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchemeApplicationScreen(
          scheme: scheme,
          userProfile: _userProfile!,
          onApplicationSubmitted: () {
            _initializeData();
            _tabController.animateTo(1);
          },
        ),
      ),
    );
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey.shade50,
    // Add the drawer here
    drawer: _buildSideNavigation(),
    body: Column(
      children: [
        // Enhanced TabBar with menu button
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A9D88), Color(0xFF0C7B68)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // App bar with menu button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Agricultural Schemes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the menu button
                    ],
                  ),
                ),
                // TabBar
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 4,
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.list_alt_rounded, size: 24),
                      text: 'Available Schemes',
                      height: 80,
                    ),
                    Tab(
                      icon: Icon(Icons.assignment_turned_in_rounded, size: 24),
                      text: 'My Applications',
                      height: 80,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A9D88)),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Loading agricultural schemes...',
                        style: TextStyle(
                          color: Color(0xFF2C3E50),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSchemesTab(),
                    _buildApplicationsTab(),
                  ],
                ),
        ),
      ],
    ),
  );
}

// Side Navigation Drawer
Widget _buildSideNavigation() {
  return Drawer(
    child: Column(
      children: [
        Expanded(
          child: ModernSideMenu(currentRoute: '',),
        ),
      ],
    ),
  );
}

// Use the existing _buildMenuItems from home.dart
// Just call the function from your home.dart file

  Widget _buildApplicationsTab() {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Container(
          //   padding: const EdgeInsets.all(20),
          //   decoration: const BoxDecoration(
          //     color: Colors.white,
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black12,
          //         blurRadius: 4,
          //         offset: Offset(0, 2),
          //       ),
          //     ],
          //   ),
          //   child: Row(
          //     children: [
          //       const Icon(
          //         Icons.assignment_turned_in_rounded,
          //         color: Color(0xFF0A9D88),
          //         size: 28,
          //       ),
          //       const SizedBox(width: 12),
          //       const Expanded(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               "My Applications",
          //               style: TextStyle(
          //                 fontSize: 24,
          //                 fontWeight: FontWeight.bold,
          //                 color: Color(0xFF2C3E50),
          //               ),
          //             ),
          //             Text(
          //               "Track your scheme applications",
          //               style: TextStyle(
          //                 fontSize: 14,
          //                 color: Colors.grey,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //       Container(
          //         decoration: BoxDecoration(
          //           color: const Color(0xFF0A9D88).withOpacity(0.1),
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //         child: IconButton(
          //           onPressed: _initializeData,
          //           icon: const Icon(Icons.refresh_rounded),
          //           color: const Color(0xFF0A9D88),
          //           tooltip: 'Refresh Applications',
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: _userApplications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'No Applications Yet',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Start applying for schemes to track them here',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () => _tabController.animateTo(0),
                          icon: const Icon(Icons.explore_rounded),
                          label: const Text('Explore Schemes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A9D88),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _initializeData,
                    color: const Color(0xFF0A9D88),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _userApplications.length,
                      itemBuilder: (context, index) {
                        final application = _userApplications[index];
                        return _buildApplicationCard(application);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSchemeCard(GovtSchemeModel scheme, bool isEligible) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0A9D88).withOpacity(0.9),
                        const Color(0xFF0C7B68).withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: scheme.imagePath.isNotEmpty
                      ? Image.asset(
                          scheme.imagePath,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 220,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF0A9D88).withOpacity(0.9),
                                    const Color(0xFF0C7B68).withOpacity(0.9),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.agriculture_rounded,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.agriculture_rounded,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              // Eligibility badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isEligible ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: (isEligible ? Colors.green : Colors.orange).withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isEligible ? Icons.check_circle_rounded : Icons.info_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isEligible ? 'Eligible' : 'Check Criteria',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Category badge
              if (scheme.category != null)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(scheme.category!),
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          scheme.category!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          // Card content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        scheme.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (isEligible)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  scheme.description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                
                // Benefits section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0A9D88).withOpacity(0.08),
                        const Color(0xFF0C7B68).withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF0A9D88).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.card_giftcard_rounded,
                            color: Color(0xFF0A9D88),
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Key Benefits',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        scheme.benefits['description']?.toString() ?? 
                        'Financial assistance and comprehensive support for agricultural development',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showSchemeDetails(scheme, isEligible),
                        icon: const Icon(Icons.visibility_rounded, size: 20),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0A9D88),
                          side: const BorderSide(color: Color(0xFF0A9D88), width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isEligible ? () => _showApplicationForm(scheme) : null,
                        icon: const Icon(Icons.send_rounded, size: 20),
                        label: const Text('Apply Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A9D88),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(SchemeApplicationModel application) {
    final statusColor = _getStatusColor(application.status);
    final currentStep = application.steps.indexWhere((step) => step.isCurrent);
    
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    application.schemeName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    _getStatusText(application.status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Applied on: ${_formatDate(application.appliedAt)}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            
            // Enhanced progress indicator
            Row(
              children: List.generate(application.steps.length, (index) {
                final step = application.steps[index];
                return Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: step.isCompleted 
                              ? Colors.green 
                              : step.isCurrent 
                                  ? const Color(0xFF0A9D88)
                                  : Colors.grey.shade300,
                          boxShadow: step.isCompleted || step.isCurrent
                              ? [
                                  BoxShadow(
                                    color: (step.isCompleted ? Colors.green : const Color(0xFF0A9D88)).withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: step.isCompleted
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                            : step.isCurrent
                                ? const Icon(Icons.hourglass_empty_rounded, color: Colors.white, size: 16)
                                : Text(
                                    '${index + 1}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                      ),
                      if (index < application.steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: step.isCompleted ? Colors.green : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 16),
            if (currentStep >= 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A9D88).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0A9D88).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A9D88).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.timeline_rounded,
                        color: Color(0xFF0A9D88),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Status',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            application.steps[currentStep].title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showApplicationDetails(application),
                    icon: const Icon(Icons.timeline_rounded, size: 20),
                    label: const Text('View Status'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0A9D88),
                      side: const BorderSide(color: Color(0xFF0A9D88), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openApplicationDocument(application),
                    icon: const Icon(Icons.description_rounded, size: 20),
                    label: const Text('Document'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A9D88),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSchemeDetails(GovtSchemeModel scheme, bool isEligible) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchemeDetailScreen(
          scheme: scheme,
          isEligible: isEligible,
          userProfile: _userProfile,
        ),
      ),
    );
  }

  void _showApplicationDetails(SchemeApplicationModel application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: ApplicationStatusSheet(application: application),
      ),
    );
  }

  void _openApplicationDocument(SchemeApplicationModel application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0A9D88).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: Color(0xFF0A9D88),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Application Document',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDocumentInfoRow('Scheme', application.schemeName),
            const SizedBox(height: 12),
            _buildDocumentInfoRow('Application ID', application.id),
            const SizedBox(height: 12),
            _buildDocumentInfoRow('Status', _getStatusText(application.status)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Document viewer will be implemented here.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.download_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Document download feature coming soon'),
                    ],
                  ),
                  backgroundColor: const Color(0xFF0A9D88),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A9D88),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.submitted:
        return Colors.blue;
      case ApplicationStatus.underReview:
        return Colors.orange;
      case ApplicationStatus.approved:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.documentsPending:
        return Colors.purple;
    }
  }

  String _getStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.submitted:
        return 'Submitted';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.documentsPending:
        return 'Documents Pending';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Create a simple SchemeDetailScreen to handle the navigation
class SchemeDetailScreen extends StatelessWidget {
  final GovtSchemeModel scheme;
  final bool isEligible;
  final UserProfileModel? userProfile;
  final VoidCallback? onApplicationSubmitted;

  const SchemeDetailScreen({
    super.key,
    required this.scheme,
    required this.isEligible,
    this.userProfile,
    this.onApplicationSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          scheme.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF0A9D88),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A9D88), Color(0xFF0C7B68)],
                ),
              ),
              child: scheme.imagePath.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        scheme.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.agriculture_rounded,
                              size: 80,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.agriculture_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            
            // Scheme Details
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            scheme.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isEligible ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isEligible ? 'Eligible' : 'Check Criteria',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      scheme.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Benefits
                    Text(
                      'Benefits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A9D88).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        scheme.benefits['description']?.toString() ?? 
                        'Financial assistance and comprehensive support',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Eligible Crops
                    if (scheme.eligibleCropTypes.isNotEmpty) ...[
                      Text(
                        'Eligible Crops',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: scheme.eligibleCropTypes.map((crop) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              crop.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isEligible && userProfile != null
                            ? () {
                                // Navigate to SchemeApplicationScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SchemeApplicationScreen(
                                      scheme: scheme,
                                      userProfile: userProfile!,
                                      onApplicationSubmitted: () {
                                        Navigator.pop(context); // Go back to previous screen
                                        if (onApplicationSubmitted != null) {
                                          onApplicationSubmitted!();
                                        }
                                      },
                                    ),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('Apply for this Scheme'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A9D88),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}