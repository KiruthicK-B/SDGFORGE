import 'package:flutter/material.dart';
import 'dart:math' as math;

class PriceTrends extends StatefulWidget {
  const PriceTrends({super.key});

  @override
  _PriceTrendsState createState() => _PriceTrendsState();
}

class _PriceTrendsState extends State<PriceTrends> with TickerProviderStateMixin {
  String? selectedCategory;
  String? selectedProduct;
  bool isSidebarExpanded = true;
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late AnimationController _slideUpController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideUpAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideUpController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideUpAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideUpController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
    _fadeController.forward();
    _slideUpController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    _slideUpController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      isSidebarExpanded = !isSidebarExpanded;
      if (isSidebarExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  // Enhanced linear regression with confidence calculation
  Map<String, double> _predictNextPrice(List<double> priceHistory) {
    if (priceHistory.length < 2) {
      return {
      'prediction': priceHistory.last,
      'confidence': 0.5,
      'volatility': 0.0
    };
    }
    
    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    int n = priceHistory.length;
    
    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += priceHistory[i];
      sumXY += i * priceHistory[i];
      sumXX += i * i;
    }
    
    double slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    double intercept = (sumY - slope * sumX) / n;
    double prediction = slope * n + intercept;
    
    // Calculate volatility
    double avgPrice = sumY / n;
    double volatility = 0;
    for (int i = 0; i < n; i++) {
      volatility += math.pow(priceHistory[i] - avgPrice, 2);
    }
    volatility = math.sqrt(volatility / n) / avgPrice;
    
    // Calculate confidence (inverse of volatility)
    double confidence = math.max(0.1, 1 - volatility);
    
    return {
      'prediction': prediction,
      'confidence': confidence,
      'volatility': volatility
    };
  }

  // Calculate price insights
  Map<String, dynamic> _calculateInsights(ProductData product) {
    final prices = product.priceHistory;
    final avgPrice = prices.reduce((a, b) => a + b) / prices.length;
    final maxPrice = prices.reduce(math.max);
    final minPrice = prices.reduce(math.min);
    
    String trend = "Stable";
    if (product.changePercentage > 5) trend = "Rising";
    if (product.changePercentage < -5) trend = "Falling";
    
    String recommendation = "Hold";
    if (product.changePercentage > 10) recommendation = "Sell";
    if (product.changePercentage < -10) recommendation = "Buy";
    
    return {
      'avgPrice': avgPrice,
      'maxPrice': maxPrice,
      'minPrice': minPrice,
      'trend': trend,
      'recommendation': recommendation,
      'seasonality': _getSeasonality(product.name),
    };
  }

  String _getSeasonality(String productName) {
    final seasonal = {
      'Tomato': 'Peak: Nov-Feb',
      'Mango': 'Peak: Apr-Jun',
      'Apple': 'Peak: Oct-Dec',
      'Rice': 'Year-round',
      'Potato': 'Peak: Jan-Mar',
      'Spinach': 'Peak: Oct-Mar',
    };
    return seasonal[productName] ?? 'Year-round';
  }

