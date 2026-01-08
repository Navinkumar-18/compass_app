import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  User? _user;
  String? _role;
  String? _mockEmail; // For mock mode
  bool _firebaseInitialized = false;

  User? get user => _user;
  String? get role => _role;
  String? get userEmail => _user?.email ?? _mockEmail;

  // Initialize Firebase instances lazily
  void _initializeFirebase() {
    if (!_firebaseInitialized) {
      try {
        _auth = FirebaseAuth.instance;
        _firestore = FirebaseFirestore.instance;
        _firebaseInitialized = true;
      } catch (e) {
        // Firebase not available - will use mock mode
        _firebaseInitialized = false;
      }
    }
  }

  // Mock data for announcements
  final List<Announcement> _announcements = [
    Announcement(
      id: '1',
      title: 'System Maintenance Scheduled',
      description: 'We will be performing scheduled maintenance on our servers. The platform will be unavailable for approximately 2 hours during this period.',
      date: DateTime(2025, 11, 15),
      time: '2:00 AM - 4:00 AM EST',
      category: 'Maintenance',
      priority: 'High Priority',
      isNew: true,
    ),
    Announcement(
      id: '2',
      title: 'New Feature Release: Advanced Analytics',
      description: 'We\'re excited to announce the launch of our new Advanced Analytics dashboard. This feature provides detailed insights and reporting capabilities to help you make data-driven decisions.',
      date: DateTime(2025, 11, 12),
      time: '9:00 AM EST',
      category: 'Feature',
      priority: 'Medium Priority',
      isNew: true,
    ),
  ];

  // Mock data for events
  final List<Event> _events = [
    Event(
      id: '1',
      title: 'ThinkHud Innovation Summit 2025',
      description: 'Join us for an inspiring day of innovation, technology, and creative thinking. Network with industry leaders, attend workshops, and discover the latest trends shaping the future.',
      date: DateTime(2025, 12, 15),
      time: '9:00 AM - 6:00 PM EST',
      location: 'Tech Hub Convention Center, San Francisco',
      category: 'Conference',
      status: 'Available',
      attendees: 247,
      maxAttendees: 500,
      imageUrl: 'https://via.placeholder.com/400x200',
    ),
  ];

  // Mock data for chat groups
  final List<ChatGroup> _chatGroups = [
    ChatGroup(
      id: '1',
      name: 'Computer Science 101',
      members: ['teacher1@vcet.edu', 'student1@vcet.edu', 'student2@vcet.edu'],
      messages: [],
    ),
  ];
  final Set<String> _registeredEventIds = {};

  static const List<_DefaultGroupConfig> _defaultStudentGroupConfigs = [
    _DefaultGroupConfig(
      id: 'default-2nd-years',
      name: '2nd Years',
      initialMembers: ['teacher1@vcet.edu'],
    ),
    _DefaultGroupConfig(
      id: 'default-2nd-years-cse',
      name: '2nd Years CSE',
      initialMembers: ['teacher1@vcet.edu'],
    ),
  ];

  List<Announcement> get announcements => List.unmodifiable(_announcements);
  List<Event> get events => List.unmodifiable(_events);
  List<ChatGroup> get chatGroups => List.unmodifiable(_chatGroups);
  Set<String> get registeredEventIds => Set.unmodifiable(_registeredEventIds);

  // Mock users storage for offline mode - Pre-populated with test users
  static final Map<String, Map<String, dynamic>> _mockUsers = {
    'student1@vcet.edu': {
      'email': 'student1@vcet.edu',
      'password': 'pass123',
      'role': 'student',
    },
    'student2@vcet.edu': {
      'email': 'student2@vcet.edu',
      'password': 'pass123',
      'role': 'student',
    },
    'teacher1@vcet.edu': {
      'email': 'teacher1@vcet.edu',
      'password': 'pass123',
      'role': 'teacher',
    },
    'admin@vcet.edu': {
      'email': 'admin@vcet.edu',
      'password': 'admin123',
      'role': 'admin',
    },
  };

  Future<bool> register(String email, String password, {String role = 'student'}) async {
    _initializeFirebase();
    
    // Try Firebase first if available
    if (_firebaseInitialized && _auth != null && _firestore != null) {
      try {
        UserCredential cred = await _auth!.createUserWithEmailAndPassword(email: email, password: password);
        _user = cred.user;
        if (_user != null) {
          await _firestore!.collection('users').doc(_user!.uid).set({
            'email': email,
            'role': role,
          });
          _role = role;
        }
        _ensureDefaultGroupsForUser(email, role);
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint("Firebase registration error: $e - Using mock mode");
        // Fall back to mock mode
      }
    }
    
    // Use mock mode (Firebase not available or failed)
    if (_mockUsers.containsKey(email)) {
      return false;
    }
    _mockUsers[email] = {
      'email': email,
      'password': password,
      'role': role,
    };
    _user = null;
    _mockEmail = email;
    _role = role;
    _ensureDefaultGroupsForUser(email, role);
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    _initializeFirebase();
    
    // Try Firebase first if available
    if (_firebaseInitialized && _auth != null && _firestore != null) {
      try {
        UserCredential cred = await _auth!.signInWithEmailAndPassword(email: email, password: password);
        _user = cred.user;
        if (_user != null) {
          DocumentSnapshot doc = await _firestore!.collection('users').doc(_user!.uid).get();
          _role = doc['role'] as String? ?? 'student';
        }
        _ensureDefaultGroupsForUser(_user?.email ?? email, _role ?? 'student');
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint("Firebase login error: $e - Using mock mode");
        // Fall back to mock mode
      }
    }
    
    // Use mock mode (Firebase not available or failed)
    final userData = _mockUsers[email];
    if (userData == null || userData['password'] != password) {
      return false;
    }
    _user = null;
    _mockEmail = email;
    _role = userData['role'] as String? ?? 'student';
    _ensureDefaultGroupsForUser(email, _role!);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    if (_firebaseInitialized && _auth != null) {
      try {
        await _auth!.signOut();
      } catch (e) {
        debugPrint("Firebase logout error: $e");
      }
    }
    _user = null;
    _mockEmail = null;
    _role = null;
    _registeredEventIds.clear();
    notifyListeners();
  }

  void addAnnouncement(String title, String description, String category, String priority) {
    final announcement = Announcement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      date: DateTime.now(),
      time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} AM EST',
      category: category,
      priority: priority,
      isNew: true,
    );
    _announcements.insert(0, announcement);
    notifyListeners();
  }

  void addEvent(String title, String description, DateTime date, String time, String location, String category) {
    final event = Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      date: date,
      time: time,
      location: location,
      category: category,
      status: 'Available',
      attendees: 0,
      maxAttendees: 500,
      imageUrl: 'https://via.placeholder.com/400x200',
    );
    _events.insert(0, event);
    notifyListeners();
  }

  bool registerForEvent(String eventId) {
    if (_registeredEventIds.contains(eventId)) {
      return false;
    }

    final event = _events.firstWhere((e) => e.id == eventId);
    if (event.attendees >= event.maxAttendees) {
      return false;
    }

    event.attendees++;
    _registeredEventIds.add(eventId);
    notifyListeners();
    return true;
  }

  bool isRegisteredForEvent(String eventId) => _registeredEventIds.contains(eventId);

  void sendMessage(String groupId, String content) {
    final group = _chatGroups.firstWhere((g) => g.id == groupId);
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: userEmail ?? 'Unknown',
      content: content,
      timestamp: DateTime.now(),
    );
    // Replace the messages list with a new list so selectors depending on the list
    // detect the change (List identity changes). This ensures UI updates immediately.
    group.messages = [...group.messages, message];
    notifyListeners();
  }

  void createChatGroup(String name, List<String> studentEmails) {
    final group = ChatGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      members: [userEmail ?? '', ...studentEmails],
      messages: [],
    );
    _chatGroups.add(group);
    notifyListeners();
  }

  void _ensureDefaultGroupsForUser(String email, String role) {
    if (email.isEmpty || role != 'student') {
      return;
    }

    for (final config in _defaultStudentGroupConfigs) {
      ChatGroup? group = _findGroupById(config.id);
      if (group == null) {
        group = ChatGroup(
          id: config.id,
          name: config.name,
          members: [...config.initialMembers, email],
          messages: [],
        );
        _chatGroups.add(group);
        continue;
      }

      for (final member in [...config.initialMembers, email]) {
        if (member.isEmpty || group.members.contains(member)) {
          continue;
        }
        group.members.add(member);
      }
    }
  }

  ChatGroup? _findGroupById(String id) {
    try {
      return _chatGroups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Update the current user's profile (display name and bio).
  /// If Firebase is initialized, write to Firestore; otherwise update the local mock store.
  Future<void> updateProfile(String name, String bio) async {
    _initializeFirebase();
    try {
      if (_firebaseInitialized && _firestore != null && _user != null) {
        await _firestore!.collection('users').doc(_user!.uid).set({
          'name': name,
          'bio': bio,
        }, SetOptions(merge: true));
      } else {
        final key = _user?.email ?? _mockEmail;
        if (key != null && _mockUsers.containsKey(key)) {
          _mockUsers[key]!['name'] = name;
          _mockUsers[key]!['bio'] = bio;
        }
      }
    } catch (e) {
      debugPrint('Profile update error: $e');
    }
    notifyListeners();
  }
}

// Data Models
class Announcement {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String category;
  final String priority;
  final bool isNew;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.category,
    required this.priority,
    this.isNew = false,
  });
}

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final String category;
  final String status;
  int attendees;
  final int maxAttendees;
  final String imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.category,
    required this.status,
    required this.attendees,
    required this.maxAttendees,
    required this.imageUrl,
  });
}

class ChatGroup {
  final String id;
  final String name;
  final List<String> members;
  // messages is mutable so we can replace the list to trigger change detection in Selectors
  List<ChatMessage> messages;

  ChatGroup({
    required this.id,
    required this.name,
    required this.members,
    required this.messages,
  });
}

class ChatMessage {
  final String id;
  final String sender;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
  });
}

class _DefaultGroupConfig {
  final String id;
  final String name;
  final List<String> initialMembers;

  const _DefaultGroupConfig({
    required this.id,
    required this.name,
    this.initialMembers = const [],
  });
}

