import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class AdminWrapper extends StatefulWidget {
  final Widget child;
  final Widget? fallback;

  const AdminWrapper({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  State<AdminWrapper> createState() => _AdminWrapperState();
}

class _AdminWrapperState extends State<AdminWrapper> {
  final _firestoreService = FirestoreService();
  final _auth = FirebaseAuth.instance;
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    if (mounted) {
      final user = _auth.currentUser;
      if (user != null) {
        final isAdmin = await _firestoreService.isAdmin(user.uid);
        if (mounted) {
          setState(() {
            _isAdmin = isAdmin;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isAdmin = false;
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink(); // Or a loading spinner if appropriate
    }
    
    if (_isAdmin) {
      return widget.child;
    }
    
    return widget.fallback ?? const SizedBox.shrink();
  }
}
