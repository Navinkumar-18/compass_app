import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connect_app/auth_provider.dart';
import 'package:connect_app/home_screen.dart';
import 'package:connect_app/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  Future<void> _login() async {
    if (!mounted) return;
    
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      try {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        
        // Attempt login
        await auth.login(email, password);
        
        // Close loading indicator and navigate
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } catch (e, stackTrace) {
        // Log the error for debugging
        debugPrint('Login error: $e');
        debugPrint('Stack trace: $stackTrace');
        
        // Close loading indicator if still open
        if (mounted) {
          try {
            Navigator.of(context).pop(); // Close loading dialog
          } catch (_) {
            // Dialog might already be closed
          }
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Section - Header with dark blue background
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A8A), // Dark blue
                ),
                child: Stack(
                  children: [
                    // Abstract building/campus architecture background effect
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CampusBackgroundPainter(),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Graduation cap icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Welcome text
                          const Text(
                            'Welcome to Campus Portal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Subtitle
                          Text(
                            'Access your academic resources and campus services.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Section - Login Form with white background
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Sign In to Your Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        'Enter your credentials to access the campus portal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Email Address Field
                      const Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'student@college.edu',
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF4A90E2)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF4A90E2)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF4A90E2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Password Field
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outlined, color: Color(0xFF4A90E2)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: const Color(0xFF4A90E2),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF4A90E2)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF4A90E2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Remember me and Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: const Color(0xFF4A90E2),
                              ),
                              const Text(
                                'Remember me',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Forgot Password feature coming soon!')),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFF4A90E2),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90E2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Registration Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final registered = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                );
                                if (!mounted) return;
                                if (registered == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Registration successful. Please sign in.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Sign up here',
                                style: TextStyle(
                                  color: Color(0xFF4A90E2),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Copyright
                      Center(
                        child: Text(
                          '©2025 College Portal. All rights reserved.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for abstract campus architecture background
class _CampusBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Draw abstract building shapes
    final path = Path();
    
    // Building 1
    path.moveTo(size.width * 0.1, size.height * 0.7);
    path.lineTo(size.width * 0.1, size.height * 0.4);
    path.lineTo(size.width * 0.25, size.height * 0.3);
    path.lineTo(size.width * 0.25, size.height * 0.7);
    path.close();
    canvas.drawPath(path, paint);

    // Building 2
    final path2 = Path();
    path2.moveTo(size.width * 0.3, size.height * 0.8);
    path2.lineTo(size.width * 0.3, size.height * 0.2);
    path2.lineTo(size.width * 0.5, size.height * 0.15);
    path2.lineTo(size.width * 0.5, size.height * 0.8);
    path2.close();
    canvas.drawPath(path2, paint);

    // Building 3
    final path3 = Path();
    path3.moveTo(size.width * 0.55, size.height * 0.75);
    path3.lineTo(size.width * 0.55, size.height * 0.35);
    path3.lineTo(size.width * 0.75, size.height * 0.4);
    path3.lineTo(size.width * 0.75, size.height * 0.75);
    path3.close();
    canvas.drawPath(path3, paint);

    // Building 4
    final path4 = Path();
    path4.moveTo(size.width * 0.8, size.height * 0.85);
    path4.lineTo(size.width * 0.8, size.height * 0.25);
    path4.lineTo(size.width * 0.95, size.height * 0.3);
    path4.lineTo(size.width * 0.95, size.height * 0.85);
    path4.close();
    canvas.drawPath(path4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
