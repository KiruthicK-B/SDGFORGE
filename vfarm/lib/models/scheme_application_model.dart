
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
  });

  factory SchemeApplicationModel.fromSnapshot(doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SchemeApplicationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      schemeId: data['schemeId'] ?? '',
      schemeName: data['schemeName'] ?? '',
      applicationData: Map<String, dynamic>.from(data['applicationData'] ?? {}),
      uploadedDocuments: List<String>.from(data['uploadedDocuments'] ?? []),
      status: ApplicationStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => ApplicationStatus.submitted,
      ),
      steps: (data['steps'] as List<dynamic>?)?.map((e) => ApplicationStep.fromMap(e)).toList() ?? [],
      appliedAt: data['appliedAt']?.toDate() ?? DateTime.now(),
      lastUpdated: data['lastUpdated']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'schemeId': schemeId,
      'schemeName': schemeName,
      'applicationData': applicationData,
      'uploadedDocuments': uploadedDocuments,
      'status': status.toString(),
      'steps': steps.map((e) => e.toMap()).toList(),
      'appliedAt': appliedAt,
      'lastUpdated': lastUpdated,
    };
  }
}

enum ApplicationStatus {
  submitted,
  underReview,
  approved,
  rejected,
  documentsPending,
}

class ApplicationStep {
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isCurrent;

  ApplicationStep({
    required this.title,
    required this.description,
    required this.isCompleted,
    this.completedAt,
    required this.isCurrent,
  });

  factory ApplicationStep.fromMap(Map<String, dynamic> map) {
    return ApplicationStep(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt']?.toDate(),
      isCurrent: map['isCurrent'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'completedAt': completedAt,
      'isCurrent': isCurrent,
    };
  }
}