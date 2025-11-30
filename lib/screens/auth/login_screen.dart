import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animations.dart';
import '../home/main_navigation.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/widgets/styled_dialog.dart';
import 'join_family_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPhoneLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 100),
                offset: const Offset(0, -0.2),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.apartment_rounded,
                      size: 64,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  'Sign in to manage your society',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textLight,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildToggleButton('Phone', _isPhoneLogin),
                      ),
                      Expanded(
                        child: _buildToggleButton('Email', !_isPhoneLogin),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 500),
                child: _isPhoneLogin ? _buildPhoneLogin() : _buildEmailLogin(),
              ),
              const SizedBox(height: 24),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 600),
                child: ScaleOnTap(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isPhoneLogin ? 'Get OTP' : 'Login',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 700),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 800),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ScaleOnTap(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleFamilyLogin,
                      icon: Icon(Icons.people_outline, size: 24, color: AppTheme.primaryGreen),
                      label:  Text('Login as Family Member',
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.w600,
                        )
                      ),),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _isPhoneLogin = text == 'Phone'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppTheme.textDark : AppTheme.textLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneLogin() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Phone Number (e.g. +91...)',
        prefixIcon: const Icon(Icons.phone_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.primaryGreen),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildEmailLogin() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.primaryGreen),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.primaryGreen),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: Text(
              'Forgot Password?',
              style: TextStyle(color: AppTheme.primaryGreen),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      if (!_isPhoneLogin) {
        // Email Login
        if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
          await _authService.signInWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
          );
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigation()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter email and password')),
          );
        }
      } else {
        // Phone Login
        if (_phoneController.text.isNotEmpty) {
          String phoneNumber = _phoneController.text.trim();
          if (!phoneNumber.startsWith('+')) {
            phoneNumber = '+91$phoneNumber';
          }
          await _authService.verifyPhone(
            phoneNumber: phoneNumber,
            verificationCompleted: (PhoneAuthCredential credential) async {
              // Auto-retrieval or instant verification
              await _authService.signInWithCredential(credential);
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainNavigation()),
                );
              }
            },
            verificationFailed: (FirebaseAuthException e) {
              if (mounted) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Verification Failed: ${e.message}')),
                );
              }
            },
            codeSent: (String verificationId, int? resendToken) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _verificationId = verificationId;
                });
                _showOtpDialog();
              }
            },
            codeAutoRetrievalTimeout: (String verificationId) {
              _verificationId = verificationId;
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter phone number')),
          );
          setState(() => _isLoading = false);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: ${e.message}')),
        );
      }
      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: ${e.toString()}')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StyledDialog(
        title: 'Enter OTP',
        icon: Icons.lock_outline,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'We have sent a 6-digit verification code to your phone number.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
              maxLength: 6,
              decoration: InputDecoration(
                counterText: '',
                hintText: '------',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryGreen),
                ),
              ),
            ),
          ],
        ),
        actions: [
          StyledButton(
            text: 'Cancel',
            isPrimary: false,
            onPressed: () => Navigator.pop(dialogContext),
          ),
          StyledButton(
            text: 'Verify',
            onPressed: () async {
              if (_otpController.text.length == 6 && _verificationId != null) {
                Navigator.pop(dialogContext); // Close dialog
                setState(() => _isLoading = true);
                try {
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: _verificationId!,
                    smsCode: _otpController.text,
                  );
                  await _authService.signInWithCredential(credential);
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainNavigation()),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    _showErrorSnackBar('Invalid OTP: ${e.toString()}');
                    setState(() => _isLoading = false);
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleFamilyLogin() async {
    setState(() => _isLoading = true);
    
    try {
      final credential = await _authService.signInWithGoogle(role: 'family_member');
      
      if (credential.user != null && mounted) {
        // Check association status
        final association = await FirestoreService().checkFamilyAssociation(credential.user!.uid);
        
        if (mounted) {
          if (association == null) {
            // Not linked yet -> Go to Join Family Screen
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const JoinFamilyScreen()),
            );
          } else {
            final status = association['status'];
            if (status == 'approved') {
              // Approved -> Go to Home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigation()),
              );
            } else if (status == 'pending') {
              // Pending -> Go to Join Family Screen (it handles pending state display)
              // Or we could show a specific "Pending" screen. 
              // For now, reusing JoinFamilyScreen which we'll update to handle this state or just letting them see the status there.
              // Actually, let's just send them to JoinFamilyScreen, and I'll update that screen to check status on init too.
               Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const JoinFamilyScreen()),
              );
            } else {
               // Rejected or other
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Your request was rejected. Please contact the resident.')),
              );
               Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const JoinFamilyScreen()),
              );
            }
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Family Login Failed: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Family Login Failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}