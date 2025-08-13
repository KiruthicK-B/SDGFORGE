import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vfarm/markets/Buy_products.dart' as tabController;
import 'package:vfarm/markets/Buy_products.dart' as animationController;

// Enhanced Color Palette
const primaryGreen = Color(0xFF0A9D88);
const secondaryGreen = Color(0xFF4CAF50);
const accentOrange = Color(0xFFFF9800);
const lightGreen = Color(0xFFE8F5E8);
const darkGreen = Color(0xFF006B5A);
const cardBackground = Color(0xFFFFFFFF);
const backgroundColor = Color(0xFFF8F9FA);
const textPrimary = Color(0xFF2D3748);
const textSecondary = Color(0xFF718096);
const successColor = Color(0xFF38A169);
const warningColor = Color(0xFFED8936);
const errorColor = Color(0xFFE53E3E);

// Enhanced Shop model class
class Shop {
  final String id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final List<String> categories;
  final double minPrice;
  final double maxPrice;
  final double currentPrice;
  final DateTime lastUpdated;
  final List<PricePoint> priceHistory;
  final bool isFollowing;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String phoneNumber;
  final Map<String, String> openingHours;
  final String description;
  final List<String> features;
  final bool isOpen;
  final double discountPercentage;
  double? distanceKm;

  Shop({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.categories,
    required this.minPrice,
    required this.maxPrice,
    required this.currentPrice,
    required this.lastUpdated,
    required this.priceHistory,
    required this.isFollowing,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.phoneNumber,
    required this.openingHours,
    required this.description,
    required this.features,
    required this.isOpen,
    required this.discountPercentage,
    this.distanceKm,
  });
}

// Price point for graph
class PricePoint {
  final DateTime date;
  final double price;
  
  PricePoint(this.date, this.price);
}

// Enhanced Category model class
class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;
  final String emoji;
  final LinearGradient gradient;

  CategoryItem(this.name, this.icon, this.color, this.emoji, this.gradient);
}

// Distance option model
class DistanceOption {
  final String label;
  final int distanceKm;

  DistanceOption(this.label, this.distanceKm);
}

class BuyProducts extends StatefulWidget {
  const BuyProducts({super.key});

  @override
  State<BuyProducts> createState() => _BuyProductsState();
}