  final Map<String, List<ProductData>> categoryProducts = {
    'Vegetables': [
      ProductData('Tomato', '🍅', 35.00, 28.50, 22.8, true, [25, 28, 32, 35, 38, 35]),
      ProductData('Cucumber', '🥒', 18.50, 20.30, -8.9, false, [22, 21, 20, 19, 18, 18]),
      ProductData('Brinjal', '🍆', 24.80, 22.40, 10.7, true, [20, 21, 22, 23, 24, 25]),
      ProductData('Capsicum', '🫑', 45.60, 42.80, 6.5, true, [40, 41, 42, 44, 45, 46]),
      ProductData('Okra', '🌶️', 32.70, 35.20, -7.1, false, [38, 36, 35, 34, 32, 33]),
      ProductData('Pumpkin', '🎃', 15.90, 17.50, -9.1, false, [19, 18, 17, 16, 15, 16]),
    ],
    'Fruits': [
      ProductData('Mango', '🥭', 85.60, 92.40, -7.4, false, [95, 92, 88, 85, 82, 86]),
      ProductData('Banana', '🍌', 45.80, 48.20, -5.0, false, [50, 49, 48, 46, 45, 46]),
      ProductData('Apple', '🍎', 120.00, 115.50, 3.9, true, [110, 112, 115, 118, 120, 122]),
      ProductData('Orange', '🍊', 65.40, 62.30, 5.0, true, [60, 61, 62, 64, 65, 66]),
      ProductData('Guava', '🍃', 38.90, 35.60, 9.3, true, [32, 33, 35, 37, 38, 39]),
      ProductData('Papaya', '🧡', 28.40, 31.20, -9.0, false, [34, 32, 31, 29, 28, 29]),
    ],
    'Grains': [
      ProductData('Rice', '🌾', 45.50, 42.30, 7.6, true, [40, 41, 42, 44, 45, 46]),
      ProductData('Wheat', '🌾', 28.75, 30.20, -4.8, false, [32, 31, 30, 29, 28, 29]),
      ProductData('Maize', '🌽', 22.40, 20.80, 7.7, true, [18, 19, 20, 21, 22, 23]),
      ProductData('Barley', '🌾', 35.60, 33.20, 7.2, true, [30, 31, 33, 35, 36, 36]),
      ProductData('Millet', '🌾', 42.80, 38.90, 10.0, true, [35, 36, 38, 41, 42, 43]),
    ],
    'Nuts': [
      ProductData('Almond', '🔸', 650.00, 620.50, 4.8, true, [600, 610, 620, 635, 650, 660]),
      ProductData('Cashew', '🥜', 780.00, 750.20, 4.0, true, [730, 740, 750, 765, 780, 785]),
      ProductData('Walnut', '🌰', 890.50, 920.30, -3.2, false, [950, 930, 920, 900, 890, 895]),
      ProductData('Pistachio', '🟢', 1200.00, 1150.80, 4.3, true, [1100, 1120, 1150, 1180, 1200, 1210]),
      ProductData('Peanut', '🥜', 85.60, 82.40, 3.9, true, [78, 80, 82, 84, 85, 86]),
    ],
    'Leafy Greens': [
      ProductData('Spinach', '🥬', 28.40, 25.60, 10.9, true, [23, 24, 25, 27, 28, 29]),
      ProductData('Lettuce', '🥬', 45.80, 42.30, 8.3, true, [38, 40, 42, 44, 45, 46]),
      ProductData('Amaranth', '🍃', 32.70, 35.90, -8.9, false, [38, 36, 35, 34, 32, 33]),
      ProductData('Cabbage', '🥬', 18.90, 21.40, -11.7, false, [24, 22, 21, 20, 18, 19]),
      ProductData('Kale', '🥬', 52.30, 48.70, 7.4, true, [45, 46, 48, 50, 52, 53]),
    ],
    'Pulses': [
      ProductData('Green Gram', '🟢', 92.80, 89.30, 3.9, true, [87, 88, 89, 91, 92, 93]),
      ProductData('Black Gram', '⚫', 105.20, 98.50, 6.8, true, [95, 97, 98, 102, 105, 107]),
      ProductData('Chickpea', '🫛', 78.90, 82.10, -3.9, false, [85, 83, 82, 80, 78, 79]),
      ProductData('Pigeon Pea', '🟡', 95.60, 88.40, 8.1, true, [82, 85, 88, 92, 95, 96]),
      ProductData('Lentil', '🔴', 110.50, 105.20, 5.0, true, [98, 102, 105, 108, 110, 112]),
    ],
    'Roots & Tubers': [
      ProductData('Potato', '🥔', 18.20, 16.90, 7.7, true, [15, 16, 17, 18, 19, 18]),
      ProductData('Sweet Potato', '🍠', 24.60, 27.30, -9.9, false, [29, 28, 27, 26, 24, 25]),
      ProductData('Yam', '🍠', 35.80, 32.40, 10.5, true, [30, 31, 32, 34, 35, 36]),
      ProductData('Carrot', '🥕', 25.50, 24.00, 6.3, true, [22, 23, 24, 25, 26, 25]),
      ProductData('Beetroot', '🟣', 32.40, 29.70, 9.1, true, [27, 28, 29, 31, 32, 33]),
      ProductData('Radish', '⚪', 15.80, 18.20, -13.2, false, [20, 19, 18, 17, 15, 16]),
    ],
    'Seeds': [
      ProductData('Sunflower', '🌻', 68.90, 65.20, 5.7, true, [62, 63, 65, 67, 68, 69]),
      ProductData('Sesame', '⚪', 125.60, 118.40, 6.1, true, [115, 116, 118, 122, 125, 127]),
      ProductData('Mustard', '🟡', 85.30, 88.70, -3.8, false, [92, 90, 88, 86, 85, 86]),
      ProductData('Flax', '🤎', 95.80, 89.20, 7.4, true, [85, 87, 89, 92, 95, 96]),
      ProductData('Chia', '⚫', 780.00, 745.50, 4.6, true, [720, 735, 745, 765, 780, 785]),
    ],
    'Spices': [
      ProductData('Black Pepper', '⚫', 450.00, 425.80, 5.7, true, [410, 415, 425, 440, 450, 455]),
      ProductData('Turmeric', '🟡', 185.60, 172.30, 7.7, true, [165, 168, 172, 180, 185, 188]),
      ProductData('Ginger', '🟤', 95.40, 102.70, -7.1, false, [108, 105, 102, 98, 95, 97]),
      ProductData('Cardamom', '🟢', 1250.00, 1180.50, 5.9, true, [1150, 1165, 1180, 1220, 1250, 1260]),
      ProductData('Cumin', '🤎', 385.70, 368.20, 4.8, true, [355, 360, 368, 378, 385, 390]),
      ProductData('Coriander', '🟤', 125.80, 132.40, -5.0, false, [138, 135, 132, 128, 125, 127]),
    ],
    'Herbs': [
      ProductData('Basil', '🌿', 45.60, 42.80, 6.5, true, [40, 41, 42, 44, 45, 46]),
      ProductData('Mint', '🌿', 38.90, 35.20, 10.5, true, [32, 33, 35, 37, 38, 39]),
      ProductData('Coriander Leaves', '🌿', 28.70, 31.50, -8.9, false, [34, 32, 31, 30, 28, 29]),
      ProductData('Lemongrass', '🌿', 52.80, 48.60, 8.6, true, [45, 46, 48, 51, 52, 53]),
      ProductData('Oregano', '🌿', 185.40, 172.80, 7.3, true, [168, 170, 172, 178, 185, 188]),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FFFE),
              Color(0xFFE8F5F3),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main Content Area
            selectedCategory == null 
                ? _buildWelcomeScreen()
                : selectedProduct == null
                    ? _buildProductList()
                    : _buildPriceTrends(),
            
            // Enhanced Floating Sidebar
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Positioned(
                  left: isSidebarExpanded ? 0 : -300,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 280,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xFF0A9D88),
                          Color(0xFF087F6A),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(8, 0),
                        ),
                      ],
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Enhanced Header
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF0EA5E9),
                                Color(0xFF0A9D88),
                              ],
                            ),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.analytics,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        "Market Categories",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _toggleSidebar,
                                      icon: const Icon(
                                        Icons.chevron_left,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${categoryProducts.keys.length} categories available",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Categories List with enhanced styling
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            itemCount: categoryProducts.keys.length,
                            itemBuilder: (context, index) {
                              final category = categoryProducts.keys.elementAt(index);
                              return _buildEnhancedCategoryCard(category, _getCategoryEmoji(category), index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Enhanced Floating Toggle Button
            if (!isSidebarExpanded)
              Positioned(
                left: 20,
                top: MediaQuery.of(context).size.height * 0.4,
                child: GestureDetector(
                  onTap: _toggleSidebar,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0EA5E9),
                          Color(0xFF0A9D88),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedCategoryCard(String category, String emoji, int index) {
    final isSelected = selectedCategory == category;
    final productCount = categoryProducts[category]!.length;
    
    return AnimatedBuilder(
      animation: _slideUpAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideUpAnimation.value * (index + 1) * 10),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (selectedCategory == category) {
                        selectedCategory = null;
                        selectedProduct = null;
                      } else {
                        selectedCategory = category;
                        selectedProduct = null;
                      }
                      _toggleSidebar();
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.25)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? Colors.white.withOpacity(0.4)
                            : Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "$productCount varieties",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.expand_less : Icons.chevron_right,
                              color: Colors.white70,
                              size: 20,
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

  Widget _buildWelcomeScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Enhanced welcome graphic
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0EA5E9),
                      Color(0xFF0A9D88),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0A9D88).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.trending_up,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Agricultural Market Insights",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Real-time price tracking, trend analysis,\nand smart predictions for agricultural commodities",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Feature highlights
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildFeatureChip("📈", "Live Prices"),
                  _buildFeatureChip("🔮", "AI Predictions"),
                  _buildFeatureChip("📊", "Trend Analysis"),
                  _buildFeatureChip("🌍", "Market Insights"),
                ],
              ),
              
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF0A9D88)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0A9D88).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Select a category to get started",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    final products = categoryProducts[selectedCategory]!;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0EA5E9),
                  Color(0xFF0A9D88),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              selectedCategory = null;
                            });
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getCategoryEmoji(selectedCategory!),
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedCategory!,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "${products.length} varieties • Fresh market data",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Quick stats
                    Row(
                      children: [
                        _buildQuickStat("Avg Price", "₹${_getAveragePrice(products).toStringAsFixed(0)}", Icons.analytics),
                        const SizedBox(width: 16),
                        _buildQuickStat("Top Performer", _getTopPerformer(products), Icons.trending_up),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Enhanced Product Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _slideUpAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideUpAnimation.value * (index + 1) * 20),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildEnhancedProductCard(products[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getAveragePrice(List<ProductData> products) {
    return products.map((p) => p.currentPrice).reduce((a, b) => a + b) / products.length;
  }

  String _getTopPerformer(List<ProductData> products) {
    final sorted = [...products]..sort((a, b) => b.changePercentage.compareTo(a.changePercentage));
    return sorted.first.name;
  }

  Widget _buildEnhancedProductCard(ProductData product) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedProduct = product.name;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Product icon with background
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0A9D88).withOpacity(0.1),
                        const Color(0xFF0EA5E9).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      product.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Product name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                // Current price
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF0A9D88)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "₹${product.currentPrice.toStringAsFixed(2)}/kg",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Change indicator with enhanced styling
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: (product.isIncreasing ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (product.isIncreasing ? Colors.green : Colors.red).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        product.isIncreasing ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color: product.isIncreasing ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${product.changePercentage.abs().toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: product.isIncreasing ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceTrends() {
    final product = categoryProducts[selectedCategory]!
        .firstWhere((p) => p.name == selectedProduct);
    
    final predictionData = _predictNextPrice(product.priceHistory);
    final insights = _calculateInsights(product);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Enhanced Product Header
            // Enhanced Product Header - Responsive
Container(
  width: double.infinity,
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0EA5E9),
        Color(0xFF0A9D88),
      ],
    ),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(30),
      bottomRight: Radius.circular(30),
    ),
  ),
  child: SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        final isMediumScreen = constraints.maxWidth < 600;
        
        return Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          child: Column(
            children: [
              // Responsive layout based on screen size
              if (isSmallScreen)
                // Vertical layout for small screens
                Column(
                  children: [
                    // Back button row
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              selectedProduct = null;
                            });
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_back, 
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Product info centered
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            product.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "₹${product.currentPrice.toStringAsFixed(2)}/kg",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          insights['trend'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            insights['seasonality'],
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                // Horizontal layout for medium and large screens
                Row(
                  children: [
                    // Back button
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedProduct = null;
                        });
                      },
                      icon: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back, 
                          color: Colors.white,
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                    ),
                    SizedBox(width: isMediumScreen ? 12 : 16),
                    // Product emoji
                    Container(
                      padding: EdgeInsets.all(isMediumScreen ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(isMediumScreen ? 16 : 20),
                      ),
                      child: Text(
                        product.emoji,
                        style: TextStyle(
                          fontSize: isMediumScreen ? 32 : 40,
                        ),
                      ),
                    ),
                    SizedBox(width: isMediumScreen ? 12 : 16),
                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product name - responsive font size
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              product.name,
                              style: TextStyle(
                                fontSize: isMediumScreen ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Price and trend - wrap to prevent overflow
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                "₹${product.currentPrice.toStringAsFixed(2)}/kg",
                                style: TextStyle(
                                  fontSize: isMediumScreen ? 14 : 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "• ${insights['trend']}",
                                style: TextStyle(
                                  fontSize: isMediumScreen ? 14 : 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Seasonality badge
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                insights['seasonality'],
                                style: TextStyle(
                                  fontSize: isMediumScreen ? 10 : 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
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
        );
      },
    ),
  ),
),
            
            const SizedBox(height: 24),
            
            // Enhanced Price Cards with animations
          // Enhanced Price Cards with animations
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 15),
  child: SizedBox(
    height: 96, // Reduced height to prevent overflow
    child: Row(
      children: [
        Expanded(
          child: _buildEnhancedPriceCard(
            "Current",
            "₹${product.currentPrice.toStringAsFixed(0)}",
            Icons.currency_rupee,
            const Color(0xFF0A9D88),
            "",
          ),
        ),
        const SizedBox(width: 5), // Reduced spacing
        Expanded(
          child: _buildEnhancedPriceCard(
            "Previous",
            "₹${product.previousPrice.toStringAsFixed(0)}",
            Icons.history,
            const Color(0xFF6B7280),
            "",
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildEnhancedPriceCard(
            "Change",
            "${product.changePercentage.toStringAsFixed(0)}%",
            product.isIncreasing ? Icons.trending_up : Icons.trending_down,
            product.isIncreasing ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            "",
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildEnhancedPriceCard(
            "Predicted",
            "₹${predictionData['prediction']!.toStringAsFixed(0)}",
            Icons.psychology,
            const Color(0xFF8B5CF6),
            "",
          ),
        ),
      ],
    ),
  ),
),

            
            const SizedBox(height: 19),
            
            // Enhanced Price Chart
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation:0 ,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0EA5E9), Color(0xFF0A9D88)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.show_chart,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Price Trend & Prediction",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "6-week historical data",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 250,
                          child: _buildEnhancedLineChart(product.priceHistory, predictionData['prediction']!),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Market Insights Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        const Color(0xFF0A9D88).withOpacity(0.02),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.insights,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Market Insights",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Insights Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildInsightCard(
                                "Price Range",
                                "₹${insights['minPrice'].toStringAsFixed(0)} - ₹${insights['maxPrice'].toStringAsFixed(0)}",
                                Icons.straighten,
                                const Color(0xFF3B82F6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInsightCard(
                                "Average",
                                "₹${insights['avgPrice'].toStringAsFixed(2)}",
                                Icons.analytics,
                                const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildInsightCard(
                                "Volatility",
                                "${(predictionData['volatility']! * 100).toStringAsFixed(1)}%",
                                Icons.show_chart,
                                const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInsightCard(
                                "Recommendation",
                                insights['recommendation'],
                                _getRecommendationIcon(insights['recommendation']),
                                _getRecommendationColor(insights['recommendation']),
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
            
            const SizedBox(height: 16),
            
            // Price Analysis Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        const Color(0xFF8B5CF6).withOpacity(0.02),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.timeline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Price Analysis",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        _buildAnalysisItem(
                          "Market Trend",
                          insights['trend'],
                          _getTrendDescription(insights['trend']),
                          _getTrendIcon(insights['trend']),
                          _getTrendColor(insights['trend']),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildAnalysisItem(
                          "Price Prediction",
                          "₹${predictionData['prediction']!.toStringAsFixed(2)}/kg",
                          "Based on ${product.priceHistory.length} weeks of data using linear regression",
                          Icons.psychology,
                          const Color(0xFF8B5CF6),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildAnalysisItem(
                          "Market Confidence",
                          "${(predictionData['confidence']! * 100).toInt()}%",
                          predictionData['confidence']! > 0.7 
                              ? "High confidence in prediction accuracy"
                              : predictionData['confidence']! > 0.4
                                  ? "Moderate confidence, market shows some volatility"
                                  : "Low confidence, highly volatile market",
                          Icons.verified,
                          predictionData['confidence']! > 0.7 
                              ? const Color(0xFF10B981)
                              : predictionData['confidence']! > 0.4
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Trading Suggestions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        const Color(0xFF10B981).withOpacity(0.02),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.lightbulb,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Trading Suggestions",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        _buildSuggestionItem(
                          "Investment Strategy",
                          insights['recommendation'],
                          _getRecommendationDescription(insights['recommendation'], product),
                          _getRecommendationIcon(insights['recommendation']),
                          _getRecommendationColor(insights['recommendation']),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildSuggestionItem(
                          "Best Trading Time",
                          "Morning Hours",
                          "Agricultural markets typically see best prices between 6 AM - 10 AM",
                          Icons.schedule,
                          const Color(0xFF3B82F6),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildSuggestionItem(
                          "Risk Assessment",
                          predictionData['volatility']! > 0.15 ? "High Risk" : predictionData['volatility']! > 0.08 ? "Medium Risk" : "Low Risk",
                          predictionData['volatility']! > 0.15 
                              ? "Price swings are frequent and significant"
                              : predictionData['volatility']! > 0.08
                                  ? "Moderate price fluctuations expected"
                                  : "Stable price movements with minimal risk",
                          Icons.shield,
                          predictionData['volatility']! > 0.15 
                              ? const Color(0xFFEF4444)
                              : predictionData['volatility']! > 0.08
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Historical Performance
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        const Color(0xFF3B82F6).withOpacity(0.02),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.history,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Historical Performance",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Weekly breakdown
                        Column(
                          children: List.generate(product.priceHistory.length, (index) {
                            final weekPrice = product.priceHistory[index];
                            final weekChange = index > 0 
                                ? ((weekPrice - product.priceHistory[index - 1]) / product.priceHistory[index - 1] * 100)
                                : 0.0;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF0A9D88).withOpacity(0.8),
                                          const Color(0xFF0EA5E9).withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "W${index + 1}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "₹${weekPrice.toStringAsFixed(2)}/kg",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        if (index > 0)
                                          Text(
                                            "${weekChange > 0 ? '+' : ''}${weekChange.toStringAsFixed(1)}% from previous week",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: weekChange > 0 ? Colors.green : weekChange < 0 ? Colors.red : Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (index > 0)
                                    Icon(
                                      weekChange > 0 ? Icons.trending_up : weekChange < 0 ? Icons.trending_down : Icons.trending_flat,
                                      color: weekChange > 0 ? Colors.green : weekChange < 0 ? Colors.red : Colors.grey,
                                      size: 20,
                                    ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Market Comparison
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        const Color(0xFFEF4444).withOpacity(0.02),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.compare_arrows,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Category Comparison",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Show top 3 products from same category
                        Column(
                          children: _getTopProductsInCategory(selectedCategory!).map((compProduct) {
                            final isCurrentProduct = compProduct.name == product.name;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isCurrentProduct 
                                    ? const Color(0xFF0A9D88).withOpacity(0.1)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCurrentProduct 
                                      ? const Color(0xFF0A9D88).withOpacity(0.3)
                                      : Colors.grey.shade200,
                                  width: isCurrentProduct ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(compProduct.emoji, style: const TextStyle(fontSize: 24)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              compProduct.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isCurrentProduct ? FontWeight.bold : FontWeight.w600,
                                                color: isCurrentProduct ? const Color(0xFF0A9D88) : const Color(0xFF1F2937),
                                              ),
                                            ),
                                            if (isCurrentProduct) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF0A9D88),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Text(
                                                  "CURRENT",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "₹${compProduct.currentPrice.toStringAsFixed(2)}/kg",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (compProduct.isIncreasing ? Colors.green : Colors.red).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          compProduct.isIncreasing ? Icons.arrow_upward : Icons.arrow_downward,
                                          size: 14,
                                          color: compProduct.isIncreasing ? Colors.green : Colors.red,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          "${compProduct.changePercentage.abs().toStringAsFixed(1)}%",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: compProduct.isIncreasing ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<ProductData> _getTopProductsInCategory(String category) {
    final products = categoryProducts[category]!;
    final sorted = [...products]..sort((a, b) => b.changePercentage.compareTo(a.changePercentage));
    return sorted.take(3).toList();
  }

  Widget _buildEnhancedPriceCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 6,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String title, String value, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String title, String value, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedLineChart(List<double> data, double predictedPrice) {
    final allData = [...data, predictedPrice];
    final maxValue = allData.reduce((a, b) => a > b ? a : b);
    final minValue = allData.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
    final padding = range * 0.1;
    final adjustedMax = maxValue + padding;
    final adjustedMin = minValue - padding;
    final adjustedRange = adjustedMax - adjustedMin;
    
    return CustomPaint(
      size: Size.infinite,
      painter: EnhancedLineChartPainter(
        data: data,
        predictedPrice: predictedPrice,
        maxValue: adjustedMax,
        minValue: adjustedMin,
        range: adjustedRange,
      ),
    );
  }

  // Helper methods for insights
  String _getTrendDescription(String trend) {
    switch (trend) {
      case "Rising":
        return "Prices are consistently increasing over time";
      case "Falling":
        return "Prices are showing a downward trend";
      default:
        return "Prices are relatively stable with minor fluctuations";
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case "Rising":
        return Icons.trending_up;
      case "Falling":
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case "Rising":
        return const Color(0xFF10B981);
      case "Falling":
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getRecommendationDescription(String recommendation, ProductData product) {
    switch (recommendation) {
      case "Buy":
        return "Prices are low, good time to purchase for inventory";
      case "Sell":
        return "Prices are high, consider selling current stock";
      default:
        return "Market is stable, maintain current position";
    }
  }

  IconData _getRecommendationIcon(String recommendation) {
    switch (recommendation) {
      case "Buy":
        return Icons.shopping_cart;
      case "Sell":
        return Icons.sell;
      default:
        return Icons.pause;
    }
  }

  Color _getRecommendationColor(String recommendation) {
    switch (recommendation) {
      case "Buy":
        return const Color(0xFF10B981);
      case "Sell":
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'Vegetables':
        return '🥬';
      case 'Fruits':
        return '🍎';
      case 'Grains':
        return '🌾';
      case 'Nuts':
        return '🥜';
      case 'Leafy Greens':
        return '🥬';
      case 'Pulses':
        return '🫘';
      case 'Roots & Tubers':
        return '🥔';
      case 'Seeds':
        return '🌻';
      case 'Spices':
        return '🌶️';
      case 'Herbs':
        return '🌿';
      default:
        return '🌱';
    }
  }
}

class EnhancedLineChartPainter extends CustomPainter {
  final List<double> data;
  final double predictedPrice;
  final double maxValue;
  final double minValue;
  final double range;

  EnhancedLineChartPainter({
    required this.data,
    required this.predictedPrice,
    required this.maxValue,
    required this.minValue,
    required this.range,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Enhanced styling
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0EA5E9), Color(0xFF0A9D88)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final predictedPaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashedPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withOpacity(0.6)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0EA5E9), Color(0xFF0A9D88)],
      ).createShader(const Rect.fromLTWH(0, 0, 20, 20))
      ..style = PaintingStyle.fill;

    final predictedPointPaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1.0;

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0A9D88).withOpacity(0.2),
          const Color(0xFF0A9D88).withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Draw grid lines with labels
    for (int i = 0; i <= 4; i++) {
      final y = (size.height - 80) * i / 4 + 30;
      canvas.drawLine(
        Offset(50, y),
        Offset(size.width - 20, y),
        gridPaint,
      );
    }

    // Vertical grid lines
    for (int i = 0; i <= data.length; i++) {
      final x = 50 + (size.width - 90) * i / data.length;
      canvas.drawLine(
        Offset(x, 30),
        Offset(x, size.height - 50),
        gridPaint,
      );
    }

    final path = Path();
    final areaPath = Path();
    final points = <Offset>[];
    
    // Calculate points for historical data
    for (int i = 0; i < data.length; i++) {
      final x = 50 + (size.width - 90) * i / (data.length - 1);
      final y = size.height - 50 - ((data[i] - minValue) / range) * (size.height - 100);
      points.add(Offset(x, y));
      
      if (i == 0) {
        path.moveTo(x, y);
        areaPath.moveTo(x, size.height - 50);
        areaPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        areaPath.lineTo(x, y);
      }
    }

    // Complete area path
    if (points.isNotEmpty) {
      areaPath.lineTo(points.last.dx, size.height - 50);
      areaPath.close();
    }

    // Draw area under curve
    canvas.drawPath(areaPath, areaPaint);

    // Draw historical line with gradient
    canvas.drawPath(path, gradientPaint);

    // Draw historical points with enhanced styling
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      // Outer glow
      canvas.drawCircle(point, 8, Paint()
        ..color = const Color(0xFF0A9D88).withOpacity(0.3)
        ..style = PaintingStyle.fill);
      // Main point
      canvas.drawCircle(point, 5, pointPaint);
      // White border
      canvas.drawCircle(point, 5, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
    }

    // Calculate predicted point position
    final predictedX = 50 + (size.width - 90) * (data.length) / (data.length - 1);
    final predictedY = size.height - 50 - ((predictedPrice - minValue) / range) * (size.height - 100);
    final predictedPoint = Offset(predictedX, predictedY);

    // Draw dashed line to prediction
    if (points.isNotEmpty) {
      _drawEnhancedDashedLine(canvas, points.last, predictedPoint, dashedPaint);
    }

    // Draw predicted point with glow effect
    canvas.drawCircle(predictedPoint, 10, Paint()
      ..color = const Color(0xFF8B5CF6).withOpacity(0.3)
      ..style = PaintingStyle.fill);
    canvas.drawCircle(predictedPoint, 6, predictedPointPaint);
    canvas.drawCircle(predictedPoint, 6, Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    // Enhanced labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw week labels
    for (int i = 0; i < data.length; i++) {
      final x = 50 + (size.width - 90) * i / (data.length - 1);
      textPainter.text = TextSpan(
        text: 'Week ${i + 1}',
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - 20));
    }

    // Draw "Prediction" label
    textPainter.text = const TextSpan(
      text: 'Prediction',
      style: TextStyle(
        color: Color(0xFF8B5CF6),
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(predictedX - textPainter.width / 2, size.height - 20));

    // Draw price labels on the left
    for (int i = 0; i <= 4; i++) {
      final value = minValue + (maxValue - minValue) * (4 - i) / 4;
      final y = (size.height - 80) * i / 4 + 30;
      
      textPainter.text = TextSpan(
        text: '₹${value.toInt()}',
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }

    // Draw price values on points with better positioning
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      textPainter.text = TextSpan(
        text: '₹${data[i].toInt()}',
        style: const TextStyle(
          color: Color(0xFF0A9D88),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.white,
              blurRadius: 4,
              offset: Offset(0, 0),
            ),
          ],
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(point.dx - textPainter.width / 2, point.dy - 25));
    }

    // Draw predicted price value
    textPainter.text = TextSpan(
      text: '₹${predictedPrice.toInt()}',
      style: const TextStyle(
        color: Color(0xFF8B5CF6),
        fontSize: 10,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.white,
            blurRadius: 4,
            offset: Offset(0, 0),
          ),
        ],
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(predictedPoint.dx - textPainter.width / 2, predictedPoint.dy - 25));
  }

  void _drawEnhancedDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashWidth = 8.0;
    const double dashSpace = 4.0;
    
    final distance = (end - start).distance;
    final normalizedDirection = (end - start) / distance;
    
    double currentDistance = 0.0;
    bool drawDash = true;
    
    while (currentDistance < distance) {
      final currentStart = start + normalizedDirection * currentDistance;
      currentDistance += drawDash ? dashWidth : dashSpace;
      
      if (drawDash) {
        final currentEnd = start + normalizedDirection * (currentDistance > distance ? distance : currentDistance);
        canvas.drawLine(currentStart, currentEnd, paint);
      }
      
      drawDash = !drawDash;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ProductData {
  final String name;
  final String emoji;
  final double currentPrice;
  final double previousPrice;
  final double changePercentage;
  final bool isIncreasing;
  final List<double> priceHistory;

  ProductData(
    this.name,
    this.emoji,
    this.currentPrice,
    this.previousPrice,
    this.changePercentage,
    this.isIncreasing,
    this.priceHistory,
  );
}