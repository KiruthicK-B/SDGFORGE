
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:vfarm/chats/chats.dart';

// //  
// class ChatRoomPage extends StatefulWidget {
//   final CommunityChat chat;
//   final String currentUserId;
//   final String currentUsername;

//   const ChatRoomPage({
//     super.key,
//     required this.chat,
//     required this.currentUserId,
//     required this.currentUsername,
//   });

//   @override
//   State<ChatRoomPage> createState() => _ChatRoomPageState();
// }

// class _ChatRoomPageState extends State<ChatRoomPage> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;

//   bool _isTyping = false;
//   bool _isUploading = false;
//   List<String> _typingUsers = [];

//   @override
//   void initState() {
//     super.initState();
//     _markMessagesAsRead();
//     _setupTypingListener();
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     _removeTypingIndicator();
//     super.dispose();
//   }

//   void _markMessagesAsRead() async {
//     final batch = _firestore.batch();
//     final messagesQuery = await _firestore
//         .collection('community_chats')
//         .doc(widget.chat.id)
//         .collection('messages')
//         .where('senderId', isNotEqualTo: widget.currentUserId)
//         .where('status', isNotEqualTo: MessageStatus.read.index)
//         .get();

//     for (var doc in messagesQuery.docs) {
//       batch.update(doc.reference, {'status': MessageStatus.read.index});
//     }

//     if (messagesQuery.docs.isNotEmpty) {
//       await batch.commit();
//     }
//   }

//   void _setupTypingListener() {
//     _firestore
//         .collection('community_chats')
//         .doc(widget.chat.id)
//         .collection('typing')
//         .snapshots()
//         .listen((snapshot) {
//       final typingUsers = <String>[];
//       for (var doc in snapshot.docs) {
//         if (doc.id != widget.currentUserId) {
//           final data = doc.data();
//           final lastTyping = (data['lastTyping'] as Timestamp).toDate();
//           if (DateTime.now().difference(lastTyping).inSeconds < 3) {
//             typingUsers.add(data['username'] ?? 'Someone');
//           }
//         }
//       }
//       if (mounted) {
//         setState(() => _typingUsers = typingUsers);
//       }
//     });
//   }

//   void _updateTypingIndicator() async {
//     await _firestore
//         .collection('community_chats')
//         .doc(widget.chat.id)
//         .collection('typing')
//         .doc(widget.currentUserId)
//         .set({
//       'username': widget.currentUsername,
//       'lastTyping': FieldValue.serverTimestamp(),
//     });
//   }

