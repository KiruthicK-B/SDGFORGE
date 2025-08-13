import 'package:flutter/material.dart';

class SoilTestingPage extends StatefulWidget {
  const SoilTestingPage({super.key});

  @override
  State<SoilTestingPage> createState() => _SoilTestingPageState();
}

class _SoilTestingPageState extends State<SoilTestingPage> {
  final Color themeColor = const Color(0xFF0A9D88);
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _depthController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  bool _imageUploaded = false;
  String _uploadedImageName = '';
  
  // Sample recent test results
  final List<Map<String, dynamic>> _recentTests = [
    {
      'date': '2024-01-15',
      'location': 'North Field Block A',
      'ph': 6.8,
      'moisture': 45.2,
      'nitrogen': 'Medium',
      'phosphorus': 'High',
      'potassium': 'Low',
      'recommendation': 'Apply potassium fertilizer. Soil pH is optimal for most crops.'
    },
    {
      'date': '2024-01-10',
      'location': 'South Field Block B',
      'ph': 7.2,
      'moisture': 38.7,
      'nitrogen': 'High',
      'phosphorus': 'Medium',
      'potassium': 'Medium',
      'recommendation': 'Good nutrient balance. Consider increasing organic matter.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Soil Testing',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: themeColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            _buildHeaderSection(),
            
            const SizedBox(height: 24),
            
            // Soil Test Form
            _buildTestForm(),
            
            const SizedBox(height: 24),
            
            // Recent Test Results
            _buildRecentResults(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeaderSection() {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              themeColor.withOpacity(0.1),
              themeColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.science,
              size: 48,
              color: themeColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Soil Analysis & Testing',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload soil samples and get detailed analysis reports with personalized recommendations',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTestForm() {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Soil Test',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 20),
              
              // Farm Location Field
              _buildTextField(
                controller: _locationController,
                label: 'Farm Location',
                hint: 'e.g., North Field Block A',
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter farm location';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Soil Depth Field
              _buildTextField(
                controller: _depthController,
                label: 'Soil Depth (cm)',
                hint: 'e.g., 15-30',
                icon: Icons.height,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter soil depth';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Notes Field
              _buildTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                hint: 'Any additional observations...',
                icon: Icons.note_alt,
                maxLines: 3,
                validator: null,
              ),
              
              const SizedBox(height: 20),
              
              // Upload Image Section
              _buildImageUploadSection(),
              
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitSoilTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Submit for Analysis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(icon, color: themeColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
  
  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soil Sample Images',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _imageUploaded ? themeColor : Colors.grey[300]!,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
            color: _imageUploaded 
                ? themeColor.withOpacity(0.05) 
                : Colors.grey[50],
          ),
          child: Column(
            children: [
              Icon(
                _imageUploaded ? Icons.check_circle : Icons.cloud_upload,
                size: 40,
                color: _imageUploaded ? themeColor : Colors.grey[400],
              ),
              const SizedBox(height: 12),
              
              if (_imageUploaded) ...[
                Text(
                  'Image Uploaded Successfully!',
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _uploadedImageName,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _uploadNewImage,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Upload Different Image'),
                  style: TextButton.styleFrom(foregroundColor: themeColor),
                ),
              ] else ...[
                Text(
                  'Upload soil sample images',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Take clear photos of your soil sample from different angles',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _uploadImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Upload Images'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: themeColor,
                    side: BorderSide(color: themeColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecentResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Test Results',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: themeColor,
          ),
        ),
        const SizedBox(height: 16),
        
        ..._recentTests.map((test) => _buildResultCard(test)),
      ],
    );
  }
  
  Widget _buildResultCard(Map<String, dynamic> test) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test['location'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Test Date: ${test['date']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: themeColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Test Results Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // pH and Moisture
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          'pH Level',
                          '${test['ph']}',
                          Icons.science,
                          _getPhColor(test['ph']),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricItem(
                          'Moisture',
                          '${test['moisture']}%',
                          Icons.water_drop,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // NPK Levels
                  Row(
                    children: [
                      Expanded(
                        child: _buildNutrientChip('N', test['nitrogen']),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildNutrientChip('P', test['phosphorus']),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildNutrientChip('K', test['potassium']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Recommendation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recommendation',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          test['recommendation'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ],
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
  
  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
  
  Widget _buildNutrientChip(String nutrient, String level) {
    Color color = _getNutrientColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            nutrient,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            level,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getPhColor(double ph) {
    if (ph < 6.0) return Colors.red;
    if (ph > 8.0) return Colors.orange;
    return Colors.green;
  }
  
  Color _getNutrientColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  void _uploadImage() {
    // Simulate image upload
    setState(() {
      _imageUploaded = true;
      _uploadedImageName = 'soil_sample_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Image uploaded successfully!'),
        backgroundColor: themeColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
  
  void _uploadNewImage() {
    _uploadImage();
  }
  
  void _submitSoilTest() {
    if (_formKey.currentState!.validate()) {
      if (!_imageUploaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload at least one soil sample image'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Simulate submission
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Soil test submitted successfully! Results will be available in 24-48 hours.'),
          backgroundColor: themeColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
        ),
      );
      
      // Clear form
      _locationController.clear();
      _depthController.clear();
      _notesController.clear();
      setState(() {
        _imageUploaded = false;
        _uploadedImageName = '';
      });
    }
  }
  
  @override
  void dispose() {
    _locationController.dispose();
    _depthController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}