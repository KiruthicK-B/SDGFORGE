import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vfarm/models/govt_scheme_model.dart';
import 'dart:io';

class SchemeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Initialize default schemes
  Future<void> initializeDefaultSchemes() async {
    final schemes = [
      {
        'id': 'pm-kisan',
        'name': 'PM-KISAN',
        'description': 'Pradhan Mantri Kisan Samman Nidhi - Income support of ₹6000 per year to eligible farmer families',
        'imagePath': 'assets/schemes/pm-kisan-scheme.webp',
        'eligibleCropTypes': ['rice', 'wheat', 'cotton', 'sugarcane', 'maize', 'all'],
        'eligibleStates': ['all'],
        'benefits': {
          'amount': 6000,
          'installments': 3,
          'perInstallment': 2000,
          'description': '₹6,000 per year in three equal installments of ₹2,000 each'
        },
        'requiredDocuments': [
          'Aadhaar Card',
          'Bank Account Details',
          'Land Ownership Documents',
          'Passport Size Photo'
        ],
        'eligibilityCriteria': {
          'landHolding': 'All landholding farmer families',
          'farmSize': 'Any size',
          'exclusions': 'Subject to government exclusion criteria'
        },
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'pmfby',
        'name': 'PMFBY',
        'description': 'Pradhan Mantri Fasal Bima Yojana - Crop insurance scheme to protect farmers against crop failure',
        'imagePath': 'assets/schemes/PMFBY.webp',
        'eligibleCropTypes': ['rice', 'wheat', 'cotton', 'sugarcane', 'maize', 'pulses', 'oilseeds'],
        'eligibleStates': ['all'],
        'benefits': {
          'coverage': 'Full crop loss protection',
          'premium': 'Subsidized premium rates',
          'description': 'Financial support in case of crop failure due to natural calamities'
        },
        'requiredDocuments': [
          'Aadhaar Card',
          'Bank Account Details',
          'Land Records',
          'Crop Sowing Certificate',
          'Premium Payment Receipt'
        ],
        'eligibilityCriteria': {
          'cropType': 'Notified crops in notified areas',
          'farmerType': 'Both loanee and non-loanee farmers',
          'includes': 'Sharecroppers and tenant farmers'
        },
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'pmksy',
        'name': 'PMKSY',
        'description': 'Pradhan Mantri Krishi Sinchayee Yojana - Scheme to improve farm water efficiency',
        'imagePath': 'assets/schemes/pmksy.webp',
        'eligibleCropTypes': ['rice', 'wheat', 'cotton', 'sugarcane', 'vegetables', 'fruits'],
        'eligibleStates': ['all'],
        'benefits': {
          'irrigation': 'Improved irrigation facilities',
          'efficiency': 'Enhanced water use efficiency',
          'description': 'Per drop more crop initiative'
        },
        'requiredDocuments': [
          'Aadhaar Card',
          'Land Ownership Documents',
          'Water Source Certificate',
          'Project Proposal',
          'Bank Account Details'
        ],
        'eligibilityCriteria': {
          'priority': 'Small and marginal farmers',
          'area': 'Drought-prone and water-scarce areas',
          'focus': 'Low water use efficiency areas'
        },
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'rkvy',
        'name': 'RKVY',
        'description': 'Rashtriya Krishi Vikas Yojana - Holistic development of agriculture and allied sectors',
        'imagePath': 'assets/schemes/RKVY.png',
        'eligibleCropTypes': ['all'],
        'eligibleStates': ['all'],
        'benefits': {
          'infrastructure': 'Agriculture infrastructure development',
          'technology': 'Modern farming practices support',
          'description': 'Financial assistance for agriculture development'
        },
        'requiredDocuments': [
          'Aadhaar Card',
          'Business Plan',
          'Land Documents',
          'Bank Account Details',
          'Registration Certificate'
        ],
        'eligibilityCriteria': {
          'target': 'All farmers and agri-entrepreneurs',
          'includes': 'Farmer Producer Organizations (FPOs)',
          'focus': 'Rural communities and agriculture development'
        },
        'isActive': true,
        'createdAt': Timestamp.now(),
      }
    ];

    for (var scheme in schemes) {
      await _firestore.collection('govt_schemes').doc(scheme['id'] as String?).set(scheme);
    }
  }

  // Get all schemes
  Future<List<GovtSchemeModel>> getAllSchemes() async {
    try {
      final snapshot = await _firestore
          .collection('govt_schemes')
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs.map((doc) => GovtSchemeModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch schemes: $e');
    }
  }

  // Get eligible schemes for user
 Future<List<GovtSchemeModel>> getEligibleSchemes(
  String userId,
  List<String> cropTypes,
  String? farmLocation, {
  String? overrideUserId, // <-- renamed
  List<String>? userCropTypes,
  String? userLocation,
  bool showAll = true,
}) async {
  try {
    final schemes = await getAllSchemes();

    if (showAll) {
      return schemes;
    }

    return schemes.where((scheme) {
      bool isEligible = true;

      if (userCropTypes != null && userCropTypes.isNotEmpty) {
        final cropEligible = scheme.eligibleCropTypes.contains('all') ||
            userCropTypes.any((crop) =>
                scheme.eligibleCropTypes.contains(crop.toLowerCase()));
        isEligible = isEligible && cropEligible;
      }

      if (userLocation != null && userLocation.isNotEmpty) {
        final stateEligible = scheme.eligibleStates.contains('all') ||
            scheme.eligibleStates.any((state) =>
                userLocation.toLowerCase().contains(state.toLowerCase()));
        isEligible = isEligible && stateEligible;
      }

      return isEligible;
    }).toList();
  } catch (e) {
    throw Exception('Failed to fetch eligible schemes: $e');
  }
}


  // Submit application
  Future<String> submitApplication({
    required String userId,
    required String schemeId,
    required String schemeName,
    required Map<String, dynamic> applicationData,
    required List<File> documents,
  }) async {
    try {
      // Upload documents
      List<String> documentUrls = [];
      for (int i = 0; i < documents.length; i++) {
        final ref = _storage.ref().child(
          'scheme_applications/$userId/$schemeId/${DateTime.now().millisecondsSinceEpoch}_$i.${documents[i].path.split('.').last}'
        );
        await ref.putFile(documents[i]);
        final url = await ref.getDownloadURL();
        documentUrls.add(url);
      }

      // Create application steps
      final steps = [
        ApplicationStep(
          title: 'Application Submitted',
          description: 'Your application has been successfully submitted',
          isCompleted: true,
          completedAt: DateTime.now(),
          isCurrent: false,
        ),
        ApplicationStep(
          title: 'Document Verification',
          description: 'Documents are being verified by the authorities',
          isCompleted: false,
          isCurrent: true,
        ),
        ApplicationStep(
          title: 'Eligibility Check',
          description: 'Checking eligibility criteria',
          isCompleted: false,
          isCurrent: false,
        ),
        ApplicationStep(
          title: 'Final Approval',
          description: 'Final approval and benefit disbursement',
          isCompleted: false,
          isCurrent: false,
        ),
      ];

      // Create application
      final applicationId = _firestore.collection('scheme_applications').doc().id;
      final application = SchemeApplicationModel(
        id: applicationId,
        userId: userId,
        schemeId: schemeId,
        schemeName: schemeName,
        applicationData: applicationData,
        uploadedDocuments: documentUrls,
        status: ApplicationStatus.submitted,
        steps: steps,
        appliedAt: DateTime.now(),
      );

      await _firestore.collection('scheme_applications').doc(applicationId).set(application.toMap());
      
      return applicationId;
    } catch (e) {
      throw Exception('Failed to submit application: $e');
    }
  }

  // Get user applications
  Future<List<SchemeApplicationModel>> getUserApplications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('scheme_applications')
          .where('userId', isEqualTo: userId)
          .orderBy('appliedAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => SchemeApplicationModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch applications: $e');
    }
  }

  // Get application by ID
  Future<SchemeApplicationModel?> getApplicationById(String applicationId) async {
    try {
      final doc = await _firestore.collection('scheme_applications').doc(applicationId).get();
      if (doc.exists) {
        return SchemeApplicationModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch application: $e');
    }
  }
}
