
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:vfarm/models/govt_scheme_model.dart';
import 'package:vfarm/models/user_profile_model.dart';
import 'package:vfarm/scheme_service.dart';
import 'package:vfarm/session_manager.dart';

class SchemeApplicationScreen extends StatefulWidget {
  final GovtSchemeModel scheme;
  final UserProfileModel userProfile;
  final VoidCallback onApplicationSubmitted;

  const SchemeApplicationScreen({
    super.key,
    required this.scheme,
    required this.userProfile,
    required this.onApplicationSubmitted,
  });

  @override
  State<SchemeApplicationScreen> createState() => _SchemeApplicationScreenState();
}

class _SchemeApplicationScreenState extends State<SchemeApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final SchemeService _schemeService = SchemeService();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _farmLocationController;
  late TextEditingController _farmSizeController;
  late TextEditingController _cropTypesController;
  late TextEditingController _bankAccountController;
  late TextEditingController _ifscController;
  late TextEditingController _aadharController;
  
  final List<File> _selectedDocuments = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.userProfile.name);
    _emailController = TextEditingController(text: widget.userProfile.email);
    _phoneController = TextEditingController(text: widget.userProfile.phone ?? '');
    _farmLocationController = TextEditingController(text: widget.userProfile.farmLocation ?? '');
    _farmSizeController = TextEditingController(text: widget.userProfile.farmSize?.toString() ?? '');
    _cropTypesController = TextEditingController(text: widget.userProfile.cropTypes.join(', '));
    _bankAccountController = TextEditingController();
    _ifscController = TextEditingController();
    _aadharController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for ${widget.scheme.name}'),
        backgroundColor: const Color(0xFF0A9D88),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Personal Information'),
                    _buildTextField('Full Name', _nameController, required: true),
                    _buildTextField('Email', _emailController, required: true),
                    _buildTextField('Phone Number', _phoneController, required: true),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader('Farm Information'),
                    _buildTextField('Farm Location', _farmLocationController, required: true),
                    _buildTextField('Farm Size (in acres)', _farmSizeController, required: true),
                    _buildTextField('Crop Types', _cropTypesController, required: true),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader('Bank Details'),
                    _buildTextField('Bank Account Number', _bankAccountController, required: true),
                    _buildTextField('IFSC Code', _ifscController, required: true),
                    _buildTextField('Aadhaar Number', _aadharController, required: true),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader('Required Documents'),
                    _buildDocumentsSection(),
                  ],
                ),
              ),
            ),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A9D88),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                          SizedBox(width: 8),
                          Text('Submitting...'),
                        ],
                      )
                    : const Text('SUBMIT APPLICATION', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A9D88))),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF0A9D88))),
        ),
        validator: required ? (value) => value?.isEmpty == true ? '$label is required' : null : null,
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Please upload the following documents:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        
        ...widget.scheme.requiredDocuments.map((doc) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              const Text("• ", style: TextStyle(color: Color(0xFF0A9D88))),
              Text(doc, style: const TextStyle(fontSize: 14)),
            ],
          ),
        )),
        
        const SizedBox(height: 16),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey.shade600),
              const SizedBox(height: 8),
              Text('Upload Documents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _pickDocuments,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A9D88), foregroundColor: Colors.white),
                child: const Text('Choose Files'),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        if (_selectedDocuments.isNotEmpty) ...[
          const Text('Selected Documents:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          ..._selectedDocuments.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Card(
              child: ListTile(
                leading: const Icon(Icons.attach_file),
                title: Text(file.path.split('/').last, style: const TextStyle(fontSize: 14)),
                subtitle: Text('${(file.lengthSync() / 1024).toStringAsFixed(1)} KB'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeDocument(index),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Future<void> _pickDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedDocuments.addAll(result.paths.map((path) => File(path!)).toList());
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    }
  }

  void _removeDocument(int index) {
    setState(() {
      _selectedDocuments.removeAt(index);
    });
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDocuments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one document')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final applicationData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'farmLocation': _farmLocationController.text,
        'farmSize': _farmSizeController.text,
        'cropTypes': _cropTypesController.text,
        'bankAccount': _bankAccountController.text,
        'ifscCode': _ifscController.text,
        'aadharNumber': _aadharController.text,
        'submittedAt': DateTime.now().toIso8601String(),
      };

      final userId = SessionManager.instance.getCurrentUserId()!;
      
      await _schemeService.submitApplication(
        userId: userId,
        schemeId: widget.scheme.id,
        schemeName: widget.scheme.name,
        applicationData: applicationData,
        documents: _selectedDocuments,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application submitted successfully for ${widget.scheme.name}'),
            backgroundColor: const Color(0xFF0A9D88),
          ),
        );
        
        widget.onApplicationSubmitted();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting application: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _farmLocationController.dispose();
    _farmSizeController.dispose();
    _cropTypesController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    _aadharController.dispose();
    super.dispose();
  }
}