import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/services/firestore_service.dart';
import '../home/main_navigation.dart';
import 'login_screen.dart';

class JoinFamilyScreen extends StatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  State<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends State<JoinFamilyScreen> {
  final _phoneController = TextEditingController();
  final _firestoreService = FirestoreService();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      final association = await _firestoreService.checkFamilyAssociation(user.uid);
      if (association != null && association['status'] == 'pending') {
        if (mounted) {
          setState(() {
            _statusMessage = 'Request sent! Waiting for approval from the resident.';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Family'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideTransition(
              delay: const Duration(milliseconds: 100),
              child: Text(
                'Find your Family',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeSlideTransition(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Enter the registered phone number of the primary resident (Family Owner) to request access.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeSlideTransition(
              delay: const Duration(milliseconds: 300),
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Resident Phone Number',
                  hintText: '+91...',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_statusMessage != null)
              FadeSlideTransition(
                delay: const Duration(milliseconds: 100),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            FadeSlideTransition(
              delay: const Duration(milliseconds: 400),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleJoinRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Send Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleJoinRequest() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showError('Please enter a phone number');
      return;
    }

    if (phone.length < 10) {
      _showError('Please enter a valid phone number (at least 10 digits)');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
         _showError('User not authenticated. Please login again.');
         return;
      }

      // 1. Find resident
      final residentDoc = await _firestoreService.findUserByPhone(phone);
      
      if (residentDoc != null) {
        // 2. Link user
        await _firestoreService.linkFamilyMember(user.uid, residentDoc.id);
        
        if (mounted) {
          setState(() {
            _statusMessage = 'Request sent! Waiting for approval from the resident.';
          });
        }
      } else {
        _showError('Resident not found. Please check the number and try again. Make sure the resident has registered with this number.');
      }
    } on FirebaseException catch (e) {
      _showError('Network error: ${e.message}. Please check your connection.');
    } catch (e) {
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