//   void _removeTypingIndicator() async {
//     await _firestore
//         .collection('community_chats')
//         .doc(widget.chat.id)
//         .collection('typing')
//         .doc(widget.currentUserId)
//         .delete();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0A9D88),
//         title: Row(
//           children: [
//             CircleAvatar(
//               radius: 16,
//               backgroundColor: Colors.white.withOpacity(0.2),
//               backgroundImage: widget.chat.imageUrl != null
//                   ? NetworkImage(widget.chat.imageUrl!)
//                   : null,
//               child: widget.chat.imageUrl == null
//                   ? Text(widget.chat.name[0].toUpperCase(),
//                       style: const TextStyle(color: Colors.white, fontSize: 12))
//                   : null,
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.chat.name,
//                     style: const TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                   Text(
//                     '${widget.chat.memberCount} members',
//                     style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.people, color: Colors.white),
//             onPressed: _showMembersList,
//           ),
//           IconButton(
//             icon: const Icon(Icons.add, color: Colors.white),
//             onPressed: _showCreateSubGroupDialog,
//           ),
//           IconButton(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onPressed: _showChatOptions,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection('community_chats')
//                   .doc(widget.chat.id)
//                   .collection('messages')
//                   .orderBy('timestamp', descending: true)
//                   .limit(50)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A9D88)),
//                     ),
//                   );
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(
//                     child: Text(
//                       'No messages yet. Start the conversation!',
//                       style: TextStyle(color: Colors.white.withOpacity(0.7)),
//                     ),
//                   );
//                 }

//                 final messages = snapshot.data!.docs
//                     .map((doc) => ChatMessage.fromFirestore(doc))
//                     .toList();

//                 return ListView.builder(
//                   controller: _scrollController,
//                   reverse: true,
//                   padding: const EdgeInsets.all(16),
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message = messages[index];
//                     final isMe = message.senderId == widget.currentUserId;
//                     final showSender = index == messages.length - 1 ||
//                         messages[index + 1].senderId != message.senderId;

//                     return _buildMessageBubble(message, isMe, showSender);
//                   },
//                 );
//               },
//             ),
//           ),
//           if (_typingUsers.isNotEmpty) _buildTypingIndicator(),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(ChatMessage message, bool isMe, bool showSender) {
//     return Container(
//       margin: EdgeInsets.only(
//         bottom: 8,
//         left: isMe ? 50 : 0,
//         right: isMe ? 0 : 50,
//       ),
//       child: Column(
//         crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           if (showSender && !isMe)
//             Padding(
//               padding: const EdgeInsets.only(left: 12, bottom: 4),
//               child: Text(
//                 message.senderName,
//                 style: const TextStyle(
//                   color: Color(0xFF0A9D88),
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               color: isMe ? const Color(0xFF0A9D88) : const Color(0xFF127A68),
//               borderRadius: BorderRadius.circular(18),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildMessageContent(message),
//                 const SizedBox(height: 4),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       _formatMessageTime(message.timestamp),
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.7),
//                         fontSize: 10,
//                       ),
//                     ),
//                     if (isMe) ...[
//                       const SizedBox(width: 4),
//                       _buildMessageStatusIcon(message.status),
//                     ],
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageContent(ChatMessage message) {
//     switch (message.type) {
//       case MessageType.text:
//         return Text(
//           message.content,
//           style: const TextStyle(color: Colors.white),
//         );
//       case MessageType.image:
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (message.content.isNotEmpty)
//               Text(message.content, style: const TextStyle(color: Colors.white)),
//             const SizedBox(height: 4),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.network(
//                 message.fileUrl!,
//                 height: 200,
//                 width: 250,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) =>
//                     const Icon(Icons.error, color: Colors.white),
//               ),
//             ),
//           ],
//         );
//       case MessageType.file:
//         return Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.attach_file, color: Colors.white, size: 16),
//             const SizedBox(width: 8),
//             Flexible(
//               child: Text(
//                 message.fileName ?? 'File',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ),
//           ],
//         );
//       case MessageType.voice:
//         return Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.mic, color: Colors.white, size: 16),
//             const SizedBox(width: 8),
//             const Text('Voice Message', style: TextStyle(color: Colors.white)),
//           ],
//         );
//     }
//   }

//   Widget _buildMessageStatusIcon(MessageStatus status) {
//     switch (status) {
//       case MessageStatus.sending:
//         return SizedBox(
//           width: 12,
//           height: 12,
//           child: CircularProgressIndicator(
//             strokeWidth: 1,
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
//           ),
//         );
//       case MessageStatus.sent:
//         return Icon(Icons.check, color: Colors.white.withOpacity(0.7), size: 12);
//       case MessageStatus.delivered:
//         return Icon(Icons.done_all, color: Colors.white.withOpacity(0.7), size: 12);
//       case MessageStatus.read:
//         return const Icon(Icons.done_all, color: Colors.white, size: 12);
//     }
//   }

//   Widget _buildTypingIndicator() {
//     final typingText = _typingUsers.length == 1
//         ? '${_typingUsers[0]} is typing...'
//         : _typingUsers.length == 2
//             ? '${_typingUsers[0]} and ${_typingUsers[1]} are typing...'
//             : '${_typingUsers.length} people are typing...';

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         children: [
//           const SizedBox(
//             width: 16,
//             height: 16,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A9D88)),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             typingText,
//             style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageInput() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: const Color(0xFF127A68),
//       child: Row(
//         children: [
//           IconButton(
//             icon: Icon(Icons.add, color: Colors.white.withOpacity(0.7)),
//             onPressed: _showAttachmentOptions,
//           ),
//           Expanded(
//             child: TextField(
//               controller: _messageController,
//               style: const TextStyle(color: Colors.white),
//               maxLines: null,
//               onChanged: (text) {
//                 if (text.isNotEmpty && !_isTyping) {
//                   setState(() => _isTyping = true);
//                   _updateTypingIndicator();
//                 } else if (text.isEmpty && _isTyping) {
//                   setState(() => _isTyping = false);
//                   _removeTypingIndicator();
//                 }
//               },
//               decoration: InputDecoration(
//                 hintText: 'Message #${widget.chat.name}',
//                 hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
//                 filled: true,
//                 fillColor: const Color(0xFF0F5D4E),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 10,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           CircleAvatar(
//             backgroundColor: const Color(0xFF0A9D88),
//             child: IconButton(
//               icon: const Icon(Icons.send, color: Colors.white, size: 20),
//               onPressed: _sendMessage,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _sendMessage() async {
//     final content = _messageController.text.trim();
//     if (content.isEmpty || _isUploading) return;

//     _messageController.clear();
//     _removeTypingIndicator();
//     setState(() => _isTyping = false);

//     final messageId = _firestore
//         .collection('community_chats')
//         .doc(widget.chat.id)
//         .collection('messages')
//         .doc().id;

//     final message = ChatMessage(
//       id: messageId,
//       senderId: widget.currentUserId,
//       senderName: widget.currentUsername,
//       content: content,
//       timestamp: DateTime.now(),
//       type: MessageType.text,
//       status: MessageStatus.sending,
//       reactions: [],
//     );

//     // Add message with sending status
//     await _firestore
//         .collection('community_chats')
//         .doc(widget.chat.id)
//         .collection('messages')
//         .doc(messageId)
//         .set(message.toFirestore());

//     // Update status to sent
//     await _firestore
//         .collection('community_chats')
//         .doc(widget.chat.id)
//         .collection('messages')
//         .doc(messageId)
//         .update({'status': MessageStatus.sent.index});

//     // Update last message in chat
//     await _firestore
//         .collection('community_chats')
//         .doc(widget.chat.id)
//         .update({
//       'lastMessage': content,
//       'lastMessageTime': FieldValue.serverTimestamp(),
//     });

//     _scrollToBottom();
//   }

//   void _showAttachmentOptions() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: const Color(0xFF0A6A5B),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.photo, color: Color.fromARGB(255, 246, 252, 251)),
//               title: const Text('Photo', style: TextStyle(color: Colors.white)),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage();
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.attach_file, color: Color(0xFF0A9D88)),
//               title: const Text('File', style: TextStyle(color: Colors.white)),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickFile();
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt, color: Color(0xFF0A9D88)),
//               title: const Text('Camera', style: TextStyle(color: Colors.white)),
//               onTap: () {
//                 Navigator.pop(context);
//                 _takePhoto();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       _uploadFile(File(pickedFile.path), MessageType.image);
//     }
//   }

