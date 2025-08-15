

// // import 'package:flutter/material.dart';
// // import 'package:vfarm/home.dart';

// // class MyVaultScreen extends StatelessWidget {
// //   const MyVaultScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return const MainWrapper(
// //       currentRoute: '/myVault',
// //       child: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.folder, size: 64, color: Color(0xFF0A9D88)),
// //             SizedBox(height: 16),
// //             Text(
// //               "My Vault",
// //               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// //             ),
// //             SizedBox(height: 8),
// //             Text(
// //               "Store and manage your documents",
// //               style: TextStyle(fontSize: 16, color: Colors.grey),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }



// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:shimmer/shimmer.dart';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'dart:math' as math;
// // Models
// class DocumentRecord {
//   final String id;
//   final String title;
//   final String category;
//   final String fileUrl;
//   final String fileName;
//   final String fileType;
//   final DateTime uploadDate;
//   final List<String> tags;
//   final String userId;
//   final int fileSize;

//   DocumentRecord({
//     required this.id,
//     required this.title,
//     required this.category,
//     required this.fileUrl,
//     required this.fileName,
//     required this.fileType,
//     required this.uploadDate,
//     required this.tags,
//     required this.userId,
//     required this.fileSize,
//   });

//   factory DocumentRecord.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return DocumentRecord(
//       id: doc.id,
//       title: data['title'] ?? '',
//       category: data['category'] ?? '',
//       fileUrl: data['fileUrl'] ?? '',
//       fileName: data['fileName'] ?? '',
//       fileType: data['fileType'] ?? '',
//       uploadDate: (data['uploadDate'] as Timestamp).toDate(),
//       tags: List<String>.from(data['tags'] ?? []),
//       userId: data['userId'] ?? '',
//       fileSize: data['fileSize'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toFirestore() {
//     return {
//       'title': title,
//       'category': category,
//       'fileUrl': fileUrl,
//       'fileName': fileName,
//       'fileType': fileType,
//       'uploadDate': Timestamp.fromDate(uploadDate),
//       'tags': tags,
//       'userId': userId,
//       'fileSize': fileSize,
//     };
//   }
// }

// class UserProfile {
//   final String userId;
//   final String name;
//   final String email;
//   final String phone;
//   final String farmName;
//   final String location;
//   final double farmSize;
//   final String profileImageUrl;
//   final DateTime createdAt;

//   UserProfile({
//     required this.userId,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.farmName,
//     required this.location,
//     required this.farmSize,
//     required this.profileImageUrl,
//     required this.createdAt,
//   });

//   factory UserProfile.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return UserProfile(
//       userId: doc.id,
//       name: data['name'] ?? '',
//       email: data['email'] ?? '',
//       phone: data['phone'] ?? '',
//       farmName: data['farmName'] ?? '',
//       location: data['location'] ?? '',
//       farmSize: data['farmSize']?.toDouble() ?? 0.0,
//       profileImageUrl: data['profileImageUrl'] ?? '',
//       createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//     );
//   }

//   Map<String, dynamic> toFirestore() {
//     return {
//       'name': name,
//       'email': email,
//       'phone': phone,
//       'farmName': farmName,
//       'location': location,
//       'farmSize': farmSize,
//       'profileImageUrl': profileImageUrl,
//       'createdAt': Timestamp.fromDate(createdAt),
//     };
//   }
// }

// // Services
// class FirebaseService {
//   static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   static final FirebaseStorage _storage = FirebaseStorage.instance;
//   static final FirebaseAuth _auth = FirebaseAuth.instance;

//   static String get currentUserId => _auth.currentUser?.uid ?? '';

//   // Document operations
//   static Future<List<DocumentRecord>> getDocuments({String? category, String? searchQuery}) async {
//     Query query = _firestore
//         .collection('documents')
//         .where('userId', isEqualTo: currentUserId)
//         .orderBy('uploadDate', descending: true);

//     if (category != null && category != 'All') {
//       query = query.where('category', isEqualTo: category);
//     }

//     QuerySnapshot snapshot = await query.get();
//     List<DocumentRecord> documents = snapshot.docs
//         .map((doc) => DocumentRecord.fromFirestore(doc))
//         .toList();

//     if (searchQuery != null && searchQuery.isNotEmpty) {
//       documents = documents.where((doc) {
//         return doc.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
//             doc.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()));
//       }).toList();
//     }

//     return documents;
//   }

//   static Future<String> uploadFile(File file, String category) async {
//     String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
//     String path = 'documents/$currentUserId/$category/$fileName';
    
//     UploadTask uploadTask = _storage.ref(path).putFile(file);
//     TaskSnapshot snapshot = await uploadTask;
//     return await snapshot.ref.getDownloadURL();
//   }

//   static Future<String> uploadWebFile(Uint8List fileBytes, String fileName, String category) async {
//     String path = 'documents/$currentUserId/$category/${DateTime.now().millisecondsSinceEpoch}_$fileName';
//     UploadTask uploadTask = _storage.ref(path).putData(fileBytes);
//     TaskSnapshot snapshot = await uploadTask;
//     return await snapshot.ref.getDownloadURL();
//   }

//   static Future<void> addDocument(DocumentRecord document) async {
//     await _firestore.collection('documents').add(document.toFirestore());
//   }

//   static Future<void> deleteDocument(String documentId) async {
//     await _firestore.collection('documents').doc(documentId).delete();
//   }

//   // User profile operations
//   static Future<UserProfile?> getUserProfile() async {
//     if (currentUserId.isEmpty) return null;
    
//     DocumentSnapshot doc = await _firestore.collection('users').doc(currentUserId).get();
//     if (doc.exists) {
//       return UserProfile.fromFirestore(doc);
//     }
//     return null;
//   }

//   static Future<void> updateUserProfile(UserProfile profile) async {
//     await _firestore.collection('users').doc(currentUserId).set(profile.toFirestore());
//   }

//   static Future<String> uploadProfileImage(File file) async {
//     String path = 'profiles/$currentUserId/profile_image.jpg';
//     UploadTask uploadTask = _storage.ref(path).putFile(file);
//     TaskSnapshot snapshot = await uploadTask;
//     return await snapshot.ref.getDownloadURL();
//   }

//   static Future<String> uploadProfileImageWeb(Uint8List fileBytes) async {
//     String path = 'profiles/$currentUserId/profile_image.jpg';
//     UploadTask uploadTask = _storage.ref(path).putData(fileBytes);
//     TaskSnapshot snapshot = await uploadTask;
//     return await snapshot.ref.getDownloadURL();
//   }
// }

// // Main Vault Screen
// class MyVaultScreen extends StatefulWidget {
//   const MyVaultScreen({super.key});

//   @override
//   State<MyVaultScreen> createState() => _MyVaultScreenState();
// }

// class _MyVaultScreenState extends State<MyVaultScreen> {
//   List<DocumentRecord> documents = [];
//   bool isLoading = true;
//   String selectedCategory = 'All';
//   String searchQuery = '';
//   UserProfile? userProfile;

//   final List<String> categories = [
//     'All',
//     'Crop History',
//     'Invoices',
//     'Land Documents',
//     'Agri-Loan Records'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() => isLoading = true);
//     await Future.wait([
//       _loadDocuments(),
//       _loadUserProfile(),
//     ]);
//     setState(() => isLoading = false);
//   }

//   Future<void> _loadDocuments() async {
//     try {
//       final docs = await FirebaseService.getDocuments(
//         category: selectedCategory,
//         searchQuery: searchQuery,
//       );
//       setState(() => documents = docs);
//     } catch (e) {
//       _showSnackBar('Error loading documents: $e');
//     }
//   }

