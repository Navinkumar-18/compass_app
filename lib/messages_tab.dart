import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:connect_app/auth_provider.dart';

class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  String? _selectedGroupId;
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final chatGroups = auth.chatGroups;
        final userEmail = auth.userEmail;
        final role = auth.role;
        final isTeacher = role == 'teacher' || role == 'admin';
        final groups = chatGroups.where((g) => g.members.contains(userEmail)).toList();

    if (_selectedGroupId == null && groups.isNotEmpty) {
      _selectedGroupId = groups.first.id;
    }

    final selectedGroup = groups.firstWhere(
      (g) => g.id == _selectedGroupId,
      orElse: () => groups.isNotEmpty ? groups.first : ChatGroup(
        id: '',
        name: 'No Group',
        members: [],
        messages: [],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          // Groups List Sidebar
          Container(
            width: 300,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Groups',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      if (isTeacher)
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Color(0xFF4A90E2)),
                          onPressed: () => _showCreateGroupDialog(context, auth),
                        ),
                    ],
                  ),
                ),
                // Groups List
                Expanded(
                  child: groups.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.group_outlined, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No groups yet',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                              if (isTeacher) ...[
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _showCreateGroupDialog(context, auth),
                                  child: const Text('Create Group'),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: groups.length,
                          itemBuilder: (context, index) {
                            final group = groups[index];
                            final isSelected = group.id == _selectedGroupId;
                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF4A90E2),
                                child: Text(
                                  group.name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                group.name,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                '${group.members.length} members',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedGroupId = group.id;
                                });
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          // Chat Area
          Expanded(
            child: Column(
              children: [
                // Chat Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF4A90E2),
                        child: Text(
                          selectedGroup.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedGroup.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              '${selectedGroup.members.length} members',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Messages List
                Expanded(
                  child: selectedGroup.messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.message_outlined, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start the conversation!',
                                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
            : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: selectedGroup.messages.length,
              itemBuilder: (context, index) {
                            final message = selectedGroup.messages[index];
                            final isMe = message.sender == auth.userEmail;
                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe ? const Color(0xFF4A90E2) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Text(
                                        message.sender.split('@')[0],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4A90E2),
                                        ),
                                      ),
                                    if (!isMe) const SizedBox(height: 4),
                                    Text(
                                      message.content,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isMe ? Colors.white : const Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('h:mm a').format(message.timestamp),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isMe
                                            ? Colors.white.withValues(alpha: 0.7)
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Message Input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        backgroundColor: const Color(0xFF4A90E2),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () {
                            if (_messageController.text.trim().isNotEmpty &&
                                _selectedGroupId != null) {
                              auth.sendMessage(_selectedGroupId!, _messageController.text.trim());
                              _messageController.clear();
                              // wait for the frame after provider notifies, then scroll to bottom
                              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    try {
      final position = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        position + 100,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } catch (_) {
      // ignore
    }
  }

  void _showCreateGroupDialog(BuildContext context, AuthProvider auth) {
    final nameController = TextEditingController();
    final studentsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: studentsController,
              decoration: const InputDecoration(
                labelText: 'Student Emails (comma separated)',
                hintText: 'student1@vcet.edu, student2@vcet.edu',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final emails = studentsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                auth.createChatGroup(nameController.text, emails);
                Navigator.pop(context);
                setState(() {
                  _selectedGroupId = auth.chatGroups.last.id;
                });
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