//   void _takePhoto() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);

//     if (pickedFile != null) {
//       _uploadFile(File(pickedFile.path), MessageType.image);
//     }
//   }

//   void _pickFile() async {
//     final result = await FilePicker.platform.pickFiles();

//     if (result != null && result.files.single.path != null) {
//       _uploadFile(File(result.files.single.path!), MessageType.file,
//                  fileName: result.files.single.name);
//     }
//   }

//   void _uploadFile(File file, MessageType type, {String? fileName}) async {
//     setState(() => _isUploading = true);

//     try {
//       final messageId = _firestore
//           .collection('community_chats')
//           .doc(widget.chat.id)
//           .collection('messages')
//           .doc().id;

//       final ref = _storage.ref().child(
//           'chat_files/${widget.chat.id}/$messageId${_getFileExtension(file.path)}');

//       await ref.putFile(file);
//       final downloadUrl = await ref.getDownloadURL();

//       final message = ChatMessage(
//         id: messageId,
//         senderId: widget.currentUserId,
//         senderName: widget.currentUsername,
//         content: _messageController.text.trim(),
//         timestamp: DateTime.now(),
//         type: type,
//         fileUrl: downloadUrl,
//         fileName: fileName ?? file.path.split('/').last,
//         status: MessageStatus.sent,
//         reactions: [],
//       );

//       await _firestore
//           .collection('community_chats')
//           .doc(widget.chat.id)
//           .collection('messages')
//           .doc(messageId)
//           .set(message.toFirestore());

//       _messageController.clear();
//       _scrollToBottom();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to upload file', style: TextStyle(color: Colors.white)),
//           backgroundColor: Color(0xFF127A68),
//         ),
//       );
//     } finally {
//       setState(() => _isUploading = false);
//     }
//   }

//   String _getFileExtension(String path) {
//     return path.substring(path.lastIndexOf('.'));
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           0,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   void _showMembersList() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: const Color(0xFF0A6A5B),
//       builder: (context) => MembersListSheet(
//         chatId: widget.chat.id,
//         currentUserId: widget.currentUserId,
//         isAdmin: widget.chat.admins.contains(widget.currentUserId),
//       ),
//     );
//   }

//   void _showCreateSubGroupDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => CreateSubGroupDialog(
//         parentChatId: widget.chat.id,
//         currentUserId: widget.currentUserId,
//         currentUsername: widget.currentUsername,
//       ),
//     );
//   }

//   void _showChatOptions() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: const Color(0xFF0A6A5B),
//       builder: (context) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.search, color: Colors.white),
//             title: const Text('Search Messages', style: TextStyle(color: Colors.white)),
//             onTap: () => Navigator.pop(context),
//           ),
//           ListTile(
//             leading: const Icon(Icons.notifications, color: Colors.white),
//             title: const Text('Notification Settings', style: TextStyle(color: Colors.white)),
//             onTap: () => Navigator.pop(context),
//           ),
//           if (widget.chat.admins.contains(widget.currentUserId))
//             ListTile(
//               leading: const Icon(Icons.settings, color: Colors.white),
//               title: const Text('Manage Chat', style: TextStyle(color: Colors.white)),
//               onTap: () => Navigator.pop(context),
//             ),
//           ListTile(
//             leading: const Icon(Icons.info, color: Colors.white),
//             title: const Text('Chat Info', style: TextStyle(color: Colors.white)),
//             onTap: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatMessageTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);

