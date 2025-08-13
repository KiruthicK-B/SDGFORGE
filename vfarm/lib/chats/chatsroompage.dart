
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:vfarm/chats/chats.dart';

class ChatRoomPage extends StatefulWidget {
  final CommunityChat chat;
  final String currentUserId;
  final String currentUsername;

  const ChatRoomPage({
    super.key,
    required this.chat,
    required this.currentUserId,
    required this.currentUsername,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isTyping = false;
  bool _isUploading = false;
  List<String> _typingUsers = [];

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
    _setupTypingListener();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _removeTypingIndicator();
    super.dispose();
  }

  void _markMessagesAsRead() async {
    final batch = _firestore.batch();
    final messagesQuery = await _firestore
        .collection('community_chats')
        .doc(widget.chat.id)
        .collection('messages')
        .where('senderId', isNotEqualTo: widget.currentUserId)
        .where('status', isNotEqualTo: MessageStatus.read.index)
        .get();

    for (var doc in messagesQuery.docs) {
      batch.update(doc.reference, {'status': MessageStatus.read.index});
    }

    if (messagesQuery.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  void _setupTypingListener() {
    _firestore
        .collection('community_chats')
        .doc(widget.chat.id)
        .collection('typing')
        .snapshots()
        .listen((snapshot) {
      final typingUsers = <String>[];
      for (var doc in snapshot.docs) {
        if (doc.id != widget.currentUserId) {
          final data = doc.data();
          final lastTyping = (data['lastTyping'] as Timestamp).toDate();
          if (DateTime.now().difference(lastTyping).inSeconds < 3) {
            typingUsers.add(data['username'] ?? 'Someone');
          }
        }
      }
      if (mounted) {
        setState(() => _typingUsers = typingUsers);
      }
    });
  }

  void _updateTypingIndicator() async {
    await _firestore
        .collection('community_chats')
        .doc(widget.chat.id)
        .collection('typing')
        .doc(widget.currentUserId)
        .set({
      'username': widget.currentUsername,
      'lastTyping': FieldValue.serverTimestamp(),
    });
  }

  void _removeTypingIndicator() async {
    await _firestore
        .collection('community_chats')
        .doc(widget.chat.id)
        .collection('typing')
        .doc(widget.currentUserId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A9D88),
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: widget.chat.imageUrl != null
                    ? NetworkImage(widget.chat.imageUrl!)
                    : null,
                child: widget.chat.imageUrl == null
                    ? Text(widget.chat.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.name,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${widget.chat.memberCount} members',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8), 
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people, size: 24),
            onPressed: _showMembersList,
            tooltip: 'Members',
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 24),
            onPressed: _showCreateSubGroupDialog,
            tooltip: 'Create Sub Group',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 24),
            onPressed: _showChatOptions,
            tooltip: 'More Options',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('community_chats')
                  .doc(widget.chat.id)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A9D88)),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!.docs
                    .map((doc) => ChatMessage.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == widget.currentUserId;
                    final showSender = index == messages.length - 1 ||
                        messages[index + 1].senderId != message.senderId;

                    return _buildMessageBubble(message, isMe, showSender);
                  },
                );
              },
            ),
          ),
          if (_typingUsers.isNotEmpty) _buildTypingIndicator(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe, bool showSender) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 8,
        left: isMe ? 50 : 0,
        right: isMe ? 0 : 50,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showSender && !isMe)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Text(
                message.senderName,
                style: const TextStyle(
                  color: Color(0xFF0A9D88),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF0A9D88) : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMessageContent(message, isMe),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatMessageTime(message.timestamp),
                      style: TextStyle(
                        color: isMe ? Colors.white.withOpacity(0.8) : Colors.grey[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      _buildMessageStatusIcon(message.status),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message, bool isMe) {
    final textColor = isMe ? Colors.white : Colors.black87;
    
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        );
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.content.isNotEmpty) ...[
              Text(
                message.content, 
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                message.fileUrl!,
                height: 200,
                width: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                      height: 200,
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.grey[600],
                        size: 32,
                      ),
                    ),
              ),
            ),
          ],
        );
      case MessageType.file:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isMe ? Colors.white.withOpacity(0.1) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.attach_file, 
                color: isMe ? Colors.white : const Color(0xFF0A9D88), 
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.fileName ?? 'File',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        );
      case MessageType.voice:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isMe ? Colors.white.withOpacity(0.1) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mic, 
                color: isMe ? Colors.white : const Color(0xFF0A9D88), 
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Voice Message', 
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildMessageStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check, 
          color: Colors.white.withOpacity(0.8), 
          size: 14,
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all, 
          color: Colors.white.withOpacity(0.8), 
          size: 14,
        );
      case MessageStatus.read:
        return const Icon(
          Icons.done_all, 
          color: Colors.white, 
          size: 14,
        );
    }
  }

  Widget _buildTypingIndicator() {
    final typingText = _typingUsers.length == 1
        ? '${_typingUsers[0]} is typing...'
        : _typingUsers.length == 2
            ? '${_typingUsers[0]} and ${_typingUsers[1]} are typing...'
            : '${_typingUsers.length} people are typing...';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0A9D88)),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            typingText,
            style: TextStyle(
              color: Colors.grey[600], 
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.grey[600]),
              onPressed: _showAttachmentOptions,
              tooltip: 'Attach',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.black87, fontSize: 15),
                maxLines: null,
                onChanged: (text) {
                  if (text.isNotEmpty && !_isTyping) {
                    setState(() => _isTyping = true);
                    _updateTypingIndicator();
                  } else if (text.isEmpty && _isTyping) {
                    setState(() => _isTyping = false);
                    _removeTypingIndicator();
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Message #${widget.chat.name}',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0A9D88),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
              tooltip: 'Send',
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isUploading) return;

    _messageController.clear();
    _removeTypingIndicator();
    setState(() => _isTyping = false);

    final messageId = _firestore
        .collection('community_chats')
        .doc(widget.chat.id)
        .collection('messages')
        .doc().id;

    final message = ChatMessage(
      id: messageId,
      senderId: widget.currentUserId,
      senderName: widget.currentUsername,
      content: content,
      timestamp: DateTime.now(),
      type: MessageType.text,
      status: MessageStatus.sending,
      reactions: [],
    );

    // Add message with sending status
    await _firestore
        .collection('community_chats')
        .doc(widget.chat.id)
        .collection('messages')
        .doc(messageId)
        .set(message.toFirestore());

    // Update status to sent
    await _firestore
        .collection('community_chats')
        .doc(widget.chat.id)
        .collection('messages')
        .doc(messageId)
        .update({'status': MessageStatus.sent.index});

    // Update last message in chat
    await _firestore
        .collection('community_chats')
        .doc(widget.chat.id)
        .update({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    _scrollToBottom();
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Share Content',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.photo,
                  label: 'Photo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.attach_file,
                  label: 'File',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFile();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF0A9D88).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0A9D88),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _uploadFile(File(pickedFile.path), MessageType.image);
    }
  }

  void _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _uploadFile(File(pickedFile.path), MessageType.image);
    }
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      _uploadFile(File(result.files.single.path!), MessageType.file,
                 fileName: result.files.single.name);
    }
  }

  void _uploadFile(File file, MessageType type, {String? fileName}) async {
    setState(() => _isUploading = true);

    try {
      final messageId = _firestore
          .collection('community_chats')
          .doc(widget.chat.id)
          .collection('messages')
          .doc().id;

      final ref = _storage.ref().child(
          'chat_files/${widget.chat.id}/$messageId${_getFileExtension(file.path)}');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      final message = ChatMessage(
        id: messageId,
        senderId: widget.currentUserId,
        senderName: widget.currentUsername,
        content: _messageController.text.trim(),
        timestamp: DateTime.now(),
        type: type,
        fileUrl: downloadUrl,
        fileName: fileName ?? file.path.split('/').last,
        status: MessageStatus.sent,
        reactions: [],
      );

      await _firestore
          .collection('community_chats')
          .doc(widget.chat.id)
          .collection('messages')
          .doc(messageId)
          .set(message.toFirestore());

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to upload file',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  String _getFileExtension(String path) {
    return path.substring(path.lastIndexOf('.'));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showMembersList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MembersListSheet(
        chatId: widget.chat.id,
        currentUserId: widget.currentUserId,
        isAdmin: widget.chat.admins.contains(widget.currentUserId),
      ),
    );
  }

  void _showCreateSubGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateSubGroupDialog(
        parentChatId: widget.chat.id,
        currentUserId: widget.currentUserId,
        currentUsername: widget.currentUsername,
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Chat Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            _buildChatOption(
              icon: Icons.search,
              title: 'Search Messages',
              onTap: () => Navigator.pop(context),
            ),
            _buildChatOption(
              icon: Icons.notifications,
              title: 'Notification Settings',
              onTap: () => Navigator.pop(context),
            ),
            if (widget.chat.admins.contains(widget.currentUserId))
              _buildChatOption(
                icon: Icons.settings,
                title: 'Manage Chat',
                onTap: () => Navigator.pop(context),
              ),
            _buildChatOption(
              icon: Icons.info,
              title: 'Chat Info',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildChatOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF0A9D88).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF0A9D88),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}



