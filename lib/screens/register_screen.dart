import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/input_field.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Debounce timer for email check
  Timer? _emailDebounce;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    _emailDebounce?.cancel();

    super.dispose();
  }

  // Check email with debounce
  void _checkEmailWithDebounce(String value, AuthProvider authProvider) {
    if (_emailDebounce?.isActive ?? false) {
      _emailDebounce!.cancel();
    }

    _emailDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (value.isNotEmpty &&
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        await authProvider.checkEmailAvailability(value);
      }
    });
  }

  void _submitForm() async {
    // Check if email is valid before submitting
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // First check email availability if it hasn't been checked yet
    if (!authProvider.isEmailChecked) {
      final email = _emailController.text.trim();
      if (email.isNotEmpty &&
          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        // Wait for email check to complete
        final isAvailable = await authProvider.checkEmailAvailability(email);
        if (!isAvailable) {
          // Don't proceed if email is taken
          return;
        }
      }
    } else if (!authProvider.isEmailAvailable) {
      // Don't proceed if we know the email is taken
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      // Hide keyboard
      FocusScope.of(context).unfocus();

      final success = await authProvider.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.status == AuthStatus.authenticating;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Error message
                  if (authProvider.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        authProvider.error!.replaceAll('Exception: ', ''),
                        style: TextStyle(color: colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ], // Username field
                  InputField(
                    controller: _usernameController,
                    label: 'Username',
                    hint: 'Enter your username',
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username is required';
                      }
                      if (value.length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                    focusNode: _usernameFocus,
                    textInputAction: TextInputAction.next,
                    nextFocus: _emailFocus,
                  ),
                  const SizedBox(height: 16), // Email field
                  InputField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    nextFocus: _passwordFocus,
                    label: 'Email',
                    hint: 'Enter your email address',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      if (authProvider.isEmailChecked &&
                          !authProvider.isEmailAvailable) {
                        return 'This email is already registered';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _checkEmailWithDebounce(value, authProvider);
                    },
                    suffixIcon:
                        authProvider.isCheckingEmail
                            ? Container(
                              width: 20,
                              height: 20,
                              padding: const EdgeInsets.all(8),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                            : authProvider.isEmailChecked
                            ? authProvider.isEmailAvailable
                                ? const Icon(Icons.check_circle_outline)
                                : const Icon(Icons.error_outline)
                            : null,
                    suffixIconColor:
                        authProvider.isEmailChecked
                            ? authProvider.isEmailAvailable
                                ? Colors.green
                                : Colors.red
                            : null,
                  ),

                  // Show message if email is not available
                  if (authProvider.isEmailChecked &&
                      !authProvider.isEmailAvailable) ...[
                    const SizedBox(height: 8),
                    Text(
                      'This email is already registered. Try logging in instead.',
                      style: TextStyle(color: colorScheme.error, fontSize: 12),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Password field
                  InputField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: !_isPasswordVisible,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    focusNode: _passwordFocus,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () {
                      _passwordFocus.unfocus();
                      FocusScope.of(
                        context,
                      ).requestFocus(_confirmPasswordFocus);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm password field
                  InputField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    obscureText: !_isConfirmPasswordVisible,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    focusNode: _confirmPasswordFocus,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _submitForm,
                  ),
                  const SizedBox(height: 32),

                  // Register button
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child:
                        isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text('Register'),
                  ),
                  const SizedBox(height: 24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Login'),
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
