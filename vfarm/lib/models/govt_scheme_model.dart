import 'package:cloud_firestore/cloud_firestore.dart';

class GovtSchemeModel {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String? category; // Added missing category field
  final List<String> eligibleCropTypes;
  final List<String> eligibleStates;
  final Map<String, dynamic> benefits;
  final List<String> requiredDocuments;
  final Map<String, dynamic> eligibilityCriteria;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? departmentName; // Additional field
  final double? maxBenefitAmount; // Additional field
  final String? applicationDeadline; // Additional field

  GovtSchemeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    this.category,
    required this.eligibleCropTypes,
    required this.eligibleStates,
    required this.benefits,
    required this.requiredDocuments,
    required this.eligibilityCriteria,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.departmentName,
    this.maxBenefitAmount,
    this.applicationDeadline,
  });

  factory GovtSchemeModel.fromMap(Map<String, dynamic> map) {
    return GovtSchemeModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'] ?? '',
      category: map['category'],
      eligibleCropTypes: List<String>.from(map['eligibleCropTypes'] ?? []),
      eligibleStates: List<String>.from(map['eligibleStates'] ?? []),
      benefits: Map<String, dynamic>.from(map['benefits'] ?? {}),
      requiredDocuments: List<String>.from(map['requiredDocuments'] ?? []),
      eligibilityCriteria: Map<String, dynamic>.from(map['eligibilityCriteria'] ?? {}),
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      departmentName: map['departmentName'],
      maxBenefitAmount: map['maxBenefitAmount']?.toDouble(),
      applicationDeadline: map['applicationDeadline'],
    );
  }

  factory GovtSchemeModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    return GovtSchemeModel.fromMap({...data, 'id': snapshot.id});
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'category': category,
      'eligibleCropTypes': eligibleCropTypes,
      'eligibleStates': eligibleStates,
      'benefits': benefits,
      'requiredDocuments': requiredDocuments,
      'eligibilityCriteria': eligibilityCriteria,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'departmentName': departmentName,
      'maxBenefitAmount': maxBenefitAmount,
      'applicationDeadline': applicationDeadline,
    };
  }

  // Helper method to get category display name
  String get categoryDisplayName {
    switch (category?.toLowerCase()) {
      case 'subsidy':
        return 'Subsidy';
      case 'loan':
        return 'Loan Scheme';
      case 'insurance':
        return 'Insurance';
      case 'training':
        return 'Training Program';
      case 'technology':
        return 'Technology Support';
      default:
        return category ?? 'General';
    }
  }

  // Helper method to check if scheme is eligible for user
  bool isEligibleForCrops(List<String> userCrops) {
    if (eligibleCropTypes.contains('all')) return true;
    return userCrops.any((crop) => 
        eligibleCropTypes.any((eligible) => 
            eligible.toLowerCase() == crop.toLowerCase()));
  }

  // Helper method to check if scheme is eligible for state
  bool isEligibleForState(String userState) {
    if (eligibleStates.contains('all')) return true;
    return eligibleStates.any((state) => 
        state.toLowerCase() == userState.toLowerCase());
  }
}

class SchemeApplicationModel {
  final String id;
  final String userId;
  final String schemeId;
  final String schemeName;
  final Map<String, dynamic> applicationData;
  final List<String> uploadedDocuments;
  final ApplicationStatus status;
  final List<ApplicationStep> steps;
  final DateTime appliedAt;
  final DateTime? lastUpdated;
  final String? rejectionReason;
  final String? approvalNotes;
  final double? benefitAmount; // Added benefit amount field
  final String? trackingNumber; // Added tracking number field

  SchemeApplicationModel({
    required this.id,
    required this.userId,
    required this.schemeId,
    required this.schemeName,
    required this.applicationData,
    required this.uploadedDocuments,
    required this.status,
    required this.steps,
    required this.appliedAt,
    this.lastUpdated,
    this.rejectionReason,
    this.approvalNotes,
    this.benefitAmount,
    this.trackingNumber,
  });

  factory SchemeApplicationModel.fromMap(Map<String, dynamic> map) {
    return SchemeApplicationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      schemeId: map['schemeId'] ?? '',
      schemeName: map['schemeName'] ?? '',
      applicationData: Map<String, dynamic>.from(map['applicationData'] ?? {}),
      uploadedDocuments: List<String>.from(map['uploadedDocuments'] ?? []),
      status: ApplicationStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => ApplicationStatus.submitted,
      ),
      steps: (map['steps'] as List<dynamic>?)
          ?.map((e) => ApplicationStep.fromMap(e))
          .toList() ?? _getDefaultSteps(),
      appliedAt: (map['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate(),
      rejectionReason: map['rejectionReason'],
      approvalNotes: map['approvalNotes'],
      benefitAmount: map['benefitAmount']?.toDouble(),
      trackingNumber: map['trackingNumber'],
    );
  }

