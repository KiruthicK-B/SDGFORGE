import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:vfarm/models/govt_scheme_model.dart';
import 'package:vfarm/models/user_profile_model.dart';

class ApplicationDocumentScreen extends StatelessWidget {
  final SchemeApplicationModel application;
  final UserProfileModel userProfile;

  const ApplicationDocumentScreen({
    super.key,
    required this.application,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Document'),
        backgroundColor: const Color(0xFF0A9D88),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _generatePDF(context),
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => _generatePDF(context),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
      ),
    );
  }

  Future<Uint8List> _generatePDF(BuildContext context) async {
    final pdf = pw.Document();
    
    // Load logo (you'll need to add this to assets)
    final logoData = await rootBundle.load('assets/images/vfarm_logo.png');
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Column(
                children: [
                  pw.Image(logo, width: 80, height: 80),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    'VFARM',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green,
                    ),
                  ),
                  pw.Text(
                    'Government Scheme Application',
                    style: pw.TextStyle(fontSize: 16),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Application Details
            pw.Text(
              'APPLICATION FOR ${application.schemeName.toUpperCase()}',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 16),

            // Application ID and Date
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Application ID: ${application.id}'),
                pw.Text('Date: ${_formatDate(application.appliedAt)}'),
              ],
            ),

            pw.SizedBox(height: 24),

            // Personal Information
            _buildPDFSection('PERSONAL INFORMATION', [
              ['Full Name', application.applicationData['name'] ?? ''],
              ['Email', application.applicationData['email'] ?? ''],
              ['Phone Number', application.applicationData['phone'] ?? ''],
              ['Aadhaar Number', application.applicationData['aadharNumber'] ?? ''],
            ]),

            pw.SizedBox(height: 16),

            // Farm Information
            _buildPDFSection('FARM INFORMATION', [
              ['Farm Location', application.applicationData['farmLocation'] ?? ''],
              ['Farm Size', '${application.applicationData['farmSize'] ?? ''} acres'],
              ['Crop Types', application.applicationData['cropTypes'] ?? ''],
            ]),

            pw.SizedBox(height: 16),

            // Bank Details
            _buildPDFSection('BANK DETAILS', [
              ['Bank Account Number', application.applicationData['bankAccount'] ?? ''],
              ['IFSC Code', application.applicationData['ifscCode'] ?? ''],
            ]),

            pw.SizedBox(height: 16),

            // Application Status
            _buildPDFSection('APPLICATION STATUS', [
              ['Current Status', _getStatusText(application.status)],
              ['Applied Date', _formatDate(application.appliedAt)],
              if (application.lastUpdated != null)
                ['Last Updated', _formatDate(application.lastUpdated!)],
            ]),

            pw.SizedBox(height: 24),

            // Progress Steps
            pw.Text(
              'APPLICATION PROGRESS',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            
            ...application.steps.map((step) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 12,
                    height: 12,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      color: step.isCompleted ? PdfColors.green : PdfColors.grey300,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          step.title,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        pw.Text(
                          step.description,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        if (step.completedAt != null)
                          pw.Text(
                            'Completed: ${_formatDate(step.completedAt!)}',
                            style: pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.green,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )),

            pw.SizedBox(height: 24),

            // Documents
            pw.Text(
              'UPLOADED DOCUMENTS',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            ...application.uploadedDocuments.asMap().entries.map((entry) =>
              pw.Text('${entry.key + 1}. Document ${entry.key + 1}')
            ),

            pw.SizedBox(height: 24),

            // Footer
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Column(
                children: [
                  pw.Divider(thickness: 1),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'This is a system-generated document from VFARM',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    'Generated on: ${_formatDate(DateTime.now())}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPDFSection(String title, List<List<String>> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: data.map((row) => pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  row[0],
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(row[1]),
              ),
            ],
          )).toList(),
        ),
      ],
    );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}