class _BuyProductsState extends State<BuyProducts> 
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  
  // Enhanced Animation controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _scaleAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _loadingAnimation;

  // Enhanced Categories with gradients
  final List<CategoryItem> categories = [
    CategoryItem('Vegetables', Icons.grass, Color(0xFF4CAF50), '🥬',
        LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)])),
    CategoryItem('Fruits', Icons.apple, Color(0xFFFF9800), '🍎',
        LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFFB74D)])),
    CategoryItem('Equipment', Icons.agriculture, Color(0xFF607D8B), '🚜',
        LinearGradient(colors: [Color(0xFF607D8B), Color(0xFF90A4AE)])),
    CategoryItem('Fertilizers', Icons.eco, Color(0xFF9C27B0), '🌱',
        LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)])),
    CategoryItem('Seeds', Icons.spa, Color(0xFF8BC34A), '🌰',
        LinearGradient(colors: [Color(0xFF8BC34A), Color(0xFFAED581)])),
    CategoryItem('Grains', Icons.grain, Color(0xFF795548), '🌾',
        LinearGradient(colors: [Color(0xFF795548), Color(0xFFA1887F)])),
  ];
  
  String selectedCategory = 'Vegetables';

  // Distance filter options
  final List<DistanceOption> distanceOptions = [
    DistanceOption('Within 2 km', 2),
    DistanceOption('Within 5 km', 5),
    DistanceOption('Within 10 km', 10),
    DistanceOption('Within 25 km', 25),
    DistanceOption('Within 50 km', 50),
    DistanceOption('Within 100 km', 100),
  ];
  
  int selectedDistanceKm = 25;
  bool sortByDistance = true;
  bool showMapView = false;

  // Location and maps
  Position? userPosition;
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  
  // Loading states
  bool isLoading = true;
  bool isLoadingShops = false;
  bool isLoadingMap = false;

  // Data
  List<Shop> allShops = [];
  List<Shop> filteredShops = [];
  
  // Search
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Timer? _debounceTimer;

  // Page controller for smooth transitions
  late PageController _pageController;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _pageController = PageController();
    _initializePage();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    
    _slideAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    
    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    
    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimationController.forward();
    _slideAnimationController.forward();
    _scaleAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _scaleAnimationController.dispose();
    _loadingAnimationController.dispose();
    _pageController.dispose();
    searchController.dispose();
    _debounceTimer?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializePage() async {
    setState(() => isLoading = true);
    
    try {
      await _getCurrentLocation();
      await _loadShopsFromGooglePlaces();
      _applyFilters();
    } catch (e) {
      debugPrint('Error initializing page: $e');
      _showErrorSnackBar('Failed to load data. Please try again.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar('Location permission denied. Please enable in settings.');
        return;
      }

      userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );
    } catch (e) {
      debugPrint('Location error: $e');
      _showErrorSnackBar('Unable to get location. Using default area.');
      userPosition = Position(
        latitude: 12.9716,
        longitude: 77.5946,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 1,
        headingAccuracy: 1,
      );
    }
  }

  Future<void> _loadShopsFromGooglePlaces() async {
    if (userPosition == null) {
      debugPrint('❌ User position is null, cannot load shops');
      return;
    }

    debugPrint('📍 User position: ${userPosition!.latitude}, ${userPosition!.longitude}');
    setState(() => isLoadingShops = true);

    try {
      const String apiKey = 'AIzaSyAVcz0-ooE0MkmCkpDaigolWtI4By8NSHc';
      
      debugPrint('🔑 Loading shops...');
      
      List<String> searchQueries = _getSearchQueries();
      debugPrint('🔍 Search queries: $searchQueries');
      
      List<Shop> allFoundShops = [];

      for (String query in searchQueries) {
        debugPrint('🔄 Searching for: $query');
        
        try {
          final shops = await _searchNearbyPlaces(query, apiKey);
          debugPrint('✅ Found ${shops.length} shops for query: $query');
          allFoundShops.addAll(shops);
        } catch (queryError) {
          debugPrint('❌ Error searching for $query: $queryError');
        }
      }

      debugPrint('📊 Total shops found from API: ${allFoundShops.length}');

      allShops = _removeDuplicateShops(allFoundShops);
      debugPrint('📊 After removing duplicates: ${allShops.length}');
      
      final mockShops = _generateEnhancedMockShops();
      allShops.addAll(mockShops);
      debugPrint('📊 After adding mock data: ${allShops.length}');

      _updateMapMarkers();
      debugPrint('🗺️ Map markers updated');

    } catch (e) {
      debugPrint('❌ Error loading shops from Google Places: $e');
      
      allShops = _generateEnhancedMockShops();
      debugPrint('🔄 Using fallback mock data: ${allShops.length} shops');
    }

    setState(() => isLoadingShops = false);
    debugPrint('✅ Shop loading completed. Total shops: ${allShops.length}');
  }

  List<String> _getSearchQueries() {
    Map<String, List<String>> categoryQueries = {
      'Vegetables': ['vegetable market', 'grocery store', 'supermarket'],
      'Fruits': ['fruit market', 'grocery store', 'supermarket'],
      'Equipment': ['hardware store', 'farm equipment', 'tools'],
      'Fertilizers': ['garden center', 'agricultural supplies', 'fertilizer'],
      'Seeds': ['garden center', 'agricultural supplies', 'seeds'],
      'Grains': ['grocery store', 'supermarket', 'food store'],
    };
    
    return categoryQueries[selectedCategory] ?? ['store'];
  }

  Future<List<Shop>> _searchNearbyPlaces(String query, String apiKey) async {
    if (userPosition == null) return [];
    
    final lat = userPosition!.latitude;
    final lng = userPosition!.longitude;
    final radius = 5000;
    
    final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lng'
        '&radius=$radius'
        '&keyword=$query'
        '&type=store'
        '&key=$apiKey';

    debugPrint('🌐 API URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          List<Shop> shops = [];
          
          for (var place in results) {
            try {
              shops.add(_createShopFromGooglePlace(place));
            } catch (e) {
              debugPrint('❌ Error parsing place: $e');
            }
          }
          
          return shops;
        } else {
          debugPrint('❌ API Error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
          return [];
        }
      } else {
        debugPrint('❌ HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Network Error: $e');
      return [];
    }
  }

  Shop _createShopFromGooglePlace(Map<String, dynamic> place) {
    final location = place['geometry']['location'];
    final double lat = location['lat'].toDouble();
    final double lng = location['lng'].toDouble();
    
    return Shop(
      id: place['place_id'] ?? 'unknown_${Random().nextInt(10000)}',
      name: place['name'] ?? 'Unknown Shop',
      location: place['vicinity'] ?? 'Unknown Location',
      latitude: lat,
      longitude: lng,
      categories: [selectedCategory],
      minPrice: _generateRandomPrice(50, 200),
      maxPrice: _generateRandomPrice(200, 500),
      currentPrice: _generateRandomPrice(100, 300),
      lastUpdated: DateTime.now(),
      priceHistory: _generatePriceHistory(),
      isFollowing: Random().nextBool(),
      rating: double.parse((Random().nextDouble() * 2 + 3).toStringAsFixed(1)),
      reviewCount: Random().nextInt(500) + 10,
      imageUrl: _getRandomShopImage(),
      phoneNumber: _generatePhoneNumber(),
      openingHours: _generateOpeningHours(),
      description: _generateDescription(),
      features: _generateFeatures(),
      isOpen: Random().nextBool(),
      discountPercentage: Random().nextDouble() * 20,
    );
  }

  List<Shop> _generateEnhancedMockShops() {
    if (userPosition == null) return [];
    
    List<Shop> mockShops = [];
    Random random = Random();
    
    final shopNames = {
      'Vegetables': ['Green Fresh Market', 'Organic Veggies', 'Farm Fresh Store', 'Daily Vegetables', 'Fresh Produce Hub'],
      'Fruits': ['Fruit Paradise', 'Sweet Fruits', 'Fresh Fruit Corner', 'Seasonal Fruits', 'Fruit Basket'],
      'Equipment': ['Farm Tools Store', 'Agricultural Equipment', 'Machinery Hub', 'Tool Center', 'Equipment Shop'],
      'Fertilizers': ['Garden Supplies', 'Fertilizer Store', 'Plant Nutrition', 'Agricultural Supplies', 'Farm Chemicals'],
      'Seeds': ['Seed Store', 'Quality Seeds', 'Agricultural Seeds', 'Farming Seeds', 'Seed Center'],
      'Grains': ['Grain Market', 'Rice & Wheat', 'Cereal Store', 'Grain Hub', 'Food Grains'],
    };

    final categoryShops = shopNames[selectedCategory] ?? shopNames['Vegetables']!;

    for (int i = 0; i < 15; i++) {
      final shopName = categoryShops[i % categoryShops.length];
      
      mockShops.add(Shop(
        id: 'mock_shop_${selectedCategory.toLowerCase()}_$i',
        name: '$shopName ${i + 1}',
        location: '${_getRandomArea()}, ${_getRandomCity()}',
        latitude: userPosition!.latitude + (random.nextDouble() - 0.5) * 0.03,
        longitude: userPosition!.longitude + (random.nextDouble() - 0.5) * 0.03,
        categories: [selectedCategory],
        minPrice: _generateRandomPrice(50, 200),
        maxPrice: _generateRandomPrice(200, 500),
        currentPrice: _generateRandomPrice(100, 300),
        lastUpdated: DateTime.now().subtract(Duration(minutes: random.nextInt(120))),
        priceHistory: _generatePriceHistory(),
        isFollowing: random.nextBool(),
        rating: double.parse((random.nextDouble() * 2 + 3).toStringAsFixed(1)),
        reviewCount: random.nextInt(500) + 10,
        imageUrl: _getRandomShopImage(),
        phoneNumber: _generatePhoneNumber(),
        openingHours: _generateOpeningHours(),
        description: _generateDescription(),
        features: _generateFeatures(),
        isOpen: random.nextBool(),
        discountPercentage: random.nextDouble() * 20,
      ));
    }

    debugPrint('✅ Generated ${mockShops.length} mock shops for category: $selectedCategory');
    return mockShops;
  }

  List<Shop> _removeDuplicateShops(List<Shop> shops) {
    Map<String, Shop> uniqueShops = {};
    for (Shop shop in shops) {
      uniqueShops[shop.id] = shop;
    }
    return uniqueShops.values.toList();
  }

  double _generateRandomPrice(double min, double max) {
    final random = Random();
    return double.parse((min + random.nextDouble() * (max - min)).toStringAsFixed(2));
  }

  List<PricePoint> _generatePriceHistory() {
    final random = Random();
    final history = <PricePoint>[];
    double basePrice = 100 + random.nextDouble() * 200;
    
    for (int i = 30; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      basePrice += (random.nextDouble() - 0.5) * 20;
      basePrice = basePrice.clamp(50.0, 500.0);
      history.add(PricePoint(date, double.parse(basePrice.toStringAsFixed(2))));
    }
    return history;
  }

  String _getRandomShopImage() {
    final images = [
      'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Shop',
      'https://via.placeholder.com/300x200/FF9800/FFFFFF?text=Market',
      'https://via.placeholder.com/300x200/2196F3/FFFFFF?text=Store',
      'https://via.placeholder.com/300x200/9C27B0/FFFFFF?text=Shop',
      'https://via.placeholder.com/300x200/F44336/FFFFFF?text=Market',
    ];
    return images[Random().nextInt(images.length)];
  }

  String _generatePhoneNumber() {
    final random = Random();
    return '+91 ${(9000000000 + random.nextInt(999999999)).toString()}';
  }

  Map<String, String> _generateOpeningHours() {
    final hours = ['9:00 AM - 8:00 PM', '8:00 AM - 9:00 PM', '10:00 AM - 7:00 PM'];
    final selectedHours = hours[Random().nextInt(hours.length)];
    
    return {
      'monday': selectedHours,
      'tuesday': selectedHours,
      'wednesday': selectedHours,
      'thursday': selectedHours,
      'friday': selectedHours,
      'saturday': selectedHours,
      'sunday': Random().nextBool() ? selectedHours : 'Closed',
    };
  }

  String _generateDescription() {
    final descriptions = [
      'Fresh, organic produce sourced directly from local farms. We pride ourselves on quality and freshness.',
      'Your one-stop shop for all agricultural needs. Quality products at competitive prices.',
      'Family-owned business serving the community for over 20 years with premium products.',
      'Specializing in fresh, seasonal produce with a commitment to sustainable farming practices.',
      'Premium quality agricultural products with excellent customer service and competitive pricing.',
    ];
    return descriptions[Random().nextInt(descriptions.length)];
  }

  List<String> _generateFeatures() {
    final allFeatures = [
      'Free Home Delivery',
      'Organic Certified',
      'Fresh Daily',
      '24/7 Customer Support',
      'Quality Guarantee',
      'Bulk Discounts',
      'Online Ordering',
      'Same Day Delivery',
      'Expert Consultation',
      'Seasonal Offers',
    ];
    
    final random = Random();
    final numFeatures = 3 + random.nextInt(4); // 3-6 features
    final selectedFeatures = <String>[];
    final shuffled = List.from(allFeatures)..shuffle(random);
    
    for (int i = 0; i < numFeatures && i < shuffled.length; i++) {
      selectedFeatures.add(shuffled[i]);
    }
    
    return selectedFeatures;
  }

  String _getRandomArea() {
    final areas = [
      'Gandhi Nagar', 'Market Street', 'Main Road', 'Commercial Complex',
      'Shopping Center', 'Local Market', 'Town Center', 'Business District'
    ];
    return areas[Random().nextInt(areas.length)];
  }

  String _getRandomCity() {
    final cities = [
      'Central Area', 'City Center', 'Downtown', 'Market Area',
      'Commercial Zone', 'Business District'
    ];
    return cities[Random().nextInt(cities.length)];
  }

  void _updateMapMarkers() {
    markers.clear();
    
    if (userPosition != null) {
      markers.add(
        Marker(
          markerId: MarkerId('user_location'),
          position: LatLng(userPosition!.latitude, userPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      );
    }
    
    for (int i = 0; i < filteredShops.length && i < 50; i++) {
      final shop = filteredShops[i];
      markers.add(
        Marker(
          markerId: MarkerId(shop.id),
          position: LatLng(shop.latitude, shop.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerHue(shop.categories.first),
          ),
          infoWindow: InfoWindow(
            title: shop.name,
            snippet: '₹${shop.currentPrice.toInt()} • ${shop.distanceKm?.toStringAsFixed(1) ?? '0.0'} km',
            onTap: () => _showShopDetails(shop),
          ),
          onTap: () => _showShopDetails(shop),
        ),
      );
    }
  }

  double _getMarkerHue(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables': return BitmapDescriptor.hueGreen;
      case 'fruits': return BitmapDescriptor.hueOrange;
      case 'equipment': return BitmapDescriptor.hueViolet;
      case 'fertilizers': return BitmapDescriptor.hueMagenta;
      case 'seeds': return BitmapDescriptor.hueYellow;
      case 'grains': return BitmapDescriptor.hueRose;
      default: return BitmapDescriptor.hueRed;
    }
  }

  void _applyFilters() {
    if (userPosition == null) {
      filteredShops = [];
      return;
    }

    filteredShops = allShops.where((shop) {
      bool categoryMatch = shop.categories.contains(selectedCategory);
      bool searchMatch = searchQuery.isEmpty || 
          shop.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          shop.location.toLowerCase().contains(searchQuery.toLowerCase());
      
      return categoryMatch && searchMatch;
    }).toList();

    filteredShops = filteredShops.where((shop) {
      double distance = Geolocator.distanceBetween(
        userPosition!.latitude,
        userPosition!.longitude,
        shop.latitude,
        shop.longitude,
      ) / 1000;
      
      shop.distanceKm = distance;
      return distance <= selectedDistanceKm;
    }).toList();

    if (sortByDistance) {
      filteredShops.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
    } else {
      filteredShops.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
    }

    _updateMapMarkers();
    
    setState(() {});
  }

  void _onCategoryChanged(String category) {
    if (selectedCategory != category) {
      setState(() {
        selectedCategory = category;
        isLoadingShops = true;
      });
      
      HapticFeedback.lightImpact();
      
      _loadShopsFromGooglePlaces().then((_) {
        _applyFilters();
        setState(() => isLoadingShops = false);
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      setState(() => searchQuery = query);
      _applyFilters();
    });
  }

  void _toggleView() {
    setState(() {
      showMapView = !showMapView;
      isLoadingMap = showMapView;
    });
    
    HapticFeedback.mediumImpact();
    
    if (showMapView) {
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() => isLoadingMap = false);
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showShopDetails(Shop shop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShopDetailsModal(shop: shop),
    );
  }

  // Wave Loading Widget
  Widget _buildWaveLoading() {
    return AnimatedBuilder(
      animation: _loadingAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              double delay = index * 0.2;
              double animValue = (_loadingAnimation.value - delay).clamp(0.0, 1.0);
              double height = 20 + (sin(animValue * pi * 2) * 15);
              
              return Container(
                width: 8,
                height: height,
                margin: EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.7 + animValue * 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // Dotted Loading Widget
  Widget _buildDottedLoading() {
    return AnimatedBuilder(
      animation: _loadingAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            double delay = index * 0.3;
            double animValue = (_loadingAnimation.value - delay) % 1.0;
            double scale = 0.5 + (sin(animValue * pi * 2) * 0.5);
            
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 12,
                height: 12,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWaveLoading(),
              SizedBox(height: 24),
              Text(
                'Finding the best shops for you...',
                style: TextStyle(
                  fontSize: 16,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              _buildDottedLoading(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Buy Products',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: showMapView ? primaryGreen : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                showMapView ? Icons.list_rounded : Icons.map_rounded,
                color: showMapView ? Colors.white : textSecondary,
              ),
              onPressed: _toggleView,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced Categories Section
          Container(
            height: 140,
            padding: EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category.name;
                
                return GestureDetector(
                  onTap: () => _onCategoryChanged(category.name),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 90,
                    margin: EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      gradient: isSelected 
                          ? category.gradient 
                          : LinearGradient(colors: [Colors.grey[100]!, Colors.grey[100]!]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected 
                          ? [
                              BoxShadow(
                                color: category.color.withOpacity(0.3),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.2 : 1.0,
                          duration: Duration(milliseconds: 300),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              category.icon,
                              color: isSelected ? Colors.white : textSecondary,
                              size: 28,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          category.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isSelected) ...[
                          SizedBox(height: 4),
                          Container(
                            width: 20,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Enhanced Search Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search shops, products...',
                      hintStyle: TextStyle(color: textSecondary),
                      prefixIcon: Icon(Icons.search_rounded, color: textSecondary),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, color: textSecondary),
                              onPressed: () {
                                searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${filteredShops.length} shops found',
                          style: TextStyle(
                            fontSize: 14,
                            color: darkGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: sortByDistance ? primaryGreen : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.sort_rounded,
                          color: sortByDistance ? Colors.white : textSecondary,
                        ),
                        onPressed: () {
                          setState(() => sortByDistance = !sortByDistance);
                          _applyFilters();
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content Section
          Expanded(
            child: isLoadingShops
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildWaveLoading(),
                        SizedBox(height: 16),
                        Text(
                          'Loading shops...',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredShops.isEmpty
                    ? _buildEmptyState()
                    : showMapView
                        ? _buildMapView()
                        : _buildEnhancedListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store_rounded,
              size: 64,
              color: primaryGreen,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No shops found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try changing your category or search terms',
            style: TextStyle(
              color: textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              searchController.clear();
              setState(() => searchQuery = '');
              _applyFilters();
            },
            icon: Icon(Icons.refresh_rounded),
            label: Text('Reset Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(
          userPosition?.latitude ?? 12.9716,
          userPosition?.longitude ?? 77.5946,
        ),
        zoom: 12,
      ),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      style: '''
        [
          {
            "featureType": "poi",
            "elementType": "labels",
            "stylers": [{"visibility": "off"}]
          }
        ]
      ''',
    );
  }

  Widget _buildEnhancedListView() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredShops.length,
      itemBuilder: (context, index) {
        final shop = filteredShops[index];
        return _buildEnhancedShopCard(shop, index);
      },
    );
  }

  Widget _buildEnhancedShopCard(Shop shop, int index) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showShopDetails(shop),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          children: [
                            // Shop Avatar
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryGreen, secondaryGreen],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryGreen.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  shop.name.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            // Shop Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          shop.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (shop.isOpen) ...[
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: successColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Open',
                                            style: TextStyle(
                                              color: successColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: errorColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Closed',
                                            style: TextStyle(
                                              color: errorColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_rounded, 
                                           color: textSecondary, size: 16),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          shop.location,
                                          style: TextStyle(
                                            color: textSecondary,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (shop.discountPercentage > 0) ...[
                                  Text(
                                    '₹${(shop.currentPrice * 1.2).toInt()}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textSecondary,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                ],
                                Text(
                                  '₹${shop.currentPrice.toInt()}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: primaryGreen,
                                  ),
                                ),
                                Text(
                                  'per kg',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Stats Row
                        Row(
                          children: [
                            // Rating
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded, 
                                       color: Colors.amber, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    shop.rating.toString(),
                                    style: TextStyle(
                                      color: Colors.amber[700],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            // Distance
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.directions_rounded, 
                                       color: primaryGreen, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    '${shop.distanceKm?.toStringAsFixed(1)} km',
                                    style: TextStyle(
                                      color: primaryGreen,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            // Discount Badge
                            if (shop.discountPercentage > 0)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: warningColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${shop.discountPercentage.toInt()}% OFF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Enhanced Shop Details Modal
class ShopDetailsModal extends StatefulWidget {
  final Shop shop;

  const ShopDetailsModal({super.key, required this.shop});

  @override
  State<ShopDetailsModal> createState() => _ShopDetailsModalState();
}

class _ShopDetailsModalState extends State<ShopDetailsModal> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _tabController = TabController(length: 3, vsync: this);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _animation.value) * 300),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                _buildHeader(),
                
                // Tabs
                _buildTabs(),
                
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildPriceTrendTab(),
                      _buildDetailsTab(),
                    ],
                  ),
                ),
                
                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          // Shop Image/Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryGreen, secondaryGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.shop.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          // Shop Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.shop.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, 
                         color: textSecondary, size: 16),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.shop.location,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    // Status Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.shop.isOpen 
                            ? successColor.withOpacity(0.1) 
                            : errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.shop.isOpen ? 'Open Now' : 'Closed',
                        style: TextStyle(
                          color: widget.shop.isOpen ? successColor : errorColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Rating
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          SizedBox(width: 4),
                          Text(
                            widget.shop.rating.toString(),
                            style: TextStyle(
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
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
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.shop.discountPercentage > 0) ...[
                Text(
                  '₹${(widget.shop.currentPrice * 1.2).toInt()}',
                  style: TextStyle(
                    fontSize: 16,
                    color: textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(height: 2),
              ],
              Text(
                '₹${widget.shop.currentPrice.toInt()}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: primaryGreen,
                ),
              ),
              Text(
                'per kg',
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: textSecondary,
        indicator: BoxDecoration(
          color: primaryGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'Overview'),
          Tab(text: 'Price Trend'),
          Tab(text: 'Details'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          _buildSectionHeader('About'),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),

            child: Text(
              widget.shop.description,
              style: TextStyle(
                color: textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Features
          _buildSectionHeader('Features'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.shop.features.map((feature) => Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                feature,
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )).toList(),
          ),
          
          SizedBox(height: 24),
          
          // Quick Stats
          _buildSectionHeader('Quick Stats'),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Reviews',
                  widget.shop.reviewCount.toString(),
                  Icons.reviews_rounded,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Distance',
                  '${widget.shop.distanceKm?.toStringAsFixed(1)} km',
                  Icons.directions_rounded,
                  primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildPriceTrendTab() {
  return SingleChildScrollView(
    padding: EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Price Trend (Last 30 Days)'),
        
        // Enhanced Price Chart using your custom painter
        Container(
          height: 250,
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: CustomPaint(
            painter: EnhancedPriceChartPainter(widget.shop.priceHistory),
            size: Size.infinite,
            child: Container(), // Empty container to provide space for the painter
          ),
        ),
        
        SizedBox(height: 24),
        
        // Price Statistics
        _buildSectionHeader('Price Statistics'),
        Column(
          children: [
            _buildPriceStatRow('Current Price', '₹${widget.shop.currentPrice.toInt()}', primaryGreen),
            _buildPriceStatRow('Minimum Price', '₹${widget.shop.minPrice.toInt()}', successColor),
            _buildPriceStatRow('Maximum Price', '₹${widget.shop.maxPrice.toInt()}', errorColor),
            _buildPriceStatRow('Average Price', '₹${_calculateAveragePrice().toInt()}', Colors.blue),
          ],
        ),
        
        SizedBox(height: 24),
        
        // Additional trend information
        _buildSectionHeader('Trend Analysis'),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTrendIndicator(),
              SizedBox(height: 12),
              _buildPriceChangeInfo(),
            ],
          ),
        ),
      ],
    ),
  );
}

// Helper method to build trend indicator
Widget _buildTrendIndicator() {
  if (widget.shop.priceHistory.length < 2) {
    return Row(
      children: [
        Icon(Icons.trending_flat, color: Colors.grey, size: 20),
        SizedBox(width: 8),
        Text(
          'Insufficient data for trend analysis',
          style: TextStyle(
            color: textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  final firstPrice = widget.shop.priceHistory.first.price;
  final lastPrice = widget.shop.priceHistory.last.price;
  final isIncreasing = lastPrice > firstPrice;
  final isDecreasing = lastPrice < firstPrice;
  
  IconData trendIcon;
  Color trendColor;
  String trendText;
  
  if (isIncreasing) {
    trendIcon = Icons.trending_up;
    trendColor = errorColor;
    trendText = 'Price Increasing';
  } else if (isDecreasing) {
    trendIcon = Icons.trending_down;
    trendColor = successColor;
    trendText = 'Price Decreasing';
  } else {
    trendIcon = Icons.trending_flat;
    trendColor = Colors.grey;
    trendText = 'Price Stable';
  }
  
  return Row(
    children: [
      Icon(trendIcon, color: trendColor, size: 20),
      SizedBox(width: 8),
      Text(
        trendText,
        style: TextStyle(
          color: trendColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

// Helper method to build price change information
Widget _buildPriceChangeInfo() {
  if (widget.shop.priceHistory.length < 2) return SizedBox.shrink();
  
  final firstPrice = widget.shop.priceHistory.first.price;
  final lastPrice = widget.shop.priceHistory.last.price;
  final priceChange = lastPrice - firstPrice;
  final percentageChange = (priceChange / firstPrice) * 100;
  
  final isPositive = priceChange > 0;
  final changeColor = isPositive ? errorColor : successColor;
  final changePrefix = isPositive ? '+' : '';
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Price Change (30 days)',
        style: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      SizedBox(height: 4),
      Row(
        children: [
          Text(
            '$changePrefix₹${priceChange.toInt()}',
            style: TextStyle(
              color: changeColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: changeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$changePrefix${percentageChange.toStringAsFixed(1)}%',
              style: TextStyle(
                color: changeColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceStatRow(String label, String value, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryGreen, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildOpeningHoursRows() {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return days.asMap().entries.map((entry) {
      int index = entry.key;
      String day = entry.value;
      String dayName = dayNames[index];
      String hours = widget.shop.openingHours[day] ?? 'Closed';
      bool isToday = DateTime.now().weekday - 1 == index;
      
      return Container(
        margin: EdgeInsets.only(bottom: index < days.length - 1 ? 8 : 0),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isToday ? lightGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: isToday ? darkGreen : textPrimary,
              ),
            ),
            Text(
              hours,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: hours == 'Closed' ? errorColor : 
                       (isToday ? darkGreen : textSecondary),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Call Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Implement phone call functionality
                HapticFeedback.lightImpact();
              },
              icon: Icon(Icons.phone_rounded),
              label: Text('Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryGreen,
                side: BorderSide(color: primaryGreen),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          // Directions Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Implement directions functionality
                HapticFeedback.lightImpact();
              },
              icon: Icon(Icons.directions_rounded),
              label: Text('Directions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                side: BorderSide(color: Colors.blue),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          // Buy Button
          Expanded(
            flex: 1,
            child: ElevatedButton.icon(
              onPressed: () {
                // Implement buy functionality
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order placed for ${widget.shop.name}'),
                    backgroundColor: successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.all(16),
                  ),
                );
              },
              icon: Icon(Icons.shopping_cart_rounded),
              label: Text('Buy Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateAveragePrice() {
    if (widget.shop.priceHistory.isEmpty) return widget.shop.currentPrice;
    
    double total = widget.shop.priceHistory.fold(0.0, (sum, point) => sum + point.price);
    return total / widget.shop.priceHistory.length;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
  
Widget _buildDetailsTab() {
  return SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shop Image (if available)
        if (widget.shop.imageUrl.isNotEmpty)  // CHANGED: removed != null check
          Container(
            height: 200,
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(widget.shop.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

        // Shop Status
        Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: widget.shop.isOpen ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.shop.isOpen ? Colors.green[200]! : Colors.red[200]!,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.shop.isOpen ? Icons.check_circle : Icons.cancel,
                color: widget.shop.isOpen ? Colors.green[600] : Colors.red[600],
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                widget.shop.isOpen ? 'Currently Open' : 'Currently Closed',
                style: TextStyle(
                  color: widget.shop.isOpen ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.shop.discountPercentage > 0) ...[
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.shop.discountPercentage.toInt()}% OFF',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Contact Information
        _buildSectionHeader('Contact Information'),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                Icons.location_on,
                'Address',
                '${widget.shop.name}, ${widget.shop.location}',
              ),
              if (widget.shop.phoneNumber.isNotEmpty) ...[  // CHANGED: removed != null check
                Divider(height: 24),
                _buildInfoRow(
                  Icons.phone,
                  'Phone',
                  widget.shop.phoneNumber,
                ),
              ],
              if (widget.shop.openingHours.isNotEmpty) ...[  // CHANGED: removed != null check
                Divider(height: 24),
                _buildInfoRow(
                  Icons.access_time,
                  'Opening Hours',
                  'Mon-Sun: ${widget.shop.openingHours['monday'] ?? 'Closed'}',  // CHANGED: Fixed casting issue
                ),
              ],
              if (widget.shop.distanceKm != null) ...[
                Divider(height: 24),
                _buildInfoRow(
                  Icons.directions,
                  'Distance',
                  '${widget.shop.distanceKm!.toStringAsFixed(1)} km away',
                ),
              ],
            ],
          ),
        ),

        // Shop Rating
        _buildSectionHeader('Ratings & Reviews'),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 4),
                    Text(
                      widget.shop.rating.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.shop.reviewCount} Reviews',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _getRatingText(widget.shop.rating),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Available Categories
        _buildSectionHeader('Available Products'),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.shop.categories.map((category) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryGreen.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconForCategory(category),
                      size: 16,
                      color: primaryGreen,
                    ),
                    SizedBox(width: 4),
                    Text(
                      category,
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // Shop Features (if available)
        if (widget.shop.features.isNotEmpty) ...[  // CHANGED: removed != null check
          _buildSectionHeader('Features & Services'),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: widget.shop.features.map((feature) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: primaryGreen,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        // Description (if available)
        if (widget.shop.description.isNotEmpty) ...[  // CHANGED: removed != null check
          _buildSectionHeader('About This Shop'),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              widget.shop.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],

        // Quick Actions
        _buildSectionHeader('Quick Actions'),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Call action
                  if (widget.shop.phoneNumber.isNotEmpty) {  // CHANGED: removed != null check
                    // Implement phone call
                    _showInfoDialog('Calling ${widget.shop.phoneNumber}');
                  } else {
                    _showInfoDialog('Phone number not available');
                  }
                },
                icon: Icon(Icons.phone),
                label: Text('Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Directions action
                  _showInfoDialog('Opening directions to ${widget.shop.name}');
                },
                icon: Icon(Icons.directions),
                label: Text('Directions'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryGreen,
                  side: BorderSide(color: primaryGreen),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 80), // Bottom padding for floating button
      ],
    ),
  );
}
// Helper methods

Widget _buildInfoRow(IconData icon, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: primaryGreen),
      SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

IconData _getIconForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'vegetables':
      return Icons.eco;
    case 'fruits':
      return Icons.apple;
    case 'equipment':
      return Icons.handyman;
    case 'fertilizers':
      return Icons.local_florist;
    default:
      return Icons.store;
  }
}

String _getRatingText(double rating) {
  if (rating >= 4.5) return 'Excellent';
  if (rating >= 4.0) return 'Very Good';
  if (rating >= 3.5) return 'Good';
  if (rating >= 3.0) return 'Average';
  return 'Below Average';
}

void _showInfoDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Info'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}


  }
  // Replace the broken dispose() method at the end with this:
@override
 @override
  void dispose() {
    tabController.dispose();
    
}
class EnhancedPriceChartPainter extends CustomPainter {
  final List<PricePoint> priceHistory;
  final Offset? hoverPoint;
  final int? hoveredIndex;
  
  EnhancedPriceChartPainter(
    this.priceHistory, {
    this.hoverPoint,
    this.hoveredIndex,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (priceHistory.isEmpty) return;
    
    // Enhanced paint objects with better styling
    final linePaint = Paint()
      ..color = primaryGreen
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final shadowPaint = Paint()
      ..color = primaryGreen.withOpacity(0.2)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);
    
    final dotPaint = Paint()
      ..color = primaryGreen
      ..style = PaintingStyle.fill;
    
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.12)
      ..strokeWidth = 0.5;
    
    final axisPaint = Paint()
      ..color = Colors.grey.withOpacity(0.4)
      ..strokeWidth = 1.2;
    
    // Calculate price range with smart padding
    double minPrice = priceHistory.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    double maxPrice = priceHistory.map((p) => p.price).reduce((a, b) => a > b ? a : b);
    double priceRange = maxPrice - minPrice;
    
    // Adaptive padding based on price range
    double paddingPercent = priceRange == 0 ? 0.2 : 0.15;
    if (priceRange == 0) priceRange = maxPrice * 0.2;
    
    double originalMin = minPrice;
    double originalMax = maxPrice;
    minPrice -= priceRange * paddingPercent;
    maxPrice += priceRange * paddingPercent;
    priceRange = maxPrice - minPrice;
    
    final margin = EdgeInsets.fromLTRB(50, 25, 25, 40);
    final chartArea = Rect.fromLTRB(
      margin.left, 
      margin.top, 
      size.width - margin.right, 
      size.height - margin.bottom,
    );
    
    // Draw background with subtle gradient
    final backgroundGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey.withOpacity(0.02),
          Colors.grey.withOpacity(0.05),
        ],
      ).createShader(chartArea);
    canvas.drawRect(chartArea, backgroundGradient);
    
    // Enhanced grid with better spacing
    _drawEnhancedGrid(canvas, chartArea, minPrice, maxPrice, priceRange, gridPaint, axisPaint);
    
    // Calculate control points for smooth curves
    final controlPoints = <Offset>[];
    for (int i = 0; i < priceHistory.length; i++) {
      final point = priceHistory[i];
      final x = chartArea.left + (chartArea.width * i / (priceHistory.length - 1));
      final y = chartArea.bottom - (chartArea.height * (point.price - minPrice) / priceRange);
      controlPoints.add(Offset(x, y));
    }
    
    if (controlPoints.isNotEmpty) {
      // Create enhanced smooth curves
      final paths = _createSmoothPath(controlPoints, chartArea);
      
      // Draw enhanced gradient area
      _drawGradientArea(canvas, paths['area']!, chartArea);
      
      // Draw line with shadow
      canvas.drawPath(paths['line']!, shadowPaint);
      canvas.drawPath(paths['line']!, linePaint);
      
      // Draw enhanced data points
      _drawEnhancedDataPoints(canvas, controlPoints, originalMin, originalMax);
      
      // Draw hover effects if applicable
      if (hoverPoint != null && hoveredIndex != null) {
        _drawHoverEffects(canvas, controlPoints, hoveredIndex!);
      }
    }
    
    // Add trend indicators
    _drawTrendIndicators(canvas, chartArea, controlPoints);
  }
  
  void _drawEnhancedGrid(Canvas canvas, Rect chartArea, double minPrice, 
                        double maxPrice, double priceRange, Paint gridPaint, Paint axisPaint) {
    // Horizontal grid lines with better labels
    for (int i = 0; i <= 6; i++) {
      double y = chartArea.top + (chartArea.height * i / 6);
      
      // Draw grid line
      canvas.drawLine(
        Offset(chartArea.left, y),
        Offset(chartArea.right, y),
        gridPaint,
      );
      
      // Enhanced Y-axis labels
      double price = maxPrice - (priceRange * i / 6);
      _drawYAxisLabel(canvas, price, y);
    }
    
    // Vertical grid lines with time labels
    for (int i = 0; i <= 6; i++) {
      double x = chartArea.left + (chartArea.width * i / 6);
      canvas.drawLine(
        Offset(x, chartArea.top),
        Offset(x, chartArea.bottom),
        gridPaint,
      );
      
      // Add time labels if we have enough data
      if (priceHistory.length > 6) {
        _drawTimeLabel(canvas, x, chartArea.bottom + 5, i);
      }
    }
    
    // Enhanced axes
    canvas.drawLine(
      Offset(chartArea.left, chartArea.bottom),
      Offset(chartArea.right, chartArea.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(chartArea.left, chartArea.top),
      Offset(chartArea.left, chartArea.bottom),
      axisPaint,
    );
  }
  
  void _drawYAxisLabel(Canvas canvas, double price, double y) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '₹${_formatPrice(price)}',
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Draw with background for better visibility
    final labelBg = Rect.fromLTWH(
      2, y - textPainter.height / 2 - 2,
      textPainter.width + 6, textPainter.height + 4,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelBg, Radius.circular(3)),
      Paint()..color = Colors.white.withOpacity(0.8),
    );
    
    textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
  }
  
  void _drawTimeLabel(Canvas canvas, double x, double y, int index) {
    if (priceHistory.isEmpty) return;
    
    String label = '';
    if (index == 0) {
      label = 'Start';
    } else if (index == 6) label = 'Now';
    else label = '${7 - index}d ago';
    
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y + 5));
  }
  
  Map<String, Path> _createSmoothPath(List<Offset> controlPoints, Rect chartArea) {
    final linePath = Path();
    final areaPath = Path();
    
    if (controlPoints.isEmpty) return {'line': linePath, 'area': areaPath};
    
    linePath.moveTo(controlPoints[0].dx, controlPoints[0].dy);
    areaPath.moveTo(controlPoints[0].dx, chartArea.bottom);
    areaPath.lineTo(controlPoints[0].dx, controlPoints[0].dy);
    
    // Enhanced smooth curve algorithm
    for (int i = 1; i < controlPoints.length; i++) {
      final current = controlPoints[i];
      final previous = controlPoints[i - 1];
      
      if (i == 1) {
        // First segment - gentler curve
        final cp1x = previous.dx + (current.dx - previous.dx) * 0.2;
        final cp1y = previous.dy;
        final cp2x = current.dx - (current.dx - previous.dx) * 0.2;
        final cp2y = current.dy;
        
        linePath.cubicTo(cp1x, cp1y, cp2x, cp2y, current.dx, current.dy);
        areaPath.cubicTo(cp1x, cp1y, cp2x, cp2y, current.dx, current.dy);
      } else if (i == controlPoints.length - 1) {
        // Last segment - gentler curve
        final cp1x = previous.dx + (current.dx - previous.dx) * 0.3;
        final cp1y = previous.dy;
        final cp2x = current.dx - (current.dx - previous.dx) * 0.2;
        final cp2y = current.dy;
        
        linePath.cubicTo(cp1x, cp1y, cp2x, cp2y, current.dx, current.dy);
        areaPath.cubicTo(cp1x, cp1y, cp2x, cp2y, current.dx, current.dy);
      } else {
        // Middle segments - smooth curves
        final next = controlPoints[i + 1];
        final cp1x = previous.dx + (current.dx - previous.dx) * 0.25;
        final cp1y = previous.dy + (current.dy - previous.dy) * 0.25;
        final cp2x = current.dx - (next.dx - previous.dx) * 0.15;
        final cp2y = current.dy - (next.dy - previous.dy) * 0.15;
        
        linePath.cubicTo(cp1x, cp1y, cp2x, cp2y, current.dx, current.dy);
        areaPath.cubicTo(cp1x, cp1y, cp2x, cp2y, current.dx, current.dy);
      }
    }
    
    // Complete area path
    areaPath.lineTo(controlPoints.last.dx, chartArea.bottom);
    areaPath.lineTo(controlPoints.first.dx, chartArea.bottom);
    areaPath.close();
    
    return {'line': linePath, 'area': areaPath};
  }
  
  void _drawGradientArea(Canvas canvas, Path areaPath, Rect chartArea) {
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryGreen.withOpacity(0.3),
          primaryGreen.withOpacity(0.15),
          primaryGreen.withOpacity(0.05),
          primaryGreen.withOpacity(0.0),
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ).createShader(chartArea);
    
    canvas.drawPath(areaPath, gradientPaint);
  }
  
  void _drawEnhancedDataPoints(Canvas canvas, List<Offset> controlPoints, 
                              double originalMin, double originalMax) {
    for (int i = 0; i < controlPoints.length; i++) {
      final point = controlPoints[i];
      final price = priceHistory[i].price;
      
      // Determine point importance
      bool isKeyPoint = _isKeyPoint(i, price, originalMin, originalMax);
      bool isHovered = hoveredIndex == i;
      
      // Draw glow effect for key points or hovered points
      if (isKeyPoint || isHovered) {
        final glowPaint = Paint()
          ..color = primaryGreen.withOpacity(isHovered ? 0.4 : 0.25)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, isHovered ? 6 : 4);
        
        canvas.drawCircle(point, isHovered ? 12.0 : 10.0, glowPaint);
      }
      
      // Draw point layers
      double outerRadius = isKeyPoint ? 7.0 : 5.5;
      double innerRadius = isKeyPoint ? 5.0 : 3.5;
      
      if (isHovered) {
        outerRadius += 2.0;
        innerRadius += 1.5;
      }
      
      // Outer circle (white background)
      canvas.drawCircle(
        point,
        outerRadius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..color = primaryGreen.withOpacity(0.3),
      );
      
      canvas.drawCircle(
        point,
        outerRadius,
        Paint()..color = Colors.white..style = PaintingStyle.fill,
      );
      
      // Inner circle (colored)
      canvas.drawCircle(
        point, 
        innerRadius, 
        Paint()
          ..color = _getPointColor(price, originalMin, originalMax)
          ..style = PaintingStyle.fill,
      );
      
      // Draw labels for key points
      if (isKeyPoint || isHovered) {
        _drawPointLabel(canvas, point, price, isHovered);
      }
    }
  }
  
  void _drawHoverEffects(Canvas canvas, List<Offset> controlPoints, int hoveredIndex) {
    if (hoveredIndex < 0 || hoveredIndex >= controlPoints.length) return;
    
    final point = controlPoints[hoveredIndex];
    final price = priceHistory[hoveredIndex].price;
    
    // Draw vertical line to x-axis
    canvas.drawLine(
      Offset(point.dx, point.dy),
      Offset(point.dx, controlPoints.last.dy + 30),
      Paint()
        ..color = primaryGreen.withOpacity(0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    
    // Enhanced hover label
    _drawHoverLabel(canvas, point, price);
  }
  
  void _drawHoverLabel(Canvas canvas, Offset point, double price) {
    final labelText = '₹${_formatPrice(price)}';
    TextPainter labelPainter = TextPainter(
      text: TextSpan(
        text: labelText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    
    // Position label
    double labelY = point.dy - 35;
    final labelRect = Rect.fromCenter(
      center: Offset(point.dx, labelY),
      width: labelPainter.width + 16,
      height: labelPainter.height + 10,
    );
    
    // Draw enhanced background
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, Radius.circular(8)),
      Paint()
        ..color = primaryGreen
        ..style = PaintingStyle.fill,
    );
    
    // Draw shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        labelRect.translate(0, 2), 
        Radius.circular(8),
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3),
    );
    
    labelPainter.paint(
      canvas, 
      Offset(
        point.dx - labelPainter.width / 2, 
        labelY - labelPainter.height / 2,
      ),
    );
  }
  
  void _drawTrendIndicators(Canvas canvas, Rect chartArea, List<Offset> controlPoints) {
    if (controlPoints.length < 2) return;
    
    final firstPoint = controlPoints.first;
    final lastPoint = controlPoints.last;
    final isUpTrend = lastPoint.dy < firstPoint.dy;
    
    // Draw trend arrow
    final arrowPaint = Paint()
      ..color = isUpTrend ? Colors.green : Colors.red
      ..style = PaintingStyle.fill;
    
    final arrowPath = Path();
    final arrowSize = 8.0;
    final arrowX = chartArea.right - 15;
    final arrowY = chartArea.top + 15;
    
    if (isUpTrend) {
      arrowPath.moveTo(arrowX, arrowY + arrowSize);
      arrowPath.lineTo(arrowX + arrowSize, arrowY + arrowSize);
      arrowPath.lineTo(arrowX + arrowSize / 2, arrowY);
      arrowPath.close();
    } else {
      arrowPath.moveTo(arrowX, arrowY);
      arrowPath.lineTo(arrowX + arrowSize, arrowY);
      arrowPath.lineTo(arrowX + arrowSize / 2, arrowY + arrowSize);
      arrowPath.close();
    }
    
    canvas.drawPath(arrowPath, arrowPaint);
  }
  
  void _drawPointLabel(Canvas canvas, Offset point, double price, bool isHovered) {
    final labelText = '₹${_formatPrice(price)}';
    TextPainter labelPainter = TextPainter(
      text: TextSpan(
        text: labelText,
        style: TextStyle(
          color: primaryGreen,
          fontSize: isHovered ? 12 : 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    
    double labelY = point.dy - (isHovered ? 30 : 25);
    final labelRect = Rect.fromCenter(
      center: Offset(point.dx, labelY),
      width: labelPainter.width + 8,
      height: labelPainter.height + 4,
    );
    
    // Enhanced background
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, Radius.circular(6)),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, Radius.circular(6)),
      Paint()
        ..color = primaryGreen.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    
    labelPainter.paint(
      canvas, 
      Offset(
        point.dx - labelPainter.width / 2, 
        labelY - labelPainter.height / 2,
      ),
    );
  }
  
  bool _isKeyPoint(int index, double price, double minPrice, double maxPrice) {
    return index == 0 || 
           index == priceHistory.length - 1 || 
           price == minPrice || 
           price == maxPrice;
  }
  
  Color _getPointColor(double price, double minPrice, double maxPrice) {
    if (price == minPrice) return Colors.green;
    if (price == maxPrice) return Colors.red;
    return primaryGreen;
  }
  
  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}k';
    }
    return price.toInt().toString();
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

// Enhanced wrapper widget for interactivity
class InteractivePriceChart extends StatefulWidget {
  final List<PricePoint> priceHistory;
  final double height;
  
  const InteractivePriceChart({
    super.key,
    required this.priceHistory,
    this.height = 250,
  });
  
  @override
  _InteractivePriceChartState createState() => _InteractivePriceChartState();
}

class _InteractivePriceChartState extends State<InteractivePriceChart> {
  Offset? hoverPoint;
  int? hoveredIndex;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: MouseRegion(
        onHover: (event) {
          setState(() {
            hoverPoint = event.localPosition;
            hoveredIndex = _calculateHoveredIndex(event.localPosition);
          });
        },
        onExit: (event) {
          setState(() {
            hoverPoint = null;
            hoveredIndex = null;
          });
        },
        child: CustomPaint(
          painter: EnhancedPriceChartPainter(
            widget.priceHistory,
            hoverPoint: hoverPoint,
            hoveredIndex: hoveredIndex,
          ),
          size: Size.infinite,
          child: Container(),
        ),
      ),
    );
  }
  
  int? _calculateHoveredIndex(Offset localPosition) {
    if (widget.priceHistory.isEmpty) return null;
    
    final margin = EdgeInsets.fromLTRB(50, 25, 25, 40);
    final chartWidth = widget.height * 2 - margin.left - margin.right; // Approximate
    final relativeX = localPosition.dx - margin.left;
    
    if (relativeX < 0 || relativeX > chartWidth) return null;
    
    final index = (relativeX / chartWidth * (widget.priceHistory.length - 1)).round();
    return index.clamp(0, widget.priceHistory.length - 1);
  }
}