//     if (difference.inDays > 0) {
//       return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
//     } else if (difference.inHours > 0) {
//       return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes}m ago';
//     } else {
//       return 'Just now';
//     }
//   }
// }

// // Members List Sheet
// class MembersListSheet extends StatelessWidget {
//   final String chatId;
//   final String currentUserId;
//   final bool isAdmin;

//   const MembersListSheet({
//     super.key,
//     required this.chatId,
//     required this.currentUserId,
//     required this.isAdmin,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.7,
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           const Text(
//             'Members',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: StreamBuilder<DocumentSnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('community_chats')
//                   .doc(chatId)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A9D88)),
//                     ),
//                   );
//                 }

//                 final chat = CommunityChat.fromFirestore(snapshot.data!);

//                 return ListView.builder(
//                   itemCount: chat.members.length,
//                   itemBuilder: (context, index) {
//                     final memberId = chat.members[index];
//                     final isCurrentUser = memberId == currentUserId;
//                     final isMemberAdmin = chat.admins.contains(memberId);

//                     return ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor: const Color(0xFF0A9D88),
//                         child: Text(
//                           memberId[0].toUpperCase(),
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ),
//                       title: Text(
//                         isCurrentUser ? 'You' : 'User $memberId',
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           if (isMemberAdmin)
//                             const Icon(Icons.admin_panel_settings,
//                                      color: Color(0xFF0A9D88), size: 16),
//                           if (isAdmin && !isCurrentUser)
//                             PopupMenuButton(
//                               icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.7)),
//                               color: const Color(0xFF127A68),
//                               itemBuilder: (context) => [
//                                 PopupMenuItem(
//                                   child: Text(
//                                     isMemberAdmin ? 'Remove Admin' : 'Make Admin',
//                                     style: const TextStyle(color: Colors.white),
//                                   ),
//                                   onTap: () => _toggleAdminStatus(memberId, isMemberAdmin),
//                                 ),
//                                 const PopupMenuItem(
//                                   child: Text(
//                                     'Remove from Chat',
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _toggleAdminStatus(String memberId, bool isCurrentlyAdmin) {
//     // Implementation for toggling admin status
//   }
// }

// // Create Sub Group Dialog
// class CreateSubGroupDialog extends StatefulWidget {
//   final String parentChatId;
//   final String currentUserId;
//   final String currentUsername;

//   const CreateSubGroupDialog({
//     super.key,
//     required this.parentChatId,
//     required this.currentUserId,
//     required this.currentUsername,
//   });

//   @override
//   State<CreateSubGroupDialog> createState() => _CreateSubGroupDialogState();
// }

// class _CreateSubGroupDialogState extends State<CreateSubGroupDialog> {
//   final _nameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   bool _isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: const Color(0xFF0A6A5B),
//       title: const Text('Create Sub Group', style: TextStyle(color: Colors.white)),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: _nameController,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               labelText: 'Sub Group Name',
//               labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
//               ),
//               focusedBorder: const OutlineInputBorder(
//                 borderSide: BorderSide(color: Color(0xFF0A9D88)),
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             controller: _descriptionController,
//             style: const TextStyle(color: Colors.white),
//             maxLines: 2,
//             decoration: InputDecoration(
//               labelText: 'Description',
//               labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
//               ),
//               focusedBorder: const OutlineInputBorder(
//                 borderSide: BorderSide(color: Color(0xFF0A9D88)),
//               ),
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.7))),
//         ),
//         ElevatedButton(
//           onPressed: _isLoading ? null : _createSubGroup,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF0A9D88),
//             foregroundColor: Colors.white,
//           ),
//           child: _isLoading
//               ? const SizedBox(width: 16, height: 16,
//                                child: CircularProgressIndicator(
//                                  strokeWidth: 2,
//                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                ))
//               : const Text('Create'),
//         ),
//       ],
//     );
//   }

//   void _createSubGroup() async {
//     if (_nameController.text.trim().isEmpty) return;

//     setState(() => _isLoading = true);

//     try {
//       final subGroup = {
//         'parentChatId': widget.parentChatId,
//         'name': _nameController.text.trim(),
//         'description': _descriptionController.text.trim(),
//         'createdBy': widget.currentUserId,
//         'createdAt': FieldValue.serverTimestamp(),
//         'members': [widget.currentUserId],
//         'admins': [widget.currentUserId],
//         'isSubGroup': true,
//       };

//       await FirebaseFirestore.instance
//           .collection('community_chats')
//           .add(subGroup);

//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Sub group created successfully!', style: TextStyle(color: Colors.white)),
//           backgroundColor: Color.fromARGB(255, 255, 255, 255),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to create sub group', style: TextStyle(color: Colors.white)),
//           backgroundColor: Color.fromARGB(255, 255, 255, 255),
//         ),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
// }

