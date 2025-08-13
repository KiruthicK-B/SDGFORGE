// import 'package:flutter/material.dart';

// class Fertilizers extends StatefulWidget {
//   const Fertilizers({super.key});

//   @override
//   State<Fertilizers> createState() => _FertilizersState();
// }

// class _FertilizersState extends State<Fertilizers> {
//   final Color primaryColor = const Color(0xFF0A9D88);

//   String? selectedCrop;
//   String? selectedSoil;
//   String? selectedSeason;
//   bool showRecommendations = false;

//   final List<String> crops = [
//     'Rice',
//     'Wheat',
//     'Corn',
//     'Cotton',
//     'Sugarcane',
//     'Tomato',
//     'Potato',
//     'Onion',
//     'Soybean',
//     'Mustard'
//   ];

//   final List<String> soilTypes = [
//     'Clay',
//     'Sandy',
//     'Loamy',
//     'Silt',
//     'Chalky',
//     'Peaty'
//   ];

//   final List<String> seasons = ['Kharif', 'Rabi', 'Zaid'];

//   final List<Map<String, dynamic>> fertilizers = [
//     {
//       'name': 'NPK 20:20:0',
//       'type': 'Complex Fertilizer',
//       'icon': Icons.eco,
//       'usage': 'Apply 200-250 kg per hectare during basal application',
//       'benefits': ['Balanced nutrition', 'Improved root development', 'Enhanced flowering']
//     },
//     {
//       'name': 'Urea 46%',
//       'type': 'Nitrogen Fertilizer',
//       'icon': Icons.grass,
//       'usage': 'Split application: 50% at sowing, 50% at tillering stage',
//       'benefits': ['Promotes vegetative growth', 'Increases protein content', 'Cost effective']
//     },
//     {
//       'name': 'Single Super Phosphate',
//       'type': 'Phosphorus Fertilizer',
//       'icon': Icons.wb_sunny,
//       'usage': 'Apply 150-200 kg per hectare before sowing',
//       'benefits': ['Root development', 'Early maturity', 'Improved seed quality']
//     },
//     {
//       'name': 'Muriate of Potash',
//       'type': 'Potassium Fertilizer',
//       'icon': Icons.water_drop,
//       'usage': 'Apply 100-150 kg per hectare at flowering stage',
//       'benefits': ['Disease resistance', 'Quality improvement', 'Water regulation']
//     }
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'Fertilizer Recommendations',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: primaryColor,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Header Section
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.1),
//                       spreadRadius: 2,
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.agriculture,
//                       size: 48,
//                       color: primaryColor,
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       'Get Personalized Fertilizer Recommendations',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Select your crop, soil type, and season to get optimal fertilizer suggestions',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                         height: 1.4,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Input Form Section
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.1),
//                       spreadRadius: 2,
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Crop Information',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: primaryColor,
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     // Crop Type Dropdown
//                     _buildDropdown(
//                       label: 'Select Crop Type',
//                       value: selectedCrop,
//                       items: crops,
//                       icon: Icons.eco,
//                       onChanged: (value) => setState(() => selectedCrop = value),
//                     ),

//                     const SizedBox(height: 16),

//                     // Soil Type Dropdown
//                     _buildDropdown(
//                       label: 'Select Soil Type',
//                       value: selectedSoil,
//                       items: soilTypes,
//                       icon: Icons.terrain,
//                       onChanged: (value) => setState(() => selectedSoil = value),
//                     ),

//                     const SizedBox(height: 20),

//                     // Season Selector
//                     Text(
//                       'Growing Season',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                     const SizedBox(height: 12),

//                     Row(
//                       children: seasons.map((season) {
//                         bool isSelected = selectedSeason == season;
//                         return Expanded(
//                           child: Container(
//                             margin: const EdgeInsets.only(right: 8),
//                             child: GestureDetector(
//                               onTap: () => setState(() => selectedSeason = season),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(vertical: 12),
//                                 decoration: BoxDecoration(
//                                   color: isSelected ? primaryColor : Colors.grey[100],
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(
//                                     color: isSelected ? primaryColor : Colors.grey[300]!,
//                                   ),
//                                 ),
//                                 child: Text(
//                                   season,
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w500,
//                                     color: isSelected ? Colors.white : Colors.grey[600],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),

//                     const SizedBox(height: 24),

//                     // Get Recommendation Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _canGetRecommendation() ? _getRecommendations : null,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: primaryColor,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 2,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(Icons.search, size: 20),
//                             const SizedBox(width: 8),
//                             const Text(
//                               'Get Recommendations',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Recommendations Section
//               if (showRecommendations) ...[
//                 const SizedBox(height: 24),
//                 Text(
//                   'Recommended Fertilizers',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                     color: primaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Fertilizer Cards
//                 ...fertilizers.map((fertilizer) => _buildFertilizerCard(fertilizer)),

//                 const SizedBox(height: 20),

//                 // Additional Tips Card
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: primaryColor.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: primaryColor.withOpacity(0.2)),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.lightbulb, color: primaryColor),
//                           const SizedBox(width: 8),
//                           Text(
//                             'Pro Tips',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: primaryColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         '• Always conduct soil testing before application\n'
//                         '• Follow recommended dosage to avoid over-fertilization\n'
//                         '• Apply fertilizers during appropriate weather conditions\n'
//                         '• Consider organic alternatives for sustainable farming',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[700],
//                           height: 1.5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown({
//     required String label,
//     required String? value,
//     required List<String> items,
//     required IconData icon,
//     required void Function(String?) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: Colors.grey[800],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey[300]!),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: DropdownButtonFormField<String>(
//             value: value,
//             decoration: InputDecoration(
//               prefixIcon: Icon(icon, color: primaryColor),
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               hintText: 'Choose $label',
//               hintStyle: TextStyle(color: Colors.grey[500]),
//             ),
//             items: items.map((String item) {
//               return DropdownMenuItem<String>(
//                 value: item,
//                 child: Text(item),
//               );
//             }).toList(),
//             onChanged: onChanged,
//             style: TextStyle(color: Colors.grey[800], fontSize: 16),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFertilizerCard(Map<String, dynamic> fertilizer) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 2,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   fertilizer['icon'],
//                   color: primaryColor,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       fertilizer['name'],
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: primaryColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Text(
//                         fertilizer['type'],
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: primaryColor,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 16),

