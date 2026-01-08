import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connect_app/auth_provider.dart';
import 'package:connect_app/login_screen.dart';
import 'package:connect_app/announcements_tab.dart';
import 'package:connect_app/events_tab.dart';
import 'package:connect_app/resources_tab.dart';
import 'package:connect_app/messages_tab.dart';
import 'package:connect_app/settings_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // App Logo
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'App Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Manage your announcements, events, and resources.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Logout button
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      auth.logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Tab Bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF4A90E2),
                indicatorWeight: 3,
                labelColor: const Color(0xFF1E3A8A),
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.campaign),
                    text: 'Announcements',
                  ),
                  Tab(
                    icon: Icon(Icons.event),
                    text: 'Events',
                  ),
                  Tab(
                    icon: Icon(Icons.folder),
                    text: 'Resources',
                  ),
                  Tab(
                    icon: Icon(Icons.message),
                    text: 'Messages',
                  ),
                  Tab(
                    icon: Icon(Icons.settings),
                    text: 'Settings',
                  ),
                ],
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  AnnouncementsTab(),
                  EventsTab(),
                  ResourcesTab(),
                  MessagesTab(),
                  SettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
