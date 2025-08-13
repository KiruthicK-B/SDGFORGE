
import 'package:flutter/material.dart';
import 'package:vfarm/models/govt_scheme_model.dart';
import 'package:vfarm/models/user_profile_model.dart';
import 'package:vfarm/screens/scheme_application_screen.dart';

class SchemeDetailScreen extends StatelessWidget {
  final GovtSchemeModel scheme;
  final bool isEligible;
  final UserProfileModel? userProfile;

  const SchemeDetailScreen({
    super.key,
    required this.scheme,
    required this.isEligible,
    this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(scheme.name),
        backgroundColor: const Color(0xFF0A9D88),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                scheme.imagePath,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isEligible ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isEligible ? 'You are Eligible' : 'Check Eligibility',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scheme.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSection('About the Scheme', scheme.description as Widget),
                  _buildSection('Benefits', _buildBenefitsList()),
                  _buildSection('Eligibility Criteria', _buildEligibilityList()),
                  _buildSection('Required Documents', _buildDocumentsList()),
                  
                  if (!isEligible) _buildEligibilityCheck(),
                ],
              ),
            ),
          ),
          
          if (isEligible)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => _showApplicationForm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A9D88),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("APPLY NOW", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        content,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBenefitsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: scheme.benefits.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("• ", style: TextStyle(fontSize: 16)),
              Expanded(child: Text("${entry.key}: ${entry.value}", style: const TextStyle(fontSize: 16))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEligibilityList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: scheme.eligibilityCriteria.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("• ", style: TextStyle(fontSize: 16)),
              Expanded(child: Text("${entry.key}: ${entry.value}", style: const TextStyle(fontSize: 16))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDocumentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: scheme.requiredDocuments.map((doc) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("• ", style: TextStyle(fontSize: 16)),
              Expanded(child: Text(doc, style: const TextStyle(fontSize: 16))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEligibilityCheck() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 8),
              Text('Eligibility Check', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 8),
          Text(_getEligibilityMessage(), style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  String _getEligibilityMessage() {
    if (userProfile == null) return 'Please complete your profile to check eligibility.';
    
    final userCrops = userProfile!.cropTypes.map((c) => c.toLowerCase()).toList();
    final schemeCrops = scheme.eligibleCropTypes;
    
    if (!schemeCrops.contains('all') && !userCrops.any((crop) => schemeCrops.contains(crop))) {
      return 'Your crop types (${userProfile!.cropTypes.join(', ')}) may not be eligible for this scheme. Eligible crops: ${schemeCrops.join(', ')}.';
    }
    
    return 'You may be eligible. Please verify all criteria before applying.';
  }

  void _showApplicationForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchemeApplicationScreen(
          scheme: scheme,
          userProfile: userProfile!,
          onApplicationSubmitted: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
