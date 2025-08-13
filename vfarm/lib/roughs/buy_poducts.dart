// import 'dart:math';
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:vfarm/session_manager.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// const primaryGreen = Color(0xFF0A9D88);
// const secondaryGreen = Color(0xFF4CAF50);
// const accentOrange = Color(0xFFFF9800);

// class BuyProducts extends StatefulWidget {
//   const BuyProducts({super.key});

//   @override
//   State<BuyProducts> createState() => _BuyProductsState();
// }

// class _BuyProductsState extends State<BuyProducts> 
//     with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  
//   // Animation controllers for smooth transitions
//   late AnimationController _fadeAnimationController;
//   late AnimationController _slideAnimationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   // Categories with enhanced icons and colors
//   final List<CategoryItem> categories = [
//     CategoryItem('Vegetables', Icons.grass, Color(0xFF4CAF50), '🥬'),
//     CategoryItem('Fruits', Icons.apple, Color(0xFFFF9800), '🍎'),
//     CategoryItem('Equipment', Icons.agriculture, Color(0xFF607D8B), '🚜'),
//     CategoryItem('Fertilizers', Icons.eco, Color(0xFF9C27B0), '🌱'),
//     CategoryItem('Seeds', Icons.spa, Color(0xFF8BC34A), '🌰'),
//     CategoryItem('Grains', Icons.grain, Color(0xFF795548), '🌾'),
//   ];
  
//   String selectedCategory = 'Vegetables';

//   // Distance filter options
//   final List<DistanceOption> distanceOptions = [
//     DistanceOption('Within 2 km', 2),
//     DistanceOption('Within 5 km', 5),
//     DistanceOption('Within 10 km', 10),
//     DistanceOption('Within 25 km', 25),
//     DistanceOption('Within 50 km', 50),
//     DistanceOption('Within 100 km', 100),
//   ];
  
//   int selectedDistanceKm = 25;
//   bool sortByDistance = true;
//   bool showMapView = false;

//   // Location and maps
//   Position? userPosition;
//   GoogleMapController? mapController;
//   Set<Marker> markers = {};
  
//   // Loading states
//   bool isLoading = true;
//   bool isLoadingShops = false;
//   bool isLoadingMap = false;

//   // Data
//   List<Shop> allShops = [];
//   List<Shop> filteredShops = [];
  
//   // Search
//   final TextEditingController searchController = TextEditingController();
//   String searchQuery = '';
//   Timer? _debounceTimer;

//   // Page controller for smooth transitions
//   late PageController _pageController;
  
//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _pageController = PageController();
//     _initializePage();
//   }

//   void _initializeAnimations() {
//     _fadeAnimationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 300),
//     );
    
//     _slideAnimationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 400),
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeAnimationController,
//       curve: Curves.easeInOut,
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _slideAnimationController,
//       curve: Curves.easeOutCubic,
//     ));

//     _fadeAnimationController.forward();
//     _slideAnimationController.forward();
//   }

//   @override
//   void dispose() {
//     _fadeAnimationController.dispose();
//     _slideAnimationController.dispose();
//     _pageController.dispose();
//     searchController.dispose();
//     _debounceTimer?.cancel();
//     mapController?.dispose();
//     super.dispose();
//   }

//   Future<void> _initializePage() async {
//     setState(() => isLoading = true);
    
//     try {
//       await _getCurrentLocation();
//       await _loadShopsFromGooglePlaces();
//       _applyFilters();
//     } catch (e) {
//       debugPrint('Error initializing page: $e');
//       _showErrorSnackBar('Failed to load data. Please try again.');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }

//       if (permission == LocationPermission.deniedForever) {
//         _showErrorSnackBar('Location permission denied. Please enable in settings.');
//         return;
//       }

//       userPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: Duration(seconds: 15),
//       );
//     } catch (e) {
//       debugPrint('Location error: $e');
//       _showErrorSnackBar('Unable to get location. Using default area.');
//       // Default to a central location in India
//       userPosition = Position(
//         latitude: 12.9716,
//         longitude: 77.5946,
//         timestamp: DateTime.now(),
//         accuracy: 0,
//         altitude: 0,
//         heading: 0,
//         speed: 0,
//         speedAccuracy: 0,
//         altitudeAccuracy: 1,
//         headingAccuracy: 1,
//       );
//     }
//   }
// Future<void> _loadShopsFromGooglePlaces() async {
//   if (userPosition == null) {
//     debugPrint('❌ User position is null, cannot load shops');
//     return;
//   }

//   debugPrint('📍 User position: ${userPosition!.latitude}, ${userPosition!.longitude}');
//   setState(() => isLoadingShops = true);

//   try {
//     const String apiKey = 'AIzaSyAVcz0-ooE0MkmCkpDaigolWtI4By8NSHc';
    
//     // Test API key first
//     debugPrint('🔑 Testing API key...');
    
//     List<String> searchQueries = _getSearchQueries();
//     debugPrint('🔍 Search queries: $searchQueries');
    
//     List<Shop> allFoundShops = [];

//     for (String query in searchQueries) {
//       debugPrint('🔄 Searching for: $query');
      
//       try {
//         final shops = await _searchNearbyPlaces(query, apiKey);
//         debugPrint('✅ Found ${shops.length} shops for query: $query');
        
//         if (shops.isNotEmpty) {
//           for (var shop in shops) {
//             debugPrint('   - ${shop.name} at ${shop.location}'); // Changed from 'address' to 'location'
//           }
//         }
        
//         allFoundShops.addAll(shops);
//       } catch (queryError) {
//         debugPrint('❌ Error searching for $query: $queryError');
//       }
//     }

//     debugPrint('📊 Total shops found from API: ${allFoundShops.length}');

//     // Remove duplicates and add mock data
//     allShops = _removeDuplicateShops(allFoundShops);
//     debugPrint('📊 After removing duplicates: ${allShops.length}');
    
//     // Add mock data for demonstration
//     final mockShops = _generateEnhancedMockShops();
//     allShops.addAll(mockShops);
//     debugPrint('📊 After adding mock data: ${allShops.length}');

//     // Update markers for map
//     _updateMapMarkers();
//     debugPrint('🗺️ Map markers updated');

//   } catch (e) {
//     debugPrint('❌ Error loading shops from Google Places: $e');
//     debugPrint('📱 Stack trace: ${StackTrace.current}');
    
//     // Fallback to enhanced mock data
//     allShops = _generateEnhancedMockShops();
//     debugPrint('🔄 Using fallback mock data: ${allShops.length} shops');
//   }

//   setState(() => isLoadingShops = false);
//   debugPrint('✅ Shop loading completed. Total shops: ${allShops.length}');
// }

// // Add this method to test a simple API call

//   // Mock data generation
//   List<Shop> _generateEnhancedMockShops() {
//     List<Shop> mockShops = [];
//     Random random = Random();

