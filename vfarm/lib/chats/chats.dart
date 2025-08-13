import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:vfarm/chats/chatsroompage.dart';

// Models
class CommunityChat {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String createdBy;
  final DateTime createdAt;
  final List<String> members;
  final List<String> admins;
  final bool isPublic;
  final int memberCount;
  final List<String> tags;

  CommunityChat({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.createdBy,
    required this.createdAt,
    required this.members,
    required this.admins,
    required this.isPublic,
    required this.memberCount,
    required this.tags,
  });

  factory CommunityChat.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CommunityChat(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      members: List<String>.from(data['members'] ?? []),
      admins: List<String>.from(data['admins'] ?? []),
      isPublic: data['isPublic'] ?? true,
      memberCount: data['memberCount'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'members': members,
      'admins': admins,
      'isPublic': isPublic,
      'memberCount': memberCount,
      'tags': tags,
    };
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final String? fileUrl;
  final String? fileName;
  final MessageStatus status;
  final List<String> reactions;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.type,
    this.fileUrl,
    this.fileName,
    required this.status,
    required this.reactions,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: MessageType.values[data['type'] ?? 0],
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
      status: MessageStatus.values[data['status'] ?? 0],
      reactions: List<String>.from(data['reactions'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.index,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'status': status.index,
      'reactions': reactions,
    };
  }
}

enum MessageType { text, image, file, voice }
enum MessageStatus { sending, sent, delivered, read }

class CommunityChatsPage extends StatefulWidget {
  final String currentUserId;
  final String currentUsername;

  const CommunityChatsPage({
    super.key,
    required this.currentUserId,
    required this.currentUsername,
  });