//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.05),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Usage Instructions',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.blue[700],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         fertilizer['usage'],
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey[700],
//                           height: 1.4,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 12),

//           Text(
//             'Key Benefits:',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[800],
//             ),
//           ),
//           const SizedBox(height: 8),

//           Wrap(
//             spacing: 8,
//             runSpacing: 6,
//             children: (fertilizer['benefits'] as List<String>).map((benefit) {
//               return Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.green.withOpacity(0.3)),
//                 ),
//                 child: Text(
//                   benefit,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.green[700],
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   bool _canGetRecommendation() {
//     return selectedCrop != null && selectedSoil != null && selectedSeason != null;
//   }

//   void _getRecommendations() {
//     setState(() {
//       showRecommendations = true;
//     });

//     // Scroll to recommendations section
//     Future.delayed(const Duration(milliseconds: 300), () {
//       Scrollable.ensureVisible(
//         context,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     });

//     // Show success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Recommendations generated for $selectedCrop in $selectedSoil soil ($selectedSeason season)',
//         ),
//         backgroundColor: primaryColor,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Fertilizers extends StatefulWidget {
  const Fertilizers({super.key});

  @override
  State<Fertilizers> createState() => _FertilizersState();
}

class _FertilizersState extends State<Fertilizers>
    with TickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF0A9D88);
  final Color accentColor = const Color(0xFF4CAF50);
  final Color warningColor = const Color(0xFFFF9800);

  // Form Fields
  String? selectedCrop;
  String? selectedSoil;
  String? selectedSeason;
  String? selectedRegion;
  double farmSize = 1.0;
  double currentPH = 7.0;
  bool isOrganicPreferred = false;
  bool showRecommendations = false;
  bool showDetailedAnalysis = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Tamil Nadu Regions with their main crops
  final Map<String, List<String>> tamilNaduRegions = {
    'Chennai': ['Rice', 'Groundnut', 'Vegetables'],
    'Coimbatore': ['Cotton', 'Sugarcane', 'Coconut', 'Turmeric'],
    'Madurai': ['Cotton', 'Sugarcane', 'Groundnut', 'Chilli'],
    'Tiruchirappalli': ['Rice', 'Sugarcane', 'Groundnut', 'Banana'],
    'Salem': ['Rice', 'Sugarcane', 'Mango', 'Tamarind'],
    'Tirunelveli': ['Rice', 'Banana', 'Coconut', 'Cashew'],
    'Vellore': ['Rice', 'Groundnut', 'Sugarcane', 'Mango'],
    'Erode': ['Turmeric', 'Cotton', 'Sugarcane', 'Coconut'],
    'Theni': ['Cardamom', 'Tea', 'Coffee', 'Grapes'],
    'Dindigul': ['Banana', 'Coconut', 'Cotton', 'Groundnut'],
    'Thanjavur': ['Rice', 'Sugarcane', 'Banana', 'Coconut'],
    'Kanyakumari': ['Rice', 'Coconut', 'Banana', 'Rubber'],
    'Nilgiris': ['Tea', 'Coffee', 'Potato', 'Carrot'],
    'Krishnagiri': ['Mango', 'Tomato', 'Grapes', 'Silk'],
    'Dharmapuri': ['Mango', 'Tamarind', 'Coconut', 'Groundnut'],
  };

  // Expanded crop list for Tamil Nadu
  final List<String> crops = [
    'Rice',
    'Wheat',
    'Corn',
    'Cotton',
    'Sugarcane',
    'Coconut',
    'Tomato',
    'Potato',
    'Onion',
    'Soybean',
    'Mustard',
    'Groundnut',
    'Banana',
    'Mango',
    'Turmeric',
    'Chilli',
    'Tea',
    'Coffee',
    'Cardamom',
    'Tamarind',
    'Cashew',
    'Rubber',
    'Grapes',
    'Silk',
  ];

  final List<String> soilTypes = [
    'Red Soil',
    'Black Soil',
    'Alluvial Soil',
    'Laterite Soil',
    'Sandy Soil',
    'Clay Soil',
    'Loamy Soil',
    'Coastal Saline Soil',
  ];

  final List<String> seasons = ['Kharif', 'Rabi', 'Zaid', 'Perennial'];

  // Field help information
  final Map<String, Map<String, String>> fieldHelpInfo = {
    'region': {
      'title': 'Tamil Nadu Regions',
      'content':
          'Select your farming region in Tamil Nadu. Each region has different climate conditions and soil types that affect crop selection and fertilizer requirements. This helps provide region-specific recommendations.',
    },
    'crop': {
      'title': 'Crop Selection',
      'content':
          'Choose the crop you want to cultivate. Different crops have different nutritional needs. The list is filtered based on your selected region to show crops commonly grown in that area.',
    },
    'soil': {
      'title': 'Soil Types',
      'content':
          'Red Soil: Good drainage, iron-rich\nBlack Soil: High water retention, cotton-friendly\nAlluvial Soil: Fertile, river deposits\nLaterite Soil: Iron/aluminum rich\nSandy Soil: Good drainage, low nutrients\nClay Soil: High nutrients, poor drainage\nLoamy Soil: Balanced, ideal for most crops\nCoastal Saline: High salt content',
    },
    'season': {
      'title': 'Growing Seasons',
      'content':
          'Kharif: Monsoon season (June-Oct) - Rice, Cotton, Sugarcane\nRabi: Winter season (Nov-Apr) - Wheat, Gram, Mustard\nZaid: Summer season (Apr-Jun) - Fodder, Watermelon\nPerennial: Year-round crops - Coconut, Mango, Tea',
    },
    'farmSize': {
      'title': 'Farm Size',
      'content':
          'Enter your farm size in hectares (1 hectare = 2.47 acres). This helps calculate the total fertilizer quantity needed and cost estimates for your farming operation.',
    },
    'pH': {
      'title': 'Soil pH Level',
      'content':
          'Soil pH measures acidity/alkalinity:\n• pH 3-5: Very acidic (add lime)\n• pH 6-7: Slightly acidic (ideal for most crops)\n• pH 7: Neutral\n• pH 8-9: Alkaline (add sulfur)\n• pH 10-11: Very alkaline\n\nTip: Get soil tested at nearest agriculture center',
    },
    'organic': {
      'title': 'Organic Fertilizers',
      'content':
          'Organic fertilizers are made from natural materials like compost, manure, and plant residues. They improve soil structure, water retention, and provide slow-release nutrients. Choose this for sustainable farming.',
    },
  };

  // Enhanced fertilizer recommendations with regional data
  final Map<String, List<Map<String, dynamic>>> fertilizerDatabase = {
    'Rice': [
      {
        'name': 'NPK 20:20:0',
        'type': 'Complex Fertilizer',
        'icon': Icons.eco,
        'dosage': '200-250 kg/hectare',
        'timing': 'Basal application before transplanting',
        'cost': '₹25-30 per kg',
        'benefits': [
          'Balanced nutrition',
          'Improved tillering',
          'Better grain filling',
        ],
        'precautions': ['Avoid over-application', 'Ensure adequate water'],
        'expectedYield': 6.5,
        'yieldIncrease': 15.0,
        'nutrientContent': {'N': 20, 'P': 20, 'K': 0},
        'videoSearchTerm': 'rice fertilizer application NPK',
      },
      {
        'name': 'Urea 46%',
        'type': 'Nitrogen Fertilizer',
        'icon': Icons.grass,
        'dosage': '100-120 kg/hectare',
        'timing': 'Split: 25% basal, 50% tillering, 25% panicle',
        'cost': '₹6-8 per kg',
        'benefits': [
          'Enhanced vegetative growth',
          'Increased protein',
          'Cost effective',
        ],
        'precautions': [
          'Split application mandatory',
          'Avoid waterlogged conditions',
        ],
        'expectedYield': 6.0,
        'yieldIncrease': 20.0,
        'nutrientContent': {'N': 46, 'P': 0, 'K': 0},
        'videoSearchTerm': 'urea application rice cultivation',
      },
    ],
    'Cotton': [
      {
        'name': 'DAP 18:46:0',
        'type': 'Phosphorus Rich',
        'icon': Icons.local_florist,
        'dosage': '150-200 kg/hectare',
        'timing': 'Basal application at sowing',
        'cost': '₹28-32 per kg',
        'benefits': [
          'Strong root development',
          'Better flowering',
          'Disease resistance',
        ],
        'precautions': ['Soil test recommended', 'Adequate moisture needed'],
        'expectedYield': 2.2,
        'yieldIncrease': 18.0,
        'nutrientContent': {'N': 18, 'P': 46, 'K': 0},
        'videoSearchTerm': 'cotton fertilizer DAP application',
      },
      {
        'name': 'Potash 60%',
        'type': 'Potassium Fertilizer',
        'icon': Icons.local_florist,
        'dosage': '50-80 kg/hectare',
        'timing': 'Split application: 50% basal, 50% flowering',
        'cost': '₹20-25 per kg',
        'benefits': [
          'Better fiber quality',
          'Disease resistance',
          'Water use efficiency',
        ],
        'precautions': ['Avoid chloride-based in saline soils'],
        'expectedYield': 2.0,
        'yieldIncrease': 12.0,
        'nutrientContent': {'N': 0, 'P': 0, 'K': 60},
        'videoSearchTerm': 'cotton potash fertilizer application',
      },
    ],
    'Sugarcane': [
      {
        'name': 'NPK 12:32:16',
        'type': 'Complex Fertilizer',
        'icon': Icons.agriculture,
        'dosage': '300-400 kg/hectare',
        'timing': 'Basal application at planting',
        'cost': '₹22-26 per kg',
        'benefits': [
          'Strong root system',
          'Better sugar content',
          'Increased tonnage',
        ],
        'precautions': ['Ensure proper soil moisture'],
        'expectedYield': 80.0,
        'yieldIncrease': 25.0,
        'nutrientContent': {'N': 12, 'P': 32, 'K': 16},
        'videoSearchTerm': 'sugarcane fertilizer NPK application',
      },
    ],
    'Groundnut': [
      {
        'name': 'SSP 16% P2O5',
        'type': 'Phosphorus Fertilizer',
        'icon': Icons.scatter_plot,
        'dosage': '250-300 kg/hectare',
        'timing': 'Basal application before sowing',
        'cost': '₹8-12 per kg',
        'benefits': [
          'Better pod formation',
          'Oil content improvement',
          'Root nodulation',
        ],
        'precautions': ['Adequate calcium for shell formation'],
        'expectedYield': 2.8,
        'yieldIncrease': 20.0,
        'nutrientContent': {'N': 0, 'P': 16, 'K': 0},
        'videoSearchTerm': 'groundnut SSP fertilizer application',
      },
    ],
    // Add more crops with detailed fertilizer recommendations
    'Coconut': [
      {
        'name': 'NPK 16:16:16',
        'type': 'Balanced Fertilizer',
        'icon': Icons.eco,
        'dosage': '1.3 kg per palm per year',
        'timing': 'Split into 4 applications (quarterly)',
        'cost': '₹18-22 per kg',
        'benefits': [
          'Balanced nutrition',
          'Better nut yield',
          'Improved copra',
        ],
        'precautions': ['Apply in root zone', 'Ensure adequate moisture'],
        'expectedYield': 80.0,
        'yieldIncrease': 30.0,
        'nutrientContent': {'N': 16, 'P': 16, 'K': 16},
        'videoSearchTerm': 'coconut fertilizer application NPK',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showHelpDialog(String fieldKey) {
    final helpInfo = fieldHelpInfo[fieldKey];
    if (helpInfo != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.help_outline, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  helpInfo['title']!,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(
                helpInfo['content']!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Got it!',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.info, color: primaryColor),
              const SizedBox(width: 1),
              Text(
                'Fertilizer Advisor',
                style: TextStyle(color: primaryColor),
              ),
            ],
          ),
          content: const Text(
            'This AI-powered tool provides personalized fertilizer recommendations based on your crop, soil type, region, and farming conditions. Get scientific advice to maximize yield and optimize costs.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _showQuickSuggestionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.auto_awesome, color: primaryColor),
              const SizedBox(width: 8),
              Text('Quick Suggestions', style: TextStyle(color: primaryColor)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Popular combinations for Tamil Nadu:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildQuickOption('Rice + Alluvial Soil + Kharif', () {
                Navigator.pop(context);
                setState(() {
                  selectedCrop = 'Rice';
                  selectedSoil = 'Alluvial Soil';
                  selectedSeason = 'Kharif';
                });
              }),
              _buildQuickOption('Cotton + Black Soil + Kharif', () {
                Navigator.pop(context);
                setState(() {
                  selectedCrop = 'Cotton';
                  selectedSoil = 'Black Soil';
                  selectedSeason = 'Kharif';
                });
              }),
              _buildQuickOption('Sugarcane + Red Soil + Perennial', () {
                Navigator.pop(context);
                setState(() {
                  selectedCrop = 'Sugarcane';
                  selectedSoil = 'Red Soil';
                  selectedSeason = 'Perennial';
                });
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickOption(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.touch_app, color: primaryColor, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
          ],
        ),
      ),
    );
  }

  bool _canGetRecommendation() {
    return selectedCrop != null &&
        selectedSoil != null &&
        selectedSeason != null &&
        selectedRegion != null;
  }

  void _getRecommendations() {
    if (_canGetRecommendation()) {
      setState(() {
        showRecommendations = true;
      });
      _animationController.forward();
    }
  }

  List<Map<String, dynamic>> _getFertilizerRecommendations() {
    if (selectedCrop == null) return [];

    List<Map<String, dynamic>> recommendations =
        fertilizerDatabase[selectedCrop] ?? [];

    // Filter organic if preferred
    if (isOrganicPreferred) {
      // Add organic alternatives
      recommendations =
          recommendations.map((fert) {
            Map<String, dynamic> organicVersion = Map.from(fert);
            organicVersion['name'] = 'Organic ${fert['name']}';
            organicVersion['cost'] = '₹15-25 per kg';
            organicVersion['type'] = 'Organic ${fert['type']}';
            return organicVersion;
          }).toList();
    }

    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Smart Fertilizer Advisor',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 20),
              _buildQuickRecommendations(),
              const SizedBox(height: 24),
              _buildDetailedForm(),
              if (showRecommendations) ...[
                const SizedBox(height: 24),
                _buildRecommendationsSection(),
              ],
              if (showDetailedAnalysis) ...[
                const SizedBox(height: 24),
                _buildDetailedAnalysis(),
                const SizedBox(height: 24),
                _buildYieldPredictionGraph(),
                const SizedBox(height: 24),
                _buildVideoRecommendations(),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickSuggestionDialog,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text(
          'Suggest Me',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.agriculture, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            'Smart Fertilizer Recommendations',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get AI-powered fertilizer suggestions tailored for Tamil Nadu farming conditions',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('15+', 'Regions'),
              _buildStatItem('24+', 'Crops'),
              _buildStatItem('8+', 'Soil Types'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildQuickRecommendations() {
    final List<Map<String, dynamic>> quickTips = [
      {
        'title': 'Rice Season Alert',
        'subtitle': 'Kharif season - Apply NPK for better yield',
        'icon': Icons.grain,
        'color': Colors.orange,
      },
      {
        'title': 'Soil Health',
        'subtitle': 'Test pH levels before fertilizer application',
        'icon': Icons.science,
        'color': Colors.blue,
      },
      {
        'title': 'Weather Update',
        'subtitle': 'Good conditions for fertilizer application',
        'icon': Icons.wb_sunny,
        'color': Colors.amber,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: quickTips.length,
            itemBuilder: (context, index) {
              final tip = quickTips[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: tip['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            tip['icon'],
                            color: tip['color'],
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.trending_up, color: Colors.green, size: 16),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tip['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip['subtitle'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

 Widget _buildDetailedForm() {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isTablet = constraints.maxWidth > 600;
      final isMobile = constraints.maxWidth < 400;
      
      return Container(
        padding: EdgeInsets.all(isMobile ? 16 : isTablet ? 32 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildResponsiveHeader(isTablet, isMobile),
              SizedBox(height: isMobile ? 16 : isTablet ? 32 : 24),

              // Form Fields in Responsive Grid
              if (isTablet)
                _buildTabletLayout()
              else
                _buildMobileLayout(isMobile),

              SizedBox(height: isMobile ? 20 : 30),

              // Enhanced Get Recommendation Button
              _buildResponsiveButton(constraints.maxWidth, isMobile),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildResponsiveHeader(bool isTablet, bool isMobile) {
  return Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Icon(
        Icons.assignment,
        color: primaryColor,
        size: isMobile ? 20 : isTablet ? 28 : 24,
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          'Detailed Farm Information',
          style: TextStyle(
            fontSize: isMobile ? 16 : isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    ],
  );
}

Widget _buildTabletLayout() {
  return Column(
    children: [
      // Row 1: Region and Crop
      Row(
        children: [
          Expanded(
            child: _buildEnhancedDropdown(
              label: 'Select Region in Tamil Nadu',
              value: selectedRegion,
              items: tamilNaduRegions.keys.toList(),
              icon: Icons.location_on,
              helpKey: 'region',
              onChanged: (value) {
                setState(() {
                  selectedRegion = value;
                  selectedCrop = null;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildEnhancedDropdown(
              label: 'Select Crop Type',
              value: selectedCrop,
              items: selectedRegion != null
                  ? tamilNaduRegions[selectedRegion!]!
                  : crops,
              icon: Icons.eco,
              helpKey: 'crop',
              onChanged: (value) => setState(() => selectedCrop = value),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Row 2: Soil Type and Season
      Row(
        children: [
          Expanded(
            child: _buildEnhancedDropdown(
              label: 'Select Soil Type',
              value: selectedSoil,
              items: soilTypes,
              icon: Icons.terrain,
              helpKey: 'soil',
              onChanged: (value) => setState(() => selectedSoil = value),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: _buildSeasonSelector()),
        ],
      ),
      const SizedBox(height: 20),

      // Row 3: Farm Size and pH
      Row(
        children: [
          Expanded(
            child: _buildSliderInput(
              label: 'Farm Size (Hectares)',
              value: farmSize,
              min: 0.1,
              max: 100.0,
              divisions: 999,
              helpKey: 'farmSize',
              onChanged: (value) => setState(() => farmSize = value),
              format: (value) => '${value.toStringAsFixed(1)} ha',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSliderInput(
              label: 'Current Soil pH Level',
              value: currentPH,
              min: 3.0,
              max: 11.0,
              divisions: 80,
              helpKey: 'pH',
              onChanged: (value) => setState(() => currentPH = value),
              format: (value) => value.toStringAsFixed(1),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Organic Preference
      _buildResponsiveOrganicSwitch(false),
    ],
  );
}

Widget _buildMobileLayout(bool isMobile) {
  return Column(
    children: [
      // Region Selection
      _buildEnhancedDropdown(
        label: 'Select Region in Tamil Nadu',
        value: selectedRegion,
        items: tamilNaduRegions.keys.toList(),
        icon: Icons.location_on,
        helpKey: 'region',
        onChanged: (value) {
          setState(() {
            selectedRegion = value;
            selectedCrop = null;
          });
        },
      ),
      SizedBox(height: isMobile ? 12 : 16),

      // Crop Selection
      _buildEnhancedDropdown(
        label: 'Select Crop Type',
        value: selectedCrop,
        items: selectedRegion != null
            ? tamilNaduRegions[selectedRegion!]!
            : crops,
        icon: Icons.eco,
        helpKey: 'crop',
        onChanged: (value) => setState(() => selectedCrop = value),
      ),
      SizedBox(height: isMobile ? 12 : 16),

      // Soil Type Selection
      _buildEnhancedDropdown(
        label: 'Select Soil Type',
        value: selectedSoil,
        items: soilTypes,
        icon: Icons.terrain,
        helpKey: 'soil',
        onChanged: (value) => setState(() => selectedSoil = value),
      ),
      SizedBox(height: isMobile ? 12 : 16),

      // Season Selection
      _buildSeasonSelector(),
      SizedBox(height: isMobile ? 12 : 16),

      // Farm Size Slider
      _buildSliderInput(
        label: 'Farm Size (Hectares)',
        value: farmSize,
        min: 0.1,
        max: 100.0,
        divisions: 999,
        helpKey: 'farmSize',
        onChanged: (value) => setState(() => farmSize = value),
        format: (value) => '${value.toStringAsFixed(1)} ha',
      ),
      SizedBox(height: isMobile ? 12 : 16),

      // Soil pH Slider
      _buildSliderInput(
        label: 'Current Soil pH Level',
        value: currentPH,
        min: 3.0,
        max: 11.0,
        divisions: 80,
        helpKey: 'pH',
        onChanged: (value) => setState(() => currentPH = value),
        format: (value) => value.toStringAsFixed(1),
      ),
      SizedBox(height: isMobile ? 12 : 16),

      // Organic Preference Switch
      _buildResponsiveOrganicSwitch(isMobile),
    ],
  );
}

Widget _buildResponsiveOrganicSwitch(bool isMobile) {
  return Container(
    padding: EdgeInsets.all(isMobile ? 12 : 16),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.eco_outlined,
              color: Colors.green,
              size: isMobile ? 20 : 24,
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Prefer Organic Fertilizers',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showHelpDialog('organic'),
                        icon: Icon(
                          Icons.help_outline,
                          size: isMobile ? 16 : 18,
                          color: primaryColor,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  Text(
                    'Include eco-friendly options',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: isOrganicPreferred,
              onChanged: (value) => setState(() => isOrganicPreferred = value),
              activeColor: accentColor,
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildResponsiveButton(double screenWidth, bool isMobile) {
  final buttonHeight = isMobile ? 48.0 : 56.0;
  final fontSize = isMobile ? 14.0 : 16.0;
  final iconSize = isMobile ? 20.0 : 24.0;
  
  return SizedBox(
    width: double.infinity,
    height: buttonHeight,
    child: ElevatedButton(
      onPressed: _canGetRecommendation() ? _getRecommendations : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _canGetRecommendation() ? primaryColor : Colors.grey[300],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        ),
        elevation: _canGetRecommendation() ? 4 : 0,
      ),
      child: FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology,
              size: iconSize,
              color: _canGetRecommendation() ? Colors.white : Colors.grey[600],
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Text(
              isMobile ? 'Get Recommendations' : 'Get Smart Recommendations',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: _canGetRecommendation() ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Helper method for enhanced dropdowns with responsive sizing
Widget _buildEnhancedDropdown({
  required String label,
  required String? value,
  required List<String> items,
  required IconData icon,
  required String helpKey,
  required ValueChanged<String?> onChanged,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 300;
      
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 12 : 16,
                isMobile ? 8 : 12,
                isMobile ? 12 : 16,
                4,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: primaryColor,
                    size: isMobile ? 16 : 18,
                  ),
                  SizedBox(width: isMobile ? 6 : 8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showHelpDialog(helpKey),
                    icon: Icon(
                      Icons.help_outline,
                      size: isMobile ? 14 : 16,
                      color: primaryColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 12 : 16,
                0,
                isMobile ? 12 : 16,
                isMobile ? 8 : 12,
              ),
              child: DropdownButtonFormField<String>(
                value: value,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  color: Colors.grey[800],
                ),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                isExpanded: true,
              ),
            ),
          ],
        ),
      );
    },
  );
}


  Widget _buildSeasonSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Growing Season',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            IconButton(
              onPressed: () => _showHelpDialog('season'),
              icon: Icon(Icons.help_outline, size: 18, color: primaryColor),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: seasons.length,
          itemBuilder: (context, index) {
            final season = seasons[index];
            final isSelected = selectedSeason == season;
            return GestureDetector(
              onTap: () => setState(() => selectedSeason = season),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient:
                      isSelected
                          ? LinearGradient(
                            colors: [primaryColor, accentColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                          : null,
                  color: isSelected ? null : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey[300]!,
                    width: 1.5,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Center(
                  child: Text(
                    season,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSliderInput({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String helpKey,
    required void Function(double) onChanged,
    required String Function(double) format,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  onPressed: () => _showHelpDialog(helpKey),
                  icon: Icon(Icons.help_outline, size: 18, color: primaryColor),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                format(value),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: primaryColor,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: primaryColor,
            overlayColor: primaryColor.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  accentColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.recommend, color: primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personalized Recommendations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        'Based on $selectedCrop cultivation in $selectedRegion region',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed:
                      () => setState(
                        () => showDetailedAnalysis = !showDetailedAnalysis,
                      ),
                  icon: Icon(
                    showDetailedAnalysis
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Fertilizer Cards
          ...(_getFertilizerRecommendations()).map(
            (fertilizer) => _buildEnhancedFertilizerCard(fertilizer),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFertilizerCard(Map<String, dynamic> fertilizer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.2),
                        accentColor.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    fertilizer['icon'],
                    color: primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fertilizer['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              fertilizer['type'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '+${fertilizer['yieldIncrease']}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      Text(
                        'Yield',
                        style: TextStyle(fontSize: 10, color: accentColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Key Information Row
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Dosage',
                        fertilizer['dosage'],
                        Icons.straighten,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        'Cost',
                        fertilizer['cost'],
                        Icons.currency_rupee,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Timing Information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Application Timing',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              fertilizer['timing'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Benefits and Precautions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildBenefitsPrecautionsCard(
                        'Benefits',
                        fertilizer['benefits'],
                        Colors.green,
                        Icons.check_circle_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBenefitsPrecautionsCard(
                        'Precautions',
                        fertilizer['precautions'],
                        warningColor,
                        Icons.warning_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Cost Calculation for User's Farm
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.1),
                        accentColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'For your ${farmSize.toStringAsFixed(1)} hectare farm:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          Icon(Icons.calculate, color: primaryColor, size: 20),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quantity needed:',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            _calculateFertilizerQuantity(fertilizer['dosage']),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimated cost:',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            _calculateFertilizerCost(
                              fertilizer['dosage'],
                              fertilizer['cost'],
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsPrecautionsCard(
    String title,
    List<String> items,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $item',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateFertilizerQuantity(String dosage) {
    // Extract numeric value from dosage string (e.g., "200-250 kg/hectare")
    final numbers =
        RegExp(
          r'\d+',
        ).allMatches(dosage).map((m) => int.parse(m.group(0)!)).toList();
    if (numbers.isNotEmpty) {
      final avgDosage =
          numbers.length > 1
              ? (numbers[0] + numbers[1]) / 2
              : numbers[0].toDouble();
      final totalQuantity = avgDosage * farmSize;
      return '${totalQuantity.toStringAsFixed(0)} kg';
    }
    return 'Calculate manually';
  }

  String _calculateFertilizerCost(String dosage, String cost) {
    // Extract numeric values
    final dosageNumbers =
        RegExp(
          r'\d+',
        ).allMatches(dosage).map((m) => int.parse(m.group(0)!)).toList();
    final costNumbers =
        RegExp(
          r'\d+',
        ).allMatches(cost).map((m) => int.parse(m.group(0)!)).toList();

    if (dosageNumbers.isNotEmpty && costNumbers.isNotEmpty) {
      final avgDosage =
          dosageNumbers.length > 1
              ? (dosageNumbers[0] + dosageNumbers[1]) / 2
              : dosageNumbers[0].toDouble();
      final avgCost =
          costNumbers.length > 1
              ? (costNumbers[0] + costNumbers[1]) / 2
              : costNumbers[0].toDouble();
      final totalQuantity = avgDosage * farmSize;
      final totalCost = totalQuantity * avgCost;
      return '₹${totalCost.toStringAsFixed(0)}';
    }
    return 'Calculate manually';
  }

  Widget _buildDetailedAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Detailed Analysis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Soil pH Analysis
          _buildAnalysisCard(
            'Soil pH Analysis',
            _getPHAnalysis(),
            _getPHRecommendation(),
            Icons.science,
            _getPHColor(),
          ),

          const SizedBox(height: 16),

          // Farm Size Analysis
          _buildAnalysisCard(
            'Farm Size Category',
            _getFarmSizeCategory(),
            _getFarmSizeRecommendation(),
            Icons.landscape,
            primaryColor,
          ),

          const SizedBox(height: 16),

          // Regional Analysis
          _buildAnalysisCard(
            'Regional Considerations',
            'Climate: ${_getRegionalClimate()}',
            _getRegionalRecommendation(),
            Icons.location_on,
            accentColor,
          ),
        ],
      ),
    );
  }
Widget _buildAnalysisCard(
  String title,
  String analysis,
  String recommendation,
  IconData icon,
  Color color,
) {
  return Container(
    padding: const EdgeInsets.all(12), // Reduced from 16
    decoration: BoxDecoration(
      color: color.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Important: This prevents overflow
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16), // Reduced from 20
            const SizedBox(width: 6), // Reduced from 8
            Expanded( // Wrap title with Expanded to prevent overflow
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: 13, // Reduced from 16
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6), // Reduced from 12
        Expanded( // This makes the text take available space
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible( // Allow text to shrink if needed
                child: Text(
                  analysis,
                  style: TextStyle(
                    fontSize: 11, // Reduced from 14
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    height: 1.2, // Reduced line height
                  ),
                  maxLines: 2, // Limit to 2 lines
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4), // Reduced from 8
              Flexible( // Allow text to shrink if needed
                child: Text(
                  recommendation,
                  style: TextStyle(
                    fontSize: 10, // Reduced from 13
                    color: Colors.grey[600],
                    height: 1.2, // Reduced from 1.4
                  ),
                  maxLines: 2, // Limit to 2 lines
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
  String _getPHAnalysis() {
    if (currentPH < 6.0) {
      return 'Acidic soil (pH ${currentPH.toStringAsFixed(1)})';
    }
    if (currentPH > 8.0) {
      return 'Alkaline soil (pH ${currentPH.toStringAsFixed(1)})';
    }
    return 'Optimal soil pH (${currentPH.toStringAsFixed(1)})';
  }

  String _getPHRecommendation() {
    if (currentPH < 6.0) {
      return 'Add lime to increase pH. Apply 2-3 tons/hectare of agricultural lime. This will improve nutrient availability and fertilizer effectiveness.';
    } else if (currentPH > 8.0) {
      return 'Add sulfur or organic matter to decrease pH. Apply 500-1000 kg/hectare of elemental sulfur. Consider gypsum for saline-alkaline soils.';
    }
    return 'Your soil pH is in the optimal range for most crops. Maintain current levels with balanced fertilization and organic matter additions.';
  }

  Color _getPHColor() {
    if (currentPH < 6.0 || currentPH > 8.0) return warningColor;
    return accentColor;
  }

  String _getFarmSizeCategory() {
    if (farmSize < 1.0) return 'Small scale farming (<1 hectare)';
    if (farmSize < 5.0) return 'Medium scale farming (1-5 hectares)';
    return 'Large scale farming (>5 hectares)';
  }

  String _getFarmSizeRecommendation() {
    if (farmSize < 1.0) {
      return 'Focus on high-value crops and intensive management. Consider drip irrigation and precision fertilizer application for maximum returns.';
    } else if (farmSize < 5.0) {
      return 'Suitable for diverse cropping systems. Consider crop rotation and mechanized fertilizer application for efficiency.';
    }
    return 'Ideal for commercial farming. Invest in soil testing, mechanized equipment, and bulk fertilizer purchases for cost optimization.';
  }

  String _getRegionalClimate() {
    final climateMap = {
      'Chennai': 'Tropical coastal',
      'Coimbatore': 'Semi-arid',
      'Madurai': 'Semi-arid',
      'Tiruchirappalli': 'Tropical dry',
      'Salem': 'Tropical dry',
      'Tirunelveli': 'Tropical dry',
      'Nilgiris': 'Temperate',
    };
    return climateMap[selectedRegion] ?? 'Tropical';
  }

  String _getRegionalRecommendation() {
    final recommendationMap = {
      'Chennai':
          'High humidity affects fertilizer storage. Use waterproof storage and avoid urea during heavy rains.',
      'Coimbatore':
          'Semi-arid conditions require efficient water and nutrient management. Consider fertigation.',
      'Madurai':
          'Hot, dry climate increases nitrogen losses. Apply fertilizers in cooler hours.',
      'Nilgiris':
          'Cool climate slows nutrient release. Use quick-release fertilizers and adjust timing.',
    };
    return recommendationMap[selectedRegion] ??
        'Follow standard application practices for tropical conditions.';
  }

  Widget _buildYieldPredictionGraph() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Yield Prediction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${value.toInt()} kg',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                        ];
                        if (value.toInt() >= 0 &&
                            value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              months[value.toInt()],
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getYieldPredictionSpots(),
                    isCurved: true,
                    color: primaryColor,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: primaryColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.2),
                          primaryColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Comparison line (without fertilizer optimization)
                  LineChartBarData(
                    spots: _getBaselineYieldSpots(),
                    isCurved: true,
                    color: Colors.grey[400]!,
                    barWidth: 2,
                    dashArray: [5, 5],
                    dotData: FlDotData(show: false),
                  ),
                ],
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: _getMaxYield() * 1.1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildLegendItem('With Optimization', primaryColor, false),
              const SizedBox(width: 20),
              _buildLegendItem('Current Practice', Colors.grey[400]!, true),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: accentColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Predicted yield increase: ${_calculateYieldIncrease()}% with optimized fertilization',
                    style: TextStyle(
                      fontSize: 12,
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDashed) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
          child:
              isDashed
                  ? CustomPaint(
                    painter: DashedLinePainter(color: color),
                    size: const Size(20, 2),
                  )
                  : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getYieldPredictionSpots() {
    // Sample data - replace with your actual calculation logic
    double baseYield = _calculateBaseYield();
    return [
      FlSpot(0, baseYield * 0.8),
      FlSpot(1, baseYield * 1.1),
      FlSpot(2, baseYield * 1.3),
      FlSpot(3, baseYield * 1.4),
      FlSpot(4, baseYield * 1.2),
      FlSpot(5, baseYield * 1.1),
    ];
  }

  List<FlSpot> _getBaselineYieldSpots() {
    // Sample baseline data
    double baseYield = _calculateBaseYield();
    return [
      FlSpot(0, baseYield * 0.7),
      FlSpot(1, baseYield * 0.9),
      FlSpot(2, baseYield * 1.0),
      FlSpot(3, baseYield * 1.1),
      FlSpot(4, baseYield * 0.95),
      FlSpot(5, baseYield * 0.9),
    ];
  }

  double _calculateBaseYield() {
    // Base yield calculation considering crop type, soil conditions, etc.
    double baseYield = 2000.0; // kg per hectare

    // Adjust for crop type
    final cropYieldMap = {
      'Rice': 3000.0,
      'Wheat': 2500.0,
      'Maize': 4000.0,
      'Cotton': 1200.0,
      'Sugarcane': 70000.0,
      'Groundnut': 1500.0,
    };
    baseYield = cropYieldMap[selectedCrop] ?? baseYield;

    // Adjust for soil pH
    if (currentPH < 6.0 || currentPH > 8.0) {
      baseYield *= 0.8;
    }

    return baseYield;
  }

  double _getMaxYield() {
    List<FlSpot> allSpots = [
      ..._getYieldPredictionSpots(),
      ..._getBaselineYieldSpots(),
    ];
    return allSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
  }

  String _calculateYieldIncrease() {
    List<FlSpot> optimizedSpots = _getYieldPredictionSpots();
    List<FlSpot> baselineSpots = _getBaselineYieldSpots();

    double avgOptimized =
        optimizedSpots.map((s) => s.y).reduce((a, b) => a + b) /
        optimizedSpots.length;
    double avgBaseline =
        baselineSpots.map((s) => s.y).reduce((a, b) => a + b) /
        baselineSpots.length;

    double increase = ((avgOptimized - avgBaseline) / avgBaseline) * 100;
    return increase.toStringAsFixed(1);
  }
  
    DashedLinePainter({required Color color}) {

      
    }
}

_buildVideoRecommendations() {
}




// Custom painter for dashed lines in legend
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashSpace = 2.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
