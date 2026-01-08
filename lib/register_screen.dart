import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connect_app/auth_provider.dart';
import 'package:connect_app/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'Student';

  Future<void> _register() async {
    if (!mounted) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final role = _selectedRole.toLowerCase();

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.register(email, password, role: role);
      if (!mounted) return;
      Navigator.of(context).pop(); // close loader

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed: email may already be registered'), backgroundColor: Colors.red),
        );
      }
  } catch (e) {
      if (mounted) Navigator.of(context).pop();
      debugPrint('Registration error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Color(0xFF1E3A8A)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('connect_app', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 32),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.person_add, color: Colors.white, size: 64),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Center(child: Text('Create Your Account', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 12),
                      Center(child: Text('Join Connect App to access your campus resources.', style: TextStyle(color: Colors.white.withValues(alpha: 0.9)), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(child: Text('Registration', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)))),
                      const SizedBox(height: 32),
                      TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(hintText: 'Email Address', prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF4A90E2)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                      const SizedBox(height: 20),
                      TextField(controller: _passwordController, obscureText: _obscurePassword, decoration: InputDecoration(hintText: 'Password', prefixIcon: const Icon(Icons.lock_outlined, color: Color(0xFF4A90E2)), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF4A90E2)), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                      const SizedBox(height: 20),
                      TextField(controller: _confirmPasswordController, obscureText: _obscureConfirmPassword, decoration: InputDecoration(hintText: 'Confirm Password', prefixIcon: const Icon(Icons.lock_outlined, color: Color(0xFF4A90E2)), suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF4A90E2)), onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                      const SizedBox(height: 32),
                      const Text('Select Role', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _RoleChip(label: 'Student', isSelected: _selectedRole == 'Student', onTap: () => setState(() => _selectedRole = 'Student'))),
                        const SizedBox(width: 12),
                        Expanded(child: _RoleChip(label: 'Teacher', isSelected: _selectedRole == 'Teacher', onTap: () => setState(() => _selectedRole = 'Teacher'))),
                        const SizedBox(width: 12),
                        Expanded(child: _RoleChip(label: 'Admin', isSelected: _selectedRole == 'Admin', onTap: () => setState(() => _selectedRole = 'Admin'))),
                      ]),
                      const SizedBox(height: 32),
                      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _register, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A90E2), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            }
                          },
                          child: const Text('Already have an account? Sign in', style: TextStyle(color: Color(0xFF4A90E2), fontSize: 14)),
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

class _RoleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(color: isSelected ? Colors.grey[200] : Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[300]!, width: isSelected ? 2 : 1)),
        child: Center(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[700]))),
      ),
    );
  }
}

// Note: no custom painter is used currently. If you want the abstract campus background
// re-enabled, add a CustomPaint in the header area and restore this painter.