  @override
  State<CommunityChatsPage> createState() => _CommunityChatsPageState();
}

class _CommunityChatsPageState extends State<CommunityChatsPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  late TabController _tabController;
  String _searchQuery = '';
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text('Community Chats', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A9D88),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF5865F2),
          labelColor: const Color.fromARGB(255, 255, 255, 255),
          unselectedLabelColor: const Color.fromARGB(255, 255, 253, 253),
          tabs: const [
            Tab(text: 'Discover'),
            Tab(text: 'My Chats'),
            Tab(text: 'DMs'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showCreateChatDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDiscoverTab(),
                _buildMyChatsTab(),
                _buildDirectMessagesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color.fromARGB(255, 255, 255, 255),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search communities, messages...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF40444B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('community_chats')
          .where('isPublic', isEqualTo: true)
          .orderBy('memberCount', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('No communities found', 'Be the first to create one!');
        }

        final chats = snapshot.data!.docs
            .map((doc) => CommunityChat.fromFirestore(doc))
            .where((chat) => _searchQuery.isEmpty ||
                chat.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                chat.description.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chats.length,
          itemBuilder: (context, index) => _buildCommunityCard(chats[index]),
        );
      },
    );
  }

  Widget _buildMyChatsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('community_chats')
          .where('members', arrayContains: widget.currentUserId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('No chats joined', 'Join a community to start chatting!');
        }

        final chats = snapshot.data!.docs
            .map((doc) => CommunityChat.fromFirestore(doc))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chats.length,
          itemBuilder: (context, index) => _buildMyChatCard(chats[index]),
        );
      },
    );
  }

  Widget _buildDirectMessagesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('direct_messages')
          .where('participants', arrayContains: widget.currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState('No direct messages', 'Start a conversation!');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final dmData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return _buildDirectMessageCard(dmData, snapshot.data!.docs[index].id);
          },
        );
      },
    );
  }

  Widget _buildCommunityCard(CommunityChat chat) {
    final isMember = chat.members.contains(widget.currentUserId);
    
    return Card(
      color: const Color(0xFF36393F),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF5865F2),
                  backgroundImage: chat.imageUrl != null ? NetworkImage(chat.imageUrl!) : null,
                  child: chat.imageUrl == null
                      ? Text(chat.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 20))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${chat.memberCount} members',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                isMember
                    ? ElevatedButton(
                        onPressed: () => _openChat(chat),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 29, 155, 136),
                        ),
                        child: const Text('Open',style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                      )
                    : OutlinedButton(
                        onPressed: () => _joinChat(chat),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                        child: const Text('Join', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
                      ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              chat.description,
              style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (chat.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: chat.tags.map((tag) => Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 10)),
                  backgroundColor: const Color(0xFF5865F2).withOpacity(0.2),
                  labelStyle: const TextStyle(color: Color(0xFF5865F2)),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMyChatCard(CommunityChat chat) {
    return Card(
      color: const Color(0xFF36393F),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF5865F2),
          backgroundImage: chat.imageUrl != null ? NetworkImage(chat.imageUrl!) : null,
          child: chat.imageUrl == null
              ? Text(chat.name[0].toUpperCase(), style: const TextStyle(color: Colors.white))
              : null,
        ),
        title: Text(chat.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          chat.description,
          style: const TextStyle(color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chat.admins.contains(widget.currentUserId))
              const Icon(Icons.admin_panel_settings, color: Color(0xFFF04747), size: 16),
            const SizedBox(width: 4),
            Text('${chat.memberCount}', style: const TextStyle(color: Colors.grey)),
            const Icon(Icons.people, color: Colors.grey, size: 16),
          ],
        ),
        onTap: () => _openChat(chat),
        onLongPress: () => _showChatOptions(chat),
      ),
    );
  }

  Widget _buildDirectMessageCard(Map<String, dynamic> dmData, String dmId) {
    final participants = List<String>.from(dmData['participants'] ?? []);
    final otherUserId = participants.firstWhere((id) => id != widget.currentUserId, orElse: () => '');
    
    return Card(
      color: const Color(0xFF36393F),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF43B581),
          child: Text(
            dmData['otherUserName']?[0]?.toUpperCase() ?? 'U',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          dmData['otherUserName'] ?? 'Unknown User',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          dmData['lastMessage'] ?? 'No messages yet',
          style: const TextStyle(color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: dmData['lastMessageTime'] != null
            ? Text(
                _formatTime((dmData['lastMessageTime'] as Timestamp).toDate()),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              )
            : null,
        onTap: () => _openDirectMessage(dmId, dmData['otherUserName'] ?? 'Unknown User'),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18, color: Colors.grey[400])),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _showCreateChatDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateChatDialog(
        currentUserId: widget.currentUserId,
        currentUsername: widget.currentUsername,
      ),
    );
  }

  void _joinChat(CommunityChat chat) async {
    try {
      await _firestore.collection('community_chats').doc(chat.id).update({
        'members': FieldValue.arrayUnion([widget.currentUserId]),
        'memberCount': FieldValue.increment(1),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined ${chat.name}!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join chat')),
      );
    }
  }

  void _openChat(CommunityChat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomPage(
          chat: chat,
          currentUserId: widget.currentUserId,
          currentUsername: widget.currentUsername,
        ),
      ),
    );
  }

  void _openDirectMessage(String dmId, String otherUserName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DirectMessagePage(
          dmId: dmId,
          otherUserName: otherUserName,
          currentUserId: widget.currentUserId,
          currentUsername: widget.currentUsername,
        ),
      ),
    );
  }

  void _showChatOptions(CommunityChat chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF36393F),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.white),
            title: const Text('Notification Settings', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
          if (chat.admins.contains(widget.currentUserId))
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Manage Chat', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Leave Chat', style: TextStyle(color: Colors.red)),
            onTap: () => _leaveChat(chat),
          ),
        ],
      ),
    );
  }

  void _leaveChat(CommunityChat chat) async {
    Navigator.pop(context);
    try {
      await _firestore.collection('community_chats').doc(chat.id).update({
        'members': FieldValue.arrayRemove([widget.currentUserId]),
        'memberCount': FieldValue.increment(-1),
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Left ${chat.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to leave chat')),
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Create Chat Dialog
class CreateChatDialog extends StatefulWidget {
  final String currentUserId;
  final String currentUsername;

  const CreateChatDialog({
    super.key,
    required this.currentUserId,
    required this.currentUsername,
  });

  @override
  State<CreateChatDialog> createState() => _CreateChatDialogState();
}

class _CreateChatDialogState extends State<CreateChatDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isPublic = true;
  bool _isLoading = false;
  File? _selectedImage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF36393F),
      title: const Text('Create Community Chat', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF5865F2),
                backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                child: _selectedImage == null
                    ? const Icon(Icons.add_a_photo, color: Colors.white, size: 30)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Chat Name',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5865F2)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5865F2)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5865F2)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Public Chat', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Anyone can discover and join', style: TextStyle(color: Colors.grey)),
              value: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
              activeColor: const Color(0xFF5865F2),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createChat,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5865F2)),
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Create'),
        ),
      ],
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _createChat() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a chat name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final ref = _storage.ref().child('chat_images/${DateTime.now().millisecondsSinceEpoch}');
        await ref.putFile(_selectedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      final tags = _tagsController.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();

      final chat = CommunityChat(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        createdBy: widget.currentUserId,
        createdAt: DateTime.now(),
        members: [widget.currentUserId],
        admins: [widget.currentUserId],
        isPublic: _isPublic,
        memberCount: 1,
        tags: tags,
      );

      await _firestore.collection('community_chats').add(chat.toFirestore());

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create chat')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

// Direct Message Page (placeholder)
class DirectMessagePage extends StatelessWidget {
  final String dmId;
  final String otherUserName;
  final String currentUserId;
  final String currentUsername;

  const DirectMessagePage({
    super.key,
    required this.dmId,
    required this.otherUserName,
    required this.currentUserId,
    required this.currentUsername,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF36393F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202225),
        title: Text(otherUserName, style: const TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text(
          'Direct Message Implementation',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}