//     for (int i = 0; i < 20; i++) {
//       mockShops.add(Shop(
//         id: 'mock_shop_$i',
//         name: 'Mock Shop ${i + 1}',
//         location: 'Mock Location ${i + 1}',
//         latitude: userPosition!.latitude + (random.nextDouble() - 0.5) * 0.05,
//         longitude: userPosition!.longitude + (random.nextDouble() - 0.5) * 0.05,
//         categories: [selectedCategory],
//         minPrice: _generateRandomPrice(50, 200),
//         maxPrice: _generateRandomPrice(200, 500),
//         currentPrice: _generateRandomPrice(100, 300),
//         lastUpdated: DateTime.now(),
//         priceHistory: _generateExtensivePriceHistory(),
//         isFollowing: random.nextBool(),
//         rating: (random.nextDouble() * 2 + 3), // 3-5 rating
//         reviewCount: random.nextInt(500) + 10,
//         imageUrl: _getRandomShopImage(),
//         phoneNumber: _generatePhoneNumber(),
//         openingHours: _generateOpeningHours(),
//       ));
//     }

//     return mockShops;
//   }
// // Add this method to test a simple API call

//   List<String> _getSearchQueries() {
//     Map<String, List<String>> categoryQueries = {
//       'Vegetables': ['vegetable market', 'mandi', 'fresh produce market'],
//       'Fruits': ['fruit market', 'fresh fruit shop', 'fruit vendor'],
//       'Equipment': ['agricultural equipment', 'farm tools', 'tractor dealer'],
//       'Fertilizers': ['fertilizer shop', 'agricultural supplies', 'farm chemicals'],
//       'Seeds': ['seed store', 'agricultural seeds', 'farming seeds'],
//       'Grains': ['grain market', 'rice mill', 'wheat market'],
//     };
    
//     return categoryQueries[selectedCategory] ?? ['market'];
//   }

//   Future<List<Shop>> _searchNearbyPlaces(String query, String apiKey) async {
//     if (userPosition == null) return [];
   
//   final lat = userPosition!.latitude;
//   final lng = userPosition!.longitude;
//   final radius = 5000; // 5km radius (must be <= 50000 for Google Places API)
  
//   // Using Places API Nearby Search
//   final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
//       '?location=$lat,$lng'
//       '&radius=$radius'
//       '&keyword=$query'
//       '&type=store'
//       '&key=$apiKey';

//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         List<Shop> shops = [];
        
//         for (var place in (data['results'] as List)) {
//           shops.add(_createShopFromGooglePlace(place));
//         }
        
//         return shops;
//       }
//     } catch (e) {
//       debugPrint('Error searching places: $e');
//     }
    
//     return [];
//   }

//   Shop _createShopFromGooglePlace(Map<String, dynamic> place) {
//     final location = place['geometry']['location'];
//     final double lat = location['lat'].toDouble();
//     final double lng = location['lng'].toDouble();
    
//     return Shop(
//       id: place['place_id'] ?? 'unknown',
//       name: place['name'] ?? 'Unknown Shop',
//       location: place['vicinity'] ?? 'Unknown Location',
//       latitude: lat,
//       longitude: lng,
//       categories: [selectedCategory],
//       minPrice: _generateRandomPrice(50, 200),
//       maxPrice: _generateRandomPrice(200, 500),
//       currentPrice: _generateRandomPrice(100, 300),
//       lastUpdated: DateTime.now(),
//       priceHistory: _generateExtensivePriceHistory(),
//       isFollowing: Random().nextBool(),
//       rating: (Random().nextDouble() * 2 + 3), // 3-5 rating
//       reviewCount: Random().nextInt(500) + 10,
//       imageUrl: _getRandomShopImage(),
//       phoneNumber: _generatePhoneNumber(),
//       openingHours: _generateOpeningHours(),
//     );
//   }

//   List<Shop> _removeDuplicateShops(List<Shop> shops) {
//     Map<String, Shop> uniqueShops = {};
//     for (Shop shop in shops) {
//       uniqueShops[shop.id] = shop;
//     }
//     return uniqueShops.values.toList();
//   }

//   void _updateMapMarkers() {
//     markers.clear();
    
//     // Add user location marker
//     if (userPosition != null) {
//       markers.add(
//         Marker(
//           markerId: MarkerId('user_location'),
//           position: LatLng(userPosition!.latitude, userPosition!.longitude),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//           infoWindow: InfoWindow(title: 'Your Location'),
//         ),
//       );
//     }
    
//     // Add shop markers
//     for (int i = 0; i < filteredShops.length; i++) {
//       final shop = filteredShops[i];
//       markers.add(
//         Marker(
//           markerId: MarkerId(shop.id),
//           position: LatLng(shop.latitude, shop.longitude),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             _getMarkerHue(shop.categories.first),
//           ),
//           infoWindow: InfoWindow(
//             title: shop.name,
//             snippet: '₹${shop.currentPrice.toInt()} • ${shop.distanceKm?.toStringAsFixed(1)} km',
//             onTap: () => _showShopDetails(shop),
//           ),
//           onTap: () => _showShopDetails(shop),
//         ),
//       );
//     }
//   }

//   double _getMarkerHue(String category) {
//     switch (category.toLowerCase()) {
//       case 'vegetables': return BitmapDescriptor.hueGreen;
//       case 'fruits': return BitmapDescriptor.hueOrange;
//       case 'equipment': return BitmapDescriptor.hueViolet;
//       case 'fertilizers': return BitmapDescriptor.hueMagenta;
//       case 'seeds': return BitmapDescriptor.hueYellow;
//       case 'grains': return BitmapDescriptor.hueRose;
//       default: return BitmapDescriptor.hueRed;
//     }
//   }

//   void _applyFilters() {
//     if (userPosition == null) {
//       filteredShops = [];
//       return;
//     }

//     // Filter by category and search query
//     filteredShops = allShops.where((shop) {
//       bool categoryMatch = shop.categories.contains(selectedCategory);
//       bool searchMatch = searchQuery.isEmpty || 
//           shop.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
//           shop.location.toLowerCase().contains(searchQuery.toLowerCase());
      
//       return categoryMatch && searchMatch;
//     }).toList();

//     // Calculate distances and filter by distance
//     filteredShops = filteredShops.where((shop) {
//       double distance = Geolocator.distanceBetween(
//         userPosition!.latitude,
//         userPosition!.longitude,
//         shop.latitude,
//         shop.longitude,
//       ) / 1000;
      
//       shop.distanceKm = distance;
//       return distance <= selectedDistanceKm;
//     }).toList();

//     // Sort shops
//     if (sortByDistance) {
//       filteredShops.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
//     } else {
//       filteredShops.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
//     }

//     // Update map markers
//     _updateMapMarkers();
    
//     setState(() {});
//   }

//   void _onCategoryChanged(String category) {
//     if (selectedCategory != category) {
//       setState(() {
//         selectedCategory = category;
//         isLoadingShops = true;
//       });
      
//       // Add haptic feedback
//       HapticFeedback.lightImpact();
      
