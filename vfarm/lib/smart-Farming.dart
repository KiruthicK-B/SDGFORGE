import 'package:flutter/material.dart';
import 'dart:math';

class SmartFarmingPage extends StatefulWidget {
  const SmartFarmingPage({super.key});

  @override
  State<SmartFarmingPage> createState() => _SmartFarmingPageState();
}

class _SmartFarmingPageState extends State<SmartFarmingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  bool _isAnalyzing = false;
  bool _showResults = false;
  
  // Sample farm data
  Map<String, dynamic> _farmData = {
    'soilMoisture': 0.0,
    'soilPH': 0.0,
    'temperature': 0.0,
    'humidity': 0.0,
    'cropHealth': 0.0,
    'pestRisk': 0.0,
  };

  List<String> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _generateRandomFarmData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _generateRandomFarmData() {
    final random = Random();
    setState(() {
      _farmData = {
        'soilMoisture': 30 + random.nextDouble() * 40, // 30-70%
        'soilPH': 6.0 + random.nextDouble() * 2.0, // 6.0-8.0
        'temperature': 20 + random.nextDouble() * 15, // 20-35°C
        'humidity': 40 + random.nextDouble() * 40, // 40-80%
        'cropHealth': 70 + random.nextDouble() * 30, // 70-100%
        'pestRisk': random.nextDouble() * 30, // 0-30%
      };
    });
  }

  void _runAnalysis() async {
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
      _showResults = false;
    });

    _pulseController.repeat();

    // Simulate AI analysis
    await Future.delayed(const Duration(seconds: 3));

    _generateRecommendations();

    setState(() {
      _isAnalyzing = false;
      _showResults = true;
    });

    _pulseController.stop();
    _pulseController.reset();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Analysis complete! Check your recommendations below.'),
          ],
        ),
        backgroundColor: const Color(0xFF0A9D88),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _generateRecommendations() {
    List<String> recommendations = [];
    
    if (_farmData['soilMoisture'] < 40) {
      recommendations.add('💧 Increase irrigation - Soil moisture is low (${_farmData['soilMoisture'].toStringAsFixed(1)}%)');
    }
    
    if (_farmData['soilPH'] < 6.5) {
      recommendations.add('🌱 Add lime to increase soil pH (Current: ${_farmData['soilPH'].toStringAsFixed(1)})');
    } else if (_farmData['soilPH'] > 7.5) {
      recommendations.add('🌱 Add sulfur to decrease soil pH (Current: ${_farmData['soilPH'].toStringAsFixed(1)})');
    }
    
    if (_farmData['temperature'] > 30) {
      recommendations.add('🌡️ Consider shade nets - High temperature detected (${_farmData['temperature'].toStringAsFixed(1)}°C)');
    }
    
    if (_farmData['pestRisk'] > 20) {
      recommendations.add('🐛 Apply preventive pest control - High risk detected (${_farmData['pestRisk'].toStringAsFixed(1)}%)');
    }
    
    if (_farmData['cropHealth'] < 80) {
      recommendations.add('🌾 Monitor crop closely - Health score below optimal (${_farmData['cropHealth'].toStringAsFixed(1)}%)');
    }

    if (recommendations.isEmpty) {
      recommendations.add('✅ All parameters are optimal! Continue current practices.');
    }

    setState(() {
      _recommendations = recommendations;
    });
  }

  Color _getHealthColor(double value, {bool isInverted = false}) {
    if (isInverted) {
      // For values like pest risk where lower is better
      if (value < 10) return Colors.green;
      if (value < 20) return Colors.orange;
      return Colors.red;
    } else {
      // For values like crop health where higher is better
      if (value > 80) return Colors.green;
      if (value > 60) return Colors.orange;
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced Top App Bar
                      Container(
                        margin: const EdgeInsets.all(20.0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Smart Farming',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'AI-powered crop management',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Status indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.greenAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Online',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Enhanced Hero Section
                      Center(
                        child: Column(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _isAnalyzing ? _pulseAnimation.value : 1.0,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isAnalyzing ? Icons.analytics : Icons.psychology,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40.0),
                              child: Text(
                                'Monitor soil, weather, and crop health',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            if (_isAnalyzing) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Analyzing farm data...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Live Farm Data Section
                      if (_showResults) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'Live Farm Data',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20.0),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _buildDataItem(
                                    'Soil Moisture',
                                    '${_farmData['soilMoisture'].toStringAsFixed(1)}%',
                                    Icons.water_drop,
                                    _getHealthColor(_farmData['soilMoisture']),
                                  ),
                                  const SizedBox(width: 20),
                                  _buildDataItem(
                                    'Soil pH',
                                    _farmData['soilPH'].toStringAsFixed(1),
                                    Icons.science,
                                    _getHealthColor((_farmData['soilPH'] - 6.5).abs() < 0.5 ? 90 : 60),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildDataItem(
                                    'Temperature',
                                    '${_farmData['temperature'].toStringAsFixed(1)}°C',
                                    Icons.thermostat,
                                    _getHealthColor(_farmData['temperature'] < 30 ? 90 : 60),
                                  ),
                                  const SizedBox(width: 20),
                                  _buildDataItem(
                                    'Crop Health',
                                    '${_farmData['cropHealth'].toStringAsFixed(1)}%',
                                    Icons.eco,
                                    _getHealthColor(_farmData['cropHealth']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Enhanced Feature Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            _buildEnhancedFeatureCard(
                              'Soil Monitoring',
                              'Real-time soil analysis',
                              Icons.grass,
                              Colors.teal,
                              _showResults ? _farmData['soilMoisture'].toStringAsFixed(1) + '%' : null,
                            ),
                            const SizedBox(width: 16),
                            _buildEnhancedFeatureCard(
                              'Weather Alerts',
                              'Smart weather insights',
                              Icons.wb_sunny,
                              Colors.orange,
                              _showResults ? _farmData['temperature'].toStringAsFixed(1) + '°C' : null,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Enhanced Crop Health Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Card(
                          elevation: 20,
                          shadowColor: Colors.black38,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.green.shade50],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.local_florist,
                                        size: 32,
                                        color: Color(0xFF4CAF50),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Text(
                                        'Crop Health Insights',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (_showResults)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _getHealthColor(_farmData['cropHealth']),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${_farmData['cropHealth'].toStringAsFixed(1)}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Advanced AI algorithms analyze crop images and sensor data to detect diseases, pests, and nutritional deficiencies early. Get personalized recommendations for optimal treatment and prevention strategies.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildStatRow('Disease detection accuracy', '95%'),
                                      const SizedBox(height: 12),
                                      _buildStatRow('Yield prediction precision', '92%'),
                                      const SizedBox(height: 12),
                                      _buildStatRow('Early pest detection', '89%'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // AI Recommendations Section
                      if (_showResults && _recommendations.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'AI Recommendations',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._recommendations.map((recommendation) => 
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Text(
                              recommendation,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ).toList(),
                      ],

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // Enhanced Floating Action Button
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0A9D88).withOpacity(0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isAnalyzing ? null : _runAnalysis,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A9D88),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isAnalyzing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Analyzing...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.analytics, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Get Recommendations',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataItem(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFeatureCard(String title, String description, IconData icon, Color accentColor, String? liveData) {
    return Expanded(
      child: Card(
        elevation: 15,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.white, accentColor.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: accentColor),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (liveData != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    liveData,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF4CAF50),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}