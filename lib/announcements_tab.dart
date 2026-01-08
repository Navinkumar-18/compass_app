import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:connect_app/auth_provider.dart';

class AnnouncementsTab extends StatelessWidget {
  const AnnouncementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final announcements = auth.announcements;
        final isTeacher = auth.role == 'teacher' || auth.role == 'admin';

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Section Header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.campaign,
                    color: Color(0xFF4A90E2),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Announcements',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'Stay updated with the latest news and important information.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isTeacher)
                  ElevatedButton.icon(
                    onPressed: () => _showCreateAnnouncementDialog(context, auth),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Create Announcement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // Announcement Cards
            if (announcements.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.campaign_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No announcements yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...announcements.map((announcement) => _AnnouncementCard(announcement: announcement)),
          ],
        ),
      ),
    );
      },
    );
  }

  void _showCreateAnnouncementDialog(BuildContext context, AuthProvider auth) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'General';
    String selectedPriority = 'Medium Priority';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Announcement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'General', child: Text('General')),
                    DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance')),
                    DropdownMenuItem(value: 'Feature', child: Text('Feature')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value ?? 'General';
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  initialValue: selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: const [
                    DropdownMenuItem(value: 'High Priority', child: Text('High Priority')),
                    DropdownMenuItem(value: 'Medium Priority', child: Text('Medium Priority')),
                    DropdownMenuItem(value: 'Low Priority', child: Text('Low Priority')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value ?? 'Medium Priority';
                    });
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
            onPressed: () {
              if (titleController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                auth.addAnnouncement(
                  titleController.text,
                  descriptionController.text,
                  selectedCategory,
                  selectedPriority,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const _AnnouncementCard({required this.announcement});

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Maintenance':
        return const Color(0xFF9B59B6);
      case 'Feature':
        return const Color(0xFF3498DB);
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    if (priority.contains('High')) {
      return const Color(0xFFE74C3C);
    } else if (priority.contains('Medium')) {
      return const Color(0xFFF39C12);
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and New Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    announcement.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                if (announcement.isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'New',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Category and Priority Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(announcement.category).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    announcement.category,
                    style: TextStyle(
                      color: _getCategoryColor(announcement.category),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(announcement.priority).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    announcement.priority,
                    style: TextStyle(
                      color: _getPriorityColor(announcement.priority),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              announcement.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            // Date and Time
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMMM d, yyyy').format(announcement.date),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  announcement.time,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
