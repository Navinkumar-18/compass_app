import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:connect_app/auth_provider.dart';

class EventsTab extends StatelessWidget {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AuthProvider, Map<String, dynamic>>(
      selector: (_, auth) => {
        'events': auth.events,
        'role': auth.role,
        'registeredEvents': auth.registeredEventIds,
      },
      builder: (context, data, _) {
        final events = data['events'] as List;
        final role = data['role'] as String?;
        final registeredEvents = data['registeredEvents'] as Set<String>;
        final isTeacher = role == 'teacher' || role == 'admin';
        final auth = Provider.of<AuthProvider>(context, listen: false);

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
                    Icons.event,
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
                        'Events',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'Discover and register for upcoming ThinkHud events',
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
                    onPressed: () => _showCreateEventDialog(context, auth),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Create Event'),
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
            // Event Cards
            if (events.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.event_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No events scheduled',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...events.map(
                (event) => _EventCard(
                  event: event,
                  auth: auth,
                  isRegistered: registeredEvents.contains(event.id),
                ),
              ),
          ],
        ),
      ),
    );
      },
    );
  }

  void _showCreateEventDialog(BuildContext context, AuthProvider auth) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final timeController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    String selectedCategory = 'Conference';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Event'),
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
                ListTile(
                  title: Text('Date: ${DateFormat('MMMM d, yyyy').format(selectedDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2026, 12, 31),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(labelText: 'Time (e.g., 9:00 AM - 6:00 PM EST)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setStateDropdown) => DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(value: 'Conference', child: Text('Conference')),
                      DropdownMenuItem(value: 'Workshop', child: Text('Workshop')),
                      DropdownMenuItem(value: 'Seminar', child: Text('Seminar')),
                    ],
                    onChanged: (value) {
                      setStateDropdown(() {
                        selectedCategory = value ?? 'Conference';
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
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    locationController.text.isNotEmpty &&
                    timeController.text.isNotEmpty) {
                  auth.addEvent(
                    titleController.text,
                    descriptionController.text,
                    selectedDate,
                    timeController.text,
                    locationController.text,
                    selectedCategory,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final AuthProvider auth;
  final bool isRegistered;

  const _EventCard({
    required this.event,
    required this.auth,
    required this.isRegistered,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Conference':
        return const Color(0xFFE91E63);
      case 'Workshop':
        return const Color(0xFF9C27B0);
      default:
        return Colors.blue;
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'Available') {
      return const Color(0xFF4CAF50);
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Image.network(
                  event.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.event, size: 64, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Upcoming',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Tags
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(event.category).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.category,
                        style: TextStyle(
                          color: _getCategoryColor(event.category),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(event.status).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.status,
                        style: TextStyle(
                          color: _getStatusColor(event.status),
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
                  event.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                // Event Details
                _EventDetailRow(Icons.calendar_today, DateFormat('MMMM d, yyyy').format(event.date)),
                const SizedBox(height: 8),
                _EventDetailRow(Icons.access_time, event.time),
                const SizedBox(height: 8),
                _EventDetailRow(Icons.location_on, event.location),
                const SizedBox(height: 8),
                _EventDetailRow(
                  Icons.people,
                  '${event.attendees} / ${event.maxAttendees} attendees',
                ),
                const SizedBox(height: 20),
                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isRegistered
                        ? null
                        : () {
                            auth.registerForEvent(event.id);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRegistered ? Colors.grey[400] : const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[400],
                      disabledForegroundColor: Colors.white,
                    ),
                    child: Text(
                      isRegistered ? 'Registered' : 'Register Now',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EventDetailRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}

