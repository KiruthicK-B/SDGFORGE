import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vfarm/models/document_model.dart';
import 'dart:io';

class DocumentViewerScreen extends StatefulWidget {
  final DocumentModel document;

  const DocumentViewerScreen({super.key, required this.document});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  bool _isDownloading = false;
  bool _showFullScreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A9D88),
        foregroundColor: Colors.white,
        title: Text(widget.document.fileName),
        actions: [
          IconButton(
            icon: Icon(_isDownloading ? Icons.downloading : Icons.download),
            onPressed: _isDownloading ? null : _downloadDocument,
          ),
          if (_isImageFile(widget.document.fileType))
            IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: () => setState(() => _showFullScreen = true),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDocumentCard(),
                const SizedBox(height: 20),
                _buildPreview(),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          ),
          if (_showFullScreen && _isImageFile(widget.document.fileType)) 
            _buildFullScreenViewer(),
        ],
      ),
    );
  }

  Widget _buildDocumentCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(widget.document.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(widget.document.category),
                    color: _getCategoryColor(widget.document.category),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.document.fileName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.document.category,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow('File Type', widget.document.fileType.toUpperCase()),
            _buildInfoRow('File Size', _formatFileSize(widget.document.fileSize)),
            _buildInfoRow('Upload Date', '${widget.document.uploadDate.day}/${widget.document.uploadDate.month}/${widget.document.uploadDate.year}'),
            if (widget.document.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Tags', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.document.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A9D88).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(tag, style: const TextStyle(color: Color(0xFF0A9D88), fontWeight: FontWeight.bold)),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: _isImageFile(widget.document.fileType) 
            ? _buildImagePreview()
            : _buildFilePreview(),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: () => setState(() => _showFullScreen = true),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: widget.document.fileUrl,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text('Unable to load image', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFileIcon(widget.document.fileType),
            size: 64,
            color: _getCategoryColor(widget.document.category),
          ),
          const SizedBox(height: 12),
          Text(
            widget.document.fileType.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap "Open Document" to view',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _openDocument,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Document'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A9D88),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isDownloading ? null : _downloadDocument,
            icon: Icon(_isDownloading ? Icons.downloading : Icons.download),
            label: Text(_isDownloading ? 'Downloading...' : 'Download'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0A9D88),
              side: const BorderSide(color: Color(0xFF0A9D88)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullScreenViewer() {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: CachedNetworkImage(
                imageUrl: widget.document.fileUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white, size: 64),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => setState(() => _showFullScreen = false),
            ),
          ),
          Positioned(
            top: 50,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.download, color: Colors.white, size: 30),
              onPressed: _downloadDocument,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600])),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Crop History': return Colors.green;
      case 'Invoices': return Colors.blue;
      case 'Land Documents': return Colors.orange;
      case 'Agri-Loan Records': return Colors.purple;
      default: return const Color(0xFF0A9D88);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Crop History': return Icons.agriculture;
      case 'Invoices': return Icons.receipt;
      case 'Land Documents': return Icons.landscape;
      case 'Agri-Loan Records': return Icons.account_balance;
      default: return Icons.description;
    }
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc':
      case 'docx': return Icons.description;
      case 'xls':
      case 'xlsx': return Icons.table_chart;
      case 'ppt':
      case 'pptx': return Icons.slideshow;
      case 'txt': return Icons.text_snippet;
      default: return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  bool _isImageFile(String fileType) {
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(fileType.toLowerCase());
  }

  Future<void> _openDocument() async {
    try {
      final uri = Uri.parse(widget.document.fileUrl);
      
      // For Firebase Storage URLs, try browser first as it handles auth better
      if (widget.document.fileUrl.contains('firebasestorage.googleapis.com')) {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) return;
        
        // Fallback to in-app browser
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
        return;
      }
      
      // Try to launch with different modes for better compatibility
      bool launched = false;
      
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e2) {
          // Final fallback - try to launch in browser
          launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
        }
      }
      
      if (launched) {
        _showSnackBar('Opening document...');
      } else {
        _showSnackBar('No app found to open this file type. Try downloading first.');
      }
    } catch (e) {
      print('Open document error: $e');
      _showSnackBar('Unable to open document. Try downloading instead.');
    }
  }

  Future<void> _downloadDocument() async {
    if (_isDownloading) return;
    
    setState(() => _isDownloading = true);
    
    try {
      // Request storage permission
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          _showSnackBar('Storage permission denied');
          setState(() => _isDownloading = false);
          return;
        }
      }

      // Configure Dio with proper settings
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);
      dio.options.followRedirects = true;
      dio.options.validateStatus = (status) => status! < 500;
      
      // Add headers for Firebase Storage
      dio.options.headers = {
        'User-Agent': 'Mozilla/5.0 (Android; Mobile)',
        'Accept': '*/*',
      };
      
      // Get downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath = '${directory!.path}/${widget.document.fileName}';

      // Test network connectivity first
      final response = await dio.head(widget.document.fileUrl);
      if (response.statusCode != 200) {
        throw Exception('File not accessible');
      }

      await dio.download(
        widget.document.fileUrl,
        filePath,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print('Download progress: $progress%');
          }
        },
      );

      _showSnackBar('Downloaded: ${widget.document.fileName}');
    } catch (e) {
      print('Download error: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        _showSnackBar('Network error. Please check your connection and try again.');
      } else if (e.toString().contains('403') || e.toString().contains('401')) {
        _showSnackBar('Access denied. File may have expired.');
      } else {
        _showSnackBar('Download failed. Error: ${e.toString().split(':').last.trim()}');
      }
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: const Color(0xFF0A9D88),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}