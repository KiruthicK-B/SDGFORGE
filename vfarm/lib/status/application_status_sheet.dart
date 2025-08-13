
import 'package:flutter/material.dart';
import 'package:vfarm/models/govt_scheme_model.dart';
import 'package:vfarm/models/user_profile_model.dart';
import 'package:vfarm/session_manager.dart';
import 'package:vfarm/scheme_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ApplicationStatusSheet extends StatefulWidget {
  final SchemeApplicationModel application;
  final VoidCallback? onRefresh;

  const ApplicationStatusSheet({
    super.key,
    required this.application,
    this.onRefresh,
  });

  @override
  State<ApplicationStatusSheet> createState() => _ApplicationStatusSheetState();
}

class _ApplicationStatusSheetState extends State<ApplicationStatusSheet> {
  late SchemeApplicationModel currentApplication;
  bool isRefreshing = false;
  bool isDownloading = false;
  final SchemeService _schemeService = SchemeService();

  @override
  void initState() {
    super.initState();
    currentApplication = widget.application;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A9D88).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Color(0xFF0A9D88),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Application Status',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Track your scheme application',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF0A9D88)),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: isRefreshing ? null : _refreshApplication,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    isRefreshing
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF0A9D88),
                                                ),
                                          ),
                                        )
                                        : const Icon(
                                          Icons.refresh,
                                          color: Color(0xFF0A9D88),
                                          size: 18,
                                        ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isRefreshing
                                          ? 'Refreshing...'
                                          : 'Refresh Status',
                                      style: const TextStyle(
                                        color: Color(0xFF0A9D88),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0A9D88), Color(0xFF0B8A7A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0A9D88).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap:
                                  isDownloading ? null : _downloadApplication,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    isDownloading
                                        ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : const Icon(
                                          Icons.file_download,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isDownloading
                                          ? 'Generating...'
                                          : 'Download Report',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getStatusColor(
                            currentApplication.status,
                          ).withOpacity(0.1),
                          _getStatusColor(
                            currentApplication.status,
                          ).withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(
                          currentApplication.status,
                        ).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(currentApplication.status),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getStatusIcon(currentApplication.status),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getStatusText(currentApplication.status),
                                style: TextStyle(
                                  color: _getStatusColor(
                                    currentApplication.status,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getStatusDescription(
                                  currentApplication.status,
                                ),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Progress Header
                  Row(
                    children: [
                      const Icon(
                        Icons.timeline,
                        color: Color(0xFF0A9D88),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Application Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A9D88).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_getCompletedStepsCount()}/${currentApplication.steps.length} Steps',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF0A9D88),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Progress Timeline
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: currentApplication.steps.length,
                      itemBuilder: (context, index) {
                        final step = currentApplication.steps[index];
                        return _buildStepItem(
                          step,
                          index == currentApplication.steps.length - 1,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Footer Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Applied on: ${_formatDate(currentApplication.appliedAt)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (currentApplication.lastUpdated != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.update,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Last updated: ${_formatDate(currentApplication.lastUpdated!)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(ApplicationStep step, bool isLast) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color:
                      step.isCompleted
                          ? Colors.green
                          : step.isCurrent
                          ? const Color(0xFF0A9D88)
                          : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child:
                    step.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                        : step.isCurrent
                        ? Container(
                          margin: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                        : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: step.isCompleted ? Colors.green : Colors.grey[300],
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Step content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    step.isCurrent
                        ? const Color(0xFF0A9D88).withOpacity(0.05)
                        : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      step.isCurrent
                          ? const Color(0xFF0A9D88).withOpacity(0.2)
                          : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          step.isCompleted
                              ? Colors.green[700]
                              : step.isCurrent
                              ? const Color(0xFF0A9D88)
                              : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                  if (step.completedAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Completed: ${_formatDate(step.completedAt!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getCompletedStepsCount() {
    return currentApplication.steps.where((step) => step.isCompleted).length;
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.submitted:
        return Colors.blue;
      case ApplicationStatus.underReview:
        return Colors.orange;
      case ApplicationStatus.approved:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.documentsPending:
        return Colors.amber;
    }
  }

  IconData _getStatusIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.submitted:
        return Icons.upload_file;
      case ApplicationStatus.underReview:
        return Icons.hourglass_empty;
      case ApplicationStatus.approved:
        return Icons.check_circle;
      case ApplicationStatus.rejected:
        return Icons.cancel;
      case ApplicationStatus.documentsPending:
        return Icons.warning;
    }
  }

  String _getStatusText(ApplicationStatus status) {
    switch (status) {
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

  String _getStatusClass(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.submitted:
        return 'status-pending';
      case ApplicationStatus.underReview:
        return 'status-review';
      case ApplicationStatus.approved:
        return 'status-approved';
      case ApplicationStatus.rejected:
        return 'status-rejected';
      case ApplicationStatus.documentsPending:
        return 'status-pending';
    }
  }

  String _getStatusDescription(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.submitted:
        return 'Your application has been successfully submitted';
      case ApplicationStatus.underReview:
        return 'Application is being reviewed by officials';
      case ApplicationStatus.approved:
        return 'Congratulations! Your application has been approved';
      case ApplicationStatus.rejected:
        return 'Application was rejected. Check details below';
      case ApplicationStatus.documentsPending:
        return 'Additional documents are required';
    }
  }

  Future<void> _refreshApplication() async {
    setState(() => isRefreshing = true);

    try {
      final userId = SessionManager.instance.getCurrentUserId();
      if (userId != null) {
        final updatedApplications = await _schemeService.getUserApplications(
          userId,
        );

        final updatedApp = updatedApplications.firstWhere(
          (app) => app.id == currentApplication.id,
          orElse: () => currentApplication,
        );

        setState(() {
          currentApplication = updatedApp;
        });

        widget.onRefresh?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Status refreshed successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed to refresh: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() => isRefreshing = false);
    }
  }

  Future<void> _downloadApplication() async {
    setState(() => isDownloading = true);

    try {
      final userProfile = SessionManager.instance.getCurrentUserProfile();
      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      // Create professional document as HTML first
      final htmlContent = await _createProfessionalDocument(
        userProfile,
        currentApplication,
      );

      final appDir = await getApplicationDocumentsDirectory();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'VFarm_Application_${currentApplication.schemeName.replaceAll(' ', '_')}_$timestamp.html';
      final filePath = '${appDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(htmlContent);

      await _openFile(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Document generated successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed to create document: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() => isDownloading = false);
    }
  }

  Future<bool> _openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type == ResultType.done) {
        return true;
      } else {
        print('Could not open file: ${result.message}');
        return false;
      }
    } catch (e) {
      print('Error opening file: $e');
      return false;
    }
  }

  Future<String> _createProfessionalDocument(
    UserProfileModel userProfile,
    SchemeApplicationModel application,
  ) async {
    final content = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>VFarm Application Report</title>
    <style>
        :root {
            --primary-color: #2E7D32;        /* Deep Green */
            --primary-light: #4CAF50;        /* Light Green */
            --primary-dark: #1B5E20;         /* Dark Green */ 
            --secondary-color: #FF8F00;      /* Amber */
            --secondary-light: #FFC107;      /* Light Amber */
            --accent-color: #0277BD;         /* Blue */
            --success-color: #388E3C;        /* Success Green */
            --warning-color: #F57C00;        /* Warning Orange */
            --error-color: #D32F2F;          /* Error Red */
            --info-color: #1976D2;           /* Info Blue */
            --neutral-50: #FAFAFA;
            --neutral-100: #F5F5F5;
            --neutral-200: #EEEEEE;
            --neutral-300: #E0E0E0;
            --neutral-400: #BDBDBD;
            --neutral-500: #9E9E9E;
            --neutral-600: #757575;
            --neutral-700: #616161;
            --neutral-800: #424242;
            --neutral-900: #212121;
            --white: #FFFFFF;
            --shadow-sm: 0 2px 4px rgba(0,0,0,0.05);
            --shadow-md: 0 4px 12px rgba(0,0,0,0.1);
            --shadow-lg: 0 8px 24px rgba(0,0,0,0.12);
            --shadow-xl: 0 12px 32px rgba(0,0,0,0.15);
            --border-radius-sm: 4px;
            --border-radius: 8px;
            --border-radius-lg: 12px;
            --border-radius-xl: 16px;
        }

        * {
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 24px;
            background: linear-gradient(135deg, var(--neutral-50) 0%, var(--neutral-100) 100%);
            color: var(--neutral-800);
        }
        
        .header {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
            color: var(--white);
            padding: 32px 24px;
            text-align: center;
            border-radius: var(--border-radius-xl);
            margin-bottom: 24px;
            box-shadow: var(--shadow-lg);
            position: relative;
            overflow: hidden;
        }

        .header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="grain" width="100" height="100" patternUnits="userSpaceOnUse"><circle cx="25" cy="25" r="1" fill="white" opacity="0.1"/><circle cx="75" cy="75" r="1" fill="white" opacity="0.1"/><circle cx="50" cy="10" r="0.5" fill="white" opacity="0.05"/></pattern></defs><rect width="100" height="100" fill="url(%23grain)"/></svg>');
            opacity: 0.3;
        }
        
        .logo {
            position: relative;
            z-index: 1;
        }

        .logo h3 {
            font-size: 42px;
            font-weight: 700;
            margin: 0 0 8px 0;
            text-shadow: 2px 2px 8px rgba(0,0,0,0.3);
            letter-spacing: -0.5px;
        }

        .logo h6 {
            font-size: 16px;
            font-weight: 400;
            margin: 0 0 20px 0;
            opacity: 0.9;
            letter-spacing: 0.5px;
        }
        
        .document-title {
            font-size: 28px;
            font-weight: 600;
            margin: 0;
            position: relative;
            z-index: 1;
        }
        
        .container {
            max-width: 900px;
            margin: 0 auto;
            background: var(--white);
            border-radius: var(--border-radius-xl);
            overflow: hidden;
            box-shadow: var(--shadow-xl);
        }
        
        .section {
            margin: 0;
            background: var(--white);
            border-bottom: 1px solid var(--neutral-200);
        }

        .section:last-child {
            border-bottom: none;
        }
        
        .section-header {
            background: linear-gradient(135deg, var(--neutral-50) 0%, var(--neutral-100) 100%);
            padding: 20px 24px;
            font-weight: 600;
            font-size: 18px;
            color: var(--primary-dark);
            border-bottom: 2px solid var(--primary-color);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .section-content {
            padding: 24px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 16px;
            margin-bottom: 0;
        }
        
        .info-item {
            background: var(--neutral-50);
            padding: 16px;
            border-radius: var(--border-radius);
            border: 1px solid var(--neutral-200);
            transition: all 0.2s ease;
        }

        .info-item:hover {
            border-color: var(--primary-light);
            box-shadow: var(--shadow-sm);
        }
        
        .info-label {
            font-weight: 600;
            color: var(--neutral-600);
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            margin-bottom: 6px;
        }
        
        .info-value {
            color: var(--neutral-800);
            font-size: 15px;
            font-weight: 500;
        }
        
        .status-badge {
            display: inline-flex;
            align-items: center;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-size: 11px;
            gap: 6px;
        }
        
        .status-approved { 
            background: linear-gradient(135deg, #E8F5E8 0%, #D4F2D4 100%); 
            color: var(--success-color);
            border: 1px solid #C8E6C8;
        }
        .status-pending { 
            background: linear-gradient(135deg, #FFF8E1 0%, #FFECB3 100%); 
            color: var(--warning-color);
            border: 1px solid #FFE082;
        }
        .status-rejected { 
            background: linear-gradient(135deg, #FFEBEE 0%, #FFCDD2 100%); 
            color: var(--error-color);
            border: 1px solid #EF9A9A;
        }
        .status-review { 
            background: linear-gradient(135deg, #E3F2FD 0%, #BBDEFB 100%); 
            color: var(--info-color);
            border: 1px solid #90CAF9;
        }
        
        .timeline {
            position: relative;
            padding-left: 0;
        }
        
        .timeline-item {
            position: relative;
            padding: 16px 0 16px 48px;
            border-left: 3px solid var(--neutral-300);
            margin-bottom: 8px;
            transition: all 0.3s ease;
        }

        .timeline-item:hover {
            background: var(--neutral-50);
            border-radius: var(--border-radius);
            margin-left: -16px;
            padding-left: 64px;
        }
        
        .timeline-item.completed {
            border-left-color: var(--success-color);
        }
        
        .timeline-item.current {
            border-left-color: var(--primary-color);
            background: linear-gradient(135deg, rgba(76, 175, 80, 0.05) 0%, rgba(46, 125, 50, 0.05) 100%);
        }
        
        .timeline-dot {
            position: absolute;
            left: -9px;
            top: 20px;
            width: 16px;
            height: 16px;
            border-radius: 50%;
            background: var(--neutral-400);
            border: 3px solid var(--white);
            box-shadow: var(--shadow-sm);
        }
        
        .timeline-item.completed .timeline-dot {
            background: var(--success-color);
        }
        
        .timeline-item.current .timeline-dot {
            background: var(--primary-color);
            box-shadow: 0 0 0 4px rgba(76, 175, 80, 0.2);
        }
        
        .timeline-title {
            font-weight: 600;
            color: var(--neutral-800);
            margin-bottom: 4px;
            font-size: 16px;
        }
        
        .timeline-desc {
            color: var(--neutral-600);
            font-size: 14px;
            margin-bottom: 6px;
            line-height: 1.5;
        }
        
        .timeline-date {
            color: var(--success-color);
            font-size: 12px;
            font-weight: 600;
            background: var(--neutral-100);
            padding: 4px 8px;
            border-radius: var(--border-radius-sm);
            display: inline-block;
        }
        
        .documents-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 12px;
            margin-top: 0;
        }
        
        .document-item {
            background: linear-gradient(135deg, var(--neutral-50) 0%, var(--white) 100%);
            padding: 16px 12px;
            border-radius: var(--border-radius);
            border: 1px solid var(--neutral-200);
            text-align: center;
            font-size: 14px;
            font-weight: 500;
            color: var(--success-color);
            transition: all 0.2s ease;
        }

        .document-item:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
            border-color: var(--success-color);
        }
        
        .benefits-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .benefits-list li {
            padding: 16px;
            margin-bottom: 12px;
            background: linear-gradient(135deg, var(--neutral-50) 0%, var(--white) 100%);
            border-radius: var(--border-radius);
            border-left: 4px solid var(--primary-color);
            box-shadow: var(--shadow-sm);
            transition: all 0.2s ease;
        }

        .benefits-list li:hover {
            transform: translateX(4px);
            box-shadow: var(--shadow-md);
        }

        .benefits-list li strong {
            color: var(--primary-dark);
            display: block;
            margin-bottom: 4px;
        }
        
        .footer {
            background: linear-gradient(135deg, var(--neutral-800) 0%, var(--neutral-900) 100%);
            color: var(--white);
            padding: 24px;
            text-align: center;
            margin-top: 0;
        }

        .footer p {
            margin: 0;
            opacity: 0.9;
        }

        .footer p:last-child {
            margin-top: 8px;
            font-size: 12px;
            opacity: 0.7;
        }
        
        .important-note {
            background: linear-gradient(135deg, #FFF8E1 0%, #FFECB3 100%);
            border: 1px solid var(--secondary-light);
            border-left: 4px solid var(--secondary-color);
            border-radius: var(--border-radius);
            padding: 20px;
            margin: 24px;
        }
        
        .important-note h4 {
            color: var(--warning-color);
            margin: 0 0 12px 0;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .important-note ul {
            margin: 0;
            padding-left: 20px;
        }

        .important-note li {
            margin-bottom: 6px;
            color: var(--neutral-700);
        }
        
        .contact-info {
            background: linear-gradient(135deg, #E3F2FD 0%, #BBDEFB 100%);
            border: 1px solid var(--accent-color);
            border-left: 4px solid var(--accent-color);
            border-radius: var(--border-radius);
            padding: 20px;
            margin: 24px;
        }
        
        .contact-info h4 {
            color: var(--accent-color);
            margin: 0 0 12px 0;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .contact-info p {
            margin: 8px 0;
            color: var(--neutral-700);
        }

        .contact-info strong {
            color: var(--accent-color);
        }
        
        @media print {
            body { 
                background: var(--white); 
                padding: 0; 
            }
            .container { 
                box-shadow: none; 
                max-width: none;
            }
            .header {
                box-shadow: none;
            }
        }

        @media (max-width: 768px) {
            body {
                padding: 16px;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
            
            .documents-grid {
                grid-template-columns: 1fr;
            }
            
            .header {
                padding: 24px 16px;
            }
            
            .section-content {
                padding: 16px;
            }
            
            .important-note,
            .contact-info {
                margin: 16px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <div class="logo">
                <center>
                    <h3>VFarm</h3>
                    <h6>We Farm, We Evolve</h6>
                </center>
            </div>
            <div class="document-title">Government Scheme Application Report</div>
        </div>
        
        <!-- Application Overview -->
        <div class="section">
            <div class="section-header">📋 Application Overview</div>
            <div class="section-content">
                <div class="info-grid">
                    <div class="info-item">
                        <div class="info-label">Application ID</div>
                        <div class="info-value">${application.id}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Scheme Name</div>
                        <div class="info-value">${application.schemeName}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Application Status</div>
                        <div class="info-value">
                            <span class="status-badge ${_getStatusClass(application.status)}">
                                ${_getStatusText(application.status)}
                            </span>
                        </div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Applied Date</div>
                        <div class="info-value">${_formatDate(application.appliedAt)}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Last Updated</div>
                        <div class="info-value">${application.lastUpdated != null ? _formatDate(application.lastUpdated!) : 'N/A'}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Document Generated</div>
                        <div class="info-value">${_formatDate(DateTime.now())}</div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Applicant Information -->
        <div class="section">
            <div class="section-header">👤 Applicant Information</div>
            <div class="section-content">
                <div class="info-grid">
                    <div class="info-item">
                        <div class="info-label">Full Name</div>
                        <div class="info-value">${userProfile.name}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Email Address</div>
                        <div class="info-value">${userProfile.email}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Phone Number</div>
                        <div class="info-value">${userProfile.phone ?? 'Not provided'}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Address</div>
                        <div class="info-value">${userProfile.farmLocation ?? 'Not provided'}</div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Farm Details -->
        <div class="section">
            <div class="section-header">🚜 Farm Details</div>
            <div class="section-content">
                <div class="info-grid">
                    <div class="info-item">
                        <div class="info-label">Farm Location</div>
                        <div class="info-value">${userProfile.farmLocation ?? 'Not provided'}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Farm Size</div>
                        <div class="info-value">${userProfile.farmSize?.toString() ?? 'Not provided'} acres</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Crop Types</div>
                        <div class="info-value">${userProfile.cropTypes.join(', ')}</div>
                    </div>
                    <div class="info-item">
                        <div class="info-label">Farming Experience</div>
                        <div class="info-value">${userProfile.farmingExperience?.toString() ?? 'Not provided'} years</div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Required Documents -->
        <div class="section">
            <div class="section-header">📄 Required Documents</div>
            <div class="section-content">
                <div class="documents-grid">
                    <div class="document-item">✅ Aadhaar Card Copy</div>
                    <div class="document-item">✅ Land Ownership Documents</div>
                    <div class="document-item">✅ Bank Account Details</div>
                    <div class="document-item">✅ Passport Size Photograph</div>
                    <div class="document-item">✅ Farm Registration Certificate</div>
                    <div class="document-item">✅ Income Certificate</div>
                </div>
            </div>
        </div>
        
        <!-- Scheme Benefits -->
        <div class="section">
            <div class="section-header">💰 Scheme Benefits</div>
            <div class="section-content">
                <ul class="benefits-list">
                    <li>
                        <strong>💵 Financial Assistance</strong>
                        As per scheme guidelines with direct bank transfer
                    </li>
                    <li>
                        <strong>🎓 Technical Support</strong>
                        Comprehensive training and expert guidance programs
                    </li>
                    <li>
                        <strong>🔬 Modern Techniques</strong>
                        Access to latest sustainable farming methods and technology
                    </li>
                    <li>
                        <strong>🏪 Market Linkage</strong>
                        Direct market access support and price guarantee schemes
                    </li>
                    <li>
                        <strong>🌾 Crop Insurance</strong>
                        Complete protection against natural calamities and weather risks
                    </li>
                </ul>
            </div>
        </div>
        
        <!-- Important Notes -->
        <div class="important-note">
            <h4>📌 Important Notes</h4>
            <ul>
                <li>Keep this document for your official records and future reference</li>
                <li>Contact our support team if you need any clarification or assistance</li>
                <li>All updates and communications will be sent to your registered email and phone</li>
                <li>Ensure all required documents are submitted as per the specified guidelines</li>
                <li>Regular monitoring of application status is recommended through our portal</li>
            </ul>
        </div>
        
        <!-- Contact Information -->
        <div class="contact-info">
            <h4>📞 Contact Information</h4>
            <p><strong>VFarm Support Email:</strong> support@vfarm.com</p>
            <p><strong>24/7 Helpline:</strong> 1800-123-4567</p>
            <p><strong>Official Website:</strong> www.vfarm.com</p>
            <p><strong>Support Hours:</strong> Monday to Saturday, 9:00 AM - 6:00 PM</p>
        </div>
        
        <!-- Footer -->
        <div class="footer">
            <p>This is a system-generated document from VFarm Digital Agriculture Platform</p>
            <p>Generated on ${_formatDate(DateTime.now())} at ${_formatTime(DateTime.now())}</p>
        </div>
    </div>
</body>
</html>
    ''';

    return content;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _generateTimelineHtml {
  _generateTimelineHtml(List<ApplicationStep> steps);
}