  factory SchemeApplicationModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    return SchemeApplicationModel.fromMap({...data, 'id': snapshot.id});
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'schemeId': schemeId,
      'schemeName': schemeName,
      'applicationData': applicationData,
      'uploadedDocuments': uploadedDocuments,
      'status': status.toString(),
      'steps': steps.map((e) => e.toMap()).toList(),
      'appliedAt': Timestamp.fromDate(appliedAt),
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
      'rejectionReason': rejectionReason,
      'approvalNotes': approvalNotes,
      'benefitAmount': benefitAmount,
      'trackingNumber': trackingNumber,
    };
  }

  // Getter for application ID (for backward compatibility)
  String get applicationId => id;

  // Helper method to get current step
  ApplicationStep? get currentStep {
    try {
      return steps.firstWhere((step) => step.isCurrent);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get completion percentage
  double get completionPercentage {
    if (steps.isEmpty) return 0.0;
    final completedSteps = steps.where((step) => step.isCompleted).length;
    return (completedSteps / steps.length) * 100;
  }

  // Helper method to get status color
  String get statusColor {
    switch (status) {
      case ApplicationStatus.submitted:
        return '#2196F3';
      case ApplicationStatus.underReview:
        return '#FF9800';
      case ApplicationStatus.approved:
        return '#4CAF50';
      case ApplicationStatus.rejected:
        return '#F44336';
      case ApplicationStatus.documentsPending:
        return '#9C27B0';
    }
  }

  // Helper method to check if application can be edited
  bool get canBeEdited {
    return status == ApplicationStatus.submitted || 
           status == ApplicationStatus.documentsPending;
  }

  // Static method to create default steps
  static List<ApplicationStep> _getDefaultSteps() {
    return [
      ApplicationStep(
        title: 'Application Submitted',
        description: 'Your application has been submitted successfully',
        isCompleted: true,
        completedAt: DateTime.now(),
        isCurrent: false,
      ),
      ApplicationStep(
        title: 'Document Verification',
        description: 'Documents are being verified by the department',
        isCompleted: false,
        isCurrent: true,
      ),
      ApplicationStep(
        title: 'Review Process',
        description: 'Application is under review by officials',
        isCompleted: false,
        isCurrent: false,
      ),
      ApplicationStep(
        title: 'Final Decision',
        description: 'Final decision on your application',
        isCompleted: false,
        isCurrent: false,
      ),
    ];
  }
}

enum ApplicationStatus {
  submitted,
  underReview,
  approved,
  rejected,
  documentsPending,
}

// Extension to get display text for ApplicationStatus
extension ApplicationStatusExtension on ApplicationStatus {
  String get displayText {
    switch (this) {
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

  String get description {
    switch (this) {
      case ApplicationStatus.submitted:
        return 'Your application has been successfully submitted and is awaiting review.';
      case ApplicationStatus.underReview:
        return 'Your application is currently being reviewed by the concerned department.';
      case ApplicationStatus.approved:
        return 'Congratulations! Your application has been approved.';
      case ApplicationStatus.rejected:
        return 'Unfortunately, your application has been rejected.';
      case ApplicationStatus.documentsPending:
        return 'Additional documents are required to process your application.';
    }
  }
}

class ApplicationStep {
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isCurrent;
  final String? notes; // Additional field for step notes
  final String? assignedTo; // Additional field for assigned officer

  ApplicationStep({
    required this.title,
    required this.description,
    required this.isCompleted,
    this.completedAt,
    required this.isCurrent,
    this.notes,
    this.assignedTo,
  });

  factory ApplicationStep.fromMap(Map<String, dynamic> map) {
    return ApplicationStep(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      isCurrent: map['isCurrent'] ?? false,
      notes: map['notes'],
      assignedTo: map['assignedTo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'isCurrent': isCurrent,
      'notes': notes,
      'assignedTo': assignedTo,
    };
  }

  // Helper method to create a copy with updated fields
  ApplicationStep copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isCurrent,
    String? notes,
    String? assignedTo,
  }) {
    return ApplicationStep(
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isCurrent: isCurrent ?? this.isCurrent,
      notes: notes ?? this.notes,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}

// Additional utility class for scheme categories
class SchemeCategory {
  static const String subsidy = 'subsidy';
  static const String loan = 'loan';
  static const String insurance = 'insurance';
  static const String training = 'training';
  static const String technology = 'technology';
  static const String general = 'general';

  static List<String> get allCategories => [
    subsidy,
    loan,
    insurance,
    training,
    technology,
    general,
  ];

  static String getDisplayName(String category) {
    switch (category.toLowerCase()) {
      case subsidy:
        return 'Subsidy Schemes';
      case loan:
        return 'Loan Schemes';
      case insurance:
        return 'Insurance Schemes';
      case training:
        return 'Training Programs';
      case technology:
        return 'Technology Support';
      case general:
        return 'General Schemes';
      default:
        return 'Other';
    }
  }

  static String getIcon(String category) {
    switch (category.toLowerCase()) {
      case subsidy:
        return '💰';
      case loan:
        return '🏦';
      case insurance:
        return '🛡️';
      case training:
        return '📚';
      case technology:
        return '💻';
      case general:
        return '📋';
      default:
        return '📄';
    }
  }
}