//   Future<void> _loadUserProfile() async {
//     try {
//       final profile = await FirebaseService.getUserProfile();
//       setState(() => userProfile = profile);
//     } catch (e) {
//       _showSnackBar('Error loading profile: $e');
//     }
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAF9),
//       appBar: AppBar(
//         title: const Text('My Vault', style: TextStyle(fontWeight: FontWeight.bold)),
//         backgroundColor: const Color(0xFF0A9D88),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person),
//             onPressed: () => _showProfileDialog(),
//           ),
//         ],
//       ),
//       body: isLoading ? _buildLoadingWidget() : _buildMainContent(),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showUploadDialog,
//         backgroundColor: const Color(0xFF0A9D88),
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildLoadingWidget() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: Column(
//         children: [
//           Container(height: 60, margin: const EdgeInsets.all(16), color: Colors.white),
//           Container(height: 40, margin: const EdgeInsets.symmetric(horizontal: 16), color: Colors.white),
//           Expanded(
//             child: ListView.builder(
//               itemCount: 5,
//               itemBuilder: (context, index) => Container(
//                 height: 100,
//                 margin: const EdgeInsets.all(16),
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMainContent() {
//     return Column(
//       children: [
//         _buildSearchBar(),
//         _buildCategoryFilter(),
//         Expanded(child: _buildDocumentList()),
//       ],
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextField(
//         onChanged: (value) {
//           setState(() => searchQuery = value);
//           _loadDocuments();
//         },
//         decoration: const InputDecoration(
//           hintText: 'Search documents and tags...',
//           prefixIcon: Icon(Icons.search, color: Color(0xFF0A9D88)),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.all(16),
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryFilter() {
//     return SizedBox(
//       height: 50,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           final category = categories[index];
//           final isSelected = category == selectedCategory;
//           return Container(
//             margin: const EdgeInsets.only(right: 8),
//             child: FilterChip(
//               label: Text(category),
//               selected: isSelected,
//               onSelected: (selected) {
//                 setState(() => selectedCategory = category);
//                 _loadDocuments();
//               },
//               backgroundColor: Colors.white,
//               selectedColor: const Color(0xFF0A9D88).withOpacity(0.2),
//               checkmarkColor: const Color(0xFF0A9D88),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDocumentList() {
//     if (documents.isEmpty) {
//       return _buildEmptyState();
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: documents.length,
//       itemBuilder: (context, index) => _buildDocumentCard(documents[index]),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             'No documents found',
//             style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Upload your first document to get started',
//             style: TextStyle(fontSize: 14, color: Colors.grey[500]),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: _showUploadDialog,
//             icon: const Icon(Icons.upload_file),
//             label: const Text('Upload Document'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0A9D88),
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDocumentCard(DocumentRecord document) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         onTap: () => _openDocument(document),
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               _buildFileIcon(document.fileType),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       document.title,
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       document.category,
//                       style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '${_formatFileSize(document.fileSize)} • ${_formatDate(document.uploadDate)}',
//                       style: TextStyle(color: Colors.grey[500], fontSize: 12),
//                     ),
//                     if (document.tags.isNotEmpty) ...[
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 4,
//                         children: document.tags.take(3).map((tag) => Chip(
//                           label: Text(tag, style: const TextStyle(fontSize: 10)),
//                           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           visualDensity: VisualDensity.compact,
//                         )).toList(),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               PopupMenuButton<String>(
//                 onSelected: (value) {
//                   if (value == 'delete') {
//                     _deleteDocument(document);
//                   }
//                 },
//                 itemBuilder: (context) => [
//                   const PopupMenuItem(value: 'delete', child: Text('Delete')),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFileIcon(String fileType) {
//     IconData icon;
//     Color color;
    
//     switch (fileType.toLowerCase()) {
//       case 'pdf':
//         icon = Icons.picture_as_pdf;
//         color = Colors.red;
//         break;
//       case 'jpg':
//       case 'jpeg':
//       case 'png':
//         icon = Icons.image;
//         color = Colors.blue;
//         break;
//       case 'doc':
//       case 'docx':
//         icon = Icons.description;
//         color = Colors.blue[800]!;
//         break;
//       default:
//         icon = Icons.insert_drive_file;
//         color = Colors.grey;
//     }
    
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Icon(icon, color: color, size: 24),
//     );
//   }

//   String _formatFileSize(int bytes) {
//     if (bytes < 1024) return '$bytes B';
//     if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
//     return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   void _openDocument(DocumentRecord document) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => DocumentViewerScreen(document: document),
//       ),
//     );
//   }

//   void _deleteDocument(DocumentRecord document) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Document'),
//         content: Text('Are you sure you want to delete "${document.title}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await FirebaseService.deleteDocument(document.id);
//               _loadDocuments();
//               _showSnackBar('Document deleted successfully');
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showUploadDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => UploadDocumentDialog(
//         onUploaded: () {
//           Navigator.pop(context);
//           _loadDocuments();
//         },
//       ),
//     );
//   }

//   void _showProfileDialog() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProfileScreen(
//           userProfile: userProfile,
//           onUpdated: _loadUserProfile,
//         ),
//       ),
//     );
//   }
// }

// // Upload Document Dialog
// class UploadDocumentDialog extends StatefulWidget {
//   final VoidCallback onUploaded;

//   const UploadDocumentDialog({super.key, required this.onUploaded});

//   @override
//   State<UploadDocumentDialog> createState() => _UploadDocumentDialogState();
// }

// class _UploadDocumentDialogState extends State<UploadDocumentDialog> {
//   final _titleController = TextEditingController();
//   final _tagsController = TextEditingController();
//   String selectedCategory = 'Crop History';
//   bool isUploading = false;
//   File? selectedFile;
//   Uint8List? selectedWebFile;
//   String? selectedFileName;

//   final List<String> categories = [
//     'Crop History',
//     'Invoices',
//     'Land Documents',
//     'Agri-Loan Records'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Upload Document'),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: const InputDecoration(
//                 labelText: 'Document Title',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: selectedCategory,
//               decoration: const InputDecoration(
//                 labelText: 'Category',
//                 border: OutlineInputBorder(),
//               ),
//               items: categories.map((category) => DropdownMenuItem(
//                 value: category,
//                 child: Text(category),
//               )).toList(),
//               onChanged: (value) => setState(() => selectedCategory = value!),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _tagsController,
//               decoration: const InputDecoration(
//                 labelText: 'Tags (comma separated)',
//                 border: OutlineInputBorder(),
//                 hintText: 'e.g., wheat, 2024, harvest',
//               ),
//             ),
//             const SizedBox(height: 16),
//             if (selectedFile != null || selectedWebFile != null)
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.check_circle, color: Colors.green),
//                     const SizedBox(width: 8),
//                     Expanded(child: Text('Selected: $selectedFileName')),
//                   ],
//                 ),
//               ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: _pickFile,
//               icon: const Icon(Icons.attach_file),
//               label: const Text('Select File'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF0A9D88),
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: isUploading ? null : () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: isUploading || (selectedFile == null && selectedWebFile == null)
//               ? null
//               : _uploadDocument,
//           child: isUploading
//               ? const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//               : const Text('Upload'),
//         ),
//       ],
//     );
//   }

//   Future<void> _pickFile() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.any,
//         allowedExtensions: null,
//       );

//       if (result != null) {
//         if (kIsWeb) {
//           setState(() {
//             selectedWebFile = result.files.single.bytes;
//             selectedFileName = result.files.single.name;
//           });
//         } else {
//           setState(() {
//             selectedFile = File(result.files.single.path!);
//             selectedFileName = result.files.single.name;
//           });
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking file: $e')),
//       );
//     }
//   }

//   Future<void> _uploadDocument() async {
//     if (_titleController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a title')),
//       );
//       return;
//     }

//     setState(() => isUploading = true);

//     try {
//       String fileUrl;
//       int fileSize;
//       String fileType = selectedFileName!.split('.').last.toLowerCase();

//       if (kIsWeb && selectedWebFile != null) {
//         fileUrl = await FirebaseService.uploadWebFile(
//           selectedWebFile!,
//           selectedFileName!,
//           selectedCategory,
//         );
//         fileSize = selectedWebFile!.length;
//       } else if (selectedFile != null) {
//         fileUrl = await FirebaseService.uploadFile(selectedFile!, selectedCategory);
//         fileSize = await selectedFile!.length();
//       } else {
//         throw Exception('No file selected');
//       }

//       List<String> tags = _tagsController.text
//           .split(',')
//           .map((tag) => tag.trim())
//           .where((tag) => tag.isNotEmpty)
//           .toList();

//       DocumentRecord document = DocumentRecord(
//         id: '',
//         title: _titleController.text,
//         category: selectedCategory,
//         fileUrl: fileUrl,
//         fileName: selectedFileName!,
//         fileType: fileType,
//         uploadDate: DateTime.now(),
//         tags: tags,
//         userId: FirebaseService.currentUserId,
//         fileSize: fileSize,
//       );

//       await FirebaseService.addDocument(document);
//       widget.onUploaded();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Document uploaded successfully')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error uploading document: $e')),
//       );
//     } finally {
//       setState(() => isUploading = false);
//     }
//   }
// }

// // Document Viewer Screen
// class DocumentViewerScreen extends StatelessWidget {
//   final DocumentRecord document;

//   const DocumentViewerScreen({super.key, required this.document});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(document.title),
//         backgroundColor: const Color(0xFF0A9D88),
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               _getFileIcon(document.fileType),
//               size: 64,
//               color: const Color(0xFF0A9D88),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               document.fileName,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Category: ${document.category}',
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Uploaded: ${_formatDate(document.uploadDate)}',
//               style: TextStyle(fontSize: 14, color: Colors.grey[500]),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () {
//                 // Here you would implement file opening logic
//                 // For web, you can use html.window.open(document.fileUrl)
//                 // For mobile, you can use url_launcher package
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Opening file...')),
//                 );
//               },
//               icon: const Icon(Icons.open_in_new),
//               label: const Text('Open File'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF0A9D88),
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   IconData _getFileIcon(String fileType) {
//     switch (fileType.toLowerCase()) {
//       case 'pdf':
//         return Icons.picture_as_pdf;
//       case 'jpg':
//       case 'jpeg':
//       case 'png':
//         return Icons.image;
//       case 'doc':
//       case 'docx':
//         return Icons.description;
//       default:
//         return Icons.insert_drive_file;
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }

// // Profile Screen
// class ProfileScreen extends StatefulWidget {
//   final UserProfile? userProfile;
//   final VoidCallback onUpdated;

//   const ProfileScreen({super.key, this.userProfile, required this.onUpdated});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _farmNameController = TextEditingController();
//   final _locationController = TextEditingController();
//   final _farmSizeController = TextEditingController();
//   bool isUpdating = false;
//   File? selectedImage;
//   Uint8List? selectedWebImage;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.userProfile != null) {
//       _nameController.text = widget.userProfile!.name;
//       _phoneController.text = widget.userProfile!.phone;
//       _farmNameController.text = widget.userProfile!.farmName;
//       _locationController.text = widget.userProfile!.location;
//       _farmSizeController.text = widget.userProfile!.farmSize.toString();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: const Color(0xFF0A9D88),
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _buildProfileImage(),
//             const SizedBox(height: 24),
//             _buildTextField(_nameController, 'Name', Icons.person),
//             const SizedBox(height: 16),
//             _buildTextField(_phoneController, 'Phone', Icons.phone),
//             const SizedBox(height: 16),
//             _buildTextField(_farmNameController, 'Farm Name', Icons.agriculture),
//             const SizedBox(height: 16),
//             _buildTextField(_locationController, 'Location', Icons.location_on),
//             const SizedBox(height: 16),
//             _buildTextField(_farmSizeController, 'Farm Size (acres)', Icons.landscape, isNumber: true),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: isUpdating ? null : _updateProfile,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF0A9D88),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.all(16),
//                 ),
//                 child: isUpdating
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text('Update Profile', style: TextStyle(fontSize: 16)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileImage() {
//     return GestureDetector(
//       onTap: _pickImage,
//       child: Container(
//         width: 120,
//         height: 120,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.grey[200],
//           border: Border.all(color: const Color(0xFF0A9D88), width: 3),
//         ),
//         child: ClipOval(
//           child: _getImageWidget(),
//         ),
//       ),
//     );
//   }

//   Widget _getImageWidget() {
//     if (selectedImage != null) {
//       return Image.file(selectedImage!, fit: BoxFit.cover);
//     } else if (selectedWebImage != null) {
//       return Image.memory(selectedWebImage!, fit: BoxFit.cover);
//     } else if (widget.userProfile?.profileImageUrl.isNotEmpty == true) {
//       return CachedNetworkImage(
//         imageUrl: widget.userProfile!.profileImageUrl,
//         fit: BoxFit.cover,
//         placeholder: (context, url) => const CircularProgressIndicator(),
//         errorWidget: (context, url, error) => const Icon(Icons.person, size: 60),
//       );
//     } else {
//       return const Icon(Icons.person, size: 60, color: Colors.grey);
//     }
//   }

//   Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
//     return TextField(
//       controller: controller,
//       keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: const Color(0xFF0A9D88)),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFF0A9D88)),
//         ),
//       ),
//     );
//   }

//   Future<void> _pickImage() async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
//       if (image != null) {
//         if (kIsWeb) {
//           final bytes = await image.readAsBytes();
//           setState(() => selectedWebImage = bytes);
//         } else {
//           setState(() => selectedImage = File(image.path));
//         }
//       }
//     } catch (e) {
//       _showSnackBar('Error picking image: $e');
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_nameController.text.isEmpty) {
//       _showSnackBar('Please enter your name');
//       return;
//     }

//     setState(() => isUpdating = true);

//     try {
//       String profileImageUrl = widget.userProfile?.profileImageUrl ?? '';

//       // Upload new profile image if selected
//       if (selectedImage != null) {
//         profileImageUrl = await FirebaseService.uploadProfileImage(selectedImage!);
//       } else if (selectedWebImage != null) {
//         profileImageUrl = await FirebaseService.uploadProfileImageWeb(selectedWebImage!);
//       }

//       final profile = UserProfile(
//         userId: FirebaseService.currentUserId,
//         name: _nameController.text,
//         email: FirebaseAuth.instance.currentUser?.email ?? '',
//         phone: _phoneController.text,
//         farmName: _farmNameController.text,
//         location: _locationController.text,
//         farmSize: double.tryParse(_farmSizeController.text) ?? 0.0,
//         profileImageUrl: profileImageUrl,
//         createdAt: widget.userProfile?.createdAt ?? DateTime.now(),
//       );

//       await FirebaseService.updateUserProfile(profile);
//       widget.onUpdated();
//       _showSnackBar('Profile updated successfully');
//       Navigator.pop(context);
//     } catch (e) {
//       _showSnackBar('Error updating profile: $e');
//     } finally {
//       setState(() => isUpdating = false);
//     }
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
// }

// // Custom Wave Loading Animation Widget
// class WaveLoadingIndicator extends StatefulWidget {
//   final Color color;
//   final double size;

//   const WaveLoadingIndicator({
//     super.key,
//     this.color = const Color(0xFF0A9D88),
//     this.size = 50.0,
//   });

//   @override
//   State<WaveLoadingIndicator> createState() => _WaveLoadingIndicatorState();
// }

// class _WaveLoadingIndicatorState extends State<WaveLoadingIndicator>
//     with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat();
//     _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return SizedBox(
//           width: widget.size,
//           height: widget.size,
//           child: CustomPaint(
//             painter: WavePainter(_animation.value, widget.color),
//           ),
//         );
//       },
//     );
//   }
// }

// class WavePainter extends CustomPainter {
//   final double animationValue;
//   final Color color;

//   WavePainter(this.animationValue, this.color);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color.withOpacity(0.7)
//       ..style = PaintingStyle.fill;

//     final path = Path();
//     final waveHeight = size.height * 0.2;
//     final waveLength = size.width;
    
//     path.moveTo(0, size.height * 0.5);
    
//     for (double x = 0; x <= size.width; x += 5) {
//       final y = size.height * 0.5 + 
//           waveHeight * 
//           math.sin((x / waveLength * 2 * math.pi) + (animationValue * 2 * math.pi));
//       path.lineTo(x, y);
//     }
    
//     path.lineTo(size.width, size.height);
//     path.lineTo(0, size.height);
//     path.close();
    
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// // Service Booking Model and Screen (Basic Implementation)
// class ServiceBooking {
//   final String id;
//   final String serviceName;
//   final String providerName;
//   final DateTime bookingDate;
//   final String status;
//   final double amount;
//   final String userId;

//   ServiceBooking({
//     required this.id,
//     required this.serviceName,
//     required this.providerName,
//     required this.bookingDate,
//     required this.status,
//     required this.amount,
//     required this.userId,
//   });

//   factory ServiceBooking.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return ServiceBooking(
//       id: doc.id,
//       serviceName: data['serviceName'] ?? '',
//       providerName: data['providerName'] ?? '',
//       bookingDate: (data['bookingDate'] as Timestamp).toDate(),
//       status: data['status'] ?? '',
//       amount: data['amount']?.toDouble() ?? 0.0,
//       userId: data['userId'] ?? '',
//     );
//   }

//   Map<String, dynamic> toFirestore() {
//     return {
//       'serviceName': serviceName,
//       'providerName': providerName,
//       'bookingDate': Timestamp.fromDate(bookingDate),
//       'status': status,
//       'amount': amount,
//       'userId': userId,
//     };
//   }
// }

// // Extended Firebase Service for Service Bookings
// extension FirebaseServiceBookings on FirebaseService {
//   static Future<List<ServiceBooking>> getServiceBookings() async {
//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//         .collection('service_bookings')
//         .where('userId', isEqualTo: FirebaseService.currentUserId)
//         .orderBy('bookingDate', descending: true)
//         .get();

//     return snapshot.docs
//         .map((doc) => ServiceBooking.fromFirestore(doc))
//         .toList();
//   }

//   static Future<void> addServiceBooking(ServiceBooking booking) async {
//     await FirebaseFirestore.instance
//         .collection('service_bookings')
//         .add(booking.toFirestore());
//   }
// }

// // Service Bookings Screen
// class ServiceBookingsScreen extends StatefulWidget {
//   const ServiceBookingsScreen({super.key});

//   @override
//   State<ServiceBookingsScreen> createState() => _ServiceBookingsScreenState();
// }

// class _ServiceBookingsScreenState extends State<ServiceBookingsScreen> {
//   List<ServiceBooking> bookings = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadBookings();
//   }

//   Future<void> _loadBookings() async {
//     setState(() => isLoading = true);
//     try {
//       final loadedBookings = await FirebaseServiceBookings.getServiceBookings();
//       setState(() => bookings = loadedBookings);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading bookings: $e')),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Service Bookings'),
//         backgroundColor: const Color(0xFF0A9D88),
//         foregroundColor: Colors.white,
//       ),
//       body: isLoading
//           ? const Center(child: WaveLoadingIndicator())
//           : bookings.isEmpty
//               ? _buildEmptyState()
//               : _buildBookingsList(),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             'No service bookings found',
//             style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBookingsList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: bookings.length,
//       itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
//     );
//   }

//   Widget _buildBookingCard(ServiceBooking booking) {
//     Color statusColor;
//     switch (booking.status.toLowerCase()) {
//       case 'completed':
//         statusColor = Colors.green;
//         break;
//       case 'pending':
//         statusColor = Colors.orange;
//         break;
//       case 'cancelled':
//         statusColor = Colors.red;
//         break;
//       default:
//         statusColor = Colors.grey;
//     }

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     booking.serviceName,
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     booking.status.toUpperCase(),
//                     style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Provider: ${booking.providerName}',
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Date: ${_formatDate(booking.bookingDate)}',
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Amount: ₹${booking.amount.toStringAsFixed(2)}',
//               style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A9D88)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:vfarm/document_viewer_screen.dart';
// import 'package:vfarm/firebase_service.dart';
// import 'package:vfarm/models/document_model.dart';
// import 'dart:io';

// import 'package:vfarm/models/user_profile_model.dart';
// import 'package:vfarm/profile_edit_screen.dart';

// class MyVaultScreen extends StatefulWidget {
//   const MyVaultScreen({super.key});

//   @override
//   State<MyVaultScreen> createState() => _MyVaultScreenState();
// }

// class _MyVaultScreenState extends State<MyVaultScreen> with TickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   String _selectedCategory = 'All';
//   UserProfileModel? _userProfile;
//   bool _isLoading = true;
//   late AnimationController _waveController;
//   late Animation<double> _waveAnimation;

//   final List<String> _categories = [
//     'All',
//     'Crop History',
//     'Invoices',
//     'Land Documents',
//     'Agri-Loan Records'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _loadUserProfile();
//   }

//   void _initializeAnimations() {
//     _waveController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat();
    
//     _waveAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_waveController);
//   }

//   Future<void> _loadUserProfile() async {
//     try {
//       final profile = await FirebaseService.getUserProfile();
//       setState(() {
//         _userProfile = profile;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showSnackBar('Error loading profile: ${e.toString()}');
//     }
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0A9D88),
//         elevation: 0,
//         title: const Text(
//           'My Vault',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person, color: Colors.white),
//             onPressed: () => _navigateToProfile(),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildHeader(),
//           _buildSearchAndFilter(),
//           Expanded(
//             child: _buildDocumentsList(),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _showUploadOptions,
//         backgroundColor: const Color(0xFF0A9D88),
//         icon: const Icon(Icons.add, color: Colors.white),
//         label: const Text(
//           'Upload Document',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
      
//     );
//   }

//   Widget _buildShimmerHeader() {
//     return Shimmer.fromColors(
//       baseColor: Colors.white24,
//       highlightColor: Colors.white38,
//       child: Row(
//         children: [
//           const CircleAvatar(radius: 30, backgroundColor: Colors.white),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: 120,
//                 height: 16,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 width: 80,
//                 height: 12,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchAndFilter() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: 'Search documents...',
//               prefixIcon: const Icon(Icons.search, color: Color(0xFF0A9D88)),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//               filled: true,
//               fillColor: Colors.white,
//             ),
//             onChanged: (value) => setState(() {}),
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             height: 40,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: _categories.length,
//               itemBuilder: (context, index) {
//                 final category = _categories[index];
//                 final isSelected = _selectedCategory == category;
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: FilterChip(
//                     label: Text(category),
//                     selected: isSelected,
//                     onSelected: (selected) {
//                       setState(() {
//                         _selectedCategory = category;
//                       });
//                     },
//                     selectedColor: const Color(0xFF0A9D88).withOpacity(0.2),
//                     checkmarkColor: const Color(0xFF0A9D88),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDocumentsList() {
//     return StreamBuilder<List<DocumentModel>>(
//       stream: FirebaseService.getUserDocuments(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return _buildLoadingList();
//         }

//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error, size: 64, color: Colors.red),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Error loading documents',
//                   style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                 ),
//                 const SizedBox(height: 8),
//                 ElevatedButton(
//                   onPressed: () => setState(() {}),
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           );
//         }

//         List<DocumentModel> documents = snapshot.data ?? [];

//         // Filter documents
//         if (_selectedCategory != 'All') {
//           documents = documents
//               .where((doc) => doc.category == _selectedCategory)
//               .toList();
//         }

//         if (_searchController.text.isNotEmpty) {
//           documents = documents
//               .where((doc) =>
//                   doc.fileName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
//                   doc.tags.any((tag) =>
//                       tag.toLowerCase().contains(_searchController.text.toLowerCase())))
//               .toList();
//         }

//         if (documents.isEmpty) {
//           return _buildEmptyState();
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: documents.length,
//           itemBuilder: (context, index) {
//             return _buildDocumentCard(documents[index]);
//           },
//         );
//       },
//     );
//   }

//   Widget _buildLoadingList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: 5,
//       itemBuilder: (context, index) {
//         return Shimmer.fromColors(
//           baseColor: Colors.grey[300]!,
//           highlightColor: Colors.grey[100]!,
//           child: Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             child: Container(
//               height: 80,
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           width: double.infinity,
//                           height: 16,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Container(
//                           width: 100,
//                           height: 12,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedBuilder(
//             animation: _waveAnimation,
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: 1.0 + (_waveAnimation.value * 0.1),
//                 child: const Icon(
//                   Icons.folder_open,
//                   size: 64,
//                   color: Color(0xFF0A9D88),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'No Documents Found',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Upload your first document to get started',
//             style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed: _showUploadOptions,
//             icon: const Icon(Icons.upload_file),
//             label: const Text('Upload Document'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0A9D88),
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDocumentCard(DocumentModel document) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         leading: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: _getCategoryColor(document.category).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             _getCategoryIcon(document.category),
//             color: _getCategoryColor(document.category),
//           ),
//         ),
//         title: Text(
//           document.fileName,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               document.category,
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//             if (document.tags.isNotEmpty) ...[
//               const SizedBox(height: 4),
//               Wrap(
//                 spacing: 4,
//                 children: document.tags.take(3).map((tag) {
//                   return Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF0A9D88).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       tag,
//                       style: const TextStyle(fontSize: 10, color: Color(0xFF0A9D88)),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ],
//           ],
//         ),
//         trailing: PopupMenuButton<String>(
//           onSelected: (value) {
//             if (value == 'view') {
//               _viewDocument(document);
//             } else if (value == 'delete') {
//               _deleteDocument(document);
//             }
//           },
//           itemBuilder: (context) => [
//             const PopupMenuItem(
//               value: 'view',
//               child: ListTile(
//                 leading: Icon(Icons.visibility),
//                 title: Text('View'),
//                 dense: true,
//               ),
//             ),
//             const PopupMenuItem(
//               value: 'delete',
//               child: ListTile(
//                 leading: Icon(Icons.delete, color: Colors.red),
//                 title: Text('Delete'),
//                 dense: true,
//               ),
//             ),
//           ],
//         ),
//         onTap: () => _viewDocument(document),
//       ),
//     );
//   }

//   Color _getCategoryColor(String category) {
//     switch (category) {
//       case 'Crop History':
//         return Colors.green;
//       case 'Invoices':
//         return Colors.blue;
//       case 'Land Documents':
//         return Colors.orange;
//       case 'Agri-Loan Records':
//         return Colors.purple;
//       default:
//         return const Color(0xFF0A9D88);
//     }
//   }

//   IconData _getCategoryIcon(String category) {
//     switch (category) {
//       case 'Crop History':
//         return Icons.agriculture;
//       case 'Invoices':
//         return Icons.receipt;
//       case 'Land Documents':
//         return Icons.landscape;
//       case 'Agri-Loan Records':
//         return Icons.account_balance;
//       default:
//         return Icons.description;
//     }
//   }

//   void _navigateToProfile() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProfileEditScreen(userProfile: _userProfile),
//       ),
//     ).then((value) {
//       if (value == true) {
//         _loadUserProfile();
//       }
//     });
//   }

//   void _showProfileImageOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.photo_camera),
//               title: const Text('Camera'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickProfileImage(ImageSource.camera);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Gallery'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickProfileImage(ImageSource.gallery);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _pickProfileImage(ImageSource source) async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       final XFile? image = await picker.pickImage(source: source);
      
//       if (image != null) {
//         _showLoadingDialog('Uploading profile image...');
        
//         final imageUrl = await FirebaseService.uploadProfileImage(File(image.path));
        
//         if (_userProfile != null) {
//           final updatedProfile = UserProfileModel(
//             uid: _userProfile!.uid,
//             name: _userProfile!.name,
//             email: _userProfile!.email,
//             phone: _userProfile!.phone,
//             farmLocation: _userProfile!.farmLocation,
//             farmSize: _userProfile!.farmSize,
//             cropTypes: _userProfile!.cropTypes,
//             profileImageUrl: imageUrl,
//             createdAt: _userProfile!.createdAt,
//           );
          
//           await FirebaseService.createOrUpdateProfile(updatedProfile);
//           await _loadUserProfile();
//         }
        
//         Navigator.pop(context); // Close loading dialog
//         _showSnackBar('Profile image updated successfully');
//       }
//     } catch (e) {
//       Navigator.pop(context); // Close loading dialog
//       _showSnackBar('Error uploading image: ${e.toString()}');
//     }
//   }

//   void _showUploadOptions() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.7,
//         maxChildSize: 0.9,
//         minChildSize: 0.5,
//         builder: (context, scrollController) {
//           return DocumentUploadSheet(
//             scrollController: scrollController,
//             onDocumentUploaded: () {
//               Navigator.pop(context);
//               _showSnackBar('Document uploaded successfully');
//             },
//           );
//         },
//       ),
//     );
//   }

//   void _viewDocument(DocumentModel document) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => DocumentViewerScreen(document: document),
//       ),
//     );
//   }

//   void _deleteDocument(DocumentModel document) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Document'),
//         content: Text('Are you sure you want to delete "${document.fileName}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               _showLoadingDialog('Deleting document...');
              
//               try {
//                 await FirebaseService.deleteDocument(document.id, document.fileUrl);
//                 Navigator.pop(context); // Close loading dialog
//                 _showSnackBar('Document deleted successfully');
//               } catch (e) {
//                 Navigator.pop(context); // Close loading dialog
//                 _showSnackBar('Error deleting document: ${e.toString()}');
//               }
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showLoadingDialog(String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         content: Row(
//           children: [
//             const CircularProgressIndicator(),
//             const SizedBox(width: 16),
//             Expanded(child: Text(message)),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _waveController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
// }

// // screens/document_upload_sheet.dart
// class DocumentUploadSheet extends StatefulWidget {
//   final ScrollController scrollController;
//   final VoidCallback onDocumentUploaded;

//   const DocumentUploadSheet({
//     super.key,
//     required this.scrollController,
//     required this.onDocumentUploaded,
//   });

//   @override
//   State<DocumentUploadSheet> createState() => _DocumentUploadSheetState();
// }

// class _DocumentUploadSheetState extends State<DocumentUploadSheet> {
//   String _selectedCategory = 'Crop History';
//   final TextEditingController _tagsController = TextEditingController();
//   File? _selectedFile;
//   bool _isUploading = false;

//   final List<String> _categories = [
//     'Crop History',
//     'Invoices',
//     'Land Documents',
//     'Agri-Loan Records'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             margin: const EdgeInsets.only(top: 10),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               controller: widget.scrollController,
//               padding: const EdgeInsets.all(20),
//               children: [
//                 const Text(
//                   'Upload Document',
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 20),
                
//                 // File selection
//                 GestureDetector(
//                   onTap: _pickFile,
//                   child: Container(
//                     height: 120,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: _selectedFile != null
//                             ? const Color(0xFF0A9D88)
//                             : Colors.grey[300]!,
//                         style: BorderStyle.solid,
//                         width: 2,
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             _selectedFile != null ? Icons.check_circle : Icons.cloud_upload,
//                             size: 40,
//                             color: _selectedFile != null
//                                 ? const Color(0xFF0A9D88)
//                                 : Colors.grey[400],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             _selectedFile != null
//                                 ? _selectedFile!.path.split('/').last
//                                 : 'Tap to select file',
//                             style: TextStyle(
//                               color: _selectedFile != null
//                                   ? const Color(0xFF0A9D88)
//                                   : Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
                
//                 // Category selection
//                 const Text(
//                   'Category',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey[300]!),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: DropdownButton<String>(
//                     value: _selectedCategory,
//                     isExpanded: true,
//                     underline: const SizedBox(),
//                     items: _categories.map((category) {
//                       return DropdownMenuItem(
//                         value: category,
//                         child: Text(category),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedCategory = value!;
//                       });
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 20),
                
//                 // Tags input
//                 const Text(
//                   'Tags (comma separated)',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: _tagsController,
//                   decoration: InputDecoration(
//                     hintText: 'e.g., rice, 2024, harvest',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
                
//                 // Upload button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: _selectedFile != null && !_isUploading
//                         ? _uploadDocument
//                         : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF0A9D88),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: _isUploading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text(
//                             'Upload Document',
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _pickFile() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.any,
//       allowMultiple: false,
//     );

//     if (result != null && result.files.isNotEmpty) {
//       setState(() {
//         _selectedFile = File(result.files.first.path!);
//       });
//     }
//   }

//   Future<void> _uploadDocument() async {
//     if (_selectedFile == null) return;

//     setState(() {
//       _isUploading = true;
//     });

//     try {
//       final fileName = _selectedFile!.path.split('/').last;
//       final fileUrl = await FirebaseService.uploadDocument(
//         _selectedFile!,
//         fileName,
//         _selectedCategory,
//       );

//       final tags = _tagsController.text
//           .split(',')
//           .map((tag) => tag.trim())
//           .where((tag) => tag.isNotEmpty)
//           .toList();

//       final document = DocumentModel(
//         id: '',
//         fileName: fileName,
//         fileUrl: fileUrl,
//         category: _selectedCategory,
//         tags: tags,
//         uploadDate: DateTime.now(),
//         userId: FirebaseService.getCurrentUser()!.uid,
//         fileSize: await _selectedFile!.length(),
//         fileType: fileName.split('.').last,
//       );

//       await FirebaseService.saveDocumentMetadata(document);
//       widget.onDocumentUploaded();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Upload failed: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isUploading = false;
//         });
//       }
//     }
//   }
// }

















// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:vfarm/document_viewer_screen.dart';
// import 'package:vfarm/firebase_service.dart';
// import 'package:vfarm/models/document_model.dart';
// import 'dart:io';
// import 'dart:async';

// import 'package:vfarm/models/user_profile_model.dart';
// import 'package:vfarm/profile_edit_screen.dart';

// class MyVaultScreen extends StatefulWidget {
//   const MyVaultScreen({super.key});

//   @override
//   State<MyVaultScreen> createState() => _MyVaultScreenState();
// }

// class _MyVaultScreenState extends State<MyVaultScreen> with TickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   String _selectedCategory = 'All';
//   UserProfileModel? _userProfile;
//   bool _isLoading = true;
//   late AnimationController _waveController;
//   late Animation<double> _waveAnimation;
//   User? _currentUser;

//   final List<String> _categories = [
//     'All',
//     'Crop History',
//     'Invoices',
//     'Land Documents',
//     'Agri-Loan Records'
//   ];
  
// @override
// void initState() {
//   super.initState();
//   _initializeAnimations();
//   _initializeAuth();
// }

// void _initializeAnimations() {
//   _waveController = AnimationController(
//     duration: const Duration(seconds: 5),
//     vsync: this,
//   )..repeat();
  
//   _waveAnimation = Tween<double>(
//     begin: 0.0,
//     end: 1.0,
//   ).animate(_waveController);
// }

// Future<void> _initializeAuth() async {
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getString('loggedInUserId');
//     final username = prefs.getString('loggedInUsername');
//     final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//     final loginTimestamp = prefs.getString('loginTimestamp');
    
//     debugPrint('Session check - userId: $userId, username: $username, isLoggedIn: $isLoggedIn');
    
//     // Validate session data
//     if (userId != null &&
//         username != null &&
//         userId.isNotEmpty &&
//         username.isNotEmpty &&
//         isLoggedIn) {
      
//       // Optional: Check if session is still valid (e.g., within 30 days)
//       if (loginTimestamp != null) {
//         final loginTime = DateTime.parse(loginTimestamp);
//         final now = DateTime.now();
//         final daysDifference = now.difference(loginTime).inDays;
        
//         if (daysDifference > 30) {
//           debugPrint('Session expired, redirecting to login');
//           await _clearSession();
//           _redirectToLogin();
//           return;
//         }
//       }
      
//       // Valid session found, load user profile with userId
//       debugPrint('Valid session found for user: $username');
//       await _loadUserProfile(userId);
      
//     } else {
//       debugPrint('No valid session found, redirecting to login');
//       _redirectToLogin();
//     }
//   } catch (e) {
//     debugPrint('Error checking existing session: $e');
//     _redirectToLogin();
//   }
// }
// void _redirectToLogin() {
//   if (mounted) {
//     Navigator.of(context).pushReplacementNamed('/login');
//   }
// }
// Future<void> _loadUserProfile(String userId) async {
//   try {
//     debugPrint('Loading profile for userId: $userId');
//     setState(() {
//       _isLoading = true;
//     });
    
//     // Load profile using userId from SharedPreferences
//     final profile = await FirebaseService.getUserProfile(userId);
//     debugPrint('Profile loaded successfully: ${profile?.name}');
    
//     if (mounted) {
//       setState(() {
//         _userProfile = profile;
//         _isLoading = false;
//       });
//     }
//   } catch (e) {
//     debugPrint('Error in _loadUserProfile: $e');
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//       // Don't redirect to login on profile load error, just show error
//       _showSnackBar('Error loading profile: ${e.toString()}');
//     }
//   }
// }
// Future<void> _clearSession() async {
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('loggedInUserId');
//     await prefs.remove('loggedInUsername');
//     await prefs.remove('loggedInEmail');
//     await prefs.remove('isLoggedIn');
//     await prefs.remove('loginTimestamp');
//     debugPrint('Session cleared successfully');
//   } catch (e) {
//     debugPrint('Error clearing session: $e');
//   }
// }

// void _showSnackBar(String message) {
//   if (mounted) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: message.contains('Error') ? Colors.red : const Color(0xFF0A9D88),
//       ),
//     );
//   }
// }
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Colors.grey[50],
//     appBar: AppBar(
//       backgroundColor: const Color(0xFF0A9D88),
//       elevation: 0,
//       title: const Text(
//         'My Vault',
//         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.person, color: Colors.white),
//           onPressed: () => _navigateToProfile(),
//         ),
//         IconButton(
//           icon: const Icon(Icons.logout, color: Colors.white),
//           onPressed: () => _showLogoutDialog(),
//         ),
//       ],
//     ),
//     body: Column(
//       children: [
//         _buildHeader(),
//         _buildSearchAndFilter(),
//         Expanded(
//           child: _buildDocumentsList(),
//         ),
//       ],
//     ),
//     floatingActionButton: FloatingActionButton.extended(
//       onPressed: _showUploadOptions,
//       backgroundColor: const Color(0xFF0A9D88),
//       icon: const Icon(Icons.add, color: Colors.white),
//       label: const Text(
//         'Upload Document',
//         style: TextStyle(color: Colors.white),
//       ),
//     ),
//   );
// }

// Widget _buildHeader() {
//   return Container(
//     padding: const EdgeInsets.all(16),
//     decoration: const BoxDecoration(
//       color: Color(0xFF0A9D88),
//       borderRadius: BorderRadius.only(
//         bottomLeft: Radius.circular(20),
//         bottomRight: Radius.circular(20),
//       ),
//     ),
//     child: _isLoading ? _buildShimmerHeader() : _buildUserHeader(),
//   );
// }

// Widget _buildUserHeader() {
//   // Safe method to get the first character for avatar
//   String getInitial() {
//     String? name = _userProfile?.name ?? _userProfile?.username ?? _currentUser?.displayName;
//     if (name != null && name.trim().isNotEmpty) {
//       return name.trim().substring(0, 1).toUpperCase();
//     }
//     return 'U'; // Default fallback
//   }

//   // Safe method to get display name
//   String getDisplayName() {
//     return _userProfile?.name.isNotEmpty == true 
//         ? _userProfile!.name 
//         : _userProfile?.username.isNotEmpty == true
//             ? _userProfile!.username
//             : _currentUser?.displayName?.isNotEmpty == true
//                 ? _currentUser!.displayName!
//                 : 'User';
//   }

//   return Row(
//     children: [
//       GestureDetector(
//         onTap: _showProfileImageOptions,
//         child: CircleAvatar(
//           radius: 30,
//           backgroundColor: Colors.white,
//           backgroundImage: _userProfile?.profileImageUrl != null &&
//                   _userProfile!.profileImageUrl!.isNotEmpty
//               ? CachedNetworkImageProvider(_userProfile!.profileImageUrl!)
//               : null,
//           child: _userProfile?.profileImageUrl == null ||
//                   _userProfile!.profileImageUrl!.isEmpty
//               ? Text(
//                   getInitial(),
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF0A9D88),
//                   ),
//                 )
//               : null,
//         ),
//       ),
//       const SizedBox(width: 16),
//       Expanded(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Welcome back,',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.white.withOpacity(0.8),
//               ),
//             ),
//             Text(
//               getDisplayName(),
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             if (_userProfile?.farmLocation != null &&
//                 _userProfile!.farmLocation!.isNotEmpty)
//               Text(
//                 _userProfile!.farmLocation!,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.white.withOpacity(0.7),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     ],
//   );
// }

// Widget _buildShimmerHeader() {
//   return Shimmer.fromColors(
//     baseColor: Colors.white24,
//     highlightColor: Colors.white38,
//     child: Row(
//       children: [
//         const CircleAvatar(radius: 30, backgroundColor: Colors.white),
//         const SizedBox(width: 16),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: 120,
//               height: 16,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               width: 80,
//               height: 12,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(6),
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildSearchAndFilter() {
//   return Padding(
//     padding: const EdgeInsets.all(16),
//     child: Column(
//       children: [
//         TextField(
//           controller: _searchController,
//           decoration: InputDecoration(
//             hintText: 'Search documents...',
//             prefixIcon: const Icon(Icons.search, color: Color(0xFF0A9D88)),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: Colors.white,
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           ),
//           onChanged: (value) => setState(() {}),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           height: 40,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: _categories.length,
//             itemBuilder: (context, index) {
//               final category = _categories[index];
//               final isSelected = _selectedCategory == category;
//               return Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: FilterChip(
//                   label: Text(category),
//                   selected: isSelected,
//                   onSelected: (selected) {
//                     setState(() {
//                       _selectedCategory = category;
//                     });
//                   },
//                   selectedColor: const Color(0xFF0A9D88).withOpacity(0.2),
//                   checkmarkColor: const Color(0xFF0A9D88),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildDocumentsList() {
//   // Enhanced authentication check - try multiple approaches
//   final userId = FirebaseService.getCurrentUserId();
//   final isAuthenticated = _currentUser != null || userId != null;
  
//   // Debug prints to help troubleshoot
//   print('Debug - Current User: ${_currentUser?.uid}');
//   print('Debug - Firebase Service User ID: $userId');
//   print('Debug - Is Authenticated: $isAuthenticated');
  
//   if (!isAuthenticated) {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.person_off, size: 64, color: Colors.grey),
//           SizedBox(height: 16),
//           Text(
//             'Please login to view documents',
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   // Use the authenticated user ID for fetching documents
//   final effectiveUserId = _currentUser?.uid ?? userId;
  
//   return StreamBuilder<List<DocumentModel>>(
//     stream: FirebaseService.getUserDocuments(),
//     builder: (context, snapshot) {
//       print('Debug - Stream connection state: ${snapshot.connectionState}');
//       print('Debug - Stream has error: ${snapshot.hasError}');
//       print('Debug - Stream error: ${snapshot.error}');
//       print('Debug - Stream data length: ${snapshot.data?.length ?? 0}');

//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return _buildLoadingList();
//       }

//       if (snapshot.hasError) {
//         print('Error in stream: ${snapshot.error}');
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error, size: 64, color: Colors.red),
//               const SizedBox(height: 16),
//               Text(
//                 'Error loading documents',
//                 style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Text(
//                   snapshot.error.toString(),
//                   style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               ElevatedButton(
//                 onPressed: () => setState(() {}),
//                 child: const Text('Retry'),
//               ),
//             ],
//           ),
//         );
//       }

//       List<DocumentModel> documents = snapshot.data ?? [];
//       print('Debug - Documents before filtering: ${documents.length}');

//       // Filter documents
//       if (_selectedCategory != 'All') {
//         documents = documents
//             .where((doc) => doc.category == _selectedCategory)
//             .toList();
//       }

//       if (_searchController.text.isNotEmpty) {
//         final searchTerm = _searchController.text.toLowerCase();
//         documents = documents
//             .where((doc) =>
//                 doc.fileName.toLowerCase().contains(searchTerm) ||
//                 doc.tags.any((tag) =>
//                     tag.toLowerCase().contains(searchTerm)))
//             .toList();
//       }

//       print('Debug - Documents after filtering: ${documents.length}');

//       if (documents.isEmpty) {
//         return _buildEmptyState();
//       }

//       return RefreshIndicator(
//         onRefresh: () async {
//           setState(() {});
//         },
//         child: ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: documents.length,
//           itemBuilder: (context, index) {
//             return _buildDocumentCard(documents[index]);
//           },
//         ),
//       );
//     },
//   );
// }

// Widget _buildLoadingList() {
//   return ListView.builder(
//     padding: const EdgeInsets.all(16),
//     itemCount: 5,
//     itemBuilder: (context, index) {
//       return Shimmer.fromColors(
//         baseColor: Colors.grey[300]!,
//         highlightColor: Colors.grey[100]!,
//         child: Card(
//           margin: const EdgeInsets.only(bottom: 12),
//           child: Container(
//             height: 80,
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         height: 16,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         width: 100,
//                         height: 12,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

// Widget _buildEmptyState() {
//   return Center(
//     child: Padding(
//       padding: const EdgeInsets.all(32),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedBuilder(
//             animation: _waveAnimation,
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: 1.0 + (_waveAnimation.value * 0.1),
//                 child: const Icon(
//                   Icons.folder_open,
//                   size: 80,
//                   color: Color(0xFF0A9D88),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'No Documents Found',
//             style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             _selectedCategory == 'All'
//                 ? 'Upload your first document to get started'
//                 : 'No documents in $_selectedCategory category',
//             style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: _showUploadOptions,
//             icon: const Icon(Icons.upload_file),
//             label: const Text('Upload Document'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0A9D88),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// Widget _buildDocumentCard(DocumentModel document) {
//   return Card(
//     margin: const EdgeInsets.only(bottom: 12),
//     elevation: 2,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: ListTile(
//       contentPadding: const EdgeInsets.all(16),
//       leading: Container(
//         width: 48,
//         height: 48,
//         decoration: BoxDecoration(
//           color: _getCategoryColor(document.category).withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Icon(
//           _getCategoryIcon(document.category),
//           color: _getCategoryColor(document.category),
//           size: 24,
//         ),
//       ),
//       title: Text(
//         document.fileName,
//         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//       ),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 4),
//           Text(
//             document.category,
//             style: TextStyle(color: Colors.grey[600], fontSize: 14),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Uploaded ${_formatDate(document.uploadDate)}',
//             style: TextStyle(color: Colors.grey[500], fontSize: 12),
//           ),
//           if (document.tags.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 6,
//               runSpacing: 4,
//               children: document.tags.take(3).map((tag) {
//                 return Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF0A9D88).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     tag,
//                     style: const TextStyle(fontSize: 11, color: Color(0xFF0A9D88)),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ],
//         ],
//       ),
//       trailing: PopupMenuButton<String>(
//         onSelected: (value) {
//           if (value == 'view') {
//             _viewDocument(document);
//           } else if (value == 'delete') {
//             _deleteDocument(document);
//           }
//         },
//         itemBuilder: (context) => [
//           const PopupMenuItem(
//             value: 'view',
//             child: ListTile(
//               leading: Icon(Icons.visibility),
//               title: Text('View'),
//               dense: true,
//             ),
//           ),
//           const PopupMenuItem(
//             value: 'delete',
//             child: ListTile(
//               leading: Icon(Icons.delete, color: Colors.red),
//               title: Text('Delete'),
//               dense: true,
//             ),
//           ),
//         ],
//       ),
//       onTap: () => _viewDocument(document),
//     ),
//   );
// }

// String _formatDate(DateTime date) {
//   final now = DateTime.now();
//   final difference = now.difference(date);
  
//   if (difference.inDays == 0) {
//     return 'Today';
//   } else if (difference.inDays == 1) {
//     return 'Yesterday';
//   } else if (difference.inDays < 7) {
//     return '${difference.inDays} days ago';
//   } else {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }

// Color _getCategoryColor(String category) {
//   switch (category) {
//     case 'Crop History':
//       return Colors.green;
//     case 'Invoices':
//       return Colors.blue;
//     case 'Land Documents':
//       return Colors.orange;
//     case 'Agri-Loan Records':
//       return Colors.purple;
//     default:
//       return const Color(0xFF0A9D88);
//   }
// }

// IconData _getCategoryIcon(String category) {
//   switch (category) {
//     case 'Crop History':
//       return Icons.agriculture;
//     case 'Invoices':
//       return Icons.receipt;
//     case 'Land Documents':
//       return Icons.landscape;
//     case 'Agri-Loan Records':
//       return Icons.account_balance;
//     default:
//       return Icons.description;
//   }
// }

// void _navigateToProfile() async {
//   var profile = FirebaseService.getCurrentUserProfile();
//   if (profile == null && FirebaseService.getCurrentUserId() != null) {
//     profile = await FirebaseService.getUserProfile(FirebaseService.getCurrentUserId()!);
//   }

//   if (profile != null) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ProfileEditScreen(userProfile: profile),
//       ),
//     );
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Could not load user profile')),
//     );
//   }
// }

//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await FirebaseAuth.instance.signOut();
//               _redirectToLogin();
//             },
//             child: const Text('Logout', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showProfileImageOptions() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Update Profile Picture',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               ListTile(
//                 leading: const Icon(Icons.photo_camera),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickProfileImage(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Gallery'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickProfileImage(ImageSource.gallery);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _pickProfileImage(ImageSource source) async {
//     if (_currentUser == null) {
//       _showSnackBar('Please login to update profile image');
//       return;
//     }

//     try {
//       final ImagePicker picker = ImagePicker();
//       final XFile? image = await picker.pickImage(
//         source: source,
//         maxWidth: 512,
//         maxHeight: 512,
//         imageQuality: 70,
//       );
      
//       if (image != null) {
//         _showLoadingDialog('Uploading profile image...');
        
//         final imageUrl = await FirebaseService.uploadProfileImage(File(image.path));
        
//         if (_userProfile != null) {
//           final updatedProfile = UserProfileModel(
//             uid: _userProfile!.uid,
//             name: _userProfile!.name,
//             email: _userProfile!.email,
//             phone: _userProfile!.phone,
//             farmLocation: _userProfile!.farmLocation,
//             farmSize: _userProfile!.farmSize,
//             cropTypes: _userProfile!.cropTypes,
//             profileImageUrl: imageUrl,
//             createdAt: _userProfile!.createdAt,
//           );
          
//           await FirebaseService.createOrUpdateProfile(updatedProfile);
//           await _loadUserProfile(_currentUser!.uid); // Reload profile with updated image
//         }
        
//         Navigator.pop(context); // Close loading dialog
//         _showSnackBar('Profile image updated successfully');
//       }
//     } catch (e) {
//       Navigator.pop(context); // Close loading dialog
//       _showSnackBar('Error uploading image: ${e.toString()}');
//     }
//   }

//   void _showUploadOptions() {
//     if (_currentUser == null) {
//       _showSnackBar('Please login to upload documents');
//       return;
//     }

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.7,
//         maxChildSize: 0.9,
//         minChildSize: 0.5,
//         builder: (context, scrollController) {
//           return DocumentUploadSheet(
//             scrollController: scrollController,
//             currentUser: _currentUser!,
//             onDocumentUploaded: () {
//               Navigator.pop(context);
//               _showSnackBar('Document uploaded successfully');
//               setState(() {}); // Refresh the documents list
//             },
//           );
//         },
//       ),
//     );
//   }

//   void _viewDocument(DocumentModel document) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => DocumentViewerScreen(document: document),
//       ),
//     );
//   }

//   void _deleteDocument(DocumentModel document) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Document'),
//         content: Text('Are you sure you want to delete "${document.fileName}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               _showLoadingDialog('Deleting document...');
              
//               try {
//                 await FirebaseService.deleteDocument(document.id, document.fileUrl);
//                 Navigator.pop(context); // Close loading dialog
//                 _showSnackBar('Document deleted successfully');
//                 setState(() {}); // Refresh the list
//               } catch (e) {
//                 Navigator.pop(context); // Close loading dialog
//                 _showSnackBar('Error deleting document: ${e.toString()}');
//               }
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showLoadingDialog(String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         content: Row(
//           children: [
//             const CircularProgressIndicator(),
//             const SizedBox(width: 16),
//             Expanded(child: Text(message)),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _waveController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
// }

// // Enhanced Document Upload Sheet
// class DocumentUploadSheet extends StatefulWidget {
//   final ScrollController scrollController;
//   final User currentUser;
//   final VoidCallback onDocumentUploaded;

//   const DocumentUploadSheet({
//     super.key,
//     required this.scrollController,
//     required this.currentUser,
//     required this.onDocumentUploaded,
//   });

//   @override
//   State<DocumentUploadSheet> createState() => _DocumentUploadSheetState();
// }

// class _DocumentUploadSheetState extends State<DocumentUploadSheet> {
//   String _selectedCategory = 'Crop History';
//   final TextEditingController _tagsController = TextEditingController();
//   File? _selectedFile;
//   bool _isUploading = false;
//   double _uploadProgress = 0.0;

//   final List<String> _categories = [
//     'Crop History',
//     'Invoices',
//     'Land Documents',
//     'Agri-Loan Records'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             margin: const EdgeInsets.only(top: 12),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               controller: widget.scrollController,
//               padding: const EdgeInsets.all(20),
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.cloud_upload, color: Color(0xFF0A9D88)),
//                     const SizedBox(width: 8),
//                     const Text(
//                       'Upload Document',
//                       style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Add a new document to your vault',
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//                 const SizedBox(height: 24),
                
//                 // File selection
//                 GestureDetector(
//                   onTap: _isUploading ? null : _pickFile,
//                   child: Container(
//                     height: 140,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: _selectedFile != null
//                             ? const Color(0xFF0A9D88)
//                             : Colors.grey[300]!,
                        
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                       color: _selectedFile != null
//                           ? const Color(0xFF0A9D88).withOpacity(0.05)
//                           : Colors.grey[50],
//                     ),
//                     child: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             _selectedFile != null ? Icons.check_circle : Icons.cloud_upload_outlined,
//                             size: 48,
//                             color: _selectedFile != null
//                                 ? const Color(0xFF0A9D88)
//                                 : Colors.grey[400],
//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             _selectedFile != null
//                                 ? _selectedFile!.path.split('/').last
//                                 : 'Tap to select file',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: _selectedFile != null ? FontWeight.w500 : FontWeight.normal,
//                               color: _selectedFile != null
//                                   ? const Color(0xFF0A9D88)
//                                   : Colors.grey[600],
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           if (_selectedFile != null) ...[
//                             const SizedBox(height: 4),
//                             FutureBuilder<int>(
//                               future: _selectedFile!.length(),
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasData) {
//                                   return Text(
//                                     _formatFileSize(snapshot.data!),
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey[500],
//                                     ),
//                                   );
//                                 }
//                                 return const SizedBox();
//                               },
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
                
//                 // Category selection
//                 const Text(
//                   'Category',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey[300]!),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: DropdownButton<String>(
//                     value: _selectedCategory,
//                     isExpanded: true,
//                     underline: const SizedBox(),
//                     items: _categories.map((category) {
//                       return DropdownMenuItem(
//                         value: category,
//                         child: Row(
//                           children: [
//                             Icon(
//                               _getCategoryIcon(category),
//                               size: 20,
//                               color: _getCategoryColor(category),
//                             ),
//                             const SizedBox(width: 12),
//                             Text(category),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                     onChanged: _isUploading ? null : (value) {
//                       setState(() {
//                         _selectedCategory = value!;
//                       });
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 20),
                
//                 // Tags input
//                 const Text(
//                   'Tags',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: _tagsController,
//                   enabled: !_isUploading,
//                   decoration: InputDecoration(
//                     hintText: 'e.g., rice, 2024, harvest (comma separated)',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     prefixIcon: const Icon(Icons.tag),
//                   ),
//                   maxLines: 2,
//                 ),
//                 const SizedBox(height: 30),
                
//                 // Progress indicator
//                 if (_isUploading) ...[
//                   Column(
//                     children: [
//                       LinearProgressIndicator(
//                         value: _uploadProgress,
//                         backgroundColor: Colors.grey[300],
//                         valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0A9D88)),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Uploading... ${(_uploadProgress * 100).toInt()}%',
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                 ],
                
//                 // Upload button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton.icon(
//                     onPressed: _selectedFile != null && !_isUploading
//                         ? _uploadDocument
//                         : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF0A9D88),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     icon: _isUploading
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Icon(Icons.upload),
//                     label: Text(
//                       _isUploading ? 'Uploading...' : 'Upload Document',
//                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(height: 16),
                
//                 // Cancel button
//                 if (_isUploading)
//                   SizedBox(
//                     width: double.infinity,
//                     child: TextButton(
//                       onPressed: () {
//                         setState(() {
//                           _isUploading = false;
//                           _uploadProgress = 0.0;
//                         });
//                       },
//                       child: const Text('Cancel Upload'),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatFileSize(int bytes) {
//     if (bytes < 1024) return '$bytes B';
//     if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
//     return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
//   }

//   Color _getCategoryColor(String category) {
//     switch (category) {
//       case 'Crop History':
//         return Colors.green;
//       case 'Invoices':
//         return Colors.blue;
//       case 'Land Documents':
//         return Colors.orange;
//       case 'Agri-Loan Records':
//         return Colors.purple;
//       default:
//         return const Color(0xFF0A9D88);
//     }
//   }

//   IconData _getCategoryIcon(String category) {
//     switch (category) {
//       case 'Crop History':
//         return Icons.agriculture;
//       case 'Invoices':
//         return Icons.receipt;
//       case 'Land Documents':
//         return Icons.landscape;
//       case 'Agri-Loan Records':
//         return Icons.account_balance;
//       default:
//         return Icons.description;
//     }
//   }

//   Future<void> _pickFile() async {
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'txt'],
//         allowMultiple: false,
//       );

//       if (result != null && result.files.isNotEmpty) {
//         final file = File(result.files.first.path!);
//         final fileSize = await file.length();
        
//         // Check file size (max 10MB)
//         if (fileSize > 10 * 1024 * 1024) {
//           _showSnackBar('File size must be less than 10MB');
//           return;
//         }
        
//         setState(() {
//           _selectedFile = file;
//         });
//       }
//     } catch (e) {
//       _showSnackBar('Error selecting file: ${e.toString()}');
//     }
//   }

//   Future<void> _uploadDocument() async {
//     if (_selectedFile == null) return;

//     setState(() {
//       _isUploading = true;
//       _uploadProgress = 0.0;
//     });

//     try {
//       // Simulate progress updates
//       _simulateProgress();
      
//       final fileName = _selectedFile!.path.split('/').last;
//       final fileUrl = await FirebaseService.uploadDocument(
//         _selectedFile!,
//         fileName,
//         _selectedCategory,
//       );

//       final tags = _tagsController.text
//           .split(',')
//           .map((tag) => tag.trim())
//           .where((tag) => tag.isNotEmpty)
//           .toList();

//       final document = DocumentModel(
//         id: '',
//         fileName: fileName,
//         fileUrl: fileUrl,
//         category: _selectedCategory,
//         tags: tags,
//         uploadDate: DateTime.now(),
//         userId: widget.currentUser.uid,
//         fileSize: await _selectedFile!.length(),
//         fileType: fileName.split('.').last.toUpperCase(),
//       );

//       await FirebaseService.saveDocumentMetadata(document);
      
//       setState(() {
//         _uploadProgress = 1.0;
//       });
      
//       await Future.delayed(const Duration(milliseconds: 500));
//       widget.onDocumentUploaded();
//     } catch (e) {
//       if (mounted) {
//         _showSnackBar('Upload failed: ${e.toString()}');
//         setState(() {
//           _isUploading = false;
//           _uploadProgress = 0.0;
//         });
//       }
//     }
//   }

//   void _simulateProgress() {
//     // Simulate upload progress
//     Timer.periodic(const Duration(milliseconds: 100), (timer) {
//       if (!_isUploading) {
//         timer.cancel();
//         return;
//       }
      
//       setState(() {
//         _uploadProgress += 0.05;
//         if (_uploadProgress >= 0.9) {
//           timer.cancel();
//         }
//       });
//     });
//   }

//   void _showSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: message.contains('Error') || message.contains('failed')
//               ? Colors.red
//               : const Color(0xFF0A9D88),
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _tagsController.dispose();
//     super.dispose();
//   }
// }