//       // Reload shops for new category
//       _loadShopsFromGooglePlaces().then((_) {
//         _applyFilters();
//         setState(() => isLoadingShops = false);
//       });
//     }
//   }

//   void _onSearchChanged(String query) {
//     _debounceTimer?.cancel();
//     _debounceTimer = Timer(Duration(milliseconds: 300), () {
//       setState(() => searchQuery = query);
//       _applyFilters();
//     });
//   }

//   void _toggleView() {
//     setState(() {
//       showMapView = !showMapView;
//       isLoadingMap = showMapView;
//     });
    
//     HapticFeedback.mediumImpact();
    
//     if (showMapView) {
//       Future.delayed(Duration(milliseconds: 500), () {
//         setState(() => isLoadingMap = false);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
    
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: CustomScrollView(
//         physics: BouncingScrollPhysics(), // 60fps smooth scrolling
//         slivers: [
//           _buildSliverAppBar(),
//           SliverToBoxAdapter(child: _buildCategoryChips()),
//           SliverToBoxAdapter(child: _buildSearchAndFilters()),
//           SliverToBoxAdapter(child: _buildViewToggleAndSort()),
//           SliverFillRemaining(
//             child: AnimatedSwitcher(
//               duration: Duration(milliseconds: 300),
//               child: showMapView ? _buildMapView() : _buildShopsListView(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSliverAppBar() {
//     return SliverAppBar(
//       floating: true,
//       snap: true,
//       elevation: 0,
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black,
//       title: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [primaryGreen, secondaryGreen],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               'Mandi',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 fontSize: 18,
//               ),
//             ),
//           ),
//           Spacer(),
//           if (userPosition != null)
//             Text(
//               '${filteredShops.length} shops nearby',
//               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//             ),
//         ],
//       ),
//       actions: [
//         IconButton(
//           icon: Icon(Icons.notifications_outlined, color: primaryGreen),
//           onPressed: () {},
//         ),
//         IconButton(
//           icon: Icon(Icons.share_outlined, color: primaryGreen),
//           onPressed: () {},
//         ),
//       ],
//     );
//   }

//   Widget _buildCategoryChips() {
//     return Container(
//       height: 100,
//       color: Colors.white,
//       child: ListView.builder(
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         scrollDirection: Axis.horizontal,
//         physics: BouncingScrollPhysics(),
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           final category = categories[index];
//           final isSelected = selectedCategory == category.name;
          
//           return Padding(
//             padding: EdgeInsets.only(right: 12),
//             child: GestureDetector(
//               onTap: () => _onCategoryChanged(category.name),
//               child: AnimatedContainer(
//                 duration: Duration(milliseconds: 200),
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   gradient: isSelected 
//                       ? LinearGradient(
//                           colors: [category.color, category.color.withOpacity(0.8)],
//                         )
//                       : null,
//                   color: isSelected ? null : Colors.grey[100],
//                   borderRadius: BorderRadius.circular(25),
//                   border: isSelected ? null : Border.all(color: Colors.grey[300]!),
//                   boxShadow: isSelected ? [
//                     BoxShadow(
//                       color: category.color.withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: Offset(0, 2),
//                     ),
//                   ] : null,
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       category.emoji,
//                       style: TextStyle(fontSize: 20),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       category.name,
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : Colors.grey[700],
//                         fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSearchAndFilters() {
//     return Container(
//       color: Colors.white,
//       padding: EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Enhanced search bar
//           Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: TextField(
//               controller: searchController,
//               onChanged: _onSearchChanged,
//               decoration: InputDecoration(
//                 hintText: 'Search by shop name, location...',
//                 prefixIcon: Icon(Icons.search, color: primaryGreen),
//                 suffixIcon: searchQuery.isNotEmpty 
//                     ? IconButton(
//                         icon: Icon(Icons.clear, color: Colors.grey),
//                         onPressed: () {
//                           searchController.clear();
//                           _onSearchChanged('');
//                         },
//                       )
//                     : null,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[50],
//                 contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               ),
//             ),
//           ),
          
//           SizedBox(height: 16),
          
//           // Distance filter with enhanced design
//           Row(
//             children: [
//               Icon(Icons.location_on, color: primaryGreen, size: 20),
//               SizedBox(width: 8),
//               Text(
//                 '${filteredShops.length} shops ',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//               PopupMenuButton<int>(
//                 onSelected: (value) {
//                   setState(() {
//                     selectedDistanceKm = value;
//                     isLoadingShops = true;
//                   });
                  
//                   HapticFeedback.selectionClick();
                  
//                   Future.delayed(Duration(milliseconds: 300), () {
//                     _applyFilters();
//                     setState(() => isLoadingShops = false);
//                   });
//                 },
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [primaryGreen, primaryGreen.withOpacity(0.8)],
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: primaryGreen.withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         'within ${selectedDistanceKm} km',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       SizedBox(width: 4),
//                       Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
//                     ],
//                   ),
//                 ),
//                 itemBuilder: (context) => distanceOptions.map((option) => 
//                   PopupMenuItem(
//                     value: option.distanceKm,
//                     child: Row(
//                       children: [
//                         Icon(
//                           selectedDistanceKm == option.distanceKm 
//                               ? Icons.check_circle 
//                               : Icons.radio_button_unchecked,
//                           color: selectedDistanceKm == option.distanceKm 
//                               ? primaryGreen 
//                               : Colors.grey,
//                           size: 20,
//                         ),
//                         SizedBox(width: 12),
//                         Text(option.label),
//                       ],
//                     ),
//                   )
//                 ).toList(),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildViewToggleAndSort() {
//     return Container(
//       color: Colors.white,
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           // View toggle
//           GestureDetector(
//             onTap: _toggleView,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: showMapView ? primaryGreen : Colors.grey[100],
//                 borderRadius: BorderRadius.circular(20),
//                 border: showMapView ? null : Border.all(color: Colors.grey[300]!),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     showMapView ? Icons.map : Icons.list,
//                     color: showMapView ? Colors.white : Colors.grey[600],
//                     size: 16,
//                   ),
//                   SizedBox(width: 6),
//                   Text(
//                     showMapView ? 'Map View' : 'List View',
//                     style: TextStyle(
//                       color: showMapView ? Colors.white : Colors.grey[600],
//                       fontWeight: FontWeight.w500,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
          
//           Spacer(),
          
//           // Sort options
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () => setState(() => sortByDistance = true),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: sortByDistance ? primaryGreen : Colors.transparent,
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.near_me,
//                         color: sortByDistance ? Colors.white : Colors.grey[600],
//                         size: 14,
//                       ),
//                       SizedBox(width: 4),
//                       Text(
//                         'Distance',
//                         style: TextStyle(
//                           color: sortByDistance ? Colors.white : Colors.grey[600],
//                           fontSize: 11,
//                           fontWeight: sortByDistance ? FontWeight.bold : FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
              
//               SizedBox(width: 8),
              
//               GestureDetector(
//                 onTap: () => setState(() => sortByDistance = false),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: !sortByDistance ? primaryGreen : Colors.transparent,
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.currency_rupee,
//                         color: !sortByDistance ? Colors.white : Colors.grey[600],
//                         size: 14,
//                       ),
//                       SizedBox(width: 4),
//                       Text(
//                         'Price',
//                         style: TextStyle(
//                           color: !sortByDistance ? Colors.white : Colors.grey[600],
//                           fontSize: 11,
//                           fontWeight: !sortByDistance ? FontWeight.bold : FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMapView() {
//     if (isLoadingMap || userPosition == null) {
//       return _buildLoadingShimmer();
//     }

//     return GoogleMap(
//       key: ValueKey('map_view'),
//       onMapCreated: (GoogleMapController controller) {
//         mapController = controller;
//       },
//       initialCameraPosition: CameraPosition(
//         target: LatLng(userPosition!.latitude, userPosition!.longitude),
//         zoom: 12.0,
//       ),
//       markers: markers,
//       myLocationEnabled: true,
//       myLocationButtonEnabled: true,
//       zoomControlsEnabled: false,
//       mapType: MapType.normal,
//       style: '''
//         [
//           {
//             "featureType": "poi",
//             "elementType": "labels",
//             "stylers": [{"visibility": "off"}]
//           }
//         ]
//       ''',
//       onTap: (LatLng position) {
//         // Handle map tap
//       },
//     );
//   }

//   Widget _buildShopsListView() {
//     return Container(
//       key: ValueKey('list_view'),
//       child: isLoading 
//           ? _buildLoadingShimmer()
//           : isLoadingShops
//               ? _buildLoadingShimmer()
//               : filteredShops.isEmpty
//                   ? _buildEmptyState()
//                   : _buildEnhancedShopsList(),
//     );
//   }

//   Widget _buildEnhancedShopsList() {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: SlideTransition(
//         position: _slideAnimation,
//         child: ListView.separated(
//           padding: EdgeInsets.all(16),
//           physics: BouncingScrollPhysics(),
//           itemCount: filteredShops.length,
//           separatorBuilder: (context, index) => SizedBox(height: 16),
//           itemBuilder: (context, index) {
//             final shop = filteredShops[index];
//             return EnhancedShopCard(
//               shop: shop,
//               onTap: () => _showShopDetails(shop),
//               onFollow: () => _handleFollowShop(shop),
//               animationDelay: index * 0.1,
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingShimmer() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: ListView.separated(
//         padding: EdgeInsets.all(16),
//         itemCount: 8,
//         separatorBuilder: (context, index) => SizedBox(height: 16),
//         itemBuilder: (context, index) => Container(
//           height: 140,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.store_outlined,
//               size: 48,
//               color: Colors.grey[400],
//             ),
//           ),
//           SizedBox(height: 24),
//           Text(
//             'No shops found',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700],
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Try adjusting your filters or search terms',
//             style: TextStyle(
//               color: Colors.grey[500],
//               fontSize: 16,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: () {
//               setState(() {
//                 selectedDistanceKm = 100;
//                 searchQuery = '';
//                 searchController.clear();
//               });
//               _applyFilters();
//             },
//             icon: Icon(Icons.refresh),
//             label: Text('Expand Search'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: primaryGreen,
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(25),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showShopDetails(Shop shop) {
//     HapticFeedback.lightImpact();
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => EnhancedShopDetailsSheet(
//         shop: shop,
//         userPosition: userPosition,
//         onOrderPlaced: () => _handleOrderPlaced(shop),
//       ),
//     );
//   }

//   Future<void> _handleOrderPlaced(Shop shop) async {
//     try {
//       await SessionManager.instance.ensureAuthenticated();
      
//       final order = {
//         'shopId': shop.id,
//         'shopName': shop.name,
//         'shopLocation': shop.location,
//         'userId': SessionManager.instance.getCurrentUserId(),
//         'userProfile': SessionManager.instance.getCurrentUserProfile()?.toMap(),
//         'category': selectedCategory,
//         'items': [
//           {
//             'name': _getDefaultProduct(selectedCategory),
//             'quantity': 10,
//             'unit': 'kg',
//             'pricePerUnit': shop.currentPrice,
//             'totalPrice': shop.currentPrice * 10,
//           }
//         ],
//         'totalAmount': shop.currentPrice * 10,
//         'status': 'pending',
//         'timestamp': FieldValue.serverTimestamp(),
//         'deliveryAddress': 'User location',
//       };

//       await FirebaseFirestore.instance.collection('orders').add(order);
      
//       Navigator.pop(context);
//       _showSuccessSnackBar('Order placed successfully!');
      
//     } catch (e) {
//       debugPrint('Order error: $e');
//       if (e.toString().contains('not authenticated')) {
//         _showErrorSnackBar('Please login to place orders');
//       } else {
//         _showErrorSnackBar('Failed to place order. Please try again.');
//       }
//     }
//   }

//   String _getDefaultProduct(String category) {
//     switch (category.toLowerCase()) {
//       case 'vegetables': return 'Fresh Tomatoes';
//       case 'fruits': return 'Red Apples';
//       case 'equipment': return 'Farming Tools';
//       case 'fertilizers': return 'Organic Fertilizer';
//       case 'seeds': return 'Vegetable Seeds';
//       case 'grains': return 'Rice';
//       default: return 'Product';
//     }
//   }

//   void _handleFollowShop(Shop shop) {
//     HapticFeedback.lightImpact();
//     setState(() {
//       shop.isFollowing = !shop.isFollowing;
//     });
//     _showSuccessSnackBar(
//       shop.isFollowing 
//           ? 'Now following ${shop.name}' 
//           : 'Unfollowed ${shop.name}'
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.error_outline, color: Colors.white),
//             SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: Colors.red[600],
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: EdgeInsets.all(16),
//       ),
//     );
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.check_circle_outline, color: Colors.white),
//             SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: primaryGreen,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: EdgeInsets.all(16),
//       ),
//     );
//   }

//   // Enhanced mock data generation

//   List<String> _getRandomCategories() {
//     final allCategories = categories.map((c) => c.name).toList();
//     final numCategories = Random().nextInt(3) + 1; // 1-3 categories
    
//     List<String> selectedCategories = [];
//     for (int i = 0; i < numCategories; i++) {
//       String category = allCategories[Random().nextInt(allCategories.length)];
//       if (!selectedCategories.contains(category)) {
//         selectedCategories.add(category);
//       }
//     }
    
//     return selectedCategories.isEmpty ? [selectedCategory] : selectedCategories;
//   }

//   double _generateRandomPrice(double min, double max) {
//     return min + Random().nextDouble() * (max - min);
//   }

//   double _generateRandomRating() {
//     return 3.0 + Random().nextDouble() * 2.0; // 3.0-5.0 rating
//   }

//   String _getRandomShopImage() {
//     final images = [
//       'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
//       'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=400',
//       'https://images.unsplash.com/photo-1506617564039-2f3b650b7010?w=400',
//       'https://images.unsplash.com/photo-1534723328310-e82dad3ee43f?w=400',
//       'https://images.unsplash.com/photo-1518843875459-f738682238a6?w=400',
//     ];
//     return images[Random().nextInt(images.length)];
//   }

//   String _generatePhoneNumber() {
//     return '+91 ${Random().nextInt(9000000000) + 1000000000}';
//   }

//   String _generateOpeningHours() {
//     final hours = ['6:00 AM - 8:00 PM', '7:00 AM - 9:00 PM', '5:30 AM - 7:30 PM'];
//     return hours[Random().nextInt(hours.length)];
//   }

//   List<PricePoint> _generateExtensivePriceHistory() {
//     List<PricePoint> history = [];
//     double basePrice = 100 + Random().nextDouble() * 200;
    
//     // Generate 60 days of price history
//     for (int i = 59; i >= 0; i--) {
//       double dailyVariation = (Random().nextDouble() - 0.5) * 40; // ±20
//       double seasonalTrend = sin(i * 0.1) * 15; // Seasonal variation
//       double weeklyPattern = sin(i * 0.9) * 8; // Weekly pattern
      
//       double price = basePrice + dailyVariation + seasonalTrend + weeklyPattern;
//       price = max(50, min(500, price)); // Clamp between 50-500
      
//       history.add(PricePoint(
//         date: DateTime.now().subtract(Duration(days: i)),
//         price: price,
//       ));
//     }
    
//     return history;
//   }
// }

// // Enhanced Models
// class CategoryItem {
//   final String name;
//   final IconData icon;
//   final Color color;
//   final String emoji;

//   CategoryItem(this.name, this.icon, this.color, this.emoji);
// }

// class DistanceOption {
//   final String label;
//   final int distanceKm;

//   DistanceOption(this.label, this.distanceKm);
// }

// class Shop {
//   final String id;
//   final String name;
//   final String location;
//   final double latitude;
//   final double longitude;
//   final List<String> categories;
//   final double minPrice;
//   final double maxPrice;
//   final double currentPrice;
//   final DateTime lastUpdated;
//   final List<PricePoint> priceHistory;
//   bool isFollowing;
//   final double rating;
//   final int reviewCount;
//   final String imageUrl;
//   final String phoneNumber;
//   final String openingHours;
  
//   double? distanceKm;

//   Shop({
//     required this.id,
//     required this.name,
//     required this.location,
//     required this.latitude,
//     required this.longitude,
//     required this.categories,
//     required this.minPrice,
//     required this.maxPrice,
//     required this.currentPrice,
//     required this.lastUpdated,
//     required this.priceHistory,
//     required this.isFollowing,
//     required this.rating,
//     required this.reviewCount,
//     required this.imageUrl,
//     required this.phoneNumber,
//     required this.openingHours,
//   });
// }

// class PricePoint {
//   final DateTime date;
//   final double price;

//   PricePoint({required this.date, required this.price});
// }

// // Enhanced Shop Card Widget
// class EnhancedShopCard extends StatefulWidget {
//   final Shop shop;
//   final VoidCallback onTap;
//   final VoidCallback onFollow;
//   final double animationDelay;

//   const EnhancedShopCard({
//     Key? key,
//     required this.shop,
//     required this.onTap,
//     required this.onFollow,
//     this.animationDelay = 0.0,
//   }) : super(key: key);

//   @override
//   State<EnhancedShopCard> createState() => _EnhancedShopCardState();
// }

// class _EnhancedShopCardState extends State<EnhancedShopCard> 
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 600),
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.elasticOut,
//     ));

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeIn,
//     ));

//     // Start animation with delay
//     Future.delayed(Duration(milliseconds: (widget.animationDelay * 1000).toInt()), () {
//       if (mounted) {
//         _animationController.forward();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: GestureDetector(
//           onTap: () {
//             HapticFeedback.lightImpact();
//             widget.onTap();
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.08),
//                   blurRadius: 15,
//                   offset: Offset(0, 5),
//                   spreadRadius: 0,
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildShopHeader(),
//                 _buildShopContent(),
//                 _buildShopActions(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildShopHeader() {
//     return Container(
//       height: 80,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             primaryGreen.withOpacity(0.1),
//             secondaryGreen.withOpacity(0.05),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Stack(
//         children: [
//           // Background pattern
//           Positioned(
//             right: -20,
//             top: -20,
//             child: Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Container(
//                   width: 48,
//                   height: 48,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [primaryGreen, secondaryGreen],
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: primaryGreen.withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     Icons.store,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         widget.shop.name,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: Colors.grey[800],
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       SizedBox(height: 2),
//                       Row(
//                         children: [
//                           Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
//                           SizedBox(width: 4),
//                           Expanded(
//                             child: Text(
//                               widget.shop.location,
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 12,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (widget.shop.distanceKm != null) ...[
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 4,
//                           offset: Offset(0, 1),
//                         ),
//                       ],
//                     ),
//                     child: Text(
//                       '${widget.shop.distanceKm!.toStringAsFixed(1)} km',
//                       style: TextStyle(
//                         color: primaryGreen,
//                         fontSize: 11,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildShopContent() {
//     return Padding(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Price range and rating
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [primaryGreen.withOpacity(0.1), primaryGreen.withOpacity(0.05)],
//                   ),
//                   borderRadius: BorderRadius.circular(15),
//                   border: Border.all(color: primaryGreen.withOpacity(0.2)),
//                 ),
//                 child: Text(
//                   '₹${widget.shop.minPrice.toInt()} - ₹${widget.shop.maxPrice.toInt()}',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: primaryGreen,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//               Row(
//                 children: [
//                   Icon(Icons.star, color: accentOrange, size: 16),
//                   SizedBox(width: 4),
//                   Text(
//                     '${widget.shop.rating.toStringAsFixed(1)} (${widget.shop.reviewCount})',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
          
//           SizedBox(height: 12),
          
//           // Categories
//           Wrap(
//             spacing: 8,
//             runSpacing: 4,
//             children: widget.shop.categories.map((category) => 
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: _getCategoryColor(category).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: _getCategoryColor(category).withOpacity(0.3)),
//                 ),
//                 child: Text(
//                   category,
//                   style: TextStyle(
//                     color: _getCategoryColor(category),
//                     fontSize: 10,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ).toList(),
//           ),
          
//           SizedBox(height: 8),
          
//           // Last updated
//           Row(
//             children: [
//               Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
//               SizedBox(width: 4),
//               Text(
//                 'Updated ${_getTimeAgo(widget.shop.lastUpdated)}',
//                 style: TextStyle(
//                   color: Colors.grey[500],
//                   fontSize: 11,
//                 ),
//               ),
//               Spacer(),
//               Text(
//                 widget.shop.openingHours,
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildShopActions() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(20),
//           bottomRight: Radius.circular(20),
//         ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 HapticFeedback.lightImpact();
//                 widget.onFollow();
//               },
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 12),
//                 decoration: BoxDecoration(
//                   color: widget.shop.isFollowing ? Colors.grey[200] : primaryGreen,
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: widget.shop.isFollowing ? null : [
//                     BoxShadow(
//                       color: primaryGreen.withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       widget.shop.isFollowing ? Icons.check : Icons.add,
//                       size: 18,
//                       color: widget.shop.isFollowing ? Colors.grey[600] : Colors.white,
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       widget.shop.isFollowing ? 'Following' : 'Follow',
//                       style: TextStyle(
//                         color: widget.shop.isFollowing ? Colors.grey[600] : Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
          
//           SizedBox(width: 12),
          
//           Expanded(
//             flex: 2,
//             child: GestureDetector(
//               onTap: widget.onTap,
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 12),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [accentOrange, accentOrange.withOpacity(0.8)],
//                   ),
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     BoxShadow(
//                       color: accentOrange.withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.trending_up, size: 18, color: Colors.white),
//                     SizedBox(width: 8),
//                     Text(
//                       'View Prices',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                     SizedBox(width: 4),
//                     Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getCategoryColor(String category) {
//     switch (category.toLowerCase()) {
//       case 'vegetables': return Color(0xFF4CAF50);
//       case 'fruits': return Color(0xFFFF9800);
//       case 'equipment': return Color(0xFF607D8B);
//       case 'fertilizers': return Color(0xFF9C27B0);
//       case 'seeds': return Color(0xFF8BC34A);
//       case 'grains': return Color(0xFF795548);
//       default: return primaryGreen;
//     }
//   }

//   String _getTimeAgo(DateTime dateTime) {
//   final now = DateTime.now();
//   final difference = now.difference(dateTime);
  
//   if (difference.inSeconds < 60) {
//     return 'just now';
//   } else if (difference.inMinutes < 60) {
//     return '${difference.inMinutes}m ago';
//   } else if (difference.inHours < 24) {
//     return '${difference.inHours}h ago';
//   } else if (difference.inDays < 30) {
//     return '${difference.inDays}d ago';
//   } else {
//     // For dates older than 30 days, show actual date
//     return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
//   }
// }

//   }

// // Enhanced Shop Details Bottom Sheet
// class EnhancedShopDetailsSheet extends StatefulWidget {
//   final Shop shop;
//   final Position? userPosition;
//   final VoidCallback onOrderPlaced;

//   const EnhancedShopDetailsSheet({
//     Key? key,
//     required this.shop,
//     this.userPosition,
//     required this.onOrderPlaced,
//   }) : super(key: key);

//   @override
//   State<EnhancedShopDetailsSheet> createState() => _EnhancedShopDetailsSheetState();
// }

// class _EnhancedShopDetailsSheetState extends State<EnhancedShopDetailsSheet> 
//     with TickerProviderStateMixin {
//   bool showAccuracyQuestion = true;
//   String selectedTimeRange = '7 days';
//   late TabController _tabController;

//   final List<String> timeRanges = ['7 days', '15 days', '30 days', '60 days'];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.92,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(25),
//           topRight: Radius.circular(25),
//         ),
//       ),
//       child: Column(
//         children: [
//           _buildHandle(),
//           _buildHeader(),
//           _buildTabBar(),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               physics: BouncingScrollPhysics(),
//               children: [
//                 _buildPriceTab(),
//                 _buildDetailsTab(),
//                 _buildReviewsTab(),
//               ],
//             ),
//           ),
//           _buildBottomActions(),
//         ],
//       ),
//     );
//   }

//   Widget _buildHandle() {
//     return Container(
//       margin: EdgeInsets.only(top: 12),
//       width: 50,
//       height: 5,
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(3),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [primaryGreen.withOpacity(0.05), Colors.white],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [primaryGreen, secondaryGreen],
//               ),
//               borderRadius: BorderRadius.circular(18),
//               boxShadow: [
//                 BoxShadow(
//                   color: primaryGreen.withOpacity(0.3),
//                   blurRadius: 10,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Icon(Icons.store, color: Colors.white, size: 30),
//           ),
//           SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.shop.name,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
//                     SizedBox(width: 4),
//                     Expanded(
//                       child: Text(
//                         widget.shop.location,
//                         style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Row(
//                       children: List.generate(5, (index) => 
//                         Icon(
//                           Icons.star,
//                           size: 16,
//                           color: index < widget.shop.rating.floor() 
//                               ? accentOrange 
//                               : Colors.grey[300],
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       '${widget.shop.rating.toStringAsFixed(1)} (${widget.shop.reviewCount} reviews)',
//                       style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: Icon(Icons.share_outlined, color: primaryGreen),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabBar() {
//     return Container(
//       color: Colors.white,
//       child: TabBar(
//         controller: _tabController,
//         indicatorColor: primaryGreen,
//         labelColor: primaryGreen,
//         unselectedLabelColor: Colors.grey[600],
//         labelStyle: TextStyle(fontWeight: FontWeight.bold),
//         tabs: [
//           Tab(text: 'Prices'),
//           Tab(text: 'Details'),
//           Tab(text: 'Reviews'),
//         ],
//       ),
//     );
//   }

//   Widget _buildPriceTab() {
//     return SingleChildScrollView(
//       physics: BouncingScrollPhysics(),
//       padding: EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Current price info
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [primaryGreen.withOpacity(0.1), primaryGreen.withOpacity(0.05)],
//               ),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: primaryGreen.withOpacity(0.2)),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Current Price Range',
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         '₹${widget.shop.minPrice.toInt()} - ₹${widget.shop.maxPrice.toInt()}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 24,
//                           color: primaryGreen,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         'per kg • Updated ${_getTimeAgo(widget.shop.lastUpdated)}',
//                         style: TextStyle(
//                           color: Colors.grey[500],
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(Icons.trending_up, color: primaryGreen, size: 24),
//                 ),
//               ],
//             ),
//           ),

//           SizedBox(height: 24),

//           // Time range selector
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Price History',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: timeRanges.map((range) => 
//                     GestureDetector(
//                       onTap: () => setState(() => selectedTimeRange = range),
//                       child: Container(
//                         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: selectedTimeRange == range ? primaryGreen : Colors.transparent,
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Text(
//                           range,
//                           style: TextStyle(
//                             color: selectedTimeRange == range ? Colors.white : Colors.grey[600],
//                             fontSize: 12,
//                             fontWeight: selectedTimeRange == range ? FontWeight.bold : FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ).toList(),
//                 ),
//               ),
//             ],
//           ),

//           SizedBox(height: 16),

//           // Price trend indicator
//           Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: _getPriceTrendColor().withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: _getPriceTrendColor().withOpacity(0.3)),
//             ),
//             child: Row(
//               children: [
//                 Icon(_getPriceTrendIcon(), color: _getPriceTrendColor(), size: 20),
//                 SizedBox(width: 12),
//                 Text(
//                   _getPriceTrendText(),
//                   style: TextStyle(
//                     color: _getPriceTrendColor(),
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           SizedBox(height: 20),

//           // Enhanced price chart
//           Container(
//             height: 250,
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: LineChart(
//               LineChartData(
//                 gridData: FlGridData(
//                   show: true,
//                   drawVerticalLine: false,
//                   horizontalInterval: 50,
//                   getDrawingHorizontalLine: (value) => FlLine(
//                     color: Colors.grey[200]!,
//                     strokeWidth: 1,
//                   ),
//                 ),
//                 titlesData: FlTitlesData(
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 30,
//                       interval: _getChartInterval(),
//                       getTitlesWidget: (value, meta) {
//                         final index = value.toInt();
//                         if (index < 0 || index >= _getFilteredPriceHistory().length) {
//                           return SizedBox.shrink();
//                         }
//                         final date = _getFilteredPriceHistory()[index].date;
//                         return Padding(
//                           padding: EdgeInsets.only(top: 8),
//                           child: Text(
//                             '${date.day}/${date.month}',
//                             style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 45,
//                       interval: 50,
//                       getTitlesWidget: (value, meta) {
//                         return Text(
//                           '₹${value.toInt()}',
//                           style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                         );
//                       },
//                     ),
//                   ),
//                   rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 minX: 0,
//                 maxX: (_getFilteredPriceHistory().length - 1).toDouble(),
//                 minY: _getMinPrice() * 0.9,
//                 maxY: _getMaxPrice() * 1.1,
//                 lineBarsData: [
//                   // Price line
//                   LineChartBarData(
//                     spots: List.generate(
//                       _getFilteredPriceHistory().length,
//                       (index) => FlSpot(
//                         index.toDouble(),
//                         _getFilteredPriceHistory()[index].price,
//                       ),
//                     ),
//                     isCurved: true,
//                     color: primaryGreen,
//                     barWidth: 3,
//                     dotData: FlDotData(
//                       show: true,
//                       getDotPainter: (spot, percent, barData, index) =>
//                           FlDotCirclePainter(
//                             radius: 4,
//                             color: primaryGreen,
//                             strokeWidth: 2,
//                             strokeColor: Colors.white,
//                           ),
//                     ),
//                     belowBarData: BarAreaData(
//                       show: true,
//                       color: primaryGreen.withOpacity(0.1),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           SizedBox(height: 20),

//           // Price statistics
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatCard(
//                   'Highest',
//                   '₹${_getMaxPrice().toInt()}',
//                   Icons.trending_up,
//                   Colors.red[600]!,
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: _buildStatCard(
//                   'Lowest',
//                   '₹${_getMinPrice().toInt()}',
//                   Icons.trending_down,
//                   primaryGreen,
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: _buildStatCard(
//                   'Average',
//                   '₹${_getAveragePrice().toInt()}',
//                   Icons.show_chart,
//                   accentOrange,
//                 ),
//               ),
//             ],
//           ),

//           SizedBox(height: 20),

//           // Price accuracy question
//           if (showAccuracyQuestion) ...[
//             Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.blue[50],
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.blue[200]!),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.help_outline, color: Colors.blue[700], size: 20),
//                       SizedBox(width: 8),
//                       Text(
//                         'Are these prices accurate?',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: Colors.blue[700],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: () => setState(() => showAccuracyQuestion = false),
//                           icon: Icon(Icons.thumb_up_outlined, color: primaryGreen, size: 16),
//                           label: Text('Yes, accurate', style: TextStyle(color: primaryGreen)),
//                           style: OutlinedButton.styleFrom(
//                             side: BorderSide(color: primaryGreen),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: () => setState(() => showAccuracyQuestion = false),
//                           icon: Icon(Icons.thumb_down_outlined, color: Colors.red, size: 16),
//                           label: Text('No, incorrect', style: TextStyle(color: Colors.red)),
//                           style: OutlinedButton.styleFrom(
//                             side: BorderSide(color: Colors.red),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailsTab() {
//     return SingleChildScrollView(
//       physics: BouncingScrollPhysics(),
//       padding: EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Contact information
//           _buildDetailSection(
//             'Contact Information',
//             [
//               _buildDetailRow(Icons.phone, 'Phone', widget.shop.phoneNumber),
//               _buildDetailRow(Icons.access_time, 'Hours', widget.shop.openingHours),
//               _buildDetailRow(Icons.location_on, 'Address', widget.shop.location),
//             ],
//           ),

//           SizedBox(height: 24),

//           // Categories
//           _buildDetailSection(
//             'Available Categories',
//             widget.shop.categories.map((category) => 
//               Container(
//                 margin: EdgeInsets.only(bottom: 8),
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: _getCategoryColor(category).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: _getCategoryColor(category).withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(_getCategoryIcon(category), 
//                          color: _getCategoryColor(category), size: 20),
//                     SizedBox(width: 12),
//                     Text(
//                       category,
//                       style: TextStyle(
//                         color: _getCategoryColor(category),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             ).toList(),
//           ),

//           SizedBox(height: 24),

//           // Distance info
//           if (widget.shop.distanceKm != null) ...[
//             _buildDetailSection(
//               'Distance & Location',
//               [
//                 _buildDetailRow(
//                   Icons.directions,
//                   'Distance',
//                   '${widget.shop.distanceKm!.toStringAsFixed(1)} km from your location',
//                 ),
//                 _buildDetailRow(
//                   Icons.access_time,
//                   'Travel Time',
//                   '~${(widget.shop.distanceKm! * 2).toInt()} minutes by car',
//                 ),
//               ],
//             ),
//             SizedBox(height: 24),
//           ],

//           // Additional info
//           _buildDetailSection(
//             'Additional Information',
//             [
//               _buildDetailRow(Icons.update, 'Last Updated', _getTimeAgo(widget.shop.lastUpdated)),
//               _buildDetailRow(Icons.inventory, 'Stock Status', 'Available'),
//               _buildDetailRow(Icons.local_shipping, 'Delivery', 'Available in area'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReviewsTab() {
//     return SingleChildScrollView(
//       physics: BouncingScrollPhysics(),
//       padding: EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Overall rating
//           Container(
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [accentOrange.withOpacity(0.1), accentOrange.withOpacity(0.05)],
//               ),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Row(
//               children: [
//                 Column(
//                   children: [
//                     Text(
//                       widget.shop.rating.toStringAsFixed(1),
//                       style: TextStyle(
//                         fontSize: 36,
//                         fontWeight: FontWeight.bold,
//                         color: accentOrange,
//                       ),
//                     ),
//                     Row(
//                       children: List.generate(5, (index) => 
//                         Icon(
//                           Icons.star,
//                           size: 20,
//                           color: index < widget.shop.rating.floor() 
//                               ? accentOrange 
//                               : Colors.grey[300],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       '${widget.shop.reviewCount} reviews',
//                       style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                     ),
//                   ],
//                 ),
//                 SizedBox(width: 24),
//                 Expanded(
//                   child: Column(
//                     children: [
//                       _buildRatingBar(5, 0.6),
//                       _buildRatingBar(4, 0.3),
//                       _buildRatingBar(3, 0.08),
//                       _buildRatingBar(2, 0.02),
//                       _buildRatingBar(1, 0.0),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           SizedBox(height: 24),

//           // Sample reviews
//           Text(
//             'Recent Reviews',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             ),
//           ),
          
//           SizedBox(height: 16),

//           ..._generateSampleReviews().map((review) => 
//             Container(
//               margin: EdgeInsets.only(bottom: 16),
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey[200]!),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 20,
//                         backgroundColor: primaryGreen,
//                         child: Text(
//                           review['name'].toString().substring(0, 1),
//                           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               review['name'],
//                               style: TextStyle(fontWeight: FontWeight.w600),
//                             ),
//                             Row(
//                               children: [
//                                 ...List.generate(5, (index) => 
//                                   Icon(
//                                     Icons.star,
//                                     size: 14,
//                                     color: index < review['rating'] 
//                                         ? accentOrange 
//                                         : Colors.grey[300],
//                                   ),
//                                 ),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   review['date'],
//                                   style: TextStyle(color: Colors.grey[500], fontSize: 12),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 12),
//                   Text(
//                     review['comment'],
//                     style: TextStyle(color: Colors.grey[700], height: 1.4),
//                   ),
//                 ],
//               ),
//             ),
//           ).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomActions() {
//     return Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: OutlinedButton.icon(
//               onPressed: () {},
//               icon: Icon(Icons.call, color: primaryGreen),
//               label: Text('Call Shop', style: TextStyle(color: primaryGreen)),
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(color: primaryGreen),
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//             ),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             flex: 2,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 HapticFeedback.mediumImpact();
//                 widget.onOrderPlaced();
//               },
//               icon: Icon(Icons.shopping_cart, color: Colors.white),
//               label: Text('Place Order', style: TextStyle(color: Colors.white)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryGreen,
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper methods
//   List<PricePoint> _getFilteredPriceHistory() {
//     int days = int.parse(selectedTimeRange.split(' ')[0]);
//     return widget.shop.priceHistory.where((point) => 
//       DateTime.now().difference(point.date).inDays <= days
//     ).toList();
//   }

//   double _getChartInterval() {
//     int dataPoints = _getFilteredPriceHistory().length;
//     return (dataPoints / 5).ceilToDouble();
//   }

//   Color _getPriceTrendColor() {
//     final history = _getFilteredPriceHistory();
//     if (history.length < 2) return Colors.grey;
    
//     final recent = history.last.price;
//     final previous = history[history.length - 2].price;
    
//     if (recent > previous) return Colors.red[600]!;
//     if (recent < previous) return primaryGreen;
//     return Colors.grey[600]!;
//   }

//   IconData _getPriceTrendIcon() {
//     final history = _getFilteredPriceHistory();
//     if (history.length < 2) return Icons.trending_flat;
    
//     final recent = history.last.price;
//     final previous = history[history.length - 2].price;
    
//     if (recent > previous) return Icons.trending_up;
//     if (recent < previous) return Icons.trending_down;
//     return Icons.trending_flat;
//   }

//   String _getPriceTrendText() {
//     final history = _getFilteredPriceHistory();
//     if (history.length < 2) return 'No trend data available';
    
//     final recent = history.last.price;
//     final previous = history[history.length - 2].price;
//     final change = ((recent - previous) / previous * 100).abs();
    
//     if (recent > previous) {
//       return 'Prices increased by ${change.toStringAsFixed(1)}%';
//     } else if (recent < previous) {
//       return 'Prices decreased by ${change.toStringAsFixed(1)}%';
//     } else {
//       return 'Prices remained stable';
//     }
//   }

//   double _getMinPrice() {
//     return _getFilteredPriceHistory().map((p) => p.price).reduce((a, b) => a < b ? a : b);
//   }

//   double _getMaxPrice() {
//     return _getFilteredPriceHistory().map((p) => p.price).reduce((a, b) => a > b ? a : b);
//   }

//   double _getAveragePrice() {
//     final prices = _getFilteredPriceHistory().map((p) => p.price).toList();
//     return prices.reduce((a, b) => a + b) / prices.length;
//   }

//   Widget _buildStatCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 24),
//           SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//               color: color,
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             title,
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailSection(String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         SizedBox(height: 12),
//         ...children,
//       ],
//     );
//   }

//   Widget _buildDetailRow(IconData icon, String label, String value) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12),
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: primaryGreen, size: 20),
//           SizedBox(width: 12),
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Spacer(),
//           Text(
//             value,
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRatingBar(int stars, double percentage) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         children: [
//           Text('$stars', style: TextStyle(fontSize: 12)),
//           SizedBox(width: 4),
//           Icon(Icons.star, size: 12, color: accentOrange),
//           SizedBox(width: 8),
//           Expanded(
//             child: Container(
//               height: 8,
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: FractionallySizedBox(
//                 alignment: Alignment.centerLeft,
//                 widthFactor: percentage,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: accentOrange,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: 8),
//           Text(
//             '${(percentage * 100).toInt()}%',
//             style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }

//   List<Map<String, dynamic>> _generateSampleReviews() {
//     return [
//       {
//         'name': 'Rajesh Kumar',
//         'rating': 5,
//         'date': '2 days ago',
//         'comment': 'Excellent quality vegetables and very competitive prices. The staff is knowledgeable and helpful.',
//       },
//       {
//         'name': 'Priya Sharma',
//         'rating': 4,
//         'date': '5 days ago',
//         'comment': 'Good variety of fresh produce. Prices are reasonable and the location is convenient.',
//       },
//       {
//         'name': 'Mohammed Ali',
//         'rating': 5,
//         'date': '1 week ago',
//         'comment': 'Best mandi in the area! Always fresh stock and fair pricing. Highly recommended.',
//       },
//     ];
//   }

//   Color _getCategoryColor(String category) {
//     switch (category.toLowerCase()) {
//       case 'vegetables': return Color(0xFF4CAF50);
//       case 'fruits': return Color(0xFFFF9800);
//       case 'equipment': return Color(0xFF607D8B);
//       case 'fertilizers': return Color(0xFF9C27B0);
//       case 'seeds': return Color(0xFF8BC34A);
//       case 'grains': return Color(0xFF795548);
//       default: return primaryGreen;
//     }
//   }

//   IconData _getCategoryIcon(String category) {
//     switch (category.toLowerCase()) {
//       case 'vegetables': return Icons.eco;
//       case 'fruits': return Icons.apple;
//       case 'equipment': return Icons.agriculture;
//       case 'fertilizers': return Icons.local_florist;
//       case 'seeds': return Icons.spa;
//       case 'grains': return Icons.grain;
//       default: return Icons.store;
//     }
//   }

// String _getTimeAgo(DateTime dateTime) {
//   final now = DateTime.now();
//   final difference = now.difference(dateTime);
  
//   if (difference.inMinutes < 60) {
//     return '${difference.inMinutes}m ago';
//   } else if (difference.inHours < 24) {
//     return '${difference.inHours}h ago';
//   } else {
//     return '${difference.inDays}d ago';
//   }
// }
//     }