// Members List Sheet
class MembersListSheet extends StatelessWidget {
  final String chatId;
  final String currentUserId;
  final bool isAdmin;

  const MembersListSheet({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Members',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('community_chats')
                  .doc(chatId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A9D88)),
                    ),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text('No members found'),
                  );
                }

                final chatData = snapshot.data!.data() as Map<String, dynamic>;
                final memberIds = List<String>.from(chatData['members'] ?? []);
                final adminIds = List<String>.from(chatData['admins'] ?? []);

                return ListView.builder(
                  itemCount: memberIds.length,
                  itemBuilder: (context, index) {
                    final memberId = memberIds[index];
                    final isCurrentUser = memberId == currentUserId;
                    final isMemberAdmin = adminIds.contains(memberId);

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(memberId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                        final username = userData?['username'] ?? 'Unknown User';
                        final profileImageUrl = userData?['profileImageUrl'];

                        return ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF0A9D88).withOpacity(0.2),
                            backgroundImage: profileImageUrl != null
                                ? NetworkImage(profileImageUrl)
                                : null,
                            child: profileImageUrl == null
                                ? Text(
                                    username[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF0A9D88),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Row(
                            children: [
                              Text(
                                username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (isCurrentUser) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0A9D88).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'You',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF0A9D88),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            isMemberAdmin ? 'Admin' : 'Member',
                            style: TextStyle(
                              color: isMemberAdmin 
                                  ? const Color(0xFF0A9D88) 
                                  : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: isMemberAdmin 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isAdmin && !isCurrentUser
                              ? PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'remove') {
                                      _removeMember(context, memberId, username);
                                    } else if (value == 'make_admin') {
                                      _makeAdmin(context, memberId, username);
                                    } else if (value == 'remove_admin') {
                                      _removeAdmin(context, memberId, username);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    if (!isMemberAdmin)
                                      const PopupMenuItem(
                                        value: 'make_admin',
                                        child: Text('Make Admin'),
                                      ),
                                    if (isMemberAdmin)
                                      const PopupMenuItem(
                                        value: 'remove_admin',
                                        child: Text('Remove Admin'),
                                      ),
                                    const PopupMenuItem(
                                      value: 'remove',
                                      child: Text('Remove from Group'),
                                    ),
                                  ],
                                )
                              : null,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _removeMember(BuildContext context, String memberId, String username) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove $username from this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('community_chats')
                    .doc(chatId)
                    .update({
                  'members': FieldValue.arrayRemove([memberId]),
                  'admins': FieldValue.arrayRemove([memberId]),
                });
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$username removed from group'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to remove member'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _makeAdmin(BuildContext context, String memberId, String username) async {
    try {
      await FirebaseFirestore.instance
          .collection('community_chats')
          .doc(chatId)
          .update({
        'admins': FieldValue.arrayUnion([memberId]),
      });
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$username is now an admin'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to make admin'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeAdmin(BuildContext context, String memberId, String username) async {
    try {
      await FirebaseFirestore.instance
          .collection('community_chats')
          .doc(chatId)
          .update({
        'admins': FieldValue.arrayRemove([memberId]),
      });
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$username is no longer an admin'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove admin'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Create Sub Group Dialog
class CreateSubGroupDialog extends StatefulWidget {
  final String parentChatId;
  final String currentUserId;
  final String currentUsername;

  const CreateSubGroupDialog({
    super.key,
    required this.parentChatId,
    required this.currentUserId,
    required this.currentUsername,
  });

  @override
  State<CreateSubGroupDialog> createState() => _CreateSubGroupDialogState();
}

class _CreateSubGroupDialogState extends State<CreateSubGroupDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _selectedMembers = [];
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Sub Group'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            const Text('Select Members:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Flexible(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('community_chats')
                    .doc(widget.parentChatId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final chatData = snapshot.data!.data() as Map<String, dynamic>;
                  final memberIds = List<String>.from(chatData['members'] ?? []);

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: memberIds.length,
                    itemBuilder: (context, index) {
                      final memberId = memberIds[index];
                      if (memberId == widget.currentUserId) return const SizedBox.shrink();

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(memberId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) return const SizedBox.shrink();

                          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                          final username = userData?['username'] ?? 'Unknown User';

                          return CheckboxListTile(
                            title: Text(username),
                            value: _selectedMembers.contains(memberId),
                            onChanged: (selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedMembers.add(memberId);
                                } else {
                                  _selectedMembers.remove(memberId);
                                }
                              });
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createSubGroup,
          child: _isCreating 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  void _createSubGroup() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final subGroupRef = FirebaseFirestore.instance.collection('community_chats').doc();
      
      final members = [widget.currentUserId, ..._selectedMembers];
      
      await subGroupRef.set({
        'id': subGroupRef.id,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': null,
        'members': members,
        'admins': [widget.currentUserId],
        'memberCount': members.length,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'parentChatId': widget.parentChatId,
        'type': 'subgroup',
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sub group created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create sub group'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}