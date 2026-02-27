import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/providers/auth_provider.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/google_auth_button.dart';
import '../../../../core/utils/helpers.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLogin = true;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _submit() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      Helpers.showSnackBar(context, 'Please fill in all fields', isError: true);
      return;
    }

    if (!_isLogin &&
        _passwordController.text != _confirmPasswordController.text) {
      Helpers.showSnackBar(context, 'Passwords do not match', isError: true);
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (_isLogin) {
        await auth.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        if (_nameController.text.trim().isEmpty) {
          Helpers.showSnackBar(context, 'Please enter your name', isError: true);
          return;
        }

        await auth.register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );

        if (mounted) {
          Helpers.showSnackBar(
              context,
              'Account created! Please check your email to verify.',
              isError: false
          );
          // Login Mode
          setState(() {
            _isLogin = true;
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  // Google Sign In
  Future<void> _googleSignIn() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).googleLogin();
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  // Forgot Password
  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      Helpers.showSnackBar(context, 'Please enter your email first', isError: true);
      return;
    }
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .resetPassword(_emailController.text.trim());
      if (mounted) {
        Helpers.showSnackBar(context, 'Password reset email sent!', isError: false);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  // Toggle Auth Mode
  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.heartPulse,
                    color: Color(0xFFff7e5f),
                    size: 48,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _isLogin ? 'HealthPrime' : 'Create Account',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFff7e5f),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isLogin
                        ? 'Track your health journey comprehensively'
                        : 'Join HealthPrime today',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (!_isLogin) ...[
                    AuthFormField(
                      label: 'Full Name',
                      icon: Icons.person,
                      isPassword: false,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),
                  ],

                  AuthFormField(
                    label: 'Email Address',
                    icon: Icons.email,
                    isPassword: false,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),

                  AuthFormField(
                    label: 'Password',
                    icon: Icons.lock,
                    isPassword: true,
                    controller: _passwordController,
                  ),

                  if (_isLogin) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _forgotPassword,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color(0xFFff7e5f),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (!_isLogin) ...[
                    const SizedBox(height: 20),
                    AuthFormField(
                      label: 'Confirm Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      controller: _confirmPasswordController,
                    ),
                  ],

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFff7e5f),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFFff7e5f).withOpacity(0.3),
                      ),
                      icon: Icon(_isLogin ? Icons.login : Icons.person_add,
                          size: 20),
                      label: Text(
                        _isLogin ? 'Login' : 'Register',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Row(
                    children: [
                      Expanded(
                          child:
                              Divider(color: Color(0xFFeeeeee), thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                          child:
                              Divider(color: Color(0xFFeeeeee), thickness: 1)),
                    ],
                  ),

                  const SizedBox(height: 25),

                  GoogleAuthButton(
                    onPressed: _googleSignIn,
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? "Don't have an account? "
                            : "Already have an account? ",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleAuthMode,
                        child: Text(
                          _isLogin ? 'Register here' : 'Login here',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFff7e5